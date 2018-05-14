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
	output PkgRegisterFile::PortOut_RegFile out);

	import PkgRegisterFile::*;

	parameter __ARR_SIZE__NUM_REGISTERS = 16;
	parameter __LAST_INDEX__NUM_REGISTERS 
		= `ARR_SIZE_TO_LAST_INDEX(__ARR_SIZE__NUM_REGISTERS);


	logic [`MSB_POS__REG_FILE_DATA:0]
		__regfile[0 : __LAST_INDEX__NUM_REGISTERS];

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
	end
endmodule
