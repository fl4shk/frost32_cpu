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

	parameter __ARR_SIZE__NUM_STAGES = 3;
	parameter __LAST_INDEX__NUM_STAGES 
		= `ARR_SIZE_TO_LAST_INDEX(__ARR_SIZE__NUM_STAGES);

	typedef enum logic 
	{
		WbWritePc,
		WbWriteRg
	} WbWritePcOrReg;


	// Data used only by the Instruction Decode stage
	struct packed
	{
		logic [`MSB_POS__FROST32_CPU_DECODE_STAGE_STALL_COUNTER:0]
			stall_counter;
		logic [`MSB_POS__FROST32_CPU_DECODE_STAGE_STALL_COUNTER:0]
			start_counter;

		// For the write-back stage:  Are we writing the PC or a register?
		logic which_write_back;
	} __stage_instr_decode_data;

	// Data used only by the Execute stage
	struct packed
	{
		// Are we writing the PC or a register?
		logic which_write_back;
	} __stage_execute_data;


	// Data used only by the Write Back stage
	struct packed
	{
		logic which_write_back;
	} __stage_write_back_data;


	PkgFrost32Cpu::MultiStageData
		__multi_stage_data[0 : __LAST_INDEX__NUM_STAGES];


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

	initial
	begin
		for (int i=0; i<__ARR_SIZE__NUM_STAGES; ++i)
		begin
			__multi_stage_data[i] = 0;
		end

		{__stage_instr_decode_data, __stage_execute_data,
			__stage_write_back_data} = 0;

		//prep_mem_read(__locals.pc, PkgFrost32Cpu::Dias32);
		out.data = 0;
		out.addr = __stage_instr_decode_data.pc;
		out.data_inout_access_type = PkgFrost32Cpu::DiatRead; 
		out.data_inout_access_size = PkgFrost32Cpu::Dias32;
		out.req_mem_access = 1;

		// Initialize start_counter
		__stage_instr_decode_data.start_counter = 3;
	end

	// Stage 0:  Instruction Decode
	always_ff @ (posedge clk)
	begin
		if (__stage_instr_decode_data.stall_counter)
		begin
			__stage_instr_decode_data.stall_counter
				<= __stage_instr_decode_data.stall_counter - 1;
		end

		if (__stage_instr_decode_data.start_counter > 0)
		begin
			__stage_instr_decode_data.start_counter
				<= __stage_instr_decode_data.start_counter - 1;
		end
	end

	// Stage 1:  Execute
	always_ff @ (posedge clk)
	begin
		
	end

	// Stage 2:  Write Back
	always_ff @ (posedge clk)
	begin
		
	end

endmodule
