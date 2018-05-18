`include "src/misc_defines.header.sv"
`include "src/instr_decoder_defines.header.sv"
`include "src/alu_defines.header.sv"
`include "src/register_file_defines.header.sv"


module Frost32Cpu(input logic clk,
	input PkgFrost32Cpu::PortIn_Frost32Cpu in,
	output PkgFrost32Cpu::PortOut_Frost32Cpu out);


	import PkgInstrDecoder::*;
	import PkgAlu::*;
	import PkgRegisterFile::*;
	import PkgFrost32Cpu::*;

	parameter __REG_LR_INDEX = 13;
	parameter __REG_SP_INDEX = 15;


	// Data output by or used by the Instruction Decode stage
	struct packed
	{
		// Counter for stalling while waiting for later stages to do their
		// thing.
		// 
		// Initial value is specific to each instruction that actually uses
		// this.
		// 
		// Applies mainly to control flow and memory access instructions,
		// but will eventually apply to multiplication too once I implement
		// that in a **generally** synthesizeable way (i.e., NOT with the
		// "*" operator of SystemVerilog).
		logic [`MSB_POS__FROST32_CPU_DECODE_STAGE_STALL_COUNTER:0]
			stall_counter;

		logic [`MSB_POS__FROST32_CPU_STATE:0] stall_state;

		logic [`MSB_POS__REG_FILE_DATA:0] 
			from_stage_execute_rfile_ra_data,
			from_stage_execute_rfile_rb_data,
			from_stage_execute_rfile_rc_data;
	} __stage_instr_decode_data;

	// Data input to the execute stage
	struct packed
	{
		logic [`MSB_POS__REG_FILE_DATA:0] rfile_ra_data, rfile_rb_data,
			rfile_rc_data;

		logic [`MSB_POS__FROST32_CPU_ADDR:0] ireta_data, idsta_data;

		//logic [`MSB_POS__FROST32_CPU_ADDR:0] next_pc;
	} __stage_execute_input_data;

	struct packed
	{
		// The next program counter for load and store instructions that
		// stall (read by the instruction decode stage for updating the
		// program counter in the case of these instructions)
		logic [`MSB_POS__FROST32_CPU_ADDR:0] next_pc_after_ldst;

		logic [`MSB_POS__REG_FILE_SEL:0] prev_written_reg_index;
	} __stage_execute_output_data;

	// Data input to the write back stage (output
	struct packed
	{
		// These are written by the execute stage
		logic [`MSB_POS__REG_FILE_DATA:0] rfile_ra_data, rfile_rb_data,
			rfile_rc_data;

		logic [`MSB_POS__ALU_INOUT:0] n_reg_data;

		logic do_write_lr;

	} __stage_write_back_input_data;

	struct packed
	{
		// The program counter (written to ONLY by the instruction decode
		// stage)
		logic [`MSB_POS__FROST32_CPU_ADDR:0] pc;

		// Interrupt return address (where to return to when an interrupt
		// happens (set to the program counter of the instruction in the
		// decode stage when )
		logic [`MSB_POS__FROST32_CPU_ADDR:0] ireta;

		// Interrupt destination address (the program counter gets set to
		// this when an interrutp happens)
		logic [`MSB_POS__FROST32_CPU_ADDR:0] idsta;

		// Interrupt enable
		logic ie;

		// Split up 32-bit by 32-bit multiplications into three 16-bit by
		// 16-bit multiplications (which I believe can be synthesized into
		// combinational logic) and some adds.
		logic [`MSB_POS__ALU_INOUT:0] mul_partial_result_x0_y0,
			mul_partial_result_x1_y0, mul_partial_result_x0_y1;



		`ifdef DEBUG
		// Debugging thing
		logic [31:0] cycles_counter;
		`endif		// DEBUG

	} __locals;

	logic [`MSB_POS__FROST32_CPU_ADDR:0] __following_pc;

	PkgFrost32Cpu::MultiStageData __multi_stage_data_0, 
		__multi_stage_data_1, __multi_stage_data_2;



	`ifdef DEBUG_REGISTER_FILE
	logic [`MSB_POS__REG_FILE_DATA:0] 
		__out_debug_reg_zero, __out_debug_reg_u0,
		__out_debug_reg_u1, __out_debug_reg_u2, 
		__out_debug_reg_u3, __out_debug_reg_u4,
		__out_debug_reg_u5, __out_debug_reg_u6, 
		__out_debug_reg_u7, __out_debug_reg_u8,
		__out_debug_reg_u9, __out_debug_reg_u10, 
		__out_debug_reg_temp, __out_debug_reg_lr,
		__out_debug_reg_fp, __out_debug_reg_sp;
	`endif


	// Module instantiations
	logic [`MSB_POS__INSTRUCTION:0] __in_instr_decoder;
	PkgInstrDecoder::PortOut_InstrDecoder __out_instr_decoder;
	InstrDecoder __inst_instr_decoder(.in(__in_instr_decoder), 
		.out(__out_instr_decoder));

	PkgRegisterFile::PortIn_RegFile __in_reg_file;
	PkgRegisterFile::PortOut_RegFile __out_reg_file;
	RegisterFile __inst_reg_file(.clk(clk), .in(__in_reg_file),
		.out(__out_reg_file)
		`ifdef DEBUG_REGISTER_FILE
		,
		.out_debug_zero(__out_debug_reg_zero), 
		.out_debug_u0(__out_debug_reg_u0),
		.out_debug_u1(__out_debug_reg_u1),
		.out_debug_u2(__out_debug_reg_u2),
		.out_debug_u3(__out_debug_reg_u3),
		.out_debug_u4(__out_debug_reg_u4),
		.out_debug_u5(__out_debug_reg_u5),
		.out_debug_u6(__out_debug_reg_u6),
		.out_debug_u7(__out_debug_reg_u7),
		.out_debug_u8(__out_debug_reg_u8),
		.out_debug_u9(__out_debug_reg_u9),
		.out_debug_u10(__out_debug_reg_u10),
		.out_debug_temp(__out_debug_reg_temp),
		.out_debug_lr(__out_debug_reg_lr),
		.out_debug_fp(__out_debug_reg_fp),
		.out_debug_sp(__out_debug_reg_sp)
		`endif		// DEBUG_REGISTER_FILE
		);

	`ifdef DEBUG_REGISTER_FILE
	always_comb
	begin
		out.debug_reg_zero = __out_debug_reg_zero;
		out.debug_reg_u0 = __out_debug_reg_u0;
		out.debug_reg_u1 = __out_debug_reg_u1;
		out.debug_reg_u2 = __out_debug_reg_u2;

		out.debug_reg_u3 = __out_debug_reg_u3;
		out.debug_reg_u4 = __out_debug_reg_u4;
		out.debug_reg_u5 = __out_debug_reg_u5;
		out.debug_reg_u6 = __out_debug_reg_u6;

		out.debug_reg_u7 = __out_debug_reg_u7;
		out.debug_reg_u8 = __out_debug_reg_u8;
		out.debug_reg_u9 = __out_debug_reg_u9;
		out.debug_reg_u10 = __out_debug_reg_u10;

		out.debug_reg_temp = __out_debug_reg_temp;
		out.debug_reg_lr = __out_debug_reg_lr;
		out.debug_reg_fp = __out_debug_reg_fp;
		out.debug_reg_sp = __out_debug_reg_sp;
	end
	`endif

	PkgAlu::PortIn_Alu __in_alu;
	PkgAlu::PortOut_Alu __out_alu;
	Alu __inst_alu(.in(__in_alu), .out(__out_alu));

	PkgAlu::PortOut_Compare __out_compare_ctrl_flow;
	Compare #(.DATA_WIDTH(`WIDTH__REG_FILE_DATA)) __inst_compare_ctrl_flow
		(.a(__stage_execute_input_data.rfile_ra_data),
		.b(__stage_execute_input_data.rfile_rb_data),
		.out(__out_compare_ctrl_flow));

	// Debug stuff
	`ifdef ICARUS
	always @ (posedge clk)
	begin
	if (!in.wait_for_mem)
	begin
		if (__locals.pc >= 32'h4000)
		//if (__locals.pc >= 32'h8000)
		//if (__locals.pc >= 32'hc000)
		//if (__locals.pc >= 32'h800000)
		begin
			$display("finishing");
			$finish;
		end
	end
	end
	`endif

	`ifdef DEBUG
	always @ (posedge clk)
	begin
		//__locals.cycles_counter <= __locals.cycles_counter + 1;

		//$display("Frost32Cpu __locals.cycles_counter:  %h", 
		//	__locals.cycles_counter);
	if (!in.wait_for_mem)
	begin
		$display("Frost32Cpu pc's:  %h %h %h", 
			__multi_stage_data_0.pc_val, 
			__multi_stage_data_1.pc_val,
			__multi_stage_data_2.pc_val);
		`ifdef DEBUG_REGISTER_FILE
		$display("Frost32Cpu special purpose regs:  %h %h %h",
			__locals.ireta, __locals.idsta, __locals.ie);

		$display("Frost32Cpu regs (0 to 3):  %h %h %h %h",
			__out_debug_reg_zero, __out_debug_reg_u0, 
			__out_debug_reg_u1, __out_debug_reg_u2);
		$display("Frost32Cpu regs (4 to 7):  %h %h %h %h",
			__out_debug_reg_u3, __out_debug_reg_u4, 
			__out_debug_reg_u5, __out_debug_reg_u6);
		$display("Frost32Cpu regs (8 to 11):  %h %h %h %h",
			__out_debug_reg_u7, __out_debug_reg_u8, 
			__out_debug_reg_u9, __out_debug_reg_u10);
		$display("Frost32Cpu regs (12 to 15):  %h %h %h %h",
			__out_debug_reg_temp, __out_debug_reg_lr, 
			__out_debug_reg_fp, __out_debug_reg_sp);
		`endif

		`ifdef DEBUG_INSTR_DECODER
		`include "src/debug_instr_decoder.header.sv"
		`endif		// DEBUG_INSTR_DECODER
		$display();
	end

		//$display();
	end
	`endif		// DEBUG

	// Assignments
	assign __following_pc = __multi_stage_data_1.pc_val + 4;
	assign __in_instr_decoder = in.data;
	assign __multi_stage_data_0.raw_instruction = __in_instr_decoder;
	assign __multi_stage_data_0.instr_ra_index
		= __out_instr_decoder.ra_index;
	assign __multi_stage_data_0.instr_rb_index
		= __out_instr_decoder.rb_index;
	assign __multi_stage_data_0.instr_rc_index
		= __out_instr_decoder.rc_index;
	assign __multi_stage_data_0.instr_imm_val
		= __out_instr_decoder.imm_val;
	assign __multi_stage_data_0.instr_group
		= __out_instr_decoder.group;
	assign __multi_stage_data_0.instr_opcode
		= __out_instr_decoder.opcode;
	assign __multi_stage_data_0.instr_ldst_type
		= __out_instr_decoder.ldst_type;
	assign __multi_stage_data_0.instr_causes_stall
		= __out_instr_decoder.causes_stall;
	assign __multi_stage_data_0.instr_condition_type
		= __out_instr_decoder.condition_type;
	assign __multi_stage_data_0.pc_val
		= __locals.pc;

	assign __multi_stage_data_0.nop = 0;


	// This is the operand forwarding.  It's so simple!
	// We only write to one register at a time, so we only need one
	// multiplexer per rfile_r..._data
	always_comb
	begin
		__stage_execute_input_data.rfile_ra_data
			= ((__stage_execute_output_data.prev_written_reg_index
			== __multi_stage_data_1.instr_ra_index)
			&& (__stage_execute_output_data.prev_written_reg_index != 0)) 
			? __stage_write_back_input_data.n_reg_data
			: __out_reg_file.read_data_ra;
		__stage_execute_input_data.rfile_rb_data
			= ((__stage_execute_output_data.prev_written_reg_index
			== __multi_stage_data_1.instr_rb_index)
			&& (__stage_execute_output_data.prev_written_reg_index != 0)) 
			? __stage_write_back_input_data.n_reg_data
			: __out_reg_file.read_data_rb;
		__stage_execute_input_data.rfile_rc_data
			= ((__stage_execute_output_data.prev_written_reg_index
			== __multi_stage_data_1.instr_rc_index)
			&& (__stage_execute_output_data.prev_written_reg_index != 0)) 
			? __stage_write_back_input_data.n_reg_data
			: __out_reg_file.read_data_rc;

		// Just some copies for use in the decode stage.
		__stage_instr_decode_data.from_stage_execute_rfile_ra_data
			= __stage_execute_input_data.rfile_ra_data;
		__stage_instr_decode_data.from_stage_execute_rfile_rb_data
			= __stage_execute_input_data.rfile_rb_data;
		__stage_instr_decode_data.from_stage_execute_rfile_rc_data
			= __stage_execute_input_data.rfile_rc_data;
	end


	// Tasks and functions
	function logic in_stall();
		return (__stage_instr_decode_data.stall_counter != 0);
	endfunction

	task prep_mem_read;
		input [`MSB_POS__FROST32_CPU_ADDR:0] addr;
		//input PkgFrost32Cpu::DataInoutAccessSize size;
		input [`MSB_POS__FROST32_CPU_DATA_ACCESS_SIZE:0] size;

		out.data <= 0;
		out.addr <= addr;
		out.data_inout_access_type <= PkgFrost32Cpu::DiatRead; 
		out.data_inout_access_size <= size;
		out.req_mem_access <= 1;
	endtask

	task prep_load_next_instruction;
		input [`MSB_POS__FROST32_CPU_ADDR:0] addr;

		// Every instruction is 4 bytes long (...for now)
		__locals.pc <= addr;

		prep_mem_read(addr, PkgFrost32Cpu::Dias32);
	endtask

	task prep_mem_write;
		input [`MSB_POS__FROST32_CPU_ADDR:0] addr;
		//input PkgFrost32Cpu::DataInoutAccessSize size;
		input [`MSB_POS__FROST32_CPU_DATA_ACCESS_SIZE:0] size;
		input [`MSB_POS__FROST32_CPU_DATA_INOUT:0] data;

		out.data <= data;
		out.addr <= addr;
		out.data_inout_access_type <= PkgFrost32Cpu::DiatWrite; 
		out.data_inout_access_size <= size;
		out.req_mem_access <= 1;
	endtask

	task stop_mem_access;
		out.req_mem_access <= 0;
	endtask

	task prep_reg_write;
		input [`MSB_POS__REG_FILE_SEL:0] s_sel;
		input [`MSB_POS__REG_FILE_DATA:0] s_data;

		__in_reg_file.write_sel <= s_sel;
		__in_reg_file.write_data <= s_data;
		__in_reg_file.write_en <= 1;
	endtask

	task prep_ra_write;
		input [`MSB_POS__REG_FILE_DATA:0] s_data;
		__in_reg_file.write_sel <= __multi_stage_data_2.instr_ra_index;
		__in_reg_file.write_data <= s_data;
		__in_reg_file.write_en <= 1;
	endtask



	task stop_reg_write;
		__in_reg_file.write_en <= 0;
	endtask

	task make_bubble;
		// Send a bubble through while we're stalled a (actually
		// performs "add zero, zero, zero", but that does nothing
		// interesting anyway... besides maybe power consumption)
		__in_reg_file.read_sel_ra <= 0;
		__in_reg_file.read_sel_rb <= 0;
		__in_reg_file.read_sel_rc <= 0;
		//__multi_stage_data_1 <= 0;
		__multi_stage_data_1.instr_ra_index <= 0;
		__multi_stage_data_1.instr_rb_index <= 0;
		__multi_stage_data_1.instr_rc_index <= 0;
		__multi_stage_data_1.instr_group <= 0;
		__multi_stage_data_1.instr_opcode <= 0;
		__multi_stage_data_1.instr_ldst_type <= 0;
		__multi_stage_data_1.instr_causes_stall <= 0;
		__multi_stage_data_1.instr_condition_type <= 0;
		//__multi_stage_data_1.nop <= 1'b1;
	endtask

	task handle_ctrl_flow_in_decode_stage;
		input condition;

		if (condition)
		begin
			//$display("handle_ctrl_flow_in_decode_stage:  %s",
			//	"taking branch");
			__locals.pc <= __out_alu.data;
			prep_mem_read(__out_alu.data, PkgFrost32Cpu::Dias32);
		end

		else // if (!condition)
		begin
			//$display("handle_ctrl_flow_in_decode_stage:  %s",
			//	"NOT taking branch");
			__locals.pc <= __following_pc;
			prep_mem_read(__following_pc, PkgFrost32Cpu::Dias32);
		end
	endtask

	task handle_call_in_execute_stage;
		input condition;

		if (condition)
		begin
			// We want to store the value of __following_pc in "lr".
			__stage_write_back_input_data.n_reg_data <= __following_pc;
			__stage_write_back_input_data.do_write_lr <= 1;
		end

		else
		begin
			// We want to leave "lr" alone.
			__stage_write_back_input_data.do_write_lr <= 0;
		end
	endtask




	initial
	begin
		// Put NOPs into the stages after decode
		__multi_stage_data_1 = 0;
		__multi_stage_data_2 = 0;

		//{__stage_instr_decode_data, __stage_execute_input_data} = 0;
		__stage_instr_decode_data = 0;
		__stage_execute_output_data = 0;
		__stage_write_back_input_data = 0;
		//__stage_instr_decode_data.state = PkgFrost32Cpu::StInit;

		//__locals.pc = 0;
		//__locals.cycles_counter = 0;
		__locals = 0;

		// Prepare a read from memory
		out.data = 0;
		out.addr = __locals.pc;
		out.data_inout_access_type = PkgFrost32Cpu::DiatRead; 
		out.data_inout_access_size = PkgFrost32Cpu::Dias32;
		out.req_mem_access = 1;

		// Cause the decode stage to be stalled with
		// __stage_instr_decode_data.stall_counter == 1, so that it will
		// perform a prep_mem_read() and load the first instruction (from
		// address 0)
		__stage_instr_decode_data.stall_counter = 1;
		__stage_instr_decode_data.stall_state = PkgFrost32Cpu::StInit;
	end

	// Stage 0:  Instruction Decode
	always @ (posedge clk)
	begin
	if (!in.wait_for_mem)
	begin
		//$display("Decode:  next_pc:  %h",
		//	__stage_execute_output_data.next_pc);
		//if (__stage_instr_decode_data.stall_counter > 0)
		if (in_stall())
		begin
			// Decrement the stall counter
			__stage_instr_decode_data.stall_counter
				<= __stage_instr_decode_data.stall_counter - 1;
			//$display("in_stall():  %d",
			//	__stage_instr_decode_data.stall_counter);

			make_bubble();


			// The last stall_counter value before it hits zero (this is
			// where the PC should be changed).
			if (__stage_instr_decode_data.stall_counter == 1)
			begin
				__stage_instr_decode_data.stall_state 
					<= PkgFrost32Cpu::StInit;


				if (__stage_instr_decode_data.stall_state
					== PkgFrost32Cpu::StCpyRaToInterruptsRelatedAddr)
				begin
					// Need to use
					// __stage_execute_input_data.rfile_ra_data
					// for operand forwarding purposes

					// "cpy ireta, rA"
					if (__multi_stage_data_1.instr_opcode
						== PkgInstrDecoder::Cpy_OneIretaOneReg)
					begin
						__locals.ireta <= __stage_instr_decode_data
							.from_stage_execute_rfile_ra_data;
					end

					// "cpy idsta, rA"
					else
					begin
						__locals.idsta <= __stage_instr_decode_data
							.from_stage_execute_rfile_ra_data;
					end

					prep_load_next_instruction(__following_pc);
				end

				else if (__stage_instr_decode_data.stall_state
					== PkgFrost32Cpu::StMemAccess)
				begin
					// Prepare a load from memory of the next
					// instruction.  "prep_mem_read()" and
					// "prep_mem_write()" are **ONLY** performed in the
					// decode stage.
					prep_load_next_instruction
						(__stage_execute_output_data
						.next_pc_after_ldst);
				end


				// Resolve conditional execution in this stage
				else if (__stage_instr_decode_data.stall_state
					== PkgFrost32Cpu::StCtrlFlow)
				begin
					case (__multi_stage_data_1.instr_condition_type)
						PkgInstrDecoder::CtNe:
						begin
							handle_ctrl_flow_in_decode_stage
								(__stage_instr_decode_data
								.from_stage_execute_rfile_ra_data
								!= __stage_instr_decode_data
								.from_stage_execute_rfile_rb_data);
						end

						PkgInstrDecoder::CtEq:
						begin
							handle_ctrl_flow_in_decode_stage
								(__stage_instr_decode_data
								.from_stage_execute_rfile_ra_data
								== __stage_instr_decode_data
								.from_stage_execute_rfile_rb_data);
						end

						PkgInstrDecoder::CtLtu:
						begin
							handle_ctrl_flow_in_decode_stage
								(__out_compare_ctrl_flow.ltu);
						end
						PkgInstrDecoder::CtGeu:
						begin
							//handle_ctrl_flow_in_decode_stage
							//	(!__out_compare_ctrl_flow.ltu);
						end

						PkgInstrDecoder::CtLeu:
						begin
							handle_ctrl_flow_in_decode_stage
								(!__out_compare_ctrl_flow.gtu);
						end
						PkgInstrDecoder::CtGtu:
						begin
							handle_ctrl_flow_in_decode_stage
								(__out_compare_ctrl_flow.gtu);
						end

						PkgInstrDecoder::CtLts:
						begin
					//$display("Decode stage CtLts:  %h %h %h %h\t\t%h %h",
					//	__out_compare_ctrl_flow.ltu,
					//	__out_compare_ctrl_flow.lts,
					//	__out_compare_ctrl_flow.gtu,
					//	__out_compare_ctrl_flow.gts,
					//	__stage_execute_input_data.rfile_ra_data,
					//	__stage_execute_input_data.rfile_rb_data);
							handle_ctrl_flow_in_decode_stage
								(__out_compare_ctrl_flow.lts);
						end
						PkgInstrDecoder::CtGes:
						begin
							handle_ctrl_flow_in_decode_stage
								(!__out_compare_ctrl_flow.lts);
						end

						PkgInstrDecoder::CtLes:
						begin
							//$display("Decode stage les:  %h %h\t\t%h %h",
							//	__out_compare_ctrl_flow.ltu,
							//	__out_compare_ctrl_flow.lts,
							//	__out_compare_ctrl_flow.gtu,
							//	__out_compare_ctrl_flow.gts);
				//$display("Decode stage CtLes:  %h %h %h %h\t\t%h %h\t\t%h",
				//		__out_compare_ctrl_flow.ltu,
				//		__out_compare_ctrl_flow.lts,
				//		__out_compare_ctrl_flow.gtu,
				//		__out_compare_ctrl_flow.gts,
				//		__stage_execute_input_data.rfile_ra_data,
				//		__stage_execute_input_data.rfile_rb_data);
							handle_ctrl_flow_in_decode_stage
								(!__out_compare_ctrl_flow.gts);
						end
						PkgInstrDecoder::CtGts:
						begin
							handle_ctrl_flow_in_decode_stage
								(__out_compare_ctrl_flow.gts);
						end

						default:
						begin
							// Eek!
							__locals.pc <= __following_pc;
							prep_mem_read(__following_pc,
								PkgFrost32Cpu::Dias32);
						end
					endcase
				end

				else if (__stage_instr_decode_data.stall_state
					== PkgFrost32Cpu::StInit)
				begin
					
				end

				else
				begin
					$display("stall_counter == 1:  Eek!");
				end
			end

			else // if (we're in the middle of executing a multi-cycle
				// instruction (and not about to finish it))
				// 
				// So far, this only applies to loads and stores.
				// 
				// Note that only **this** always block (the decode stage's
				// one) is permitted to write to the output port for memory
				// access.  This follows from the principle of owner
				// computes, and is also **required** to be followed if the
				// code is to be synthesizeable.
			begin
				// Memory access:  We've done the address computation in
				// the execute stage (within the "always_comb" block
				// located after the "always" block that performs the
				// write back stage)
				if ((__stage_instr_decode_data.stall_state
					== PkgFrost32Cpu::StMemAccess)
					&& (__stage_instr_decode_data.stall_counter == 2))
				begin
					// We're in the first cycle after initiating a
					// multi-cycle load/store instruction.
					// 
					// The computed address is in __out_alu.data, and (for
					// stores) the value to store is in
					// __stage_execute_input_data.rfile_ra_data.
					case (__multi_stage_data_1.instr_ldst_type)
						PkgInstrDecoder::Ld32:
						begin
							// Write-back handles the store to the register
							prep_mem_read(__out_alu.data,
								PkgFrost32Cpu::Dias32);
						end
						PkgInstrDecoder::LdU16:
						begin
							// Write-back handles the store to the register
							prep_mem_read(__out_alu.data,
								PkgFrost32Cpu::Dias16);
						end
						PkgInstrDecoder::LdS16:
						begin
							// Write-back handles the store to the register
							prep_mem_read(__out_alu.data,
								PkgFrost32Cpu::Dias16);
						end
						PkgInstrDecoder::LdU8:
						begin
							// Write-back handles the store to the register
							prep_mem_read(__out_alu.data,
								PkgFrost32Cpu::Dias8);
						end
						PkgInstrDecoder::LdS8:
						begin
							// Write-back handles the store to the register
							prep_mem_read(__out_alu.data,
								PkgFrost32Cpu::Dias8);
						end
						PkgInstrDecoder::St32:
						begin
							prep_mem_write(__out_alu.data,
								PkgFrost32Cpu::Dias32,
								__stage_execute_input_data.rfile_ra_data);
						end
						PkgInstrDecoder::St16:
						begin
							prep_mem_write(__out_alu.data,
								PkgFrost32Cpu::Dias16,
								__stage_execute_input_data.rfile_ra_data);
						end
						PkgInstrDecoder::St8:
						begin
							prep_mem_write(__out_alu.data,
								PkgFrost32Cpu::Dias8,
								__stage_execute_input_data.rfile_ra_data);
						end
					endcase
				end
				//else if ((__stage_instr_decode_data.stall_state
				//	== PkgFrost32Cpu::StMemAccess)
				//	&& (__stage_instr_decode_data.stall_counter == 1))
				//begin
				//	stop_mem_access();
				//end
			end
		end

		//else // if (__stage_instr_decode_data.stall_counter == 0)
		else // if (!in_stall())
		begin
			if (!(in.interrupt && __locals.ie))
			begin
				// Update the program counter via owner computes (only this
				// always block can perform an actual change to the program
				// counter).
				if (!__multi_stage_data_0.instr_causes_stall)
				begin
					if ((__multi_stage_data_0.instr_group == 6)
						&& (__multi_stage_data_0.instr_opcode
						== PkgInstrDecoder::Reti_NoArgs))
					begin
						//__stage_instr_decode_data.stall_state
						//	<= PkgFrost32Cpu::StReti;
						// "reti" gets the new program counter from
						// __locals.ireta, and also enables interrupts.

						$display("reti:  %h %h", __locals.ie, 
							__locals.ireta);
						// This is a valid instruction even when *not* in
						// an interrupt (mostly because of how simple it
						// is)
						__locals.ie <= 1;
						prep_load_next_instruction(__locals.ireta);
					end

					else
					begin
						// Every instruction is 4 bytes long (...for now)
						prep_load_next_instruction(__locals.pc + 4);
					end
				end

				else // if (__multi_stage_data_0.instr_causes_stall)
				begin
					// Conditional branch or conditional jump or
					// conditional call
					if ((__multi_stage_data_0.instr_group == 2)
						|| (__multi_stage_data_0.instr_group == 3)
						|| (__multi_stage_data_0.instr_group == 4))
					begin
						__stage_instr_decode_data.stall_state
							<= PkgFrost32Cpu::StCtrlFlow;

						__stage_instr_decode_data.stall_counter <= 1;
					end

					// All loads and stores are in group 5, and they take
					// three cycles each to complete (find out that there's
					// a memory access instruction, prep mem access for
					// instruction itself, prep mem read of next
					// instruction)
					else if (__multi_stage_data_0.instr_group == 5)
					begin
						__stage_instr_decode_data.stall_state 
							<= PkgFrost32Cpu::StMemAccess;
						__stage_instr_decode_data.stall_counter <= 2;
					end

					// "cpy ireta, rA"
					// "cpy idsta, rA"
					else if (__multi_stage_data_0.instr_group == 6)
					begin
						//$display("instr_causes_stall:  instr group 6");
						__stage_instr_decode_data.stall_counter <= 1;

						__stage_instr_decode_data.stall_state
							<= PkgFrost32Cpu
							::StCpyRaToInterruptsRelatedAddr;
					end

					// Eek!
					else
					begin
						$display("instr_causes_stall:  Eek!");
						__stage_instr_decode_data.stall_state 
							<= PkgFrost32Cpu::StInit;
						__stage_instr_decode_data.stall_counter <= 3;
					end
				end

				// Handle what the execute stage sees next
				if ((__multi_stage_data_0.instr_group == 6)
					&& ((__multi_stage_data_0.instr_opcode 
					== PkgInstrDecoder::Ei_NoArgs)
					|| (__multi_stage_data_0.instr_opcode
					== PkgInstrDecoder::Di_NoArgs)
					|| (__multi_stage_data_0.instr_opcode
					== PkgInstrDecoder::Reti_NoArgs)))
				begin
					if (__multi_stage_data_0.instr_opcode
						!= PkgInstrDecoder::Reti_NoArgs)
					begin
						__locals.ie <= (__multi_stage_data_0.instr_opcode
							== PkgInstrDecoder::Ei_NoArgs);
					end

					// Just send a bubble through to the later stages since
					// they don't really need to know anything about "ei",
					// "di", and "reti"
					make_bubble();
				end

				// The instruction is **NOT** "ei", "di", or "reti", which
				// are all single cycle and completely resolved in the
				// decode stage.
				else
				begin
					// We only send a non-bubble instruction to
					// __multi_stage_data_1 when there's a new instruction
					// that is NOT "ei" or "di"
					__multi_stage_data_1 <= __multi_stage_data_0;

					__stage_execute_input_data.ireta_data 
						<= __locals.ireta;
					__stage_execute_input_data.idsta_data 
						<= __locals.idsta;

					// Use all three register file read ports.
					// Do this whenever we're not in a stall.
					__in_reg_file.read_sel_ra 
						<= __multi_stage_data_0.instr_ra_index;
					__in_reg_file.read_sel_rb 
						<= __multi_stage_data_0.instr_rb_index;
					__in_reg_file.read_sel_rc 
						<= __multi_stage_data_0.instr_rc_index;
				end
			end

			else
			begin
				$display("Interrupt happened:  %h %h %h",
					__locals.idsta,
					__locals.pc,
					__locals.ireta);
				//__locals.pc <= __locals.idsta;
				__locals.ireta <= __locals.pc;
				__locals.ie <= 0;

				prep_load_next_instruction(__locals.idsta);
			end
		end
	end

	else // if (in.wait_for_mem)
	begin
		stop_mem_access();
	end
	end

	// Stage 1:  Execute 
	always @ (posedge clk)
	begin
	if (!in.wait_for_mem)
	begin
	//if (!__multi_stage_data_1.nop)
	//begin
		//$display("Execute stage (part 1):  %h %h\t\t%h %h",
		//	__multi_stage_data_1.pc_val,
		//	__multi_stage_data_1.raw_instruction,
		//	__multi_stage_data_1.instr_group,
		//	__multi_stage_data_1.instr_opcode);

		// For load and store instructions
		__stage_execute_output_data.next_pc_after_ldst <= __following_pc;

		__multi_stage_data_2 <= __multi_stage_data_1;

		//$display("Execute stage:  %h %h %h",
		//	__stage_execute_input_data.rfile_ra_data,
		//	__stage_execute_input_data.rfile_rb_data,
		//	__stage_execute_input_data.rfile_rc_data);

		__stage_write_back_input_data.rfile_ra_data 
			<= __stage_execute_input_data.rfile_ra_data;
		__stage_write_back_input_data.rfile_rb_data 
			<= __stage_execute_input_data.rfile_rb_data;
		__stage_write_back_input_data.rfile_rc_data 
			<= __stage_execute_input_data.rfile_rc_data;

		//__stage_write_back_input_data.alu_out <= __out_alu.data;


		case (__multi_stage_data_1.instr_group)
			// Group 0:  Three register ALU operations
			4'd0:
			begin
				// For operand forwarding
				__stage_execute_output_data.prev_written_reg_index
					<= __multi_stage_data_1.instr_ra_index;

				if (__multi_stage_data_1.instr_opcode 
					!= PkgInstrDecoder::Mul_ThreeRegs)
				begin
					__stage_write_back_input_data.n_reg_data 
						<= __out_alu.data;

					////$display("0:  Changing next_pc to %h", __following_pc);

					//// The reason this is commented out is so that bubbles
					//// in the form of "add zero, zero, zero" can be used.
					//// Don't uncomment this!  Also, this assumes that no
					//// control flow is performed by group 0 instructions,
					//// which is true as of writing this comment.
					////__stage_execute_output_data.next_pc <= __following_pc;
				end

				else
				begin
					// Multiplication (performed with three 16-bit
					// multiplies and some adds)
					__stage_write_back_input_data.n_reg_data
						<= ({(__locals.mul_partial_result_x1_y0
						+ __locals.mul_partial_result_x0_y1),
						16'h0000})
						+ __locals.mul_partial_result_x0_y0;
				end
			end

			4'd1:
			begin
				if (__multi_stage_data_1.instr_opcode
					!= PkgInstrDecoder::Cpyhi_OneRegOneImm)
				begin
					// For operand forwarding
					__stage_execute_output_data.prev_written_reg_index
						<= __multi_stage_data_1.instr_ra_index;


					if (__multi_stage_data_1.instr_opcode
						!= PkgInstrDecoder::Muli_TwoRegsOneImm)
					begin
						__stage_write_back_input_data.n_reg_data 
							<= __out_alu.data;
					end

					else
					begin
						__stage_write_back_input_data.n_reg_data
							<= ({(__locals.mul_partial_result_x1_y0
							+ __locals.mul_partial_result_x0_y1),
							16'h0000})
							+ __locals.mul_partial_result_x0_y0;
					end
				end

				else // if (__multi_stage_data_1.instr_opcode
					// == PkgInstrDecoder::Cpyhi_OneRegOneImm)
				begin
					// cpyhi only changes the high 15 bits of rA
					__stage_write_back_input_data.n_reg_data
						<= {__multi_stage_data_1.instr_imm_val,
						__stage_execute_input_data.rfile_ra_data[15:0]};

					// For operand forwarding
					__stage_execute_output_data.prev_written_reg_index
						<= __multi_stage_data_1.instr_ra_index;

				end

				//else if (__multi_stage_data_1.instr_opcode
				//	== PkgInstrDecoder::Bne_TwoRegsOneSimm)
				//begin
				//	// Prevent operand forwarding
				//	__stage_execute_output_data.prev_written_reg_index
				//		<= 0;
				//end

				//else if (__multi_stage_data_1.instr_opcode
				//	== PkgInstrDecoder::Beq_TwoRegsOneSimm)
				//begin
				//	// Prevent operand forwarding
				//	__stage_execute_output_data.prev_written_reg_index
				//		<= 0;
				//end
			end

			// Group 2:  Branches
			4'd2:
			begin
				// Prevent operand forwarding
				__stage_execute_output_data.prev_written_reg_index
					<= 0;
			end
			// Group 3:  Jumps 
			4'd3:
			begin
				// Prevent operand forwarding
				__stage_execute_output_data.prev_written_reg_index
					<= 0;
			end

			// Group 4:  Calls
			4'd4:
			begin
				// Prevent operand forwarding
				__stage_execute_output_data.prev_written_reg_index <= 0;

				case (__multi_stage_data_1.instr_condition_type)
					PkgInstrDecoder::CtNe:
					begin
						handle_call_in_execute_stage
							(__stage_execute_input_data.rfile_ra_data
							!= __stage_execute_input_data.rfile_rb_data);
					end

					PkgInstrDecoder::CtEq:
					begin
						handle_call_in_execute_stage
							(__stage_execute_input_data.rfile_ra_data
							== __stage_execute_input_data.rfile_rb_data);
					end

					PkgInstrDecoder::CtLtu:
					begin
						handle_call_in_execute_stage
							(__out_compare_ctrl_flow.ltu);
					end
					PkgInstrDecoder::CtGeu:
					begin
						handle_call_in_execute_stage
							(!__out_compare_ctrl_flow.ltu);
					end

					PkgInstrDecoder::CtLeu:
					begin
						handle_call_in_execute_stage
							(!__out_compare_ctrl_flow.gtu);
					end
					PkgInstrDecoder::CtGtu:
					begin
						handle_call_in_execute_stage
							(__out_compare_ctrl_flow.gtu);
					end

					PkgInstrDecoder::CtLts:
					begin
						handle_call_in_execute_stage
							(__out_compare_ctrl_flow.lts);
					end
					PkgInstrDecoder::CtGes:
					begin
						handle_call_in_execute_stage
							(!__out_compare_ctrl_flow.lts);
					end

					PkgInstrDecoder::CtLes:
					begin
						handle_call_in_execute_stage
							(!__out_compare_ctrl_flow.gts);
					end
					PkgInstrDecoder::CtGts:
					begin
						handle_call_in_execute_stage
							(__out_compare_ctrl_flow.gts);
					end

					default:
					begin
						// Prevent "lr" write back for bad opcodes
						__stage_write_back_input_data.do_write_lr <= 0;
					end
				endcase


			end


			// Group 5:  Loads and stores
			4'd5:
			begin
				////$display("5:  Changing next_pc to %h", __following_pc);
				//__stage_execute_output_data.next_pc <= __following_pc;

				// Prevent operand forwarding (none needed for loads since
				// they stall until the new value has **really** been
				// written, and of course stores don't need operand
				// forwarding either)
				__stage_execute_output_data.prev_written_reg_index <= 0;
			end

			// Group 6:  Interrupts stuff
			4'd6:
			begin

				case (__multi_stage_data_1.instr_opcode)
					// For group 6 instructions, we only perform write back
					// for 
					// "cpy rA, ireta"
					// and
					// "cpy rA, idsta"
					PkgInstrDecoder::Cpy_OneRegOneIreta:
					begin
						__stage_write_back_input_data.n_reg_data 
							<= __stage_execute_input_data.ireta_data;

						// For operand forwarding
						__stage_execute_output_data.prev_written_reg_index
							<= __multi_stage_data_1.instr_ra_index;
					end
					PkgInstrDecoder::Cpy_OneRegOneIdsta:
					begin
						__stage_write_back_input_data.n_reg_data 
							<= __stage_execute_input_data.idsta_data;

						// For operand forwarding
						__stage_execute_output_data.prev_written_reg_index
							<= __multi_stage_data_1.instr_ra_index;
					end

					default:
					begin
						// Prevent operand forwarding
						__stage_execute_output_data.prev_written_reg_index
							<= 0;
					end
				endcase
			end
		endcase
	//end
	end
	end

	// Stage 2:  Write Back
	always @ (posedge clk)
	begin
	if (!in.wait_for_mem)
	begin
	//if (!__multi_stage_data_2.nop)
	//begin
		case (__multi_stage_data_2.instr_group)
			// Group 0:  Three register ALU operations
			4'd0:
			begin
				//if (__multi_stage_data_2.instr_opcode
				//	< PkgInstrDecoder::Bad0_Iog0)
				if ((__multi_stage_data_2.instr_opcode
					!= PkgInstrDecoder::Bad0_Iog0)
					&& (__multi_stage_data_2.instr_opcode
					!= PkgInstrDecoder::Bad1_Iog0))
				begin
					prep_ra_write
						(__stage_write_back_input_data.n_reg_data);
				end

				else
				begin
					// Treat this instruction as a NOP (no write-back)
				end
			end

			// Group 1 Instructions:  Immediates
			// All group 1 opcodes are valid instructions, and they all
			// require a write back.
			4'd1:
			begin
				prep_ra_write(__stage_write_back_input_data.n_reg_data);
			end

			// Group 2:  Branches
			// We don't need to do any actual write back for this group.
			4'd2:
			begin
				//case (__multi_stage_data_2.instr_opcode)
				//	PkgInstrDecoder::Callne_ThreeRegs:
				//	begin
				//		// Make sure to write back to lr!
				//		//$display("Write back callne:  %h",
				//		//	__stage_write_back_input_data.n_reg_data);
				//		prep_reg_write(__REG_LR_INDEX,
				//			__stage_write_back_input_data.n_reg_data);
				//	end
				//	PkgInstrDecoder::Calleq_ThreeRegs:
				//	begin
				//		// Make sure to write back to lr!
				//		//$display("Write back calleq:  %h",
				//		//	__stage_write_back_input_data.n_reg_data);
				//		prep_reg_write(__REG_LR_INDEX,
				//			__stage_write_back_input_data.n_reg_data);
				//	end

				//	default:
				//	begin
				//		// Don't need to write back anything for other
				//		// instructions
				//	end
				//endcase
			end

			// Group 3:  Jumps
			// We don't need to do any actual write back for this group.
			4'd3:
			begin
				
			end

			// Group 4:  Calls
			// We need to write back lr for these instructions
			4'd4:
			begin
				if (__stage_write_back_input_data.do_write_lr)
				begin
					// Make sure to write back to lr!
					prep_reg_write(__REG_LR_INDEX,
						__stage_write_back_input_data.n_reg_data);
				end
			end


			// Group 5:  Loads and Stores
			4'd5:
			begin
				case (__multi_stage_data_2.instr_opcode)
					PkgInstrDecoder::Ldr_ThreeRegsLdst:
					begin
						prep_ra_write(in.data);
					end

					PkgInstrDecoder::Ldh_ThreeRegsLdst:
					begin
						// Zero extend
						prep_ra_write({16'h0000, in.data[15:0]});
					end

					PkgInstrDecoder::Ldsh_ThreeRegsLdst:
					begin
						// Sign extend
						//prep_ra_write(in.data[15]
						//	? {16'hffff, in.data[15:0]}
						//	: {16'h0000, in.data[15:0]});
						prep_ra_write({{16{in.data[15]}}, 
							in.data[15:0]});
					end

					PkgInstrDecoder::Ldb_ThreeRegsLdst:
					begin
						// Zero extend
						prep_ra_write({24'h000000, in.data[7:0]});
					end

					PkgInstrDecoder::Ldsb_ThreeRegsLdst:
					begin
						// Sign extend
						//prep_ra_write(in.data[7]
						//	? {24'hffffff, in.data[7:0]}
						//	: {24'h000000, in.data[7:0]});
						prep_ra_write({{24{in.data[7]}}, in.data[7:0]});
					end

					PkgInstrDecoder::Ldri_TwoRegsOneSimm12Ldst:
					begin
						prep_ra_write(in.data);
					end

					PkgInstrDecoder::Ldhi_TwoRegsOneSimm12Ldst:
					begin
						// Zero extend
						prep_ra_write({16'h0000, in.data[15:0]});
					end

					PkgInstrDecoder::Ldshi_TwoRegsOneSimm12Ldst:
					begin
						// Sign extend
						//prep_ra_write(in.data[15]
						//	? {16'hffff, in.data[15:0]}
						//	: {16'h0000, in.data[15:0]});
						prep_ra_write({{16{in.data[15]}}, 
							in.data[15:0]});
					end

					PkgInstrDecoder::Ldbi_TwoRegsOneSimm12Ldst:
					begin
						// Zero extend
						prep_ra_write({24'h000000, in.data[7:0]});
					end

					PkgInstrDecoder::Ldsbi_TwoRegsOneSimm12Ldst:
					begin
						// Sign extend
						//prep_ra_write(in.data[7]
						//	? {24'hffffff, in.data[7:0]}
						//	: {24'h000000, in.data[7:0]});
						prep_ra_write({{24{in.data[7]}}, in.data[7:0]});
					end

					default:
					begin
						
					end
				endcase
			end

			// Group 6:  Interrupts stuff
			4'd6:
			begin
				case (__multi_stage_data_2.instr_opcode)
					//PkgInstrDecoder::Ei_NoArgs:
					//begin
					//	
					//end
					//PkgInstrDecoder::Di_NoArgs:
					//begin
					//	
					//end
					//PkgInstrDecoder::Cpy_OneIretaOneReg:
					//begin
					//	
					//end
					PkgInstrDecoder::Cpy_OneRegOneIreta:
					begin
						prep_ra_write
							(__stage_write_back_input_data.n_reg_data);
					end

					//PkgInstrDecoder::Cpy_OneIdstaOneReg:
					//begin
					//	
					//end
					PkgInstrDecoder::Cpy_OneRegOneIdsta:
					begin
						prep_ra_write
							(__stage_write_back_input_data.n_reg_data);
					end
					//PkgInstrDecoder::Reti_NoArgs:
					//begin
					//	
					//end
					default:
					begin
						
					end
				endcase
			end

			default:
			begin
				// Eek!
			end
		endcase
	//end
	end
	end

	// ALU input stuff
	always_comb
	begin
	if (!in.wait_for_mem)
	begin
		case (__multi_stage_data_1.instr_group)
			// Group 0:  Three-register ALU operations
			0:
			begin
				// It's okay if the ALU performs a bogus operation, so
				// let's decode the ALU opcode directly from the
				// instruction for group 0 instructions.
				__in_alu.a = __stage_execute_input_data.rfile_rb_data;
				__in_alu.b = __stage_execute_input_data.rfile_rc_data;
				__in_alu.oper = __multi_stage_data_1.instr_opcode;
				//$display("always_comb thing:  %h %h %h",
				//	__in_alu.a, __in_alu.b, __in_alu.oper);

				// We just always perform the temporary multiplications
				__locals.mul_partial_result_x0_y0
					= __stage_execute_input_data.rfile_rb_data[15:0]
					* __stage_execute_input_data.rfile_rc_data[15:0];
				__locals.mul_partial_result_x0_y1 
					= __stage_execute_input_data.rfile_rb_data[15:0]
					* __stage_execute_input_data.rfile_rc_data[31:16];
				__locals.mul_partial_result_x1_y0
					= __stage_execute_input_data.rfile_rb_data[31:16]
					* __stage_execute_input_data.rfile_rc_data[15:0];
			end

			// Group 1:  Immediates
			1:
			begin
				//__in_alu.oper = __multi_stage_data_1.instr_opcode;

				// We just always perform the temporary multiplications
				__locals.mul_partial_result_x0_y0
					= __stage_execute_input_data.rfile_rb_data[15:0]
					* __multi_stage_data_1.instr_imm_val;
				__locals.mul_partial_result_x0_y1 
					= __stage_execute_input_data.rfile_rb_data[15:0]
					* 16'h0000;
				__locals.mul_partial_result_x1_y0
					= __stage_execute_input_data.rfile_rb_data[31:16]
					* __multi_stage_data_1.instr_imm_val;

				case (__multi_stage_data_1.instr_opcode)
					PkgInstrDecoder::Sltsi_TwoRegsOneSimm:
					begin
						__in_alu.a
							= __stage_execute_input_data.rfile_rb_data;

						// Sign extend the immediate value
						__in_alu.b 
							= {{16{__multi_stage_data_1.instr_imm_val
							[15]}}, 
							__multi_stage_data_1.instr_imm_val};

						__in_alu.oper = PkgAlu::Slts;
					end
					PkgInstrDecoder::Sgtsi_TwoRegsOneSimm:
					begin
						__in_alu.a
							= __stage_execute_input_data.rfile_rb_data;

						// Sign extend the immediate value
						__in_alu.b 
							= {{16{__multi_stage_data_1.instr_imm_val
							[15]}}, 
							__multi_stage_data_1.instr_imm_val};

						__in_alu.oper = PkgAlu::Slts;
					end

					PkgInstrDecoder::Addsi_OneRegOnePcOneSimm:
					begin
						__in_alu.a = __multi_stage_data_1.pc_val;

						// Sign extend the immediate value
						__in_alu.b 
							= {{16{__multi_stage_data_1.instr_imm_val
							[15]}}, 
							__multi_stage_data_1.instr_imm_val};

						__in_alu.oper = PkgAlu::Add;
					end


					// Let's decode the ALU opcode directly from the
					// instruction for the remainder of the
					// instructions from group 1
					default:
					begin
						__in_alu.a 
							= __stage_execute_input_data.rfile_rb_data;

						// Zero-extend the immediate value
						__in_alu.b = {16'h0000,
							__multi_stage_data_1.instr_imm_val};
						__in_alu.oper = __multi_stage_data_1
							.instr_opcode;
					end
				endcase
				//$display("always_comb thing:  %h %h %h",
				//	__in_alu.a, __in_alu.b, __in_alu.oper);
			end

			// Group 2:  Branches
			2:
			begin
				__locals.mul_partial_result_x0_y0 = 0;
				__locals.mul_partial_result_x0_y1 = 0;
				__locals.mul_partial_result_x1_y0 = 0;

				//__in_alu.a = __multi_stage_data_1.pc_val + 4;
				__in_alu.a = __following_pc;

				// Sign extend the immediate value
				__in_alu.b 
					= {{16{__multi_stage_data_1.instr_imm_val[15]}}, 
					__multi_stage_data_1.instr_imm_val};

				__in_alu.oper = PkgAlu::Add;
			end

			// Group 3:  Jumps
			3:
			begin
				__locals.mul_partial_result_x0_y0 = 0;
				__locals.mul_partial_result_x0_y1 = 0;
				__locals.mul_partial_result_x1_y0 = 0;

				// Allows resolving conditional jump destinations with code
				// that is very similar to the branch destination
				// resolving.  Simply grab the destination address from the
				// ALU, no matter the type of control flow (branch, jump,
				// or call)
				// 
				// (See the task handle_ctrl_flow_in_decode())
				__in_alu.a = __stage_execute_input_data.rfile_rc_data;
				__in_alu.b = 0;
				__in_alu.oper = PkgAlu::Add;
			end

			// Group 4:  Calls
			4:
			begin
				__locals.mul_partial_result_x0_y0 = 0;
				__locals.mul_partial_result_x0_y1 = 0;
				__locals.mul_partial_result_x1_y0 = 0;

				// Allows resolving conditional jump destinations with code
				// that is very similar to the branch destination
				// resolving.  Simply grab the destination address from the
				// ALU, no matter the type of control flow (branch, jump,
				// or call)
				// 
				// (See the task handle_ctrl_flow_in_decode())
				__in_alu.a = __stage_execute_input_data.rfile_rc_data;
				__in_alu.b = 0;
				__in_alu.oper = PkgAlu::Add;
			end

			// Group 5:  Loads and stores
			5:
			begin
				__locals.mul_partial_result_x0_y0 = 0;
				__locals.mul_partial_result_x0_y1 = 0;
				__locals.mul_partial_result_x1_y0 = 0;

				__in_alu.a = __stage_execute_input_data.rfile_rb_data;

				// Immediate-indexed loads and stores have
				// (__multi_stage_data_1.instr_opcode[3] == 1)
				if (__multi_stage_data_1.instr_opcode[3])
				begin
					// memory address computation:  rB + sign-extended
					// immediate (actually sign extended twice since
					// the instruction decoder **also** performed a
					// sign extend, from 12-bit to 16-bit)
					__in_alu.b = {{16{__multi_stage_data_1
						.instr_imm_val[15]}},
						__multi_stage_data_1.instr_imm_val};
				end

				else
				begin
					// memory address computation:  rB + rC
					__in_alu.b = __stage_execute_input_data
						.rfile_rc_data;
				end
				__in_alu.oper = PkgAlu::Add;
			end

			default:
			begin
				__locals.mul_partial_result_x0_y0 = 0;
				__locals.mul_partial_result_x0_y1 = 0;
				__locals.mul_partial_result_x1_y0 = 0;

				// Perform a bogus add
				__in_alu = 0;
			end
		endcase
		//__in_alu.a = __stage_execute_input_data.rfile_rb_data
	end

	else // if (in.wait_for_mem)
	begin
		__locals.mul_partial_result_x0_y0 = 0;
		__locals.mul_partial_result_x0_y1 = 0;
		__locals.mul_partial_result_x1_y0 = 0;
		__in_alu = 0;
	end
	end

endmodule
