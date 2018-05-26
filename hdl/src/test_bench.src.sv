`include "src/misc_defines.header.sv"

module TestBench;

	import PkgFrost32Cpu::*;
	import PkgMainMem::*;

	logic __clk, __half_clk;
	MainClockGenerator __inst_main_clk_gen(.clk(__clk));
	HalfClockGenerator __inst_half_clk_gen(.clk(__half_clk));

	struct packed
	{
		logic interrupt;
		logic can_interrupt;
	} __locals;

	PkgFrost32Cpu::PortIn_Frost32Cpu __in_frost32_cpu;
	PkgFrost32Cpu::PortOut_Frost32Cpu __out_frost32_cpu;

	//Frost32Cpu __inst_frost32_cpu(.clk(__half_clk), .in(__in_frost32_cpu),
	//	.out(__out_frost32_cpu));
	//Frost32Cpu __inst_frost32_cpu(.clk(__clk), .in(__in_frost32_cpu),
	//	.out(__out_frost32_cpu));

	Frost32Cpu __inst_frost32_cpu(.clk(__clk), 
		.in_data(__in_frost32_cpu.data),
		.in_wait_for_mem(__in_frost32_cpu.wait_for_mem),
		.in_interrupt(__in_frost32_cpu.interrupt),
		.out_data(__out_frost32_cpu.data),
		.out_addr(__out_frost32_cpu.addr),
		.out_data_inout_access_type
			(__out_frost32_cpu.data_inout_access_type),
		.out_data_inout_access_size
			(__out_frost32_cpu.data_inout_access_size),
		.out_req_mem_access(__out_frost32_cpu.req_mem_access)
		`ifdef OPT_DEBUG_REGISTER_FILE
		,
		.out_debug_reg_zero(__out_frost32_cpu.debug_reg_zero),
		.out_debug_reg_u0(__out_frost32_cpu.debug_reg_u0),
		.out_debug_reg_u1(__out_frost32_cpu.debug_reg_u1),
		.out_debug_reg_u2(__out_frost32_cpu.debug_reg_u2),

		.out_debug_reg_u3(__out_frost32_cpu.debug_reg_u3),
		.out_debug_reg_u4(__out_frost32_cpu.debug_reg_u4),
		.out_debug_reg_u5(__out_frost32_cpu.debug_reg_u5),
		.out_debug_reg_u6(__out_frost32_cpu.debug_reg_u6),

		.out_debug_reg_u7(__out_frost32_cpu.debug_reg_u7),
		.out_debug_reg_u8(__out_frost32_cpu.debug_reg_u8),
		.out_debug_reg_u9(__out_frost32_cpu.debug_reg_u9),
		.out_debug_reg_u10(__out_frost32_cpu.debug_reg_u10),

		.out_debug_reg_temp(__out_frost32_cpu.debug_reg_temp),
		.out_debug_reg_lr(__out_frost32_cpu.debug_reg_lr),
		.out_debug_reg_fp(__out_frost32_cpu.debug_reg_fp),
		.out_debug_reg_sp(__out_frost32_cpu.debug_reg_sp)
		`endif		// OPT_DEBUG_REGISTER_FILE
		);

	PkgMainMem::PortIn_MainMem __in_main_mem;
	PkgMainMem::PortOut_MainMem __out_main_mem;
	MainMem __inst_main_mem(.clk(__clk), 
		`ifdef OPT_DEBUG_MEM_ACCESS
		.half_clk(__half_clk),
		`endif		// OPT_DEBUG_MEM_ACCESS
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

	assign __in_frost32_cpu.interrupt = __locals.interrupt;

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

		__locals = 0;

		////#500
		////#50
		//#100
		//#2000
		//#200
		//#1000
		//$finish;

		#1000
		#104
		__locals.interrupt = 1;

		//__locals.interrupt = 0;

		//#160
		#60
		__locals.interrupt = 0;

		#2000

		#104
		__locals.interrupt = 1;

		#60
		__locals.interrupt = 0;

		#1000
		$finish;
	end

	//always @ (posedge __clk)
	//begin
	//	//if (__locals.can_interrupt && !__in_frost32_cpu.wait_for_mem)
	//	//begin
	//	//	if (!__locals.interrupt)
	//	//	begin
	//	//		
	//	//	end
	//	//end
	//end

	//initial
	//begin
	//	#500
	//	$display("test bench finish");
	//	$finish;
	//end

	//always @ (posedge __half_clk)
	//begin
	//	
	//end


endmodule
