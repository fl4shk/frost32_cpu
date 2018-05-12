`include "src/misc_defines.header.sv"

module Mux2To1(input logic a, b, sel,
	output logic out);

	always_comb
	begin
		out = (!sel) ? a : b;
	end

endmodule

module TopLevel;

	// Stuffs!
endmodule
