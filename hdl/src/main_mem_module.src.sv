`include "src/misc_defines.header.sv"

`define WIDTH__TRUE_DUAL_PORT_RAM_DATA_INOUT 8
`define MSB_POS__TRUE_DUAL_PORT_RAM_DATA_INOUT \
	`WIDTH_TO_MSB_POS(`WIDTH__TRUE_DUAL_PORT_RAM_DATA_INOUT)

`define WIDTH__TRUE_DUAL_PORT_RAM_ADDR 16
`define MSB_POS__TRUE_DUAL_PORT_RAM_ADDR \
	`WIDTH_TO_MSB_POS(`WIDTH__TRUE_DUAL_PORT_RAM_ADDR)


// Synthesizeable block RAM (64 kiB), with two 8-bit read ports and two
// 8-bit write ports.
module TrueDualPortRam(input logic clk,
	input logic [`MSB_POS__TRUE_DUAL_PORT_RAM_DATA_INOUT:0] 
		in_data_a, in_data_b,
	input logic [`MSB_POS__TRUE_DUAL_PORT_RAM_ADDR:0] in_addr_a, in_addr_b,
	input logic in_we_a, in_we_b,

	output logic [`MSB_POS__TRUE_DUAL_PORT_RAM_DATA_INOUT:0] 
		out_data_a, out_data_b);

	parameter __ARR_SIZE__MAIN_MEM = 1 << 16;
	parameter __LAST_INDEX__MAIN_MEM 
		= `ARR_SIZE_TO_LAST_INDEX(__ARR_SIZE__MAIN_MEM);

	bit [`MSB_POS__TRUE_DUAL_PORT_RAM_DATA_INOUT:0] 
		__mem[0 : __LAST_INDEX__MAIN_MEM];


	//parameter __MOD_THING = 32'hffff;



	initial
	begin
		$readmemh("main_mem.txt.ignore", __mem);

		////$dumpfile("test.vcd");
		////$dumpvars(0, TestBench);

		out_data_a = 0;
		out_data_b = 0;
	end

	//always @ (posedge clk)
	//begin
	//	$display("TrueDualPortRam (port a):  %h %h", 
	//		in_addr_a, __mem[in_addr_a]);
	//	$display("TrueDualPortRam (port b):  %h %h", 
	//		in_addr_b, __mem[in_addr_b]);
	//end

	always_ff @ (posedge clk)
	begin
		if (in_we_a)
		begin
			__mem[in_addr_a] <= in_data_a;
		end

		//else
		begin
			out_data_a <= __mem[in_addr_a];
		end
	end

	always_ff @ (posedge clk)
	begin
		if (in_we_b)
		begin
			__mem[in_addr_b] <= in_data_b;
		end

		//else
		begin
			out_data_b <= __mem[in_addr_b];
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

	parameter __WIDTH_COUNTER = 3;
	//parameter __WIDTH_COUNTER = 1;
	parameter __MSB_POS_COUNTER = `WIDTH_TO_MSB_POS(__WIDTH_COUNTER);

	//parameter __ARR_SIZE__NUM_ADDRESSES = 4;
	//parameter __LAST_INDEX__NUM_ADDRESSES 
	//	= `ARR_SIZE_TO_LAST_INDEX(__ARR_SIZE__NUM_ADDRESSES);

	parameter __MOD_THING = 32'hffff;
	//parameter __MOD_THING = 32'hff_ffff;

	logic [`MSB_POS__TRUE_DUAL_PORT_RAM_DATA_INOUT:0] 
		__in_true_dual_port_ram_data_a, __in_true_dual_port_ram_data_b;
	logic [`MSB_POS__TRUE_DUAL_PORT_RAM_ADDR:0]
		__in_true_dual_port_ram_addr_a, __in_true_dual_port_ram_addr_b;
	logic __in_true_dual_port_ram_we_a, __in_true_dual_port_ram_we_b;
	logic [`MSB_POS__TRUE_DUAL_PORT_RAM_DATA_INOUT:0] 
		__out_true_dual_port_ram_data_a, __out_true_dual_port_ram_data_b;

	TrueDualPortRam __inst_true_dual_port_ram(.clk(clk),
		.in_data_a(__in_true_dual_port_ram_data_a),
		.in_data_b(__in_true_dual_port_ram_data_b),
		.in_addr_a(__in_true_dual_port_ram_addr_a),
		.in_addr_b(__in_true_dual_port_ram_addr_b),
		.in_we_a(__in_true_dual_port_ram_we_a),
		.in_we_b(__in_true_dual_port_ram_we_b),
		.out_data_a(__out_true_dual_port_ram_data_a),
		.out_data_b(__out_true_dual_port_ram_data_b));

	logic [__MSB_POS_COUNTER:0] __counter;
	logic __wait_for_mem;

	//logic [`MSB_POS__TRUE_DUAL_PORT_RAM_ADDR:0] 
	//	__addresses[0 : __LAST_INDEX__NUM_ADDRESSES];

	//assign out.wait_for_mem = (in.req_mem_access || __wait_for_mem);
	always_comb
	begin
		out.wait_for_mem = (in.req_mem_access || __wait_for_mem);
	end

	initial
	begin
		__counter = 0;


		__in_true_dual_port_ram_data_a = 0;
		__in_true_dual_port_ram_data_b = 0;
		__in_true_dual_port_ram_addr_a = 0;
		__in_true_dual_port_ram_addr_b = 0;
		__in_true_dual_port_ram_we_a = 0;
		__in_true_dual_port_ram_we_b = 0;
		//out.wait_for_mem = 0;
		__wait_for_mem = 0;
		out.data = 0;
	end


	//always_ff @ (posedge clk)
	always @ (posedge clk)
	begin
		//$display("__counter:  %h", __counter);
		if (__counter == 0)
		begin
			if (in.req_mem_access)
			begin
				//$display("in.req_mem_access == 1");
				__wait_for_mem <= 1;

				// Temporarily assume 32-bit memory access
				__counter <= 4;

				if (in.data_inout_access_type
					== PkgFrost32Cpu::DiatRead)
				begin
					__in_true_dual_port_ram_we_a <= 0;
					__in_true_dual_port_ram_we_b <= 0;

				end

				else // if (in.data_inout_access_type 
					// == PkgFrost32Cpu::DiatWrite)
				begin
					__in_true_dual_port_ram_we_a <= 1;
					__in_true_dual_port_ram_we_b <= 1;
				end
			end

			else
			begin
				__in_true_dual_port_ram_we_a <= 0;
				__in_true_dual_port_ram_we_b <= 0;
			end

		end

		else // if (__counter != 0)
		begin
			__counter <= __counter - 1;
			if (__counter == 4)
			begin
				// Two cycle delay
				__in_true_dual_port_ram_data_a <= in.data[31:24];
				__in_true_dual_port_ram_data_b <= in.data[23:16];
				__in_true_dual_port_ram_addr_a 
					= (in.addr[15:0] & __MOD_THING);
				__in_true_dual_port_ram_addr_b 
					= ((in.addr[15:0] + 16'h1) & __MOD_THING);
				//$display("__counter == 4:  %h %h",
				//	__in_true_dual_port_ram_addr_a,
				//	__in_true_dual_port_ram_addr_b);
				out.data <= 0;
			end

			else if (__counter == 3)
			begin
				__in_true_dual_port_ram_data_a <= in.data[15:8];
				__in_true_dual_port_ram_data_b <= in.data[7:0];
				__in_true_dual_port_ram_addr_a 
					= ((in.addr[15:0] + 16'h2) & __MOD_THING);
				__in_true_dual_port_ram_addr_b 
					= ((in.addr[15:0] + 16'h3) & __MOD_THING);
				//get_out_data_high();
				//$display("__counter == 3:  %h %h",
				//	__in_true_dual_port_ram_addr_a,
				//	__in_true_dual_port_ram_addr_b);
			end

			else if (__counter == 2)
			begin
				// Just disable writes now
				__in_true_dual_port_ram_we_a <= 0;
				__in_true_dual_port_ram_we_b <= 0;

				out.data[31] <= __out_true_dual_port_ram_data_a[7];
				out.data[30] <= __out_true_dual_port_ram_data_a[6];
				out.data[29] <= __out_true_dual_port_ram_data_a[5];
				out.data[28] <= __out_true_dual_port_ram_data_a[4];
				out.data[27] <= __out_true_dual_port_ram_data_a[3];
				out.data[26] <= __out_true_dual_port_ram_data_a[2];
				out.data[25] <= __out_true_dual_port_ram_data_a[1];
				out.data[24] <= __out_true_dual_port_ram_data_a[0];
				out.data[23] <= __out_true_dual_port_ram_data_b[7];
				out.data[22] <= __out_true_dual_port_ram_data_b[6];
				out.data[21] <= __out_true_dual_port_ram_data_b[5];
				out.data[20] <= __out_true_dual_port_ram_data_b[4];
				out.data[19] <= __out_true_dual_port_ram_data_b[3];
				out.data[18] <= __out_true_dual_port_ram_data_b[2];
				out.data[17] <= __out_true_dual_port_ram_data_b[1];
				out.data[16] <= __out_true_dual_port_ram_data_b[0];
			end

			else // if (__counter == 1)
			begin
				__in_true_dual_port_ram_data_a <= 0;
				__in_true_dual_port_ram_data_b <= 0;
				__in_true_dual_port_ram_addr_a <= 0;
				__in_true_dual_port_ram_addr_b <= 0;
				//get_out_data_low();
				out.data[15] <= __out_true_dual_port_ram_data_a[7];
				out.data[14] <= __out_true_dual_port_ram_data_a[6];
				out.data[13] <= __out_true_dual_port_ram_data_a[5];
				out.data[12] <= __out_true_dual_port_ram_data_a[4];
				out.data[11] <= __out_true_dual_port_ram_data_a[3];
				out.data[10] <= __out_true_dual_port_ram_data_a[2];
				out.data[9] <= __out_true_dual_port_ram_data_a[1];
				out.data[8] <= __out_true_dual_port_ram_data_a[0];
				out.data[7] <= __out_true_dual_port_ram_data_b[7];
				out.data[6] <= __out_true_dual_port_ram_data_b[6];
				out.data[5] <= __out_true_dual_port_ram_data_b[5];
				out.data[4] <= __out_true_dual_port_ram_data_b[4];
				out.data[3] <= __out_true_dual_port_ram_data_b[3];
				out.data[2] <= __out_true_dual_port_ram_data_b[2];
				out.data[1] <= __out_true_dual_port_ram_data_b[1];
				out.data[0] <= __out_true_dual_port_ram_data_b[0];
				__wait_for_mem <= 0;
			end
		end
	end

	//always_comb
	////always @ (*)
	////always @ (__counter)
	//begin
	//end


endmodule
