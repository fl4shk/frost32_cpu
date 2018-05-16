`include "src/misc_defines.header.sv"

// Just a block RAM (64 kiB)
module MainMem(input logic clk, 
	`ifdef DEBUG_MEM_ACCESS
	input logic half_clk,
	`endif		// DEBUG_MEM_ACCESS
	input PkgMainMem::PortIn_MainMem in,
	output PkgMainMem::PortOut_MainMem out);

	import PkgFrost32Cpu::*;
	import PkgMainMem::*;

	parameter __ARR_SIZE__MAIN_MEM = 1 << 16;
	//parameter __ARR_SIZE__MAIN_MEM = 1 << 24;
	parameter __LAST_INDEX__MAIN_MEM 
		= `ARR_SIZE_TO_LAST_INDEX(__ARR_SIZE__MAIN_MEM);

	bit [7:0] __main_mem[0 : __LAST_INDEX__MAIN_MEM];

	initial
	begin
		$readmemh("main_mem.txt.ignore", __main_mem);

		////$dumpfile("test.vcd");
		////$dumpvars(0, TestBench);
	end


	logic [31:0] __addr_0, __addr_1, __addr_2, __addr_3;

	parameter __MOD_THING = 32'hffff;
	//parameter __MOD_THING = 32'hff_ffff;

	assign __addr_0 = (in.addr & __MOD_THING);
	assign __addr_1 = ((in.addr + 1) & __MOD_THING);
	assign __addr_2 = ((in.addr + 2) & __MOD_THING);
	assign __addr_3 = ((in.addr + 3) & __MOD_THING);


	`ifdef DEBUG_MEM_ACCESS
	//always_ff @ (posedge clk)
	always_ff @ (posedge half_clk)
	begin
		if (in.req_mem_access 
			&& (in.data_inout_access_type
			== PkgFrost32Cpu::DiatRead))
		begin
			if (in.data_inout_access_size
				== PkgFrost32Cpu::Dias32)
			begin
				$display("Reading %h from address %h",
					{__main_mem[__addr_0], __main_mem[__addr_1],
					__main_mem[__addr_2], __main_mem[__addr_3]}, __addr_0);
			end

			else if (in.data_inout_access_size
				== PkgFrost32Cpu::Dias16)
			begin
				$display("Reading %h from address %h",
					{__main_mem[__addr_0], __main_mem[__addr_1]},
					__addr_0);
			end

			else
			begin
				$display("Reading %h from address %h",
					__main_mem[__addr_0], __addr_0);
			end
		end

		else if (in.req_mem_access
			&& (in.data_inout_access_type
			== PkgFrost32Cpu::DiatWrite))
		begin
			if (in.data_inout_access_size
				== PkgFrost32Cpu::Dias32)
			begin
				$display("Writing %h to address %h",
					in.data, __addr_0);
			end

			else if (in.data_inout_access_size
				== PkgFrost32Cpu::Dias16)
			begin
				$display("Writing %h to address %h",
					in.data[15:0], __addr_0);
			end

			else
			begin
				$display("Writing %h to address %h",
					in.data[7:0], __addr_0);
			end
		end
	end
	`endif

	always_ff @ (posedge clk)
	begin
		if (in.req_mem_access 
			&& (in.data_inout_access_type == PkgFrost32Cpu::DiatRead))
		begin
			if (in.data_inout_access_size == PkgFrost32Cpu::Dias32)
			begin
				out.data <= {__main_mem[__addr_0], __main_mem[__addr_1],
					__main_mem[__addr_2], __main_mem[__addr_3]};
			end

			else if (in.data_inout_access_size == PkgFrost32Cpu::Dias16)
			begin
				out.data <= {__main_mem[__addr_0], __main_mem[__addr_1]};
			end

			else
			begin
				out.data <= __main_mem[__addr_0];
			end
		end

		else if (in.req_mem_access
			&& (in.data_inout_access_type == PkgFrost32Cpu::DiatWrite))
		begin
			if (in.data_inout_access_size == PkgFrost32Cpu::Dias32)
			begin
				{__main_mem[__addr_0], __main_mem[__addr_1],
				__main_mem[__addr_2], __main_mem[__addr_3]} <= in.data;
			end

			else if (in.data_inout_access_size == PkgFrost32Cpu::Dias16)
			begin
				{__main_mem[__addr_0], __main_mem[__addr_1]}
					<= in.data[15:0];
			end

			else
			begin
				__main_mem[__addr_0] <= in.data[7:0];
			end
		end
	end


endmodule

