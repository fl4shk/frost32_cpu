`include "src/alu_defines.header.sv"

module Adder #(parameter DATA_WIDTH=32)
	(input logic [`WIDTH_TO_MSB_POS(DATA_WIDTH) : 0] a, b,
	output logic [`WIDTH_TO_MSB_POS(DATA_WIDTH) : 0] out);

	always_comb
	begin
		out = a + b;
	end
endmodule

module Subtractor #(parameter DATA_WIDTH=32)
	(input logic [`WIDTH_TO_MSB_POS(DATA_WIDTH) : 0] a, b, 
	output logic [`WIDTH_TO_MSB_POS(DATA_WIDTH) : 0] out);

	always_comb
	begin
		out = a - b;
	end
endmodule

module Compare #(parameter DATA_WIDTH=32)
	(input logic[`WIDTH_TO_MSB_POS(DATA_WIDTH) : 0] a, b,
	output PkgAlu::PortOut_Compare out);

	import PkgAlu::*;

	parameter __DATA_MSB_POS = `WIDTH_TO_MSB_POS(DATA_WIDTH);
	logic [__DATA_MSB_POS:0] __temp = 0;

	always_comb
	begin
		{out.ltu, __temp} = a + (~b) + {{__DATA_MSB_POS{1'b0}}, 1'b1};
		out.lts = (__temp[__DATA_MSB_POS] 
			^ ((a[__DATA_MSB_POS] ^ b[__DATA_MSB_POS]) 
			& (a[__DATA_MSB_POS] ^ __temp[__DATA_MSB_POS])));

		// (greater than or equal) and (not equal to zero)

		//out.gtu = ((!out.ltu) && (!__temp));
		//out.gts = ((!out.lts) && (!__temp));
		//out.gtu = a > b;
		//out.gts = $signed(a) > $signed(b);

		//$display("Compare:  %h %h\t\t%h\t\t%h %h\t\t%h %h\t\t%h %h %h",
		//	a, b, __temp, out.ltu, out.lts, out.gtu, out.gts,
		//	!out.ltu, !out.lts, !__temp);

		//if (out.ltu || (a == b))
		//begin
		//	out.gtu = 0;
		//end

		//else
		//begin
		//	out.gtu = 1;
		//end

		//if (out.lts || (a == b))
		//begin
		//	out.gts = 0;
		//end

		//else
		//begin
		//	out.gts = 1;
		//end
		out.gtu = 0;
		out.gts = 0;
	end
endmodule

// Barrel shifters
module LogicalShiftLeft32(input PkgAlu::PortIn_Shift in, 
	output PkgAlu::PortOut_Shift out);

	import PkgAlu::*;

	PkgAlu::PortOut_Shift __temp[0 : `ARR_SIZE_TO_LAST_INDEX(4)];

	always_comb
	begin
		__temp[0] = in.amount[0] 
			? {in.data[`MSB_POS__ALU_INOUT - 1:0], {1{1'b0}}}
			: in.data;
		__temp[1] = in.amount[1] 
			? {__temp[0][`MSB_POS__ALU_INOUT - 2:0], {2{1'b0}}}
			: __temp[0];
		__temp[2] = in.amount[2] 
			? {__temp[1][`MSB_POS__ALU_INOUT - 4:0], {4{1'b0}}}
			: __temp[1];
		__temp[3] = in.amount[3] 
			? {__temp[2][`MSB_POS__ALU_INOUT - 8:0], {8{1'b0}}}
			: __temp[2];
		out.data = in.amount[4] 
			? {__temp[3][`MSB_POS__ALU_INOUT - 16:0], {16{1'b0}}}
			: __temp[3];
	end
endmodule

module LogicalShiftRight32(input PkgAlu::PortIn_Shift in,
	output PkgAlu::PortOut_Shift out);

	import PkgAlu::*;

	PkgAlu::PortOut_Shift __temp[0 : `ARR_SIZE_TO_LAST_INDEX(4)];

	always_comb
	begin
		__temp[0] = in.amount[0] 
			? {{1{1'b0}}, in.data[`MSB_POS__ALU_INOUT:1]} : in.data;
		__temp[1] = in.amount[1] 
			? {{2{1'b0}}, __temp[0][`MSB_POS__ALU_INOUT:2]} : __temp[0];
		__temp[2] = in.amount[2] 
			? {{4{1'b0}}, __temp[1][`MSB_POS__ALU_INOUT:4]} : __temp[1];
		__temp[3] = in.amount[3] 
			? {{8{1'b0}}, __temp[2][`MSB_POS__ALU_INOUT:8]} : __temp[2];
		out.data = in.amount[4] 
			? {{16{1'b0}}, __temp[3][`MSB_POS__ALU_INOUT:16]} : __temp[3];
	end
endmodule

module ArithmeticShiftRight32(input PkgAlu::PortIn_Shift in,
	output PkgAlu::PortOut_Shift out);

	import PkgAlu::*;

	PkgAlu::PortOut_Shift __temp[0 : `ARR_SIZE_TO_LAST_INDEX(4)];

	always_comb
	begin
		if (!in.data[31])
		begin
			__temp[0] = in.amount[0] 
				? {{1{1'd0}}, in.data[`MSB_POS__ALU_INOUT:1]}
				: in.data;
			__temp[1] = in.amount[1] 
				? {{2{1'd0}}, __temp[0][`MSB_POS__ALU_INOUT:2]}
				: __temp[0];
			__temp[2] = in.amount[2] 
				? {{4{1'd0}}, __temp[1][`MSB_POS__ALU_INOUT:4]}
				: __temp[1];
			__temp[3] = in.amount[3] 
				? {{8{1'd0}}, __temp[2][`MSB_POS__ALU_INOUT:8]}
				: __temp[2];
			out.data = in.amount[4] 
				? {{16{1'd0}}, __temp[3][`MSB_POS__ALU_INOUT:16]}
				: __temp[3];
		end

		else // if (in.data[31])
		begin
			__temp[0] = in.amount[0] 
				? {{1{1'b1}}, in.data[`MSB_POS__ALU_INOUT:1]} 
				: in.data;
			__temp[1] = in.amount[1] 
				? {{2{1'b1}}, __temp[0][`MSB_POS__ALU_INOUT:2]} 
				: __temp[0];
			__temp[2] = in.amount[2] 
				? {{4{1'b1}}, __temp[1][`MSB_POS__ALU_INOUT:4]} 
				: __temp[1];
			__temp[3] = in.amount[3] 
				? {{8{1'b1}}, __temp[2][`MSB_POS__ALU_INOUT:8]} 
				: __temp[2];
			out.data = in.amount[4] 
				? {{16{1'b1}}, __temp[3][`MSB_POS__ALU_INOUT:16]} 
				: __temp[3];
		end
	end

endmodule
