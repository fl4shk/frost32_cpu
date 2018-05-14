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
			//__regfile[i] = i;
		end
	end

	generate
		genvar i;

		for (i=0; i<`WIDTH__REG_FILE_NUM_PORTS; i=i+1)
		begin : __generate_reg_file_read
			always_comb
			begin
				if (in.write_en && (in.write_sel == in.read_sel[i])
					&& (in.write_sel != 0))
				begin
					out.read_data[i] = in.write_data;
				end

				else
				begin
					out.read_data[i] = __regfile[in.read_sel[i]];
				end

				//out.read_data[i] = __regfile[in.read_sel[i]];
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
