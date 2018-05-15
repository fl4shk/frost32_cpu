`include "src/misc_defines.header.sv"

//module Mux2To1(input logic a, b, sel,
//	output logic out);
//
//	always_comb
//	begin
//		out = (!sel) ? a : b;
//	end
//
//endmodule

//module TestInstrDecoder;
//
//	parameter __ARR_SIZE__MAX_NUM_INSTRUCTIONS = 1 << 16;
//	parameter __LAST_INDEX__MAX_NUM_INSTRUCTIONS 
//		= `ARR_SIZE_TO_LAST_INDEX(__ARR_SIZE__MAX_NUM_INSTRUCTIONS);
//
//	logic [`MSB_POS__INSTRUCTION:0] 
//		__instructions[0 : __LAST_INDEX__MAX_NUM_INSTRUCTIONS];
//
//	initial
//	begin
//		$readmemh("instructions.txt.ignore", __instructions);
//	end
//
//
//endmodule




module TestBench;
	import PkgFrost32Cpu::*;

	logic __clk, __half_clk;
	MainClockGenerator __inst_main_clk_gen(.clk(__clk));
	HalfClockGenerator __inst_half_clk_gen(.clk(__half_clk));

	parameter __ARR_SIZE__MAIN_MEM = 1 << 24;
	parameter __LAST_INDEX__MAIN_MEM 
		= `ARR_SIZE_TO_LAST_INDEX(__ARR_SIZE__MAIN_MEM);

	logic [7:0] __main_mem[0 : __LAST_INDEX__MAIN_MEM];

	initial
	begin
		for (int i=0; i<__ARR_SIZE__MAIN_MEM; i=i+1)
		begin
			__main_mem[i] = 0;
		end
		$readmemh("main_mem.txt.ignore", __main_mem);

		////$dumpfile("test.vcd");
		////$dumpvars(0, TestBench);

		////#2000
		////#40
		//#100
		////#200
		////#300
		////////#1000
		//$finish;
	end

	PkgFrost32Cpu::PortIn_Frost32Cpu __in_frost32_cpu;
	PkgFrost32Cpu::PortOut_Frost32Cpu __out_frost32_cpu;

	Frost32Cpu __inst_frost32_cpu(.clk(__half_clk), .in(__in_frost32_cpu),
		.out(__out_frost32_cpu));

	//assign __in_frost32_cpu.data 
	//	= {__main_mem[(__out_frost32_cpu.addr & 16'hffff)],
	//	__main_mem[((__out_frost32_cpu.addr + 1) & 16'hfff)],
	//	__main_mem[((__out_frost32_cpu.addr + 2) & 16'hfff)],
	//	__main_mem[((__out_frost32_cpu.addr + 3) & 16'hfff)]};

	always_ff @ (posedge __clk)
	begin
		if (__out_frost32_cpu.req_mem_access 
			&& (__out_frost32_cpu.data_inout_access_type
			== PkgFrost32Cpu::DiatRead))
		begin
			if (__out_frost32_cpu.data_inout_access_size
				== PkgFrost32Cpu::Dias32)
			begin
				__in_frost32_cpu.data 
					<= {__main_mem[(__out_frost32_cpu.addr & 16'hffff)],
					__main_mem[((__out_frost32_cpu.addr + 1) & 16'hfff)],
					__main_mem[((__out_frost32_cpu.addr + 2) & 16'hfff)],
					__main_mem[((__out_frost32_cpu.addr + 3) & 16'hfff)]};
			end

			else if (__out_frost32_cpu.data_inout_access_size
				== PkgFrost32Cpu::Dias16)
			begin
				__in_frost32_cpu.data
					<= {__main_mem[(__out_frost32_cpu.addr & 16'hffff)],
					__main_mem[((__out_frost32_cpu.addr + 1) & 16'hffff)]};
			end

			else
			begin
				__in_frost32_cpu.data
					<= __main_mem[(__out_frost32_cpu.addr & 16'hffff)];
			end
		end

		else if (__out_frost32_cpu.req_mem_access
			&& (__out_frost32_cpu.data_inout_access_type
			== PkgFrost32Cpu::DiatWrite))
		begin
			if (__out_frost32_cpu.data_inout_access_size
				== PkgFrost32Cpu::Dias32)
			begin
				{__main_mem[(__out_frost32_cpu.addr & 16'hffff)],
				__main_mem[((__out_frost32_cpu.addr + 1) & 16'hfff)],
				__main_mem[((__out_frost32_cpu.addr + 2) & 16'hfff)],
				__main_mem[((__out_frost32_cpu.addr + 3) & 16'hfff)]}
					<= __out_frost32_cpu.data;
			end

			else if (__out_frost32_cpu.data_inout_access_size
				== PkgFrost32Cpu::Dias16)
			begin
				{__main_mem[(__out_frost32_cpu.addr & 16'hffff)],
				__main_mem[((__out_frost32_cpu.addr + 1) & 16'hffff)]}
					<= __out_frost32_cpu.data[15:0];
			end

			else
			begin
				__main_mem[(__out_frost32_cpu.addr & 16'hffff)]
					<= __out_frost32_cpu.data[7:0];
			end
		end
	end


endmodule

