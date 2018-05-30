`include "src/misc_defines.header.sv"

module TestBench;

	import PkgFrost32Cpu::*;
	import PkgMainMem::*;

	logic __clk, __half_clk;
	MainClockGenerator __inst_main_clk_gen(.clk(__clk));
	HalfClockGenerator __inst_half_clk_gen(.clk(__half_clk));

	//struct packed
	//{
	//	logic can_interrupt;

	//} __locals;

	logic __interrupt;
	logic [`MSB_POS__FROST32_CPU_DATA_INOUT:0] __addr_0_data;

	logic [`MSB_POS__FROST32_CPU_DATA_INOUT:0] 
		__debug_reg_u4, __debug_reg_u7,
		__debug_reg_fp,
		__debug_reg_pc,
		__debug_reg_ireta, __debug_reg_idsta;
	logic __debug_reg_ie;

	PkgFrost32Cpu::PortIn_Frost32Cpu __in_frost32_cpu;
	PkgFrost32Cpu::PortOut_Frost32Cpu __out_frost32_cpu;

	Frost32Cpu __inst_frost32_cpu(.clk(__half_clk), .in(__in_frost32_cpu),
		.out(__out_frost32_cpu));
	//Frost32Cpu __inst_frost32_cpu(.clk(__clk), .in(__in_frost32_cpu),
	//	.out(__out_frost32_cpu));

	PkgMainMem::PortIn_MainMem __in_main_mem;
	PkgMainMem::PortOut_MainMem __out_main_mem;
	MainMem __inst_main_mem(.clk(__half_clk), 
		.in(__in_main_mem), .out(__out_main_mem));
	//MainMem __inst_main_mem(.clk(__clk), 
	//	.in(__in_main_mem), .out(__out_main_mem));


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

	assign __in_frost32_cpu.interrupt = __interrupt;

	//always @ (posedge __clk)
	//begin
	//	//$display("TestBench:  %h\t\t%h %h\t\t%h %h",
	//	//	__in_frost32_cpu.wait_for_mem,
	//	//	__out_frost32_cpu.data, __out_frost32_cpu.addr,
	//	//	__out_frost32_cpu.data_inout_access_type,
	//	//	__out_frost32_cpu.data_inout_access_size);
	//	$display("TestBench:  %h", __in_frost32_cpu.wait_for_mem);
	//end

	assign __debug_reg_u4 = __out_frost32_cpu.debug_reg_u4;
	assign __debug_reg_u7 = __out_frost32_cpu.debug_reg_u7;
	assign __debug_reg_fp = __out_frost32_cpu.debug_reg_fp;
	assign __debug_reg_pc = __out_frost32_cpu.debug_reg_pc;
	assign __debug_reg_ireta = __out_frost32_cpu.debug_reg_ireta;
	assign __debug_reg_idsta = __out_frost32_cpu.debug_reg_idsta;
	assign __debug_reg_ie = __out_frost32_cpu.debug_reg_ie;

	always @ (posedge __clk)
	begin
		//$display("TestBench __out_main_mem.addr_0_data:  %h",
		//	__out_main_mem.addr_0_data);
		
		if ((__out_frost32_cpu.data_inout_access_type
			== PkgFrost32Cpu::DiatWrite)
			&& (__out_frost32_cpu.addr == 0))
		begin
			__addr_0_data <= __out_frost32_cpu.data;
		end

		//$display("TestBench stuff:  %h, %h",
		//	__addr_0_data, __debug_reg_u4);
	end

	//always @ (posedge __clk)
	//always @ (posedge __half_clk)
	always
	begin
		//#100

		//#20
		//#24
		//#28
		//#32
		if (__debug_reg_ie)
		begin
			//#52
			//#100
			if (__interrupt)
			begin
				#100
				__interrupt = $random % 2;
			end

			else
			begin
				#4
				__interrupt = $random % 2;
			end
		end

		else
		begin
			//#100
			//#1
			#4
			__interrupt = $random % 2;
		end
	end


	initial
	begin
		$dumpfile("test.vcd");
		$dumpvars(0, TestBench);

		//__locals = 0;
		__interrupt = 0;
		__addr_0_data = 0;

		////#500
		////#50
		//#100
		//#2000
		//#200
		//#1000
		//$finish;

		//for (int i=0; i<5; i=i+1)
		//begin
			//#1000
			//#10000
			#100000
		//	#104
		//	__interrupt = $random % 2;

		//	//__interrupt = 0;

		//	//#160
		//	#60
		//	__interrupt = $random % 2;

		//	#20
		//	__interrupt = $random % 2;
		//	#20
		//	__interrupt = $random % 2;
		//	#20
		//	__interrupt = $random % 2;

		//	#20
		//	__interrupt = $random % 2;


		//	#104
		//	__interrupt = $random % 2;

		//	#60
		//	__interrupt = $random % 2;

		//	#1000
			//$display("TestBench:  end of loop:  %h", i);
		//end
		$finish;
	end


	//always @ (posedge __clk)
	//begin
	//	//if (__can_interrupt && !__in_frost32_cpu.wait_for_mem)
	//	//begin
	//	//	if (!__interrupt)
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
