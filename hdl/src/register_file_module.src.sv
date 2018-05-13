`include "src/register_file_defines.header.sv"

// Asynchronous reads (two ports), synchronous writes (one port)
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
		// This is synthesizeable, right?
		// If I recall correctly, you just need the for loop to have a
		// known end point.
		for (int i=0; i<__ARR_SIZE__NUM_REGISTERS; ++i)
		begin
			__regfile[i] = 0;
		end
	end

	generate
		genvar i;

		for (i=0; i<`ARR_SIZE__REG_FILE_NUM_PORTS; i = i + 1)
		begin
			always_comb
			begin
				out.read_data[i] = __regfile[in.read_sel[i]];
			end
		end
	endgenerate


	always_ff @ (posedge clk)
	begin
		if (in.write_en && (in.write_sel != 0))
		begin
			__regfile[in.write_sel] <= in.write_data;
		end
	end

endmodule
