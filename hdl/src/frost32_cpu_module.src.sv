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
		// that in a **generally** synthesizeable way.
		logic [`MSB_POS__FROST32_CPU_DECODE_STAGE_STALL_COUNTER:0]
			stall_counter;

		//logic [`MSB_POS__FROST32_CPU_STATE:0] stall_state;
	} __stage_instr_decode_data;

	// Data input to the execute stage
	struct packed
	{
		logic [`MSB_POS__REG_FILE_DATA:0] rfile_ra_data, rfile_rb_data,
			rfile_rc_data;

		//logic [`MSB_POS__FROST32_CPU_ADDR:0] next_pc;
	} __stage_execute_input_data;

	// Data input to the write back stage (output
	struct packed
	{
		// These are written
		logic [`MSB_POS__REG_FILE_DATA:0] rfile_ra_data, rfile_rb_data,
			rfile_rc_data;
	} __stage_write_back_input_data;

	
	// Data output from the write back stage ("ahead" to the instruction
	// decode stage)
	struct packed
	{
		// The next program counter for instructions that stall (read by
		// the instruction decode stage for updating the program counter in
		// the case of these instructions)
		logic [`MSB_POS__FROST32_CPU_ADDR:0] next_pc;
	} __stage_write_back_output_data;

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
		__multi_stage_data_0.instr_causes_stall,
		__multi_stage_data_0.pc_val}
		= {__out_instr_decoder.ra_index, __out_instr_decoder.rb_index,
		__out_instr_decoder.rc_index, __out_instr_decoder.imm_val,
		__out_instr_decoder.group, __out_instr_decoder.opcode,
		__out_instr_decoder.causes_stall, __locals.pc};

	assign __stage_execute_input_data.rfile_ra_data 
		= __out_reg_file.read_data_ra;
	assign __stage_execute_input_data.rfile_rb_data 
		= __out_reg_file.read_data_rb;
	assign __stage_execute_input_data.rfile_rc_data 
		= __out_reg_file.read_data_rc;


	// Tasks and functions

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
		__stage_write_back_input_data = 0;
		__stage_write_back_output_data = 0;
		//__stage_instr_decode_data.state = PkgFrost32Cpu::StInit;

		// Prepare a read from memory
		out.data = 0;
		out.addr = __locals.pc;
		out.data_inout_access_type = PkgFrost32Cpu::DiatRead; 
		out.data_inout_access_size = PkgFrost32Cpu::Dias32;
		out.req_mem_access = 1;

		__stage_instr_decode_data.stall_counter = 0;
		//__stage_instr_decode_data.stall_state = PkgFrost32Cpu::StInit;
	end

	// Stage 0:  Instruction Decode
	always_ff @ (posedge clk)
	begin
		if (__stage_instr_decode_data.stall_counter > 0)
		begin
			__stage_instr_decode_data.stall_counter
				<= __stage_instr_decode_data.stall_counter - 1;

			// The last stall_counter value before it hits zero.
			if (__stage_instr_decode_data.stall_counter == 1)
			begin
				//case (__stage_instr_decode_data.state)
				//	PkgFrost32Cpu::StInit:
				//	begin
				//		// Do nothing
				//	end

				//	PkgFrost32Cpu::StMulDiv:
				//	begin
				//		// Not using this yet
				//	end

				//	PkgFrost32Cpu::StCtrlFlow:
				//	begin
				//	end

				//	PkgFrost32Cpu::StMemAccess:
				//	begin
				//	end
				//endcase

				//prep_mem_read
				__locals.pc <= __stage_write_back_output_data.next_pc;

				// The write-back stage will perform prep_mem_read()
			end
		end

		else // if (__stage_instr_decode_data.stall_counter == 0)
		begin
			// Update the program counter via owner computes (only this
			// always_ff block can perform an actual change to the program
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
			end
		end
	end

	// Stage 1:  Execute
	always_ff @ (posedge clk)
	begin
		__multi_stage_data_2 <= __multi_stage_data_1;
	end

	// Stage 2:  Write Back
	always_ff @ (posedge clk)
	begin
		case (__multi_stage_data_2.instr_group)
			4'd0:
			begin
				if (__multi_stage_data_2.instr_opcode
					< PkgInstrDecoder::Bad0_Iog0)
				begin
					if (__multi_stage_data_2.instr_opcode
						!= PkgInstrDecoder::Mul_ThreeRegs)
					begin
						prep_ra_write(__out_alu.data);
					end

					else
					begin
						// Temporarily pretend that 32-bit multiplies using
						// * are synthesizeable
						prep_ra_write
							(__stage_write_back_input_data.rfile_rb_data
							* __stage_write_back_input_data.rfile_rc_data);
					end
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
					if (__multi_stage_data_2.instr_opcode
						!= PkgInstrDecoder::Muli_TwoRegsOneImm)
					begin
						prep_ra_write(__out_alu.data);
					end

					else
					begin
						// Temporarily pretend that 32-bit multiplies using
						// * are synthesizeable
						prep_ra_write
							(__stage_write_back_input_data.rfile_rb_data
							* {16'h0000, 
							__stage_write_back_input_data.imm_val});
					end
				end

				else if (__multi_stage_data_2.instr_opcode
					== PkgInstrDecoder::Cpyhi_OneRegOneImm)
				begin
					// "cpyhi" does not change the lower 15 bits of rA
					prep_ra_write({__multi_stage_data_2.instr_imm_val,
						__stage_write_back_input_data.rfile_ra_data[15:0]});
				end

				else if (__multi_stage_data_2.instr_opcode
					== PkgInstrDecoder::Bne_TwoRegsOneSimm)
				begin
					//__enable_set_pc <= !__enable_set_pc;

					//request_set_pc_from_write_back
					//	(__stage_write_back_data.next_pc);
				end

				else //if (__multi_stage_data_2.instr_opcode
					//== PkgInstrDecoder::Beq_TwoRegsOneSimm)
				begin
					//request_set_pc_from_write_back
					//	(__stage_write_back_data.next_pc);
				end
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

endmodule
