`include "src/alu_defines.header.sv"

module Alu(input PkgAlu::PortIn_Alu in, output PkgAlu::PortOut_Alu out);

	import PkgAlu::*;

	parameter __WIDTH_INOUT = `WIDTH__ALU_INOUT;
	parameter __MSB_POS_INOUT = `MSB_POS__ALU_INOUT;

	// sltu, slts, sgtu, sgts
	PkgAlu::PortOut_Compare  __out_compare;

	Compare #(.DATA_WIDTH(__WIDTH_INOUT)) __inst_compare(.a(in.a),
		.b(in.b), .out(__out_compare));

	// Barrel shifters
	PkgAlu::PortIn_Shift __in_any_shift;
	assign __in_any_shift.data = in.a;
	assign __in_any_shift.amount = in.b;

	PkgAlu::PortOut_Shift __out_lsl32;
	PkgAlu::PortOut_Shift __out_lsr32;
	PkgAlu::PortOut_Shift __out_asr32;

	LogicalShiftLeft32 __inst_lsl32(.in(__in_any_shift),
		.out(__out_lsl32));
	LogicalShiftRight32 __inst_lsr32(.in(__in_any_shift),
		.out(__out_lsr32));
	ArithmeticShiftRight32 __inst_asr32(.in(__in_any_shift),
		.out(__out_asr32));

	always_comb
	//always @(*)
	begin
		case (in.oper)
			PkgAlu::Add:
			begin
				out.data = in.a + in.b;
			end
			PkgAlu::Sub:
			begin
				out.data = in.a - in.b;
			end
			PkgAlu::Sltu:
			begin
				//out.data = {{__MSB_POS_INOUT{1'b0}}, __out_compare.ltu};
				out.data = __out_compare.ltu;
			end
			PkgAlu::Slts:
			begin
				//out.data = {{__MSB_POS_INOUT{1'b0}}, __out_compare.lts};
				out.data = __out_compare.lts;
			end


			PkgAlu::Sgtu:
			begin
				//out.data = {{__MSB_POS_INOUT{1'b0}}, __out_compare.gtu};
				out.data = 0;
			end
			PkgAlu::Sgts:
			begin
				//out.data = {{__MSB_POS_INOUT{1'b0}}, __out_compare.gts};
				out.data = 0;
			end

			// The processor probably doesn't actually use this operation
			PkgAlu::AndN:
			begin
				//out.data = in.a & (~in.b);
				//out.data = in.a;
				out.data = 0;
			end
			PkgAlu::And:
			begin
				out.data = in.a & in.b;
			end



			PkgAlu::Or:
			begin
				out.data = in.a | in.b;
			end
			PkgAlu::Xor:
			begin
				out.data = in.a ^ in.b;
			end
			PkgAlu::Nor:
			begin
				out.data = ~(in.a | in.b);
			end
			PkgAlu::Lsl:
			begin
				//if (in.b[__MSB_POS_INOUT : 5])
				//begin
				//	out.data = {__WIDTH_INOUT{1'b0}};
				//end

				//else
				//begin
					out.data = __out_lsl32.data;
				//end
			end




			PkgAlu::Lsr:
			begin
				//if (in.b[__MSB_POS_INOUT : 5])
				//begin
				//	out.data = {__WIDTH_INOUT{1'b0}};
				//end

				//else
				//begin
					out.data = __out_lsr32.data;
				//end
			end
			PkgAlu::Asr:
			begin
				//if (in.b[__MSB_POS_INOUT : 5])
				//begin
				//	if (in.a[__MSB_POS_INOUT])
				//	begin
				//		out.data = {__WIDTH_INOUT{1'b1}};
				//	end

				//	else
				//	begin
				//		out.data = {__WIDTH_INOUT{1'b0}};
				//	end
				//end

				//else
				//begin
					out.data = __out_asr32.data;
				//end
			end

			// The processor probably doesn't actually use this operation
			PkgAlu::OrN:
			begin
				//out.data = in.a | (~in.b);
				//out.data = in.a;
				out.data = 0;
			end

			// The processor probably doesn't actually use this operation
			PkgAlu::Nand:
			begin
				//out.data = ~(in.a & in.b);
				//out.data = in.a;
				out.data = 0;
			end
			//PkgAlu::Cpyhi:
			//begin
			//	//$display("PkgAlu::Cpyhi:  %h %h",
			//	//	in.b[15:0], in.a[15:0]);
			//	//out.data = {in.b[15:0], in.a[15:0]};
			//end
		endcase
	end
endmodule
