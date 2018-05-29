`include "src/alu_defines.header.sv"

//module Adder #(parameter DATA_WIDTH=32)
//	(input logic [`WIDTH_TO_MSB_POS(DATA_WIDTH) : 0] a, b,
//	output logic [`WIDTH_TO_MSB_POS(DATA_WIDTH) : 0] out);
//
//	always_comb
//	begin
//		out = a + b;
//	end
//endmodule
//
//module Subtractor #(parameter DATA_WIDTH=32)
//	(input logic [`WIDTH_TO_MSB_POS(DATA_WIDTH) : 0] a, b, 
//	output logic [`WIDTH_TO_MSB_POS(DATA_WIDTH) : 0] out);
//
//	always_comb
//	begin
//		out = a - b;
//	end
//endmodule

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
		//out.gtu = !(out.ltu || (a == b));
		//out.gts = !(out.lts || (a == b));


		//out.gtu = 0;
		//out.gts = 0;
	end
endmodule

//// Barrel shifters
//module LogicalShiftLeft32(input PkgAlu::PortIn_Shift in, 
//	output PkgAlu::PortOut_Shift out);
//
//	import PkgAlu::*;
//
//	PkgAlu::PortOut_Shift __temp[0 : `ARR_SIZE_TO_LAST_INDEX(4)];
//
//	always_comb
//	begin
//		__temp[0] = in.amount[0] 
//			? {in.data[`MSB_POS__ALU_INOUT - 1:0], {1{1'b0}}}
//			: in.data;
//		__temp[1] = in.amount[1] 
//			? {__temp[0][`MSB_POS__ALU_INOUT - 2:0], {2{1'b0}}}
//			: __temp[0];
//		__temp[2] = in.amount[2] 
//			? {__temp[1][`MSB_POS__ALU_INOUT - 4:0], {4{1'b0}}}
//			: __temp[1];
//		__temp[3] = in.amount[3] 
//			? {__temp[2][`MSB_POS__ALU_INOUT - 8:0], {8{1'b0}}}
//			: __temp[2];
//		out.data = in.amount[4] 
//			? {__temp[3][`MSB_POS__ALU_INOUT - 16:0], {16{1'b0}}}
//			: __temp[3];
//	end
//endmodule
//
//module LogicalShiftRight32(input PkgAlu::PortIn_Shift in,
//	output PkgAlu::PortOut_Shift out);
//
//	import PkgAlu::*;
//
//	PkgAlu::PortOut_Shift __temp[0 : `ARR_SIZE_TO_LAST_INDEX(4)];
//
//	always_comb
//	begin
//		__temp[0] = in.amount[0] 
//			? {{1{1'b0}}, in.data[`MSB_POS__ALU_INOUT:1]} : in.data;
//		__temp[1] = in.amount[1] 
//			? {{2{1'b0}}, __temp[0][`MSB_POS__ALU_INOUT:2]} : __temp[0];
//		__temp[2] = in.amount[2] 
//			? {{4{1'b0}}, __temp[1][`MSB_POS__ALU_INOUT:4]} : __temp[1];
//		__temp[3] = in.amount[3] 
//			? {{8{1'b0}}, __temp[2][`MSB_POS__ALU_INOUT:8]} : __temp[2];
//		out.data = in.amount[4] 
//			? {{16{1'b0}}, __temp[3][`MSB_POS__ALU_INOUT:16]} : __temp[3];
//	end
//endmodule
//
//module ArithmeticShiftRight32(input PkgAlu::PortIn_Shift in,
//	output PkgAlu::PortOut_Shift out);
//
//	import PkgAlu::*;
//
//	PkgAlu::PortOut_Shift __temp[0 : `ARR_SIZE_TO_LAST_INDEX(4)];
//
//	always_comb
//	begin
//		if (!in.data[31])
//		begin
//			__temp[0] = in.amount[0] 
//				? {{1{1'd0}}, in.data[`MSB_POS__ALU_INOUT:1]}
//				: in.data;
//			__temp[1] = in.amount[1] 
//				? {{2{1'd0}}, __temp[0][`MSB_POS__ALU_INOUT:2]}
//				: __temp[0];
//			__temp[2] = in.amount[2] 
//				? {{4{1'd0}}, __temp[1][`MSB_POS__ALU_INOUT:4]}
//				: __temp[1];
//			__temp[3] = in.amount[3] 
//				? {{8{1'd0}}, __temp[2][`MSB_POS__ALU_INOUT:8]}
//				: __temp[2];
//			out.data = in.amount[4] 
//				? {{16{1'd0}}, __temp[3][`MSB_POS__ALU_INOUT:16]}
//				: __temp[3];
//		end
//
//		else // if (in.data[31])
//		begin
//			__temp[0] = in.amount[0] 
//				? {{1{1'b1}}, in.data[`MSB_POS__ALU_INOUT:1]} 
//				: in.data;
//			__temp[1] = in.amount[1] 
//				? {{2{1'b1}}, __temp[0][`MSB_POS__ALU_INOUT:2]} 
//				: __temp[0];
//			__temp[2] = in.amount[2] 
//				? {{4{1'b1}}, __temp[1][`MSB_POS__ALU_INOUT:4]} 
//				: __temp[1];
//			__temp[3] = in.amount[3] 
//				? {{8{1'b1}}, __temp[2][`MSB_POS__ALU_INOUT:8]} 
//				: __temp[2];
//			out.data = in.amount[4] 
//				? {{16{1'b1}}, __temp[3][`MSB_POS__ALU_INOUT:16]} 
//				: __temp[3];
//		end
//	end
//
//endmodule

// This is not a generic module because the algorithm used here is specific
// to the operand sizes.  
// 
// On the plus side, this lets me use packed structs for the module ports,
// which is the main way of having short code for module interfaces given
// Icarus Verilog's SystemVerilog support.
// 
// This is because, unfortunately, Icarus Verilog does not (as of writing
// this comment) really support SystemVerilog interfaces in any useful way.
// Thus I've had to make do with packed structs for my module ports, as
// I've done throughout this project.
// 
// It works fine for the most part, at least unless I'm working on modules
// with generic sizes.
// 
// Interfaces in SystemVerilog really are the right answer for module
// ports, so I look forward to being able to use them in Icarus Verilog.
module Multiplier32(input logic clk,
	input PkgAlu::PortIn_Multiplier32 in,
	output PkgAlu::PortOut_Multiplier32 out);

	localparam __STATE_MSB_POS = 0;
	localparam __STATE_START = 1;

	struct packed
	{
		logic [__STATE_MSB_POS:0] state;

		logic [`MSB_POS__MUL32_INOUT:0] x, y;

		logic [`MSB_POS__MUL32_INOUT:0] 
			partial_result_x0_y0,
			partial_result_x1_y0,
			partial_result_x0_y1;

		logic busy;
	} __locals;

	always_comb
	begin
		__locals.busy = !out.can_accept_cmd;
	end

	initial
	begin
		__locals.state = 0;

		out.can_accept_cmd = 1;
		out.data_ready = 0;
	end

	always_ff @ (posedge clk)
	begin
		if (in.enable && out.can_accept_cmd)
		begin
			__locals.x <= in.x;
			__locals.y <= in.y;

			out.can_accept_cmd <= 0;
			out.data_ready <= 0;

			__locals.state <= __STATE_START;
		end

		else if (__locals.busy)
		begin
			__locals.state <= __locals.state - 1;

			// Simple little state machine
			case (__locals.state)
				1:
				begin
					// These multiplies can be done in parallel.
					__locals.partial_result_x0_y0 
						<= __locals.x[15:0] * __locals.y[15:0];
					__locals.partial_result_x0_y1 
						<= __locals.x[15:0] * __locals.y[31:16];
					__locals.partial_result_x1_y0 
						<= __locals.x[31:16] * __locals.y[15:0];
				end

				0:
				begin
					out.prod <= {(__locals.partial_result_x1_y0
						+ __locals.partial_result_x0_y1), 16'h0000}
						+ __locals.partial_result_x0_y0;
					out.can_accept_cmd <= 1;
					out.data_ready <= 1;
				end
			endcase
		end
	end



endmodule

// Unsigned (and signed!) integer division
// Don't try to do larger than a 128-logic division with this without
// changing counter_msb_pos.

// Depending on the FPGA being used and the clock rate, it may be doable to
// perform more than one iterate() per cycle, obtaining faster divisions.

// For obvious reasons, this does not return a correct result upon division
// by zero.
//module LongDivider #(parameter ARGS_WIDTH=32,
//	parameter NUM_ITERATIONS_PER_CYCLE=1)
//	(input wire clk, in_enable, in_unsgn_or_sgn,
//	// Numerator, Denominator
//	input logic [`WIDTH_TO_MSB_POS(ARGS_WIDTH):0] in_num, in_denom,
//
//	// Quotient, Remainder
//	output logic [`WIDTH_TO_MSB_POS(ARGS_WIDTH):0] out_quot, out_rem,
//
//	output logic out_can_accept_cmd, out_data_ready);
//
//
//	parameter ARGS_MSB_POS = `WIDTH_TO_MSB_POS(ARGS_WIDTH);
//
//
//	//// This assumes you aren't trying to do division of numbers larger than
//	//// 128-bit.
//	parameter __COUNTER_MSB_POS = (ARGS_WIDTH << 1) - 1;
//	parameter __COUNTER_MSB_POS 
//		= (ARGS_WIDTH <= 32) ? 5 : ((ARGS_WIDTH <= 64) ? 6 : 7);
//
//
//
//	wire __num_is_negative, __denom_is_negative;
//	logic __num_was_negative, __denom_was_negative;
//	logic __unsgn_or_sgn_buf;
//
//
//
//	logic [__COUNTER_MSB_POS:0] __counter, __state_counter;
//
//	logic [ARGS_MSB_POS:0] __num_buf, __denom_buf;
//	logic [ARGS_MSB_POS:0] __quot_buf, __rem_buf;
//
//
//	wire __busy;
//
//
//
//	// Tasks
//
//	task iterate;
//		//__rem_buf = __rem_buf << 1;
//		//__rem_buf[0] = __num_buf[__counter];
//		__rem_buf = {__rem_buf[ARGS_MSB_POS - 1:0], __num_buf[__counter]};
//
//		if (__rem_buf >= __denom_buf)
//		begin
//			__rem_buf = __rem_buf - __denom_buf;
//			__quot_buf[__counter] = 1;
//		end
//
//		__counter = __counter - 1;
//	endtask
//
//
//
//	// Assignments
//	assign __num_is_negative = $signed(in_num) < $signed(0);
//	assign __denom_is_negative = $signed(in_denom) < $signed(0);
//	assign __busy = !out_can_accept_cmd;
//
//
//
//	initial
//	begin
//		__counter = 0;
//		__state_counter = 0;
//
//		out_quot = 0;
//		out_rem = 0;
//
//		out_can_accept_cmd = 1;
//		out_data_ready = 0;
//
//		__num_was_negative = 0;
//		__denom_was_negative = 0;
//	end
//
//
//	always @ (posedge clk)
//	begin
//		if (__state_counter[__COUNTER_MSB_POS])
//		begin
//			__quot_buf = 0;
//			__rem_buf = 0;
//
//			__counter = ARGS_MSB_POS;
//		end
//
//		else if (__busy)
//		begin
//			if ($signed(__counter) > $signed(-1))
//			begin
//				// At some clock rates, some FPGAs may be able to handle
//				// more than one iteration per clock cycle, which is why
//				// iterate() is a task.  Feel free to try more than one
//				// iteration per clock cycle.
//
//				for (int i=0; i<NUM_ITERATIONS_PER_CYCLE; i=i+1)
//				begin
//					iterate();
//				end
//			end
//		end
//
//	end
//
//
//	always @ (posedge clk)
//	begin
//		$display("LongDivider stuff:  %h\t\t%h / %h\t\t%h %h", 
//			in_unsgn_or_sgn, in_num, in_denom, out_quot, out_rem); 
//		if (in_enable && out_can_accept_cmd)
//		begin
//			$display("LongDivider starting:  %h\t\t%h / %h\t\t%h %h", 
//				in_unsgn_or_sgn, in_num, in_denom, out_quot, out_rem); 
//			out_can_accept_cmd <= 0;
//			out_data_ready <= 0;
//			__state_counter <= -1;
//
//			__unsgn_or_sgn_buf <= in_unsgn_or_sgn;
//			__num_buf <= (in_unsgn_or_sgn && __num_is_negative)
//				? (-in_num) : in_num;
//			__denom_buf <= (in_unsgn_or_sgn && __denom_is_negative)
//				? (-in_denom) : in_denom;
//
//			__num_was_negative <= __num_is_negative;
//			__denom_was_negative <= __denom_is_negative;
//		end
//
//		else if (__busy)
//		begin
//			$display("LongDivider busy:  %h\t\t%h / %h\t\t%h %h", 
//				in_unsgn_or_sgn, in_num, in_denom, out_quot, out_rem); 
//			if (!__counter[__COUNTER_MSB_POS])
//			begin
//				__state_counter <= __state_counter + 1;
//			end
//
//			else
//			begin
//				out_can_accept_cmd <= 1;
//				__state_counter <= -1;
//				out_data_ready <= 1;
//
//				out_quot <= (__unsgn_or_sgn_buf
//					&& (__num_was_negative ^ __denom_was_negative))
//					? (-__quot_buf) : __quot_buf;
//				out_rem <= (__unsgn_or_sgn_buf && __num_was_negative)
//					? (-__rem_buf) : __rem_buf;
//			end
//		end
//	end
//
//
//endmodule

//module RestoringDivider # (parameter ARGS_WIDTH=32)
//	(input logic clk, in_enable, in_unsgn_or_sgn,
//
//	// Numerator, Denominator
//	input logic [`WIDTH_TO_MSB_POS(ARGS_WIDTH):0] in_num, in_denom,
//
//	// Quotient, Remainder
//	output logic [`WIDTH_TO_MSB_POS(ARGS_WIDTH):0] out_quot, out_rem,
//
//	output logic out_can_accept_cmd, out_data_ready);
//
//	localparam __ARGS_MSB_POS = `WIDTH_TO_MSB_POS(ARGS_WIDTH);
//
//
//	localparam TEMP_WIDTH = (ARGS_WIDTH << 1) + 1;
//
//	localparam __TEMP_MSB_POS = `WIDTH_TO_MSB_POS(TEMP_WIDTH);
//
//
//	// This assumes you aren't trying to do division of numbers larger than
//	// 128-bit.
//	localparam __COUNTER_MSB_POS = 7;
//
//
//
//
//	bit [__COUNTER_MSB_POS:0] __counter, __state_counter;
//
//	bit [__ARGS_MSB_POS:0] __num_buf, __denom_buf;
//	bit [__ARGS_MSB_POS:0] __quot_buf, __rem_buf;
//
//
//	wire __busy;
//	//wire __num_is_negative, __denom_is_negative;
//	//bit __num_was_negative, __denom_was_negative;
//	//bit __unsgn_or_sgn_buf;
//
//
//
//	// Temporaries
//	bit [__TEMP_MSB_POS:0] __P;
//	bit [__TEMP_MSB_POS:0] __D;
//
//
//
//	// Tasks
//	task iterate;
//		input [__COUNTER_MSB_POS:0] i;
//
//		__P = (__P << 1) - __D;
//		if (!__P[__TEMP_MSB_POS] || (__P == 0))
//		begin
//			__quot_buf[i] = 1;
//			//__P = (__P << 1) - __D;
//		end
//
//		else
//		begin
//			//__quot_buf[i] = 0;
//			//__P = (__P << 1) + __D;
//			__P = __P + __D;
//		end
//
//		//__counter = __counter - 1;
//	endtask
//
//
//
//	// Assignments
//	assign __busy = !out_can_accept_cmd;
//
//	//assign __num_is_negative = $signed(in_num) < $signed(0);
//	//assign __denom_is_negative = $signed(in_denom) < $signed(0);
//
//
//
//	initial
//	begin
//		__counter = 0;
//		__state_counter = 0;
//		__P = 0;
//		__D = 0;
//
//		__state_counter = 0;
//
//		out_quot = 0;
//		//out_rem = 0;
//
//		out_can_accept_cmd = 1;
//		out_data_ready = 0;
//	end
//
//
//	always @ (posedge clk)
//	begin
//		if (__state_counter[__COUNTER_MSB_POS])
//		begin
//			__quot_buf = 0;
//			__rem_buf = 0;
//
//			__counter = __ARGS_MSB_POS;
//
//
//			__P = __num_buf;
//			__D = __denom_buf << ARGS_WIDTH;
//		end
//
//		else if (__busy)
//		begin
//			//if (!__state_counter[__COUNTER_MSB_POS])
//			//if ($signed(__counter) > $signed(-1))
//			//if (!__counter[__COUNTER_MSB_POS])
//			begin
//				// At some clock rates, some FPGAs may be able to handle
//				// more than one iteration per clock cycle, which is why
//				// iterate() is a task.  Feel free to try more than one
//				// iteration per clock cycle.
//
//
//				//if (NUM_ITERATIONS_PER_CYCLE > 1)
//				//begin
//				//	for (int i=0; i<NUM_ITERATIONS_PER_CYCLE; i=i+1)
//				//	begin
//				//		iterate();
//				//	end
//				//end
//
//				//else
//				//begin
//				//	iterate();
//				//end
//
//				//case (NUM_ITERATIONS_PER_CYCLE)
//				//	1:
//				//	begin
//				//		iterate();
//				//	end
//
//				//	2:
//				//	begin
//				//		iterate();
//				//		iterate();
//				//	end
//
//				//	4:
//				//	begin
//				//		iterate();
//				//		iterate();
//				//		iterate();
//				//		iterate();
//				//	end
//
//				//	default:
//				//	begin
//				//		for (int i=0; i<NUM_ITERATIONS_PER_CYCLE; i=i+1)
//				//		begin
//				//			iterate();
//				//		end
//				//	end
//				//endcase
//				`ifdef OPT_VERY_FAST_DIV
//				iterate(__counter);
//				iterate(__counter - 1);
//				iterate(__counter - 2);
//				iterate(__counter - 3);
//				__counter = __counter - 4;
//				`else
//				`ifdef OPT_FAST_DIV
//				iterate(__counter);
//				iterate(__counter - 1);
//				__counter = __counter - 2;
//				`else
//				iterate(__counter);
//				__counter = __counter - 1;
//				`endif		// OPT_FAST_DIV
//				`endif		// OPT_VERY_FAST_DIV
//			end
//		end
//
//	end
//
//
//	always @ (posedge clk)
//	begin
//		if (in_enable && out_can_accept_cmd)
//		begin
//			out_can_accept_cmd <= 0;
//			out_data_ready <= 0;
//			__state_counter <= -1;
//
//			__num_buf <= in_num;
//			__denom_buf <= in_denom;
//
//			//__num_buf <= (in_unsgn_or_sgn && __num_is_negative)
//			//	? (-in_num) : in_num;
//			//__denom_buf <= (in_unsgn_or_sgn && __denom_is_negative)
//			//	? (-in_denom) : in_denom;
//
//			//__unsgn_or_sgn_buf <= in_unsgn_or_sgn;
//
//			//__num_was_negative <= __num_is_negative;
//			//__denom_was_negative <= __denom_is_negative;
//		end
//
//		else if (__busy)
//		begin
//			if (!__counter[__COUNTER_MSB_POS])
//			begin
//				__state_counter <= __state_counter + 1;
//			end
//
//			else
//			begin
//				out_can_accept_cmd <= 1;
//				__state_counter <= -1;
//				out_data_ready <= 1;
//				out_quot <= __quot_buf;
//
//				////$display("end:  %d, %d %d, %d",
//				////	__unsgn_or_sgn_buf, 
//				////	__num_was_negative, __denom_was_negative,
//				////	(__num_was_negative ^ __denom_was_negative));
//				//if (__P[__TEMP_MSB_POS])
//				//begin
//				//	//out_quot <= (__unsgn_or_sgn_buf 
//				//	//	&& (__num_was_negative  ^ __denom_was_negative))
//				//	//	?  (-((__quot_buf - (~__quot_buf)) - 1))
//				//	//	: ((__quot_buf - (~__quot_buf)) - 1);
//				//	out_quot <= __quot_buf;
//				//	out_rem <= (__unsgn_or_sgn_buf && __num_was_negative)
//				//		? (-((__P + __D) >> ARGS_WIDTH))
//				//		: ((__P + __D) >> ARGS_WIDTH);
//				//end
//
//				//else
//				//begin
//				//	//out_quot <= (__unsgn_or_sgn_buf
//				//	//	&& (__num_was_negative ^ __denom_was_negative))
//				//	//	? (-((__quot_buf - (~__quot_buf))))
//				//	//	: ((__quot_buf - (~__quot_buf)));
//				//	out_quot <= __quot_buf;
//				//	out_rem <= (__unsgn_or_sgn_buf && __num_was_negative)
//				//		? (-((__P) >> ARGS_WIDTH))
//				//		: ((__P) >> ARGS_WIDTH);
//				//end
//			end
//		end
//
//		else
//		begin
//			$display("out_quot, out_rem:  %h, %h", out_quot, out_rem);
//		end
//	end
//
//
//endmodule

//module NonRestoringDivider #(parameter ARGS_WIDTH=32, 
//	parameter NUM_ITERATIONS_PER_CYCLE=1)
module NonRestoringDivider #(parameter ARGS_WIDTH=32)
	(input logic clk, in_enable, in_unsgn_or_sgn,
	// Numerator, Denominator
	input logic [`WIDTH_TO_MSB_POS(ARGS_WIDTH):0] in_num, in_denom,

	// Quotient, Remainder
	output logic [`WIDTH_TO_MSB_POS(ARGS_WIDTH):0] out_quot, out_rem,

	output logic out_can_accept_cmd, out_data_ready);

	localparam __ARGS_MSB_POS = `WIDTH_TO_MSB_POS(ARGS_WIDTH);


	localparam TEMP_WIDTH = (ARGS_WIDTH << 1) + 1;

	localparam __TEMP_MSB_POS = `WIDTH_TO_MSB_POS(TEMP_WIDTH);


	// This assumes you aren't trying to do division of numbers larger than
	// 128-bit.
	localparam __COUNTER_MSB_POS = 7;




	bit [__COUNTER_MSB_POS:0] __counter, __state_counter;

	bit [__ARGS_MSB_POS:0] __num_buf, __denom_buf;
	bit [__ARGS_MSB_POS:0] __quot_buf, __rem_buf;


	wire __busy;
	//wire __num_is_negative, __denom_is_negative;
	bit __num_was_negative, __denom_was_negative;
	bit __unsgn_or_sgn_buf;

	bit __start_state;



	// Temporaries
	bit [__TEMP_MSB_POS:0] __P;
	bit [__TEMP_MSB_POS:0] __D;



	// Tasks
	task iterate;
		input [__COUNTER_MSB_POS:0] i;

		// if (__P >= 0)
		if (!__P[__TEMP_MSB_POS] || (__P == 0))
		begin
			//__quot_buf[__counter] = 1;
			__quot_buf[i] = 1;
			__P = (__P << 1) - __D;
		end

		else
		begin
			////__quot_buf[__counter] = 0;
			//__quot_buf[i] = 0;
			__P = (__P << 1) + __D;
		end

		//__counter = __counter - 1;
	endtask



	// Assignments
	assign __busy = !out_can_accept_cmd;

	//assign __num_is_negative = $signed(in_num) < $signed(0);
	//assign __denom_is_negative = $signed(in_denom) < $signed(0);



	initial
	begin
		__counter = 0;
		__state_counter = 0;
		__P = 0;
		__D = 0;

		__state_counter = 0;

		__start_state = 1;

		out_quot = 0;
		out_rem = 0;

		out_can_accept_cmd = 1;
		out_data_ready = 0;
	end


	always @ (posedge clk)
	begin
		if (__state_counter[__COUNTER_MSB_POS])
		begin
			__quot_buf = 0;
			__rem_buf = 0;

			__counter = __ARGS_MSB_POS;


			__P = __num_buf;
			__D = __denom_buf << ARGS_WIDTH;
		end

		else if (__busy)
		begin
			//if (!__state_counter[__COUNTER_MSB_POS])
			//if ($signed(__counter) > $signed(-1))
			//if (!__counter[__COUNTER_MSB_POS])
			begin
				// At some clock rates, some FPGAs may be able to handle
				// more than one iteration per clock cycle, which is why
				// iterate() is a task.  Feel free to try more than one
				// iteration per clock cycle.


				//if (NUM_ITERATIONS_PER_CYCLE > 1)
				//begin
				//	for (int i=0; i<NUM_ITERATIONS_PER_CYCLE; i=i+1)
				//	begin
				//		iterate();
				//	end
				//end

				//else
				//begin
				//	iterate();
				//end

				//case (NUM_ITERATIONS_PER_CYCLE)
				//	1:
				//	begin
				//		iterate();
				//	end

				//	2:
				//	begin
				//		iterate();
				//		iterate();
				//	end

				//	4:
				//	begin
				//		iterate();
				//		iterate();
				//		iterate();
				//		iterate();
				//	end

				//	default:
				//	begin
				//		for (int i=0; i<NUM_ITERATIONS_PER_CYCLE; i=i+1)
				//		begin
				//			iterate();
				//		end
				//	end
				//endcase
				//`ifdef OPT_VERY_FAST_DIV
				//iterate();
				//iterate();
				//iterate();
				//iterate();
				//`else
				//`ifdef OPT_FAST_DIV
				//iterate();
				//iterate();
				//`else
				//iterate();
				//`endif		// OPT_FAST_DIV
				//`endif		// OPT_VERY_FAST_DIV
				`ifdef OPT_VERY_FAST_DIV
				iterate(__counter);
				iterate(__counter - 1);
				iterate(__counter - 2);
				iterate(__counter - 3);
				__counter = __counter - 4;
				`else
				`ifdef OPT_FAST_DIV
				iterate(__counter);
				iterate(__counter - 1);
				__counter = __counter - 2;
				`else
				iterate(__counter);
				__counter = __counter - 1;
				`endif		// OPT_FAST_DIV
				`endif		// OPT_VERY_FAST_DIV
			end
		end

	end


	always @ (posedge clk)
	begin
		if (in_enable && out_can_accept_cmd)
		begin
			out_can_accept_cmd <= 0;
			out_data_ready <= 0;
			__state_counter <= -1;

			__num_buf <= in_num;
			__denom_buf <= in_denom;


			//__num_buf <= (in_unsgn_or_sgn && __num_is_negative)
			//	? (-in_num) : in_num;
			//__denom_buf <= (in_unsgn_or_sgn && __denom_is_negative)
			//	? (-in_denom) : in_denom;

			__unsgn_or_sgn_buf <= in_unsgn_or_sgn;

			//__num_was_negative <= __num_is_negative;
			//__denom_was_negative <= __denom_is_negative;
			__num_was_negative <= in_num[__ARGS_MSB_POS];
			__denom_was_negative <= in_denom[__ARGS_MSB_POS];

			__start_state <= 0;
		end

		else if (__start_state == 0)
		begin
			__start_state <= 1;

			__num_buf <= (__unsgn_or_sgn_buf && __num_was_negative)
				? (-__num_buf) : __num_buf;
			__denom_buf <= (__unsgn_or_sgn_buf && __denom_was_negative)
				? (-__denom_buf) : __denom_buf;
		end

		else if (__busy)
		begin
			if (!__counter[__COUNTER_MSB_POS])
			begin
				__state_counter <= __state_counter + 1;
			end

			else
			begin
				out_can_accept_cmd <= 1;
				__state_counter <= -1;
				out_data_ready <= 1;

				//$display("end:  %d, %d %d, %d",
				//	__unsgn_or_sgn_buf, 
				//	__num_was_negative, __denom_was_negative,
				//	(__num_was_negative ^ __denom_was_negative));
				if (__P[__TEMP_MSB_POS])
				begin
					out_quot <= (__unsgn_or_sgn_buf 
						&& (__num_was_negative  ^ __denom_was_negative))
						?  (-((__quot_buf - (~__quot_buf)) - 1))
						: ((__quot_buf - (~__quot_buf)) - 1);
					out_rem <= (__unsgn_or_sgn_buf && __num_was_negative)
						? (-((__P + __D) >> ARGS_WIDTH))
						: ((__P + __D) >> ARGS_WIDTH);
				end

				else
				begin
					out_quot <= (__unsgn_or_sgn_buf
						&& (__num_was_negative ^ __denom_was_negative))
						? (-((__quot_buf - (~__quot_buf))))
						: ((__quot_buf - (~__quot_buf)));
					out_rem <= (__unsgn_or_sgn_buf && __num_was_negative)
						? (-((__P) >> ARGS_WIDTH))
						: ((__P) >> ARGS_WIDTH);
				end
			end
		end

		else
		begin
			$display("out_quot, out_rem:  %h, %h", out_quot, out_rem);
		end
	end


endmodule

