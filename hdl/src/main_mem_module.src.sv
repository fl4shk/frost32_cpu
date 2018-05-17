`include "src/misc_defines.header.sv"

`define WIDTH__INTERNAL_MAIN_MEM_ADDR 16
`define MSB_POS__INTERNAL_MAIN_MEM_ADDR \
	`WIDTH_TO_MSB_POS(`WIDTH__INTERNAL_MAIN_MEM_ADDR)



module __InternalMainMem(input logic clk,
	input bit [7:0] in_8_data,
	input bit [`MSB_POS__INTERNAL_MAIN_MEM_ADDR:0] in_8_addr,
	input bit in_8_we,
	input bit [15:0] in_16_data,
	input bit [`MSB_POS__INTERNAL_MAIN_MEM_ADDR:0] in_16_addr,
	input bit in_16_we,
	input bit [31:0] in_32_data,
	input bit [`MSB_POS__INTERNAL_MAIN_MEM_ADDR:0] in_32_addr,
	input bit in_32_we,

	output bit [7:0] out_8_data,
	output bit [15:0] out_16_data,
	output bit [31:0] out_32_data);

	parameter __ARR_SIZE__MAIN_MEM = 1 << 16;
	parameter __LAST_INDEX__MAIN_MEM 
		= `ARR_SIZE_TO_LAST_INDEX(__ARR_SIZE__MAIN_MEM);

	bit [7:0] __main_mem[0 : __LAST_INDEX__MAIN_MEM];


	parameter __MOD_THING = 32'hffff;

	wire [`MSB_POS__INTERNAL_MAIN_MEM_ADDR:0] __addr_16_1
		= ((in_16_addr + `WIDTH__INTERNAL_MAIN_MEM_ADDR'd1) & __MOD_THING);

	wire [`MSB_POS__INTERNAL_MAIN_MEM_ADDR:0] __addr_32_1
		= ((in_32_addr + `WIDTH__INTERNAL_MAIN_MEM_ADDR'd1) & __MOD_THING);
	wire [`MSB_POS__INTERNAL_MAIN_MEM_ADDR:0] __addr_32_2
		= ((in_32_addr + `WIDTH__INTERNAL_MAIN_MEM_ADDR'd2) & __MOD_THING);
	wire [`MSB_POS__INTERNAL_MAIN_MEM_ADDR:0] __addr_32_3
		= ((in_32_addr + `WIDTH__INTERNAL_MAIN_MEM_ADDR'd3) & __MOD_THING);


	initial
	begin
		$readmemh("main_mem.txt.ignore", __main_mem);

		////$dumpfile("test.vcd");
		////$dumpvars(0, TestBench);
	end

	always_ff @ (posedge clk)
	begin
		if (in_8_we)
		begin
			__main_mem[in_8_addr] <= in_8_data;
		end

		//else
		begin
			out_8_data <= __main_mem[in_8_addr];
		end
	end

	always_ff @ (posedge clk)
	begin
		if (in_16_we)
		begin
			{__main_mem[in_16_addr], __main_mem[__addr_16_1]}
				<= in_16_data;
		end

		//else
		begin
			out_16_data
				<= {__main_mem[in_16_addr], __main_mem[__addr_16_1]};
		end
	end

	always_ff @ (posedge clk)
	begin
		if (in_32_we)
		begin
			//$display("__InternalMainMem write:  %h, %h",
			//	in_32_addr, in_32_data);
			{__main_mem[in_32_addr], __main_mem[__addr_32_1],
				__main_mem[__addr_32_2], __main_mem[__addr_32_3]}
				<= in_32_data;
		end

		//else
		begin
			out_32_data
				<= {__main_mem[in_32_addr], __main_mem[__addr_32_1],
				__main_mem[__addr_32_2], __main_mem[__addr_32_3]};

			//$display("__InternalMainMem read:  %h, %h",
			//	in_32_addr,
			//	{__main_mem[in_32_addr], __main_mem[__addr_32_1],
			//	__main_mem[__addr_32_2], __main_mem[__addr_32_3]});
		end
	end

endmodule


module MainMem(input logic clk,
	`ifdef DEBUG_MEM_ACCESS
	input logic half_clk,
	`endif		// DEBUG_MEM_ACCESS
	input PkgMainMem::PortIn_MainMem in,
	output PkgMainMem::PortOut_MainMem out);

	import PkgFrost32Cpu::*;
	import PkgMainMem::*;

	//parameter __WIDTH_COUNTER = 3;
	//parameter __MSB_POS_COUNTER = `WIDTH_TO_MSB_POS(__WIDTH_COUNTER);
	parameter __MOD_THING = 32'hffff;
	//parameter __MOD_THING = 32'hff_ffff;

	bit [7:0] __in_8_data;
	bit [`MSB_POS__INTERNAL_MAIN_MEM_ADDR:0] __in_8_addr;
	bit __in_8_we;
	bit [15:0] __in_16_data;
	bit [`MSB_POS__INTERNAL_MAIN_MEM_ADDR:0] __in_16_addr;
	bit __in_16_we;
	bit [31:0] __in_32_data;
	bit [`MSB_POS__INTERNAL_MAIN_MEM_ADDR:0] __in_32_addr;
	bit __in_32_we;

	bit [7:0] __out_8_data;
	bit [15:0] __out_16_data;
	bit [31:0] __out_32_data;

	__InternalMainMem __inst_internal_main_mem
		(.clk(clk),
		.in_8_data(__in_8_data),
		.in_8_addr(__in_8_addr),
		.in_8_we(__in_8_we),
		.in_16_data(__in_16_data),
		.in_16_addr(__in_16_addr),
		.in_16_we(__in_16_we),
		.in_32_data(__in_32_data),
		.in_32_addr(__in_32_addr),
		.in_32_we(__in_32_we),

		.out_8_data(__out_8_data),
		.out_16_data(__out_16_data),
		.out_32_data(__out_32_data));

	assign __in_8_data = in.data[7:0];
	assign __in_16_data = in.data[15:0];
	assign __in_32_data = in.data;
	assign __in_8_addr = in.addr[15:0];
	assign __in_16_addr = in.addr[15:0];
	assign __in_32_addr = in.addr;

	always_comb
	//always_ff @ (posedge clk)
	begin
		if (in.req_mem_access)
		begin
			if (in.data_inout_access_type == PkgFrost32Cpu::DiatRead)
			begin
				__in_32_we = 0;
				__in_16_we = 0;
				__in_8_we = 0;

				if (in.data_inout_access_size == PkgFrost32Cpu::Dias32)
				begin
					out.data = __out_32_data;
				end

				else if (in.data_inout_access_size 
					== PkgFrost32Cpu::Dias16)
				begin
					out.data = __out_16_data;
				end

				else //if (in.data_inout_access_size 
					// == PkgFrost32Cpu::Dias8)
				begin
					out.data = __out_8_data;
				end
			end

			else // if (in.data_inout_access_type 
				// == PkgFrost32Cpu::DiatWrite)
			begin
				out.data = 0;

				if (in.data_inout_access_size == PkgFrost32Cpu::Dias32)
				begin
					__in_32_we = 1;
					__in_16_we = 0;
					__in_8_we = 0;
				end

				else if (in.data_inout_access_size 
					== PkgFrost32Cpu::Dias16)
				begin
					__in_32_we = 0;
					__in_16_we = 1;
					__in_8_we = 0;
				end

				else
				begin
					__in_32_we = 0;
					__in_16_we = 0;
					__in_8_we = 1;
				end
			end
		end

		else // if (!in.req_mem_access)
		begin
			__in_32_we = 0;
			__in_16_we = 0;
			__in_8_we = 0;

			out.data = 0;
		end

		out.stall = 0;
	end


endmodule
