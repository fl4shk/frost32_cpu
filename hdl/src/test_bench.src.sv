`include "src/misc_defines.header.sv"

module TestBench;

	import PkgFrost32Cpu::*;
	import PkgMainMem::*;

	logic __clk, __half_clk;
	MainClockGenerator __inst_main_clk_gen(.clk(__clk));
	HalfClockGenerator __inst_half_clk_gen(.clk(__half_clk));

	PkgFrost32Cpu::PortIn_Frost32Cpu __in_frost32_cpu;
	PkgFrost32Cpu::PortOut_Frost32Cpu __out_frost32_cpu;

	Frost32Cpu __inst_frost32_cpu(.clk(__half_clk), .in(__in_frost32_cpu),
		.out(__out_frost32_cpu));
	//Frost32Cpu __inst_frost32_cpu(.clk(__clk), .in(__in_frost32_cpu),
	//	.out(__out_frost32_cpu));

	PkgMainMem::PortIn_MainMem __in_main_mem;
	PkgMainMem::PortOut_MainMem __out_main_mem;
	MainMem __inst_main_mem(.clk(__clk), 
		`ifdef DEBUG_MEM_ACCESS
		.half_clk(__half_clk),
		`endif		// DEBUG_MEM_ACCESS
		.in(__in_main_mem), .out(__out_main_mem));


	assign __in_frost32_cpu.data = __out_main_mem.data;
	//assign __in_frost32_cpu.wait_for_mem = __out_main_mem.wait_for_mem;

	assign __in_main_mem.data = __out_frost32_cpu.data;
	assign __in_main_mem.addr = __out_frost32_cpu.addr;
	assign __in_main_mem.data_inout_access_type
		= __out_frost32_cpu.data_inout_access_type;
	assign __in_main_mem.data_inout_access_size
		= __out_frost32_cpu.data_inout_access_size;
	assign __in_main_mem.req_mem_access = __out_frost32_cpu.req_mem_access;

	// I'm not sure this will work
	//assign __in_frost32_cpu.wait_for_mem 
	//	= __out_frost32_cpu.req_mem_access || __out_main_mem.wait_for_mem;
	assign __in_frost32_cpu.wait_for_mem = __out_main_mem.wait_for_mem;

	//always @ (posedge __clk)
	//begin
	//	//$display("TestBench:  %h\t\t%h %h\t\t%h %h",
	//	//	__in_frost32_cpu.wait_for_mem,
	//	//	__out_frost32_cpu.data, __out_frost32_cpu.addr,
	//	//	__out_frost32_cpu.data_inout_access_type,
	//	//	__out_frost32_cpu.data_inout_access_size);
	//	$display("TestBench:  %h", __in_frost32_cpu.wait_for_mem);
	//end

	initial
	begin
		$dumpfile("test.vcd");
		$dumpvars(0, TestBench);

		////#500
		////#50
		//#100
		//$finish;
	end

	//always @ (posedge __half_clk)
	//begin
	//	
	//end


endmodule
