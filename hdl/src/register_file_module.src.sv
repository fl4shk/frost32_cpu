`include "src/register_file_defines.header.sv"

`define GEN_REG_FILE_READ(read_sel_name, read_data_name) \
	always_comb \
	begin \
		if (in.write_en && (in.write_sel == in.read_sel_name) \
			&& (in.write_sel != 0)) \
		begin \
			out.read_data_name = in.write_data; \
		end \
\
		else \
		begin \
			out.read_data_name = __regfile[in.read_sel_name]; \
		end \
	end

// Asynchronous reads (three ports), synchronous writes (one port)
module RegisterFile(input logic clk,
	input PkgRegisterFile::PortIn_RegFile in,
	output PkgRegisterFile::PortOut_RegFile out,
	output logic [`MSB_POS__REG_FILE_DATA:0] 
		out_debug_zero, 
		out_debug_u0, out_debug_u1, out_debug_u2, out_debug_u3,
		out_debug_u4, out_debug_u5, out_debug_u6, out_debug_u7,
		out_debug_u8, out_debug_u9, out_debug_u10, 
		out_debug_temp, out_debug_lr, out_debug_fp, out_debug_sp);

	import PkgRegisterFile::*;

	parameter __ARR_SIZE__NUM_REGISTERS = 16;
	parameter __LAST_INDEX__NUM_REGISTERS 
		= `ARR_SIZE_TO_LAST_INDEX(__ARR_SIZE__NUM_REGISTERS);


	logic [`MSB_POS__REG_FILE_DATA:0]
		__regfile[0 : __LAST_INDEX__NUM_REGISTERS];

	assign out_debug_zero = __regfile[0];
	assign out_debug_u0 = __regfile[1];
	assign out_debug_u1 = __regfile[2];
	assign out_debug_u2 = __regfile[3];
	assign out_debug_u3 = __regfile[4];
	assign out_debug_u4 = __regfile[5];
	assign out_debug_u5 = __regfile[6];
	assign out_debug_u6 = __regfile[7];
	assign out_debug_u7 = __regfile[8];
	assign out_debug_u8 = __regfile[9];
	assign out_debug_u9 = __regfile[10];
	assign out_debug_u10 = __regfile[11];
	assign out_debug_temp = __regfile[12];
	assign out_debug_lr = __regfile[13];
	assign out_debug_fp = __regfile[14];
	assign out_debug_sp = __regfile[15];

	initial
	begin
		for (int i=0; i<__ARR_SIZE__NUM_REGISTERS; ++i)
		begin
			__regfile[i] = 0;
		end
	end

	// Reading
	`GEN_REG_FILE_READ(read_sel_ra, read_data_ra)
	`GEN_REG_FILE_READ(read_sel_rb, read_data_rb)
	`GEN_REG_FILE_READ(read_sel_rc, read_data_rc)

	always_ff @ (posedge clk)
	begin
		if (in.write_en && (in.write_sel != 0))
		begin
			__regfile[in.write_sel] <= in.write_data;
		end

		////$display("RegisterFile:  inputs:  %h %h %h", 
		////	in.write_en, in.write_sel, in.write_data);
		//$display("RegisterFile (0 to 3):  %h %h %h %h",
		//	__regfile[0], __regfile[1], __regfile[2], __regfile[3]);
		//$display("RegisterFile (4 to 7):  %h %h %h %h",
		//	__regfile[4], __regfile[5], __regfile[6], __regfile[7]);
		////$display("RegisterFile (8 to 11):  %h %h %h %h",
		////	__regfile[8], __regfile[9], __regfile[10], __regfile[11]);
		////$display("RegisterFile (12 to 15):  %h %h %h %h",
		////	__regfile[12], __regfile[13], __regfile[14], __regfile[15]);

		//$display();
	end

	//always @ (posedge clk)
	//begin
	//end
endmodule
