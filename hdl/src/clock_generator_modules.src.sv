`include "src/misc_defines.header.sv"

module MainClockGenerator(output logic clk);

	initial
	begin
		clk = 1'b0;
	end

	always
	begin
		#1
		clk = !clk;
	end

endmodule

module HalfClockGenerator(output logic clk);
	initial
	begin
		clk = 1'b0;
	end

	always
	begin
		#2
		clk = !clk;
	end
endmodule
