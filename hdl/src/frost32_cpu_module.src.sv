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


	// Data output by or used by the Instruction Decode stage
	struct packed
	{
		// Counter for stalling while waitng for later stages to do their
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
	} __stage_instr_decode_data;

	// Data input to the execute stage
	struct packed
	{
		logic [`MSB_POS__REG_FILE_DATA:0] rfile_ra_data, rfile_rb_data,
			rfile_rc_data;

		//logic [`MSB_POS__FROST32_CPU_ADDR:0] next_pc;
	} __stage_execute_input_data;

	struct packed
	{
		// The next program counter for instructions that stall (read by
		// the instruction decode stage for updating the program counter in
		// the case of these instructions)
		logic [`MSB_POS__FROST32_CPU_ADDR:0] next_pc;
	} __stage_execute_output_data;

	// Data input to the write back stage (output
	struct packed
	{
		// These are written by the execute stage
		logic [`MSB_POS__REG_FILE_DATA:0] rfile_ra_data, rfile_rb_data,
			rfile_rc_data;

		logic [`MSB_POS__ALU_INOUT:0] n_reg_data;

	} __stage_write_back_input_data;

	struct packed
	{
		// The program counter (written to ONLY by the instruction decode
		// stage)
		logic [`MSB_POS__FROST32_CPU_ADDR:0] pc;
	} __locals;


	PkgFrost32Cpu::MultiStageData __multi_stage_data_0, 
		__multi_stage_data_1, __multi_stage_data_2;


	// Module instantiations
	logic [`MSB_POS__INSTRUCTION:0] __in_instr_decoder;
	PkgInstrDecoder::PortOut_InstrDecoder __out_instr_decoder;
	InstrDecoder __inst_instr_decoder(.in(__in_instr_decoder), 
		.out(__out_instr_decoder));

	PkgRegisterFile::PortIn_RegFile __in_reg_file;
	PkgRegisterFile::PortOut_RegFile __out_reg_file;
	RegisterFile __inst_reg_file(.clk(clk), .in(__in_reg_file),
		.out(__out_reg_file));

	PkgAlu::PortIn_Alu __in_alu;
	PkgAlu::PortOut_Alu __out_alu;
	Alu __inst_alu(.in(__in_alu), .out(__out_alu));


	// Assignments
	assign __in_instr_decoder = in.data;
	assign __multi_stage_data_0.raw_instruction = __in_instr_decoder;
	assign {__multi_stage_data_0.instr_ra_index,
		__multi_stage_data_0.instr_rb_index,
		__multi_stage_data_0.instr_rc_index,
		__multi_stage_data_0.instr_imm_val,
		__multi_stage_data_0.instr_group,
		__multi_stage_data_0.instr_opcode,
		__multi_stage_data_0.instr_ldst_type,
		__multi_stage_data_0.instr_causes_stall,
		__multi_stage_data_0.pc_val}
		= {__out_instr_decoder.ra_index, __out_instr_decoder.rb_index,
		__out_instr_decoder.rc_index, __out_instr_decoder.imm_val,
		__out_instr_decoder.group, __out_instr_decoder.opcode,
		__out_instr_decoder.ldst_type, __out_instr_decoder.causes_stall, 
		__locals.pc};


	// This will need to be replaced with operand forwarding later
	// (probably with another always_comb statement)
	assign __stage_execute_input_data.rfile_ra_data 
		= __out_reg_file.read_data_ra;
	assign __stage_execute_input_data.rfile_rb_data 
		= __out_reg_file.read_data_rb;
	assign __stage_execute_input_data.rfile_rc_data 
		= __out_reg_file.read_data_rc;




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


	initial
	begin
		//__multi_stage_data_0 = 0;
		__multi_stage_data_1 = 0;
		__multi_stage_data_2 = 0;

		//{__stage_instr_decode_data, __stage_execute_input_data} = 0;
		__stage_instr_decode_data = 0;
		__stage_execute_output_data = 0;
		__stage_write_back_input_data = 0;
		//__stage_instr_decode_data.state = PkgFrost32Cpu::StInit;

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
		//if (__stage_instr_decode_data.stall_counter > 0)
		if (in_stall())
		begin
			// Decrement the stall counter
			__stage_instr_decode_data.stall_counter
				<= __stage_instr_decode_data.stall_counter - 1;

			// Send bubbles through while we're stalled a (actually
			// performs "add zero, zero, zero", but that does nothing
			// interesting anyway... besides maybe power consumption)
			__in_reg_file.read_sel_ra <= 0;
			__in_reg_file.read_sel_rb <= 0;
			__in_reg_file.read_sel_rc <= 0;
			__multi_stage_data_1 <= 0;

			// The last stall_counter value before it hits zero (this is
			// where the PC should be changed).
			if (__stage_instr_decode_data.stall_counter == 1)
			begin
				__locals.pc <= __stage_execute_output_data.next_pc;

				// Prepare a load from memory of the next instruction.
				// "prep_mem_read()" and "prep_mem_write()" are **ONLY**
				// performed in the decode stage.
				prep_mem_read(__stage_execute_output_data.next_pc,
					PkgFrost32Cpu::Dias32);
			end

			else // if (we're in the middle of executing a multi-cycle
				// instruction (and not about to finish it))
			begin
				// Memory access:  We've done the address computation in
				// the execute stage (within the "always_comb" block
				// located after the "always" block that performs the
				// write back stage)
				if ((__stage_instr_decode_data.stall_state
					== PkgFrost32Cpu::StMemAccess)
					&& (__stage_instr_decode_data.stall_counter == 3))
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
							prep_mem_read(__out_alu.data,
								PkgFrost32Cpu::Dias32);
						end
						PkgInstrDecoder::LdU16:
						begin
							prep_mem_read(__out_alu.data,
								PkgFrost32Cpu::Dias16);
						end
						PkgInstrDecoder::LdS16:
						begin
							prep_mem_read(__out_alu.data,
								PkgFrost32Cpu::Dias16);
						end
						PkgInstrDecoder::LdU8:
						begin
							prep_mem_read(__out_alu.data,
								PkgFrost32Cpu::Dias8);
						end
						PkgInstrDecoder::LdS8:
						begin
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
			end
		end

		//else // if (__stage_instr_decode_data.stall_counter == 0)
		else // if (!in_stall())
		begin
			// Update the program counter via owner computes (only this
			// always block can perform an actual change to the program
			// counter).
			if (!__multi_stage_data_0.instr_causes_stall)
			begin
				// Every instruction is 4 bytes long
				__locals.pc <= __locals.pc + 4;
			end

			// For now, (before multiplication is implemented for real),
			// assume that all multi-cycle instructions actually take three
			// cycles (thus set the stall_counter to 3)
			else // if (__multi_stage_data_0.instr_causes_stall)
			begin
				__stage_instr_decode_data.stall_counter <= 3;

				// All loads and stores are in group 3
				if (__multi_stage_data_0.instr_group == 3)
				begin
					__stage_instr_decode_data.stall_state 
						<= PkgFrost32Cpu::StMemAccess;
				end

				// Temporary!
				else
				begin
					__stage_instr_decode_data.stall_state 
						<= PkgFrost32Cpu::StInit;
				end
			end

			// Use all three register file read ports
			__in_reg_file.read_sel_ra 
				<= __multi_stage_data_0.instr_ra_index;
			__in_reg_file.read_sel_rb 
				<= __multi_stage_data_0.instr_rb_index;
			__in_reg_file.read_sel_rc 
				<= __multi_stage_data_0.instr_rc_index;

			// We only send a non-bubble instruction to
			// __multi_stage_data_1 when there's a new instruction
			__multi_stage_data_1 <= __multi_stage_data_0;
		end
	end

	// Stage 1:  Execute 
	// (Most of the interesting code for this stage is located in the
	// "always_comb" block after the write back stage's "always" block)
	always @ (posedge clk)
	begin
		__multi_stage_data_2 <= __multi_stage_data_1;

		__stage_write_back_input_data.rfile_ra_data 
			<= __stage_execute_input_data.rfile_ra_data;
		__stage_write_back_input_data.rfile_rb_data 
			<= __stage_execute_input_data.rfile_rb_data;
		__stage_write_back_input_data.rfile_rc_data 
			<= __stage_execute_input_data.rfile_rc_data;

		//__stage_write_back_input_data.alu_out <= __out_alu.data;


		case (__multi_stage_data_1.instr_group)
			4'd0:
			begin
				// Temporary!  Doesn't perform multiplications properly!
				__stage_write_back_input_data.n_reg_data <= __out_alu.data;

				// Sneaky way to just use the updated PC from the previous
				// stage (4 was added to it)
				__stage_execute_output_data.next_pc <= __locals.pc;
			end

			4'd1:
			begin

				//// "cpyhi" does not change the lower 15 bits of rA
				//prep_ra_write({__multi_stage_data_2.instr_imm_val,
				//	__stage_write_back_input_data.rfile_ra_data[15:0]});

				if (__multi_stage_data_1.instr_opcode
					== PkgInstrDecoder::Cpyhi_OneRegOneImm)
				begin
					__stage_write_back_input_data.n_reg_data
						<= {__multi_stage_data_1.instr_imm_val,
						__stage_execute_input_data.rfile_ra_data[15:0]};
				end

				else if (__multi_stage_data_1.instr_opcode 
					== PkgInstrDecoder::Bne_TwoRegsOneSimm)
				begin
					// Temporary!  Doesn't perform multiplications properly!
					__stage_write_back_input_data.n_reg_data 
						<= __out_alu.data;

					if (__stage_execute_input_data.rfile_ra_data
						!= __stage_execute_input_data.rfile_rb_data)
					begin
						__stage_execute_output_data.next_pc 
							<= __out_alu.data;
					end

					else
					begin
						// Sneaky way to just use the updated PC from the
						// previous stage (4 was added to it)
						__stage_execute_output_data.next_pc <= __locals.pc;
					end
				end

				else if (__multi_stage_data_1.instr_opcode
					== PkgInstrDecoder::Beq_TwoRegsOneSimm)
				begin
					// Temporary!  Doesn't perform multiplications properly!
					__stage_write_back_input_data.n_reg_data 
						<= __out_alu.data;

					if (__stage_execute_input_data.rfile_ra_data
						== __stage_execute_input_data.rfile_rb_data)
					begin
						__stage_execute_output_data.next_pc 
							<= __out_alu.data;
					end

					else
					begin
						// Sneaky way to just use the updated PC from the
						// previous stage (4 was added to it)
						__stage_execute_output_data.next_pc <= __locals.pc;
					end
				end

				else
				begin
					// Temporary!  Doesn't perform multiplications properly!
					__stage_write_back_input_data.n_reg_data 
						<= __out_alu.data;

					// Sneaky way to just use the updated PC from the
					// previous stage (4 was added to it)
					__stage_execute_output_data.next_pc <= __locals.pc;
				end
			end

			4'd2:
			begin
				case (__multi_stage_data_1.instr_opcode)
					PkgInstrDecoder::Jne_ThreeRegs:
					begin
						if (__stage_execute_input_data.rfile_ra_data
							!= __stage_execute_input_data.rfile_rb_data)
						begin
							__stage_execute_output_data.next_pc
								<= __stage_execute_input_data
								.rfile_rc_data;
						end

						else
						begin
							// Sneaky way to just use the updated PC from
							// the previous stage (4 was added to it)
							__stage_execute_output_data.next_pc 
								<= __locals.pc;
						end
					end

					PkgInstrDecoder::Jeq_ThreeRegs:
					begin
						if (__stage_execute_input_data.rfile_ra_data
							== __stage_execute_input_data.rfile_rb_data)
						begin
							__stage_execute_output_data.next_pc
								<= __stage_execute_input_data
								.rfile_rc_data;
						end

						else
						begin
							// Sneaky way to just use the updated PC from
							// the previous stage (4 was added to it)
							__stage_execute_output_data.next_pc 
								<= __locals.pc;
						end
					end

					PkgInstrDecoder::Callne_ThreeRegs:
					begin
						if (__stage_execute_input_data.rfile_ra_data
							!= __stage_execute_input_data.rfile_rb_data)
						begin
							__stage_execute_output_data.next_pc
								<= __stage_execute_input_data
								.rfile_rc_data;
							
							// New lr value
							// Sneaky way to just use the updated PC from
							// the previous stage (4 was added to it)
							__stage_write_back_input_data.n_reg_data 
								<= __locals.pc;
						end

						else
						begin
							// Sneaky way to just use the updated PC from
							// the previous stage (4 was added to it)
							__stage_execute_output_data.next_pc 
								<= __locals.pc;
						end
					end

					PkgInstrDecoder::Calleq_ThreeRegs:
					begin
						if (__stage_execute_input_data.rfile_ra_data
							== __stage_execute_input_data.rfile_rb_data)
						begin
							__stage_execute_output_data.next_pc
								<= __stage_execute_input_data
								.rfile_rc_data;
							
							// New lr value
							// Sneaky way to just use the updated PC from
							// the previous stage (4 was added to it)
							__stage_write_back_input_data.n_reg_data 
								<= __locals.pc;
						end

						else
						begin
							// Sneaky way to just use the updated PC from
							// the previous stage (4 was added to it)
							__stage_execute_output_data.next_pc 
								<= __locals.pc;
						end
					end

					default:
					begin
						// Sneaky way to just use the updated PC from the
						// previous stage (4 was added to it)
						__stage_execute_output_data.next_pc <= __locals.pc;
					end
				endcase
			end

			4'd3:
			begin
				// Sneaky way to just use the updated PC from the previous
				// stage (4 was added to it)
				__stage_execute_output_data.next_pc <= __locals.pc;
			end
		endcase
	end

	// Stage 2:  Write Back
	always @ (posedge clk)
	begin
		case (__multi_stage_data_2.instr_group)
			4'd0:
			begin
				if (__multi_stage_data_2.instr_opcode
					< PkgInstrDecoder::Bad0_Iog0)
				begin
					//if (__multi_stage_data_2.instr_opcode
					//	!= PkgInstrDecoder::Mul_ThreeRegs)
					//begin
						prep_ra_write
							(__stage_write_back_input_data.n_reg_data);
					//end

					//else
					//begin
					//	// Temporarily pretend that 32-bit multiplies using
					//	// * are synthesizeable
					//	prep_ra_write
					//		(__stage_write_back_input_data.rfile_rb_data
					//		* __stage_write_back_input_data.rfile_rc_data);
					//end
				end

				else
				begin
					// Treat this instruction as a NOP (no write-back)
				end
			end

			4'd1:
			begin
				if (__multi_stage_data_2.instr_opcode
					< PkgInstrDecoder::Cpyhi_OneRegOneImm)
				begin
					//if (__multi_stage_data_2.instr_opcode
					//	!= PkgInstrDecoder::Muli_TwoRegsOneImm)
					//begin
						prep_ra_write
							(__stage_write_back_input_data.n_reg_data);
					//end

					//else
					//begin
					//	// Temporarily pretend that 32-bit multiplies using
					//	// * are synthesizeable
					//	prep_ra_write
					//		(__stage_write_back_input_data.rfile_rb_data
					//		* {16'h0000, 
					//		__stage_write_back_input_data.imm_val});
					//end
				end

				else if (__multi_stage_data_2.instr_opcode
					== PkgInstrDecoder::Addsi_OneRegOnePcOneSimm)
				begin
					prep_ra_write(__stage_write_back_input_data.n_reg_data);
				end

				else if (__multi_stage_data_2.instr_opcode
					== PkgInstrDecoder::Cpyhi_OneRegOneImm)
				begin
					//// "cpyhi" does not change the lower 15 bits of rA
					//prep_ra_write({__multi_stage_data_2.instr_imm_val,
					//	__stage_write_back_input_data.rfile_ra_data[15:0]});

					prep_ra_write(__stage_write_back_input_data.n_reg_data);
				end

				//else if (__multi_stage_data_2.instr_opcode
				//	== PkgInstrDecoder::Bne_TwoRegsOneSimm)
				//begin
				//end

				//else //if (__multi_stage_data_2.instr_opcode
				//	//== PkgInstrDecoder::Beq_TwoRegsOneSimm)
				//begin
				//end
			end

			4'd2:
			begin
				
			end

			4'd3:
			begin
				
			end

			default:
			begin
				// Eek!
			end
		endcase
	end

	// ALU input stuff (ONLY relevant to the execute stage, and almost
	// uses execute stage data exclusively)
	always_comb
	begin
		case (__multi_stage_data_1.instr_group)
			0:
			begin
				// It's okay if the ALU performs a bogus operation, so
				// let's decode the ALU opcode directly from the
				// instruction for group 0 instructions.
				__in_alu.a = __stage_execute_input_data.rfile_rb_data;
				__in_alu.b = __stage_execute_input_data.rfile_rc_data;
				__in_alu.oper = __multi_stage_data_1.instr_opcode;
			end

			1:
			begin
				//__in_alu.oper = __multi_stage_data_1.instr_opcode;

				case (__multi_stage_data_1.instr_opcode)
					PkgInstrDecoder::Sltsi_TwoRegsOneSimm:
					begin
						__in_alu.a
							= __stage_execute_input_data.rfile_rb_data;

						// Sign extend the immediate value
						__in_alu.b = __multi_stage_data_1.instr_imm_val[15]
							? {16'hffff, 
							__multi_stage_data_1.instr_imm_val}
							: {16'h0000,
							__multi_stage_data_1.instr_imm_val};

						__in_alu.oper = PkgAlu::Slts;
					end

					PkgInstrDecoder::Addsi_OneRegOnePcOneSimm:
					begin
						__in_alu.a = __multi_stage_data_1.pc_val;

						// Sign extend the immediate value
						__in_alu.b = __multi_stage_data_1.instr_imm_val[15]
							? {16'hffff, 
							__multi_stage_data_1.instr_imm_val}
							: {16'h0000,
							__multi_stage_data_1.instr_imm_val};

						__in_alu.oper = PkgAlu::Add;
					end

					//PkgInstrDecoder::Cpyhi_OneRegOneImm:
					//begin
					//	
					//end
					PkgInstrDecoder::Bne_TwoRegsOneSimm:
					begin
						// Sneaky way to use the value
						// __multi_stage_data_1.pc_val + 4 as input to the
						// ALU without an extra addition (in theory, at
						// least....)
						__in_alu.a = __multi_stage_data_0.pc_val;

						// Sign extend the immediate value
						__in_alu.b = __multi_stage_data_1.instr_imm_val[15]
							? {16'hffff, 
							__multi_stage_data_1.instr_imm_val}
							: {16'h0000,
							__multi_stage_data_1.instr_imm_val};

						__in_alu.oper = PkgAlu::Add;
					end

					PkgInstrDecoder::Beq_TwoRegsOneSimm:
					begin
						// Sneaky way to use the value
						// __multi_stage_data_1.pc_val + 4 as input to the
						// ALU without an extra addition (in theory, at
						// least....)
						__in_alu.a = __multi_stage_data_0.pc_val;

						// Sign extend the immediate value
						__in_alu.b = __multi_stage_data_1.instr_imm_val[15]
							? {16'hffff, 
							__multi_stage_data_1.instr_imm_val}
							: {16'h0000,
							__multi_stage_data_1.instr_imm_val};

						__in_alu.oper = PkgAlu::Add;
					end


					// Let's decode the ALU opcode directly from the
					// instruction for the remainder of the instructions
					// from group 1
					default:
					begin
						__in_alu.a 
							= __stage_execute_input_data.rfile_rb_data;

						// Zero-extend the immediate value
						__in_alu.b = {16'h0000,
							__multi_stage_data_1.instr_imm_val};
						__in_alu.oper = __multi_stage_data_1.instr_opcode;
					end
				endcase
			end

			//2:
			//begin
			//	// Perform a bogus add
			//	__in_alu.a = 0;
			//	__in_alu.b = 0;
			//	__in_alu.oper = 0;
			//end

			3:
			begin
				// memory address computation:  rB + rC
				//__in_alu.a = __stage_execute_input_data.rfile_rb_data;
				//__in_alu.b = __stage_execute_input_data.rfile_rc_data;

				// Sometimes this causes the ALU to perform a bogus add,
				// specifically whenever it's an invalid group 3
				// instruction.
				__in_alu.a = __stage_execute_input_data.rfile_rb_data;
				__in_alu.b = __stage_execute_input_data.rfile_rc_data;
				__in_alu.oper = PkgAlu::Add;
			end

			default:
			begin
				// Perform a bogus add
				__in_alu = 0;
			end
		endcase
		//__in_alu.a = __stage_execute_input_data.rfile_rb_data
	end

endmodule
