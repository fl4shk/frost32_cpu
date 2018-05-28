`include "src/misc_defines.header.sv"
`include "src/instr_decoder_defines.header.sv"
`include "src/alu_defines.header.sv"
`include "src/register_file_defines.header.sv"

//// Operand forwarding thing (keeps that bit out of this
//module OperandForwarder(input bit clk,
//	input PkgFrost32Cpu::PortIn_OperandForwarder in,
//	output PkgFrost32Cpu::PortOut_OperandForwarder out);
//
//endmodule


module Frost32Cpu(input logic clk,
	input PkgFrost32Cpu::PortIn_Frost32Cpu in,
	output PkgFrost32Cpu::PortOut_Frost32Cpu out);


	import PkgInstrDecoder::*;
	import PkgAlu::*;
	import PkgRegisterFile::*;
	import PkgFrost32Cpu::*;

	parameter __REG_LR_INDEX = 13;
	parameter __REG_SP_INDEX = 15;

	//parameter __STALL_COUNTER_RELATIVE_BRANCH = 4;
	//parameter __STALL_COUNTER_RELATIVE_BRANCH = 3;
	parameter __STALL_COUNTER_RELATIVE_BRANCH = 2;
	parameter __STALL_COUNTER_JUMP_OR_CALL = 4;

	// Memory access is unfortunately going to have to be a little slower.
	parameter __STALL_COUNTER_MEM_ACCESS = 3;
	parameter __STALL_COUNTER_INTERRUPTS_STUFF = 3;
	//parameter __STALL_COUNTER_RETI = 2;
	parameter __STALL_COUNTER_RETI = 3;
	parameter __STALL_COUNTER_EEK = 3;
	parameter __STALL_COUNTER_RESPOND_TO_INTERRUPTS = 1;
	//parameter __STALL_COUNTER_RESPOND_TO_INTERRUPTS = 3;
	//parameter __STALL_COUNTER_RESPOND_TO_INTERRUPTS = 2;

	//parameter __STALL_COUNTER_MULTIPLY_32 = 3;
	//parameter __STALL_COUNTER_MULTIPLY_32 = 4;
	parameter __STALL_COUNTER_MULTIPLY_32 = 5;


	// Only useful at low clock rates!
	`ifdef OPT_VERY_FAST_DIV
	parameter __NUM_ITERATIONS_PER_DIVIDE_32_CYCLE = 4;
	`else
	`ifdef OPT_FAST_DIV
	// Hardcoded, though not the cleanest.
	parameter __NUM_ITERATIONS_PER_DIVIDE_32_CYCLE = 2;
	`else
	parameter __NUM_ITERATIONS_PER_DIVIDE_32_CYCLE = 1;
	`endif		// OPT_FAST_DIV
	`endif		// OPT_VERY_FAST_DIV

	parameter __STALL_COUNTER_DIVIDE_32 
		= (32 / __NUM_ITERATIONS_PER_DIVIDE_32_CYCLE) + 5;


	// Data output by or used by the Instruction Decode stage
	struct packed
	{
		// Counter for stalling while waiting for later stages to do their
		// thing.
		// 
		// Initial value is specific to each instruction that actually uses
		// this.
		// 
		// Applies mainly to control flow and memory access instructions,
		// but will eventually apply to multiplication too once I implement
		// that in a **generally** synthesizeable way (i.e., NOT with the
		// "*" operator of SystemVerilog).
		logic [`MSB_POS__FROST32_CPU_DECODE_STAGE_STALL_COUNTER:0]
			stall_counter;

		logic [`MSB_POS__FROST32_CPU_STATE:0] stall_state;
		//PkgFrost32Cpu::StallState stall_state;

		logic [`MSB_POS__REG_FILE_DATA:0] 
			from_stage_execute_rfile_ra_data,
			from_stage_execute_rfile_rb_data,
			from_stage_execute_rfile_rc_data;

		//logic [`MSB_POS__REG_FILE_DATA:0] 
		//	from_stage_register_read_rfile_ra_data,
		//	from_stage_register_read_rfile_rb_data;

	} __stage_instr_decode_data;


	// Data input to the execute stage
	struct packed
	{
		logic [`MSB_POS__REG_FILE_DATA:0] rfile_ra_data, rfile_rb_data,
			rfile_rc_data;

		logic [`MSB_POS__FROST32_CPU_ADDR:0] ireta_data, idsta_data;

		//logic [`MSB_POS__FROST32_CPU_ADDR:0] next_pc;
	}
		//__stage_register_read_input_data,
		__stage_execute_input_data;

	//struct packed
	//{
	//	//logic [`MSB_POS__REG_FILE_DATA:0] rfile_ra_data, rfile_rb_data,
	//	//	rfile_rc_data;

	//	logic [`MSB_POS__REG_FILE_SEL:0] prev_written_reg_index;

	//	logic [`MSB_POS__REG_FILE_DATA:0] n_reg_data;

	//} __stage_register_read_output_data;

	// Combinational logic based operand forwarding to the register read
	// stage, and also for preparing write back
	//struct packed
	//{
	//	logic [`MSB_POS__REG_FILE_SEL:0] to_write_reg_index;

	//	logic [`MSB_POS__REG_FILE_DATA:0] n_reg_data;
	//} __stage_execute_generated_data;

	//assign __stage_register_read_output_data.prev_written_reg_index
	//	= __stage_execute_generated_data.prev_written_reg_index;
	//assign __stage_register_read_output_data.n_reg_data
	//	= __stage_execute_generated_data.n_reg_data;

	struct packed
	{
		// The next program counter for load and store instructions that
		// stall (read by the instruction decode stage for updating the
		// program counter in the case of these instructions)
		//logic [`MSB_POS__FROST32_CPU_ADDR:0] next_pc_after_ldst;

		logic [`MSB_POS__REG_FILE_SEL:0] prev_written_reg_index;

		logic [`MSB_POS__REG_FILE_DATA:0] n_reg_data;

		//logic do_write_lr;

		//logic perform_operand_forwarding;
	}
		__stage_execute_output_data,
		__stage_write_back_output_data;
		//__stage_write_back_prev_output_data;


	struct packed
	{
		// The program counter (written to ONLY by the instruction decode
		// stage)
		logic [`MSB_POS__FROST32_CPU_ADDR:0] pc;

		// Interrupt return address (where to return to when an interrupt
		// happens (set to the program counter of the instruction in the
		// decode stage when )
		logic [`MSB_POS__FROST32_CPU_ADDR:0] ireta;

		// Interrupt destination address (the program counter gets set to
		// this when an interrutp happens)
		logic [`MSB_POS__FROST32_CPU_ADDR:0] idsta;

		// Interrupt enable
		logic ie;

		//// Split up 32-bit by 32-bit multiplications into three 16-bit by
		//// 16-bit multiplications (which I believe can be synthesized into
		//// combinational bit) and some adds.
		//logic [`MSB_POS__MUL32_INOUT:0] 
		//	mul32_result,
		//	mul32_partial_result_x0_y0, mul32_partial_result_x1_y0, 
		//	mul32_partial_result_x0_y1;

		//logic [`MSB_POS__MUL32_INOUT:0] 
		//	mul32_partial_result_0, mul32_partial_result_1, 
		//	mul32_partial_result_2, mul32_partial_result_3;

		logic [`MSB_POS__FROST32_CPU_ADDR:0] 
			branch_adder_a, branch_adder_b;
		//logic [`MSB_POS__FROST32_CPU_ADDR:0] 
		//	dest_of_ctrl_flow_if_condition, 
		//	next_pc_after_jump_or_call_cond,
		//	next_pc_after_jump_or_call_not_cond;
		//	//next_pc_after_jump_or_call;
		//logic jump_or_call_condition;
		logic [`MSB_POS__FROST32_CPU_ADDR:0] 
			ldst_adder_a, ldst_adder_b;
		logic [`MSB_POS__FROST32_CPU_ADDR:0] ldst_address;

		logic cond_ne, cond_eq, 
			cond_ltu, cond_geu, cond_leu, cond_gtu,
			cond_lts, cond_ges, cond_les, cond_gts;

		//logic cond_branch_ne, cond_branch_eq, 
		//	cond_branch_ltu, cond_branch_geu, 
		//	cond_branch_leu, cond_branch_gtu,
		//	cond_branch_lts, cond_branch_ges, 
		//	cond_branch_les, cond_branch_gts;


		logic [`MSB_POS__REG_FILE_DATA:0] cpyhi_data;

		logic should_service_interrupt_if_not_in_stall;

		`ifdef OPT_DEBUG
		// Debugging thing
		logic [31:0] cycles_counter;
		`endif		// OPT_DEBUG


	} __locals;


	logic [`MSB_POS__FROST32_CPU_ADDR:0] __following_pc_stage_instr_decode,
		//__following_pc_stage_register_read,
		__following_pc_stage_execute;

	PkgFrost32Cpu::MultiStageData 
		__multi_stage_data_instr_decode, 
		//__multi_stage_data_register_read,
		__multi_stage_data_execute,
		__multi_stage_data_write_back;





	// Module instantiations
	logic [`MSB_POS__INSTRUCTION:0] __in_instr_decoder;
	PkgInstrDecoder::PortOut_InstrDecoder __out_instr_decoder;
	InstrDecoder __inst_instr_decoder(.in(__in_instr_decoder), 
		.out(__out_instr_decoder));


	PkgAlu::PortIn_Multiplier32 __in_mul_32;
	PkgAlu::PortOut_Multiplier32 __out_mul_32;
	Multiplier32 __inst_mul_32(.clk(clk), .in(__in_mul_32),
		.out(__out_mul_32));

	struct packed
	{
		logic enable, unsgn_or_sgn;
		logic [`MSB_POS__REG_FILE_DATA:0] num, denom;
	} __in_div_32;

	struct packed
	{
		logic can_accept_cmd, data_ready;
		logic [`MSB_POS__REG_FILE_DATA:0] quot, rem;
	} __out_div_32;

	//LongDivider 
	//RestoringDivider
	NonRestoringDivider
		#(.ARGS_WIDTH(`WIDTH__REG_FILE_DATA),
		.NUM_ITERATIONS_PER_CYCLE(__NUM_ITERATIONS_PER_DIVIDE_32_CYCLE))
		__inst_div(.clk(clk), 
		.in_enable(__in_div_32.enable),
		.in_unsgn_or_sgn(__in_div_32.unsgn_or_sgn),
		.in_num(__in_div_32.num),
		.in_denom(__in_div_32.denom),
		.out_quot(__out_div_32.quot),
		.out_rem(__out_div_32.rem),
		.out_can_accept_cmd(__out_div_32.can_accept_cmd),
		.out_data_ready(__out_div_32.data_ready));

	//parameter __ARR_SIZE__NUM_REGISTERS = 16;
	//parameter __LAST_INDEX__NUM_REGISTERS 
	//	= `ARR_SIZE_TO_LAST_INDEX(__ARR_SIZE__NUM_REGISTERS);

	//`ifdef ICARUS
	//logic [`MSB_POS__REG_FILE_DATA:0]
	//	__regfile[0 : __LAST_INDEX__NUM_REGISTERS];
	//`else
	//logic [`MSB_POS__REG_FILE_DATA:0]
	//	__regfile[0 : __LAST_INDEX__NUM_REGISTERS];
	//`endif		// ICARUS

	//initial
	//begin
	//	for (int i=0; i<__ARR_SIZE__NUM_REGISTERS; ++i)
	//	begin
	//		__regfile[i] = 0;
	//	end
	//end

	`ifdef OPT_DEBUG_REGISTER_FILE
	logic [`MSB_POS__REG_FILE_DATA:0] 
		__out_debug_reg_zero, __out_debug_reg_u0,
		__out_debug_reg_u1, __out_debug_reg_u2, 
		__out_debug_reg_u3, __out_debug_reg_u4,
		__out_debug_reg_u5, __out_debug_reg_u6, 
		__out_debug_reg_u7, __out_debug_reg_u8,
		__out_debug_reg_u9, __out_debug_reg_u10, 
		__out_debug_reg_temp, __out_debug_reg_lr,
		__out_debug_reg_fp, __out_debug_reg_sp;
	
	//assign __out_debug_reg_zero = __regfile[0];
	//assign __out_debug_reg_u0 = __regfile[1];
	//assign __out_debug_reg_u1 = __regfile[2];
	//assign __out_debug_reg_u2 = __regfile[3];
	//assign __out_debug_reg_u3 = __regfile[4];
	//assign __out_debug_reg_u4 = __regfile[5];
	//assign __out_debug_reg_u5 = __regfile[6];
	//assign __out_debug_reg_u6 = __regfile[7];
	//assign __out_debug_reg_u7 = __regfile[8];
	//assign __out_debug_reg_u8 = __regfile[9];
	//assign __out_debug_reg_u9 = __regfile[10];
	//assign __out_debug_reg_u10 = __regfile[11];
	//assign __out_debug_reg_temp = __regfile[12];
	//assign __out_debug_reg_lr = __regfile[13];
	//assign __out_debug_reg_fp = __regfile[14];
	//assign __out_debug_reg_sp = __regfile[15];
	`endif


	PkgRegisterFile::PortIn_RegFile __in_reg_file;
	PkgRegisterFile::PortOut_RegFile __out_reg_file;
	//assign __out_reg_file.read_data_ra
	//	= __regfile[__in_reg_file.read_sel_ra];
	//assign __out_reg_file.read_data_rb
	//	= __regfile[__in_reg_file.read_sel_rb];
	//assign __out_reg_file.read_data_rc
	//	= __regfile[__in_reg_file.read_sel_rc];
	//always_ff @ (posedge clk)
	//begin
	//	__out_reg_file.read_data_ra
	//		<= __regfile[__in_reg_file.read_sel_ra];
	//	__out_reg_file.read_data_rb
	//		<= __regfile[__in_reg_file.read_sel_rb];
	//	__out_reg_file.read_data_rc
	//		<= __regfile[__in_reg_file.read_sel_rc];
	//	$display("__in_reg_file.read_sel_ra, __regfile:  %h, %h",
	//		__in_reg_file.read_sel_ra,
	//		__regfile[__in_reg_file.read_sel_ra]);
	//	$display("__in_reg_file.read_sel_rb, __regfile:  %h, %h",
	//		__in_reg_file.read_sel_rb,
	//		__regfile[__in_reg_file.read_sel_rb]);
	//	$display("__in_reg_file.read_sel_rc, __regfile:  %h, %h",
	//		__in_reg_file.read_sel_rc,
	//		__regfile[__in_reg_file.read_sel_rc]);
	//end

	RegisterFile __inst_reg_file(.clk(clk), .in(__in_reg_file),
		.out(__out_reg_file)
		`ifdef OPT_DEBUG_REGISTER_FILE
		,
		.out_debug_zero(__out_debug_reg_zero), 
		.out_debug_u0(__out_debug_reg_u0),
		.out_debug_u1(__out_debug_reg_u1),
		.out_debug_u2(__out_debug_reg_u2),
		.out_debug_u3(__out_debug_reg_u3),
		.out_debug_u4(__out_debug_reg_u4),
		.out_debug_u5(__out_debug_reg_u5),
		.out_debug_u6(__out_debug_reg_u6),
		.out_debug_u7(__out_debug_reg_u7),
		.out_debug_u8(__out_debug_reg_u8),
		.out_debug_u9(__out_debug_reg_u9),
		.out_debug_u10(__out_debug_reg_u10),
		.out_debug_temp(__out_debug_reg_temp),
		.out_debug_lr(__out_debug_reg_lr),
		.out_debug_fp(__out_debug_reg_fp),
		.out_debug_sp(__out_debug_reg_sp)
		`endif		// OPT_DEBUG_REGISTER_FILE
		);

	`ifdef OPT_DEBUG_REGISTER_FILE
	always_comb
	begin
		out.debug_reg_zero = __out_debug_reg_zero;
		out.debug_reg_u0 = __out_debug_reg_u0;
		out.debug_reg_u1 = __out_debug_reg_u1;
		out.debug_reg_u2 = __out_debug_reg_u2;

		out.debug_reg_u3 = __out_debug_reg_u3;
		out.debug_reg_u4 = __out_debug_reg_u4;
		out.debug_reg_u5 = __out_debug_reg_u5;
		out.debug_reg_u6 = __out_debug_reg_u6;

		out.debug_reg_u7 = __out_debug_reg_u7;
		out.debug_reg_u8 = __out_debug_reg_u8;
		out.debug_reg_u9 = __out_debug_reg_u9;
		out.debug_reg_u10 = __out_debug_reg_u10;

		out.debug_reg_temp = __out_debug_reg_temp;
		out.debug_reg_lr = __out_debug_reg_lr;
		out.debug_reg_fp = __out_debug_reg_fp;
		out.debug_reg_sp = __out_debug_reg_sp;
	end
	`endif

	PkgAlu::PortIn_Alu __in_alu;
	PkgAlu::PortOut_Alu __out_alu;
	Alu __inst_alu(.in(__in_alu), .out(__out_alu));

	PkgAlu::PortOut_Compare __out_compare_ctrl_flow;
	assign __out_compare_ctrl_flow = 0;
	//Compare #(.DATA_WIDTH(`WIDTH__REG_FILE_DATA)) __inst_compare_ctrl_flow
	//	(.a(__stage_execute_input_data.rfile_ra_data),
	//	.b(__stage_execute_input_data.rfile_rb_data),
	//	.out(__out_compare_ctrl_flow));

	// Debug stuff
	`ifdef ICARUS
	always @ (posedge clk)
	begin
	if (!in.wait_for_mem)
	begin
		if (__locals.pc >= 32'h4000)
		//if (__locals.pc >= 32'h8000)
		//if (__locals.pc >= 32'hc000)
		//if (__locals.pc >= 32'h800000)
		begin
			$display("finishing");
			$finish;
		end
	end
	end
	`endif

	`ifdef OPT_DEBUG
	//always_comb
	//begin
	//	$display("RegisterFile inputs:  %h %h %h", 
	//		__in_reg_file.write_en, __in_reg_file.write_sel, 
	//		__in_reg_file.write_data);
	//end
	always @ (posedge clk)
	begin
	if (!in.wait_for_mem)
	begin
		//$display("RegisterFile inputs:  %h %h %h", 
		//	__in_reg_file.write_en, __in_reg_file.write_sel, 
		//	__in_reg_file.write_data);
		$display("Frost32Cpu stall_counter, stall_state:  %h, %h",
			__stage_instr_decode_data.stall_counter,
			__stage_instr_decode_data.stall_state);
		$display("Frost32Cpu pc's:  %h %h %h %h", 
			__locals.pc,
			__multi_stage_data_instr_decode.pc_val, 
			//__multi_stage_data_register_read.pc_val,
			__multi_stage_data_execute.pc_val,
			__multi_stage_data_write_back.pc_val);
		`ifdef OPT_DEBUG_REGISTER_FILE
		//$display("Frost32Cpu special purpose regs:  %h %h %h",
		//	__locals.ireta, __locals.idsta, __locals.ie);
		$display("Frost32Cpu ireta:  %h", __locals.ireta);
		$display("Frost32Cpu idsta:  %h", __locals.idsta);
		$display("Frost32Cpu ie:  %h", __locals.ie);

		$display("Frost32Cpu regs (0 to 3):  %h %h %h %h",
			__out_debug_reg_zero, __out_debug_reg_u0, 
			__out_debug_reg_u1, __out_debug_reg_u2);
		$display("Frost32Cpu regs (4 to 7):  %h %h %h %h",
			__out_debug_reg_u3, __out_debug_reg_u4, 
			__out_debug_reg_u5, __out_debug_reg_u6);
		$display("Frost32Cpu regs (8 to 11):  %h %h %h %h",
			__out_debug_reg_u7, __out_debug_reg_u8, 
			__out_debug_reg_u9, __out_debug_reg_u10);
		$display("Frost32Cpu regs (12 to 15):  %h %h %h %h",
			__out_debug_reg_temp, __out_debug_reg_lr, 
			__out_debug_reg_fp, __out_debug_reg_sp);
		`endif

		`ifdef OPT_DEBUG_INSTR_DECODER
		`include "src/debug_instr_decoder.header.sv"
		`endif		// OPT_DEBUG_INSTR_DECODER
		$display();
	end

		//$display();
	end
	`endif		// OPT_DEBUG

	// Assignments
	assign __following_pc_stage_instr_decode 
		= __multi_stage_data_instr_decode.pc_val + 4;
	//assign __following_pc_stage_register_read 
	//	= __multi_stage_data_register_read.pc_val + 4;
	assign __following_pc_stage_execute 
		= __multi_stage_data_execute.pc_val + 4;

	always_comb
	begin
		__locals.should_service_interrupt_if_not_in_stall
			= !((in.interrupt && !__locals.ie) || (!in.interrupt));
	end

	always_comb
	//always @ (__multi_stage_data_execute,
	//	__stage_instr_decode_data.stall_counter)
	begin
		// Keep old instruction whenever we're in a stall, which prevents
		// new instructions from coming into the decode stage.
		if (in_stall())
		begin
			//__in_instr_decoder
			//	= __multi_stage_data_register_read.raw_instruction;
			__in_instr_decoder
				= __multi_stage_data_execute.raw_instruction;
			//$display("Keep old instruction:  %h", __in_instr_decoder);
		end

		else
		begin
			__in_instr_decoder = in.data;
			//$display("Use new instruction:  %h", __in_instr_decoder);
		end
	end

	//assign __in_instr_decoder = in.data;


	//always_comb
	//begin
	//	__in_instr_decoder
	//		= __multi_stage_data_instr_decode.raw_instruction;
	//end

	always_comb
	begin
		__in_reg_file.read_sel_ra 
			= __multi_stage_data_instr_decode.instr_ra_index;
		//__in_reg_file.read_sel_ra 
		//	= __multi_stage_data_execute.instr_ra_index;
		//$display("__in_reg_file.read_sel_ra:  %h",
		//	__in_reg_file.read_sel_ra);
	end

	always_comb
	begin
		__in_reg_file.read_sel_rb 
			= __multi_stage_data_instr_decode.instr_rb_index;
		//__in_reg_file.read_sel_rb 
		//	= __multi_stage_data_execute.instr_rb_index;
		//$display("__in_reg_file.read_sel_rb:  %h",
		//	__in_reg_file.read_sel_rb);
	end

	always_comb
	begin
		__in_reg_file.read_sel_rc 
			= __multi_stage_data_instr_decode.instr_rc_index;
		//__in_reg_file.read_sel_rb 
		//	= __multi_stage_data_execute.instr_rc_index;
		//$display("__in_reg_file.read_sel_rc:  %h",
		//	__in_reg_file.read_sel_rc);
	end

	//always_comb
	//begin
	//	$display("__in_reg_file.read_sel_ra:  %h",
	//		__in_reg_file.read_sel_ra);
	//	$display("__in_reg_file.read_sel_rb:  %h",
	//		__in_reg_file.read_sel_rb);
	//	$display("__in_reg_file.read_sel_rc:  %h",
	//		__in_reg_file.read_sel_rc);
	//end

	always_comb __multi_stage_data_instr_decode.raw_instruction 
		= __in_instr_decoder;
	always_comb __multi_stage_data_instr_decode.instr_ra_index
		= __out_instr_decoder.ra_index;
	always_comb __multi_stage_data_instr_decode.instr_rb_index
		= __out_instr_decoder.rb_index;
	always_comb __multi_stage_data_instr_decode.instr_rc_index
		= __out_instr_decoder.rc_index;
	always_comb __multi_stage_data_instr_decode.instr_imm_val
		= __out_instr_decoder.imm_val;
	always_comb __multi_stage_data_instr_decode.instr_group
		= __out_instr_decoder.group;
	always_comb __multi_stage_data_instr_decode.instr_opcode
		= __out_instr_decoder.opcode;
	always_comb __multi_stage_data_instr_decode.instr_ldst_type
		= __out_instr_decoder.ldst_type;
	always_comb __multi_stage_data_instr_decode.instr_causes_stall
		= __out_instr_decoder.causes_stall;
	always_comb __multi_stage_data_instr_decode.instr_condition_type
		= __out_instr_decoder.condition_type;


	//always_comb
	//begin
	//	//if (in_stall() || (!in_stall() 
	//	//	&& __locals.should_service_interrupt_if_not_in_stall))

	//	// If in a stall, use the execute stage's program counter.
	//	if (in_stall())
	//	begin
	//		__multi_stage_data_instr_decode.pc_val
	//			= __multi_stage_data_execute.pc_val;
	//	end

	//	else
	//	begin
	//		__multi_stage_data_instr_decode.pc_val = __locals.pc;
	//	end
	//end


	//always_comb
	//	__multi_stage_data_instr_decode.nop = 0;



	// This is the operand forwarding.  It's so simple!
	// We only write to one register at a time, so we only need one
	// multiplexer per rfile_r..._data
//	`define perform_operand_forwarding(INDEX) \
//	always_comb \
//	begin \
//		/* Forward from last instruction */ \
//		if (__multi_stage_data_execute.instr_``INDEX``_index \
//			== __stage_execute_output_data.prev_written_reg_index \
//			&& __multi_stage_data_execute.instr_``INDEX``_index) \
//		begin \
//			__stage_execute_input_data.rfile_``INDEX``_data \
//				= __stage_execute_output_data.n_reg_data; \
//		end \
//\
//		/* Forward from two instructions ago */ \
//		else if (__multi_stage_data_execute.instr_``INDEX``_index \
//			== __stage_write_back_output_data.prev_written_reg_index \
//			&& __multi_stage_data_execute.instr_``INDEX``_index) \
//		begin \
//			__stage_execute_input_data.rfile_``INDEX``_data \
//				= __stage_write_back_output_data.n_reg_data; \
//		end \
//\
//		/* Forward from three instructions ago */ \
//		else if (__multi_stage_data_execute.instr_``INDEX``_index \
//			== __stage_write_back_prev_output_data \
//			.prev_written_reg_index \
//			&& __multi_stage_data_execute.instr_``INDEX``_index) \
//		begin \
//			__stage_execute_input_data.rfile_``INDEX``_data \
//				= __stage_write_back_prev_output_data.n_reg_data; \
//		end \
//\
//		/* No forwarding */ \
//		else \
//		begin \
//			__stage_execute_input_data.rfile_``INDEX``_data \
//				= __out_reg_file.read_data_``INDEX``; \
//		end \
//	end

	`define perform_operand_forwarding(INDEX) \
	always_comb \
	begin \
		/* Reading from register called "zero" */ \
		if (__multi_stage_data_execute.instr_``INDEX``_index == 0) \
		begin \
			__stage_execute_input_data.rfile_``INDEX``_data = 0; \
		end \
		\
		/* Forward from last instruction */ \
		else if (__multi_stage_data_execute.instr_``INDEX``_index \
			== __stage_execute_output_data.prev_written_reg_index) \
		begin \
			__stage_execute_input_data.rfile_``INDEX``_data \
				= __stage_execute_output_data.n_reg_data; \
		end \
		\
		/* Forward from two instructions ago */ \
		else if (__multi_stage_data_execute.instr_``INDEX``_index \
			== __stage_write_back_output_data.prev_written_reg_index) \
		begin \
			__stage_execute_input_data.rfile_``INDEX``_data \
				= __stage_write_back_output_data.n_reg_data; \
		end \
		\
		/* No forwarding */ \
		else \
		begin \
			__stage_execute_input_data.rfile_``INDEX``_data \
				= __out_reg_file.read_data_``INDEX``; \
		end \
	end
	`perform_operand_forwarding(ra)
	`perform_operand_forwarding(rb)
	`perform_operand_forwarding(rc)

	//always_comb
	//begin
	//	//__stage_execute_input_data.rfile_ra_data
	//	//	= __out_reg_file.read_data_ra;
	//	__stage_execute_input_data.rfile_ra_data
	//		= __regfile[__multi_stage_data_execute.instr_ra_index];
	//	$display("__stage_execute_input_data.rfile_ra_data:  %h",
	//		__stage_execute_input_data.rfile_ra_data);
	//	$display("__locals.cpyhi_data:  %h",
	//		__locals.cpyhi_data);
	//end
	//always_comb
	//begin
	//	//__stage_execute_input_data.rfile_rb_data
	//	//	= __out_reg_file.read_data_rb;
	//	__stage_execute_input_data.rfile_rb_data
	//		= __regfile[__multi_stage_data_execute.instr_rb_index];
	//end
	//always_comb
	//begin
	//	//__stage_execute_input_data.rfile_rc_data
	//	//	= __out_reg_file.read_data_rc;
	//	__stage_execute_input_data.rfile_rc_data
	//		= __regfile[__multi_stage_data_execute.instr_rc_index];
	//end

	//always_comb
	//begin
	//	if ((__multi_stage_data_register_read.instr_ra_index
	//		== __stage_execute_generated_data.to_write_reg_index)
	//		&& __stage_execute_generated_data.to_write_reg_index)
	//	begin
	//		// Forwarding from execute stage
	//		__stage_instr_decode_data
	//			.from_stage_register_read_rfile_ra_data
	//			= __stage_execute_generated_data.n_reg_data;
	//		$display("register read operand forwarding:  forward _ra (exec):  %h",
	//			__stage_instr_decode_data
	//			.from_stage_register_read_rfile_ra_data);
	//	end

	//	else if ((__multi_stage_data_register_read.instr_ra_index
	//		== __stage_execute_output_data.prev_written_reg_index)
	//		&& __stage_execute_output_data.prev_written_reg_index)
	//	begin
	//		// Forwarding from write-back sta
	//		__stage_instr_decode_data
	//			.from_stage_register_read_rfile_ra_data
	//			= __stage_execute_output_data.n_reg_data;
	//		$display("register read operand forwarding:  forward _ra (write-back):  %h",
	//			__stage_instr_decode_data
	//			.from_stage_register_read_rfile_ra_data);
	//	end

	//	else
	//	begin
	//		// No forwarding needed.
	//		__stage_instr_decode_data
	//			.from_stage_register_read_rfile_ra_data
	//			= __out_reg_file.read_data_cond_ra;
	//$display("register read operand forwarding:  don't forward _ra:  %h",
	//			__stage_instr_decode_data
	//			.from_stage_register_read_rfile_ra_data);
	//	end
	//end

	//always_comb
	//begin
	//	if ((__multi_stage_data_register_read.instr_rb_index
	//		== __stage_execute_generated_data.to_write_reg_index)
	//		&& __stage_execute_generated_data.to_write_reg_index)
	//	begin
	//		// Forwarding from execute stage
	//		__stage_instr_decode_data
	//			.from_stage_register_read_rfile_rb_data
	//			= __stage_execute_generated_data.n_reg_data;
	//		$display("register read operand forwarding:  forward _rb (exec):  %h",
	//			__stage_instr_decode_data
	//			.from_stage_register_read_rfile_rb_data);
	//	end

	//	else if ((__multi_stage_data_register_read.instr_rb_index
	//		== __stage_execute_output_data.prev_written_reg_index)
	//		&& __stage_execute_output_data.prev_written_reg_index)
	//	begin
	//		// Forwarding from write-back sta
	//		__stage_instr_decode_data
	//			.from_stage_register_read_rfile_rb_data
	//			= __stage_execute_output_data.n_reg_data;
	//		$display("register read operand forwarding:  forward _rb (write-back):  %h",
	//			__stage_instr_decode_data
	//			.from_stage_register_read_rfile_rb_data);
	//	end

	//	else
	//	begin
	//		// No forwarding needed.
	//		__stage_instr_decode_data
	//			.from_stage_register_read_rfile_rb_data
	//			= __out_reg_file.read_data_cond_rb;
	//$display("register read operand forwarding:  don't forward _rb:  %h",
	//			__stage_instr_decode_data
	//			.from_stage_register_read_rfile_rb_data);
	//	end
	//end

	// Just some copies for use in the decode stage.
	// 
	// Possibly adjust these later to use values either forwarded from the
	// execute stage or read asynchronously from the register file.
	always_comb
	begin
		__stage_instr_decode_data.from_stage_execute_rfile_ra_data
			= __stage_execute_input_data.rfile_ra_data;
	end
	always_comb
	begin
		__stage_instr_decode_data.from_stage_execute_rfile_rb_data
			= __stage_execute_input_data.rfile_rb_data;
	end
	always_comb
	begin
		__stage_instr_decode_data.from_stage_execute_rfile_rc_data
			= __stage_execute_input_data.rfile_rc_data;
	end

	// Conditions
	always_comb
	begin
		__locals.cond_ne
			= (__stage_instr_decode_data.from_stage_execute_rfile_ra_data
			!= __stage_instr_decode_data.from_stage_execute_rfile_rb_data);
	end

	always_comb
	begin
		__locals.cond_eq
			= (__stage_instr_decode_data.from_stage_execute_rfile_ra_data
			== __stage_instr_decode_data.from_stage_execute_rfile_rb_data);
		//$display("__locals.cond_eq stuff:  %h %h %h",
		//	__locals.cond_eq,
		//	__stage_instr_decode_data
		//	.from_stage_execute_rfile_ra_data,
		//	__stage_instr_decode_data
		//	.from_stage_execute_rfile_rb_data);
	end


	always_comb
	begin
		__locals.cond_ltu
			= (__stage_instr_decode_data
			.from_stage_execute_rfile_ra_data
			< __stage_instr_decode_data
			.from_stage_execute_rfile_rb_data);
	end

	always_comb
	begin
		__locals.cond_geu
			= (__stage_instr_decode_data
			.from_stage_execute_rfile_ra_data
			>= __stage_instr_decode_data
			.from_stage_execute_rfile_rb_data);
	end

	always_comb
	begin
		//__locals.cond_leu = !__out_compare_ctrl_flow.gtu;
		__locals.cond_leu
			= (__stage_instr_decode_data
			.from_stage_execute_rfile_ra_data
			<= __stage_instr_decode_data
			.from_stage_execute_rfile_rb_data);
	end

	always_comb
	begin
		//__locals.cond_gtu = __out_compare_ctrl_flow.gtu;
		__locals.cond_gtu
			=
			(__stage_instr_decode_data
			.from_stage_execute_rfile_ra_data
			> __stage_instr_decode_data
			.from_stage_execute_rfile_rb_data);
	end

	always_comb
	begin
		//__locals.cond_lts = __out_compare_ctrl_flow.lts;
		__locals.cond_lts
			=
			($signed(__stage_instr_decode_data
			.from_stage_execute_rfile_ra_data)
			< $signed(__stage_instr_decode_data
			.from_stage_execute_rfile_rb_data));
	end

	always_comb
	begin
		//__locals.cond_ges = !__out_compare_ctrl_flow.lts;
		__locals.cond_ges
			=
			($signed(__stage_instr_decode_data
			.from_stage_execute_rfile_ra_data)
			>= $signed(__stage_instr_decode_data
			.from_stage_execute_rfile_rb_data));
	end

	always_comb
	begin
		//__locals.cond_les = !__out_compare_ctrl_flow.gts;
		__locals.cond_les
			= ($signed(__stage_instr_decode_data
			.from_stage_execute_rfile_ra_data)
			<= $signed(__stage_instr_decode_data
			.from_stage_execute_rfile_rb_data));
	end

	always_comb
	begin
		//__locals.cond_gts = __out_compare_ctrl_flow.gts;
		__locals.cond_gts
			=
			($signed(__stage_instr_decode_data
			.from_stage_execute_rfile_ra_data)
			> $signed(__stage_instr_decode_data
			.from_stage_execute_rfile_rb_data));
	end

	//always_comb
	//begin
	//	__locals.cond_branch_ne
	//		= (__stage_instr_decode_data
	//		.from_stage_register_read_rfile_ra_data
	//		!= __stage_instr_decode_data
	//		.from_stage_register_read_rfile_rb_data);
	//end

	//always_comb
	//begin
	//	__locals.cond_branch_eq
	//		= (__stage_instr_decode_data
	//		.from_stage_register_read_rfile_ra_data
	//		== __stage_instr_decode_data
	//		.from_stage_register_read_rfile_rb_data);

	//	//$display("__locals.cond_branch_eq stuff:  %h %h %h",
	//	//	__locals.cond_branch_eq,
	//	//	__stage_instr_decode_data
	//	//	.from_stage_register_read_rfile_ra_data,
	//	//	__stage_instr_decode_data
	//	//	.from_stage_register_read_rfile_rb_data);
	//end


	//always_comb
	//begin
	//	__locals.cond_branch_ltu
	//		= (__stage_instr_decode_data
	//		.from_stage_register_read_rfile_ra_data
	//		< __stage_instr_decode_data
	//		.from_stage_register_read_rfile_rb_data);
	//end

	//always_comb
	//begin
	//	__locals.cond_branch_geu
	//		= (__stage_instr_decode_data
	//		.from_stage_register_read_rfile_ra_data
	//		>= __stage_instr_decode_data
	//		.from_stage_register_read_rfile_rb_data);
	//end

	//always_comb
	//begin
	//	//__locals.cond_branch_leu = !__out_compare_ctrl_flow.gtu;
	//	__locals.cond_branch_leu
	//		= (__stage_instr_decode_data
	//		.from_stage_register_read_rfile_ra_data
	//		<= __stage_instr_decode_data
	//		.from_stage_register_read_rfile_rb_data);
	//end

	//always_comb
	//begin
	//	//__locals.cond_branch_gtu = __out_compare_ctrl_flow.gtu;
	//	__locals.cond_branch_gtu
	//		=
	//		(__stage_instr_decode_data
	//		.from_stage_register_read_rfile_ra_data
	//		> __stage_instr_decode_data
	//		.from_stage_register_read_rfile_rb_data);
	//end

	//always_comb
	//begin
	//	//__locals.cond_branch_lts = __out_compare_ctrl_flow.lts;
	//	__locals.cond_branch_lts
	//		=
	//		($signed(__stage_instr_decode_data
	//		.from_stage_register_read_rfile_ra_data)
	//		< $signed(__stage_instr_decode_data
	//		.from_stage_register_read_rfile_rb_data));
	//end

	//always_comb
	//begin
	//	//__locals.cond_branch_ges = !__out_compare_ctrl_flow.lts;
	//	__locals.cond_branch_ges
	//		=
	//		($signed(__stage_instr_decode_data
	//		.from_stage_register_read_rfile_ra_data)
	//		>= $signed(__stage_instr_decode_data
	//		.from_stage_register_read_rfile_rb_data));
	//	//$display("__locals.cond_branch_ges stuff:  %h %h %h",
	//	//	__locals.cond_branch_ges,
	//	//	__stage_instr_decode_data
	//	//	.from_stage_register_read_rfile_ra_data,
	//	//	__stage_instr_decode_data
	//	//	.from_stage_register_read_rfile_rb_data);
	//end

	//always_comb
	//begin
	//	//__locals.cond_branch_les = !__out_compare_ctrl_flow.gts;
	//	__locals.cond_branch_les
	//		= ($signed(__stage_instr_decode_data
	//		.from_stage_register_read_rfile_ra_data)
	//		<= $signed(__stage_instr_decode_data
	//		.from_stage_register_read_rfile_rb_data));
	//end

	//always_comb
	//begin
	//	//__locals.cond_branch_gts = __out_compare_ctrl_flow.gts;
	//	__locals.cond_branch_gts
	//		=
	//		($signed(__stage_instr_decode_data
	//		.from_stage_register_read_rfile_ra_data)
	//		> $signed(__stage_instr_decode_data
	//		.from_stage_register_read_rfile_rb_data));
	//end
	always_comb
	begin
		__locals.branch_adder_a = __following_pc_stage_execute;
		//__locals.branch_adder_a = __following_pc_stage_register_read;
	end

	always_comb
	begin
		// Sign extend the immediate value
		//__in_alu.b 
		//	= {{16{__multi_stage_data_execute.instr_imm_val[15]}}, 
		//	__multi_stage_data_execute.instr_imm_val};

		__locals.branch_adder_b
			= {{16{__multi_stage_data_execute.instr_imm_val
			[15]}}, 
			__multi_stage_data_execute.instr_imm_val};
		//__locals.branch_adder_b
		//	= {{16{__multi_stage_data_register_read.instr_imm_val
		//	[15]}}, 
		//	__multi_stage_data_register_read.instr_imm_val};
	end

	//always_comb
	//begin
	//	__locals.dest_of_ctrl_flow_if_condition
	//		= __locals.branch_adder_a + __locals.branch_adder_b;
	//end

	always_comb
	//always @ (posedge clk)
	begin
		//if (__stage_instr_decode_data.stall_counter == 3)
		begin
			__locals.ldst_adder_a 
				= __stage_execute_input_data.rfile_rb_data;
			//__locals.ldst_adder_a <= __stage_instr_decode_data
			//	.from_stage_register_read_rfile_cond_rb_data;
		end
	end

	always_comb
	begin
		//if (__stage_instr_decode_data.stall_counter == 3)
		begin
			// Immediate-indexed loads and stores have
			// (__multi_stage_data_execute.instr_opcode[3] == 1)
			if (__multi_stage_data_execute.instr_opcode[3])
			begin
				// memory address computation:  rB + sign-extended
				// immediate (actually sign extended twice since
				// the instruction decoder **also** performed a
				// sign extend, from 12-bit to 16-bit)
				__locals.ldst_adder_b 
					= {{16{__multi_stage_data_execute.instr_imm_val
					[15]}},
					__multi_stage_data_execute.instr_imm_val};
			end

			else
			begin
				// memory address computation:  rB + rC
				__locals.ldst_adder_b 
					= __stage_execute_input_data.rfile_rc_data;
			end
		end
	end

	always_comb
	begin
		__locals.ldst_address = __locals.ldst_adder_a
			+ __locals.ldst_adder_b;
	end

	//always_comb
	//begin
	//	__in_alu.a = __stage_execute_input_data.rfile_rb_data;
	//end

	//always_comb
	//begin
	//	__in_alu.oper = __multi_stage_data_execute.instr_opcode;
	//end

	always_comb
	begin
		__locals.cpyhi_data
			= {__multi_stage_data_execute.instr_imm_val,
			__stage_execute_input_data.rfile_ra_data[15:0]};
		//$display("type 2:  cpyhi_data:  %h %h %h",
		//	__multi_stage_data_execute.instr_imm_val,
		//	__stage_execute_input_data.rfile_ra_data[15:0],
		//	__locals.cpyhi_data);
	end


	// Tasks and functions
	function bit in_stall();
		return (__stage_instr_decode_data.stall_counter != 0);
	endfunction

	task prep_mem_read;
		input [`MSB_POS__FROST32_CPU_ADDR:0] addr;
		//input PkgFrost32Cpu::DataInoutAccessSize size;
		input [`MSB_POS__FROST32_CPU_DATA_ACCESS_SIZE:0] size;

		out.data <= 0;
		out.addr <= addr;
		out.data_inout_access_type <= PkgFrost32Cpu::DiatRead; 
		out.data_inout_access_size <= size;
		out.req_mem_access <= 1;
	endtask

	task prep_load_instruction;
		input [`MSB_POS__FROST32_CPU_ADDR:0] addr;

		// Every instruction is 4 bytes long (...for now)
		__locals.pc <= addr;
		__multi_stage_data_instr_decode.pc_val <= __locals.pc;

		prep_mem_read(addr, PkgFrost32Cpu::Dias32);
	endtask

	task prep_load_following_instruction;
		prep_load_instruction(__locals.pc + 4);
	endtask

	task prep_mem_write;
		input [`MSB_POS__FROST32_CPU_ADDR:0] addr;
		//input PkgFrost32Cpu::DataInoutAccessSize size;
		input [`MSB_POS__FROST32_CPU_DATA_ACCESS_SIZE:0] size;
		input [`MSB_POS__FROST32_CPU_DATA_INOUT:0] data;

		out.data <= data;
		out.addr <= addr;
		out.data_inout_access_type <= PkgFrost32Cpu::DiatWrite; 
		out.data_inout_access_size <= size;
		out.req_mem_access <= 1;
	endtask

	task stop_mem_access;
		out.req_mem_access <= 0;
	endtask


	task prep_reg_wb;
		input [`MSB_POS__REG_FILE_SEL:0] n_sel;
		input [`MSB_POS__REG_FILE_DATA:0] n_data;

		__stage_execute_output_data.prev_written_reg_index <= n_sel;
		__stage_execute_output_data.n_reg_data <= n_data;

		$display("prep_reg_wb:  %h %h", n_sel, n_data);
	endtask

	task prep_ra_wb;
		input [`MSB_POS__REG_FILE_DATA:0] n_data;

		//$display("prep_ra_wb:  %h %h",
		//	__multi_stage_data_execute.instr_ra_index, n_data);
		prep_reg_wb(__multi_stage_data_execute.instr_ra_index, n_data);
	endtask

	task prep_reg_write;
		input [`MSB_POS__REG_FILE_SEL:0] n_sel;
		input [`MSB_POS__REG_FILE_DATA:0] n_data;

		__in_reg_file.write_sel <= n_sel;
		__in_reg_file.write_data <= n_data;
		__in_reg_file.write_en <= 1;

		$display("prep_reg_write:  %h %h", n_sel, n_data);

		//if (n_sel != 0)
		//begin
		//	__regfile[n_sel] <= n_data;
		//end
		//else
		//begin
		//	__regfile[n_sel] <= 0;
		//end

		//__stage_execute_output_data.prev_written_reg_index <= n_sel;
		//__stage_execute_output_data.n_reg_data <= n_data;
		__stage_write_back_output_data.prev_written_reg_index <= n_sel;
		__stage_write_back_output_data.n_reg_data <= n_data;

		//__stage_write_back_prev_output_data
		//	<= __stage_write_back_output_data;
	endtask

	//task prep_ra_write;
	//	input [`MSB_POS__REG_FILE_DATA:0] s_data;

	//	//$display("prep_ra_write:  %h %h",
	//	//	__multi_stage_data_write_back.instr_ra_index, s_data);
	//	//__in_reg_file.write_sel 
	//	//	<= __multi_stage_data_write_back.instr_ra_index;
	//	//__in_reg_file.write_data <= s_data;
	//	//__in_reg_file.write_en <= 1;
	//	//$display("prep_ra_write:  %h %h",
	//	//	__multi_stage_data_execute.instr_ra_index, s_data);
	//	//prep_reg_write(__multi_stage_data_execute.instr_ra_index, s_data);
	//	$display("prep_ra_write:  %h %h",
	//		__multi_stage_data_write_back.instr_ra_index, s_data);
	//	prep_reg_write(__multi_stage_data_write_back.instr_ra_index, 
	//		s_data);

	//	//$display("prep_ra_write:  %h %h",
	//	//	__multi_stage_data_write_back.instr_ra_index, s_data);
	//	//prep_reg_write(__multi_stage_data_write_back.instr_ra_index, 
	//	//	s_data);
	//endtask

	//task set_stage_execute_generated_data;
	//	input [`MSB_POS__REG_FILE_SEL:0] n_sel;
	//	input [`MSB_POS__REG_FILE_DATA:0] n_data;

	//	__stage_execute_generated_data.to_write_reg_index = n_sel;
	//	__stage_execute_generated_data.n_reg_data = n_data;
	//endtask

	//task use_ra_for_stage_execute_generated_data;
	//	input [`MSB_POS__REG_FILE_DATA:0] n_data;

	//	$display("use_ra_for_stage_execute_generated_data:  %h %h",
	//		__multi_stage_data_execute.instr_ra_index, n_data);

	//	set_stage_execute_generated_data
	//		(__multi_stage_data_execute.instr_ra_index, n_data);
	//endtask

	//task stop_register_read_operand_forwarding;
	//	__stage_execute_generated_data.to_write_reg_index = 0;
	//endtask

	task stop_operand_forwarding_or_write_back;
		__stage_execute_output_data.prev_written_reg_index <= 0;
	endtask

	//task stop_reg_write;
	//	__in_reg_file.write_en <= 0;
	//endtask

	task send_instr_through;
		// We only send a non-bubble instruction to
		// `MULTI_STAGE_DATA_AFTER_INSTR_DECODE when there's a
		// new instruction that is NOT "ei" or "di"
		__multi_stage_data_execute 
			<= __multi_stage_data_instr_decode;
		//__multi_stage_data_execute 
		//	<= __multi_stage_data_instr_decode;

		__stage_execute_input_data.ireta_data 
			<= __locals.ireta;
		__stage_execute_input_data.idsta_data 
			<= __locals.idsta;

		//// Use all three register file read ports.
		//// Do this whenever we're not in a stall.
		//__in_reg_file.read_sel_ra 
		//	<= __multi_stage_data_instr_decode.instr_ra_index;
		//__in_reg_file.read_sel_rb 
		//	<= __multi_stage_data_instr_decode.instr_rb_index;
		//__in_reg_file.read_sel_rc 
		//	<= __multi_stage_data_instr_decode.instr_rc_index;
		//$display("Sending instruction through:  %h %h %h",
		//	__multi_stage_data_instr_decode.instr_ra_index,
		//	__multi_stage_data_instr_decode.instr_rb_index,
		//	__multi_stage_data_instr_decode.instr_rc_index);
	endtask

	task make_bubble;
		//// Send a bubble through while we're stalled a (actually
		//// performs "add zero, zero, zero", but that does nothing
		//// interesting anyway... besides maybe power consumption)
		//__in_reg_file.read_sel_ra <= 0;
		//__in_reg_file.read_sel_rb <= 0;
		//__in_reg_file.read_sel_rc <= 0;

		//__multi_stage_data_execute <= 0;
		__multi_stage_data_execute.instr_ra_index <= 0;
		__multi_stage_data_execute.instr_rb_index <= 0;
		__multi_stage_data_execute.instr_rc_index <= 0;
		__multi_stage_data_execute.instr_group <= 0;
		__multi_stage_data_execute.instr_opcode <= 0;
		__multi_stage_data_execute.instr_ldst_type <= 0;
		__multi_stage_data_execute.instr_causes_stall <= 0;
		__multi_stage_data_execute.instr_condition_type <= 0;
		//__multi_stage_data_execute.nop <= 1'b1;

	endtask

	//task handle_ctrl_flow_in_decode_stage_part_1;
	task handle_branch_in_fetch_stage;
		input condition;

		if (condition)
		begin
			$display("handle_ctrl_flow_in_fetch_stage_part_1:  %s%h %h %h",
				"taking branch:  ", 
				__locals.branch_adder_a,
				__locals.branch_adder_b,
				__locals.branch_adder_a + __locals.branch_adder_b);
			prep_load_instruction
				(__locals.branch_adder_a + __locals.branch_adder_b);
		end

		else // if (!condition)
		begin
			$display("handle_ctrl_flow_in_fetch_stage_part_1:  %s%h",
				"NOT taking branch:  ",
				__following_pc_stage_execute);
			prep_load_instruction(__following_pc_stage_execute);
			//$display("handle_ctrl_flow_in_fetch_stage_part_1:  %s%h",
			//	"NOT taking branch:  ",
			//	__following_pc_stage_register_read);
			//prep_load_instruction(__following_pc_stage_register_read);
		end
	endtask

	task handle_jump_or_call_in_fetch_stage;
		input condition;

		if (condition)
		begin
			$display("handle_jump_or_call_in_fetch_stage:  %s%h",
				"condition, loading from:  ",
				__stage_instr_decode_data
				.from_stage_execute_rfile_rc_data);
			prep_load_instruction(__stage_instr_decode_data
				.from_stage_execute_rfile_rc_data);
		end

		else
		begin
			//__locals.next_pc_after_jump_or_call 
			//	<= __following_pc_stage_execute;
			$display("handle_jump_or_call_in_fetch_stage:  %s%h",
				"!condition, loading from:  ",
				__following_pc_stage_execute);
			prep_load_instruction(__following_pc_stage_execute);
		end
	endtask

	task handle_call_in_execute_stage;
		input condition;

		//__stage_write_back_input_data.n_reg_data <= __following_pc;
		//__stage_write_back_input_data.do_write_lr <= condition;
		__stage_execute_output_data.n_reg_data 
			<= __following_pc_stage_execute;
		//__stage_execute_generated_data.n_reg_data 
		//	= __following_pc_stage_execute;
		//__stage_execute_output_data.do_write_lr
		//	<= condition;
		__stage_execute_output_data.prev_written_reg_index
			<= condition ? __REG_LR_INDEX : 0;
		//__stage_execute_generated_data.to_write_reg_index
		//	= condition ? __REG_LR_INDEX : 0;

		//if (condition)
		//begin
		//	// We want to store the value of __following_pc in "lr".
		//	__stage_write_back_input_data.n_reg_data <= __following_pc;
		//	__stage_write_back_input_data.do_write_lr <= 1;
		//end

		//else
		//begin
		//	// We want to leave "lr" alone.
		//	__stage_write_back_input_data.do_write_lr <= 0;
		//end

		//if (condition)
		//begin
		//	prep_reg_write(__REG_LR_INDEX, __following_pc_stage_execute);
		//end
	endtask

	//task perform_multiply_32;
	//	input [`MSB_POS__MUL32_INOUT:0] x, y;

	//	//case (__stage_instr_decode_data.stall_counter)
	//	//case (__stage_instr_decode_data.stall_counter[2:0])
	//	case (__stage_instr_decode_data.stall_counter[1:0])
	//		//0:
	//		//begin
	//		//	
	//		//end

	//		//if (__stage_instr_decode_data.stall_counter == 1)
	//		1:
	//		begin
	//			prep_ra_wb(__locals.mul32_result);
	//		end

	//		//else if (__stage_instr_decode_data.stall_counter == 2)
	//		2:
	//		begin
	//			__locals.mul32_result
	//				<= {(__locals.mul32_partial_result_x1_y0
	//				+ __locals.mul32_partial_result_x0_y1), 16'h0000}
	//				+ __locals.mul32_partial_result_x0_y0;
	//		end

	//		////else if (__stage_instr_decode_data.stall_counter == 3)
	//		//3:
	//		//begin
	//		//	__locals.mul32_result
	//		//		<= ;
	//		//end

	//		//else
	//		//4:
	//		default:
	//		begin
	//			__locals.mul32_partial_result_x0_y0 <= x[15:0] * y[15:0];
	//			__locals.mul32_partial_result_x0_y1 <= x[15:0] * y[31:16];
	//			__locals.mul32_partial_result_x1_y0 <= x[31:16] * y[15:0];
	//		end

	//		//default:
	//		//begin
	//		//end
	//	endcase

	//endtask

	task ctrl_multiply_32;
		input [`MSB_POS__MUL32_INOUT:0] x, y;

		if (__stage_instr_decode_data.stall_counter
			== __STALL_COUNTER_MULTIPLY_32)
		begin
			__in_mul_32.enable <= 1;
			__in_mul_32.x <= x;
			__in_mul_32.y <= y;
			stop_operand_forwarding_or_write_back();
		end

		else
		begin
			__in_mul_32.enable <= 0;
			//$display("ctrl_multiply_32:  stuff 1");

			if (__stage_instr_decode_data.stall_counter
				!= __STALL_COUNTER_MULTIPLY_32 - 1)
			begin
			//$display("ctrl_multiply_32:  stuff 2");
				if (__out_mul_32.data_ready)
				begin
			//$display("ctrl_multiply_32:  stuff 3");
					prep_ra_wb(__out_mul_32.prod);
				end
			end
		end
		
	endtask

	task ctrl_divide_32;
		input n_unsgn_or_sgn;
		//$display("ctrl_divide_32:  %h %h\t\t%h %h", __in_div_32.enable,
		//	__in_div_32.unsgn_or_sgn, 
		//	__out_div_32.can_accept_cmd, __out_div_32.data_ready);

		if (__stage_instr_decode_data.stall_counter 
			== __STALL_COUNTER_DIVIDE_32)
		begin
			//if (__out_div_32.can_accept_cmd)
			begin
				__in_div_32.enable <= 1;
				//__in_div_32.unsgn_or_sgn <= 0;
				__in_div_32.unsgn_or_sgn <= n_unsgn_or_sgn;
				__in_div_32.num <= __stage_execute_input_data.rfile_rb_data;
				__in_div_32.denom <= __stage_execute_input_data.rfile_rc_data;

				stop_operand_forwarding_or_write_back();
			end
		end

		else
		begin
			__in_div_32.enable <= 0;

			if (__stage_instr_decode_data.stall_counter 
				!= __STALL_COUNTER_DIVIDE_32 - 1)
			begin
				//stop_operand_forwarding_or_write_back();
				if (__out_div_32.data_ready)
				begin
					if (__in_div_32.denom != 0)
					begin
						prep_ra_wb(__out_div_32.quot);
					end

					else
					begin
						prep_ra_wb(0);
					end
				end
			end
			//else
			//begin
			//	stop_operand_forwarding_or_write_back();
			//end
		end


	endtask




	initial
	begin
		// Put NOPs into the stages after decode
		//__multi_stage_data_register_read = 0;
		__multi_stage_data_execute = 0;

		__stage_instr_decode_data = 0;
		//__stage_register_read_output_data = 0;
		__stage_execute_output_data = 0;
		//__stage_execute_output_data = 0;
		//__stage_write_back_input_data = 0;
		//__stage_instr_decode_data.state = PkgFrost32Cpu::StInit;

		__locals = 0;

		__in_div_32 = 0;

		// Prepare a read from memory
		out.data = 0;
		out.addr = __locals.pc;
		out.data_inout_access_type = PkgFrost32Cpu::DiatRead; 
		out.data_inout_access_size = PkgFrost32Cpu::Dias32;
		out.req_mem_access = 1;

		// Cause the decode stage to be stalled with
		// __stage_instr_decode_data.stall_counter == 1, so that it will
		// perform a prep_mem_read() and load the first instruction (from
		// address 0)
		__stage_instr_decode_data.stall_counter = 2;
		__stage_instr_decode_data.stall_state = PkgFrost32Cpu::StInit;
	end

	// Stage 0:  Instruction Fetch
	// Instruction decode still controls the program counter and also other
	// things.
	always @ (posedge clk)
	begin
	if (!in.wait_for_mem)
	begin
		if (in_stall())
		begin
			// We just always do this when the stall_counter is 1
			if (__stage_instr_decode_data.stall_counter == 1)
			begin
				$display("Fetch stage:  stall_counter == 1:  %h",
					__locals.pc + 4);
				prep_load_following_instruction();
			end

			//case (__stage_instr_decode_data.stall_counter)
			case (__stage_instr_decode_data.stall_state)
			PkgFrost32Cpu::StCpyRaToInterruptsRelatedAddr:
			begin
				case (__stage_instr_decode_data.stall_counter)
					2:
					begin
						// The fetch stage now controls access to the
						// memory buses, and also writes to the program
						// counter.
						//prep_load_instruction(__following_pc);
						prep_load_instruction
							(__following_pc_stage_execute);
					end
				endcase
			end

			PkgFrost32Cpu::StMemAccess:
			begin
				// Memory access
				case (__stage_instr_decode_data.stall_counter)
					3:
					begin
					case (__multi_stage_data_execute.instr_ldst_type)
						PkgInstrDecoder::Ld32:
						begin
							// Execute handles the store to the register
							$display("Loading 32-bit val:  %h, %h + %h", 
								__locals.ldst_address,
								__locals.ldst_adder_a,
								__locals.ldst_adder_b);
							prep_mem_read(__locals.ldst_address,
								PkgFrost32Cpu::Dias32);
						end
						PkgInstrDecoder::LdU16:
						begin
							// Execute handles the store to the register
							prep_mem_read(__locals.ldst_address,
								PkgFrost32Cpu::Dias16);
						end
						PkgInstrDecoder::LdS16:
						begin
							// Execute handles the store to the register
							prep_mem_read(__locals.ldst_address,
								PkgFrost32Cpu::Dias16);
						end
						PkgInstrDecoder::LdU8:
						begin
							// Execute handles the store to the register
							prep_mem_read(__locals.ldst_address,
								PkgFrost32Cpu::Dias8);
						end
						PkgInstrDecoder::LdS8:
						begin
							// Execute handles the store to the register
							prep_mem_read(__locals.ldst_address,
								PkgFrost32Cpu::Dias8);
						end
						PkgInstrDecoder::St32:
						begin
							$display("Storing %h to address %h, %h + %h",
								__stage_execute_input_data.rfile_ra_data,
								__locals.ldst_address,
								__locals.ldst_adder_a,
								__locals.ldst_adder_b);
							//$display("Storing %h to address %h",
							//	__stage_execute_input_data.rfile_ra_data,
							//	(__locals.ldst_adder_a 
							//	+ __locals.ldst_adder_b));
							prep_mem_write(__locals.ldst_address,
								PkgFrost32Cpu::Dias32,
								__stage_execute_input_data.rfile_ra_data);
						end
						PkgInstrDecoder::St16:
						begin
							prep_mem_write(__locals.ldst_address,
								PkgFrost32Cpu::Dias16,
								__stage_execute_input_data.rfile_ra_data);
						end
						PkgInstrDecoder::St8:
						begin
							prep_mem_write(__locals.ldst_address,
								PkgFrost32Cpu::Dias8,
								__stage_execute_input_data.rfile_ra_data);
						end
					endcase
					end

					2:
					begin
						prep_load_instruction
							(__following_pc_stage_execute);
					end
				endcase
			end

			// For branches, completely resolve conditional execution in
			// this stage
			PkgFrost32Cpu::StCtrlFlowBranch:
			begin
				case (__stage_instr_decode_data.stall_counter)
					2:
					begin
						case (__multi_stage_data_execute
							.instr_condition_type)
						//case (__multi_stage_data_register_read
						//	.instr_condition_type)
							PkgInstrDecoder::CtNe:
							begin
								//$display("bne");
								handle_branch_in_fetch_stage
									(__locals.cond_ne);
							end

							PkgInstrDecoder::CtEq:
							begin
								$display("beq stuff:  %h %h %h",
									__locals.cond_eq,
									__stage_instr_decode_data
									.from_stage_execute_rfile_ra_data,
									__stage_instr_decode_data
									.from_stage_execute_rfile_ra_data);
								$display("beq");

								handle_branch_in_fetch_stage
									(__locals.cond_eq);
							end

							PkgInstrDecoder::CtLtu:
							begin
								//$display("bltu");
								handle_branch_in_fetch_stage
									(__locals.cond_ltu);
							end
							PkgInstrDecoder::CtGeu:
							begin
								//$display("bgeu");
								handle_branch_in_fetch_stage
									(__locals.cond_geu);
							end

							PkgInstrDecoder::CtLeu:
							begin
								//$display("bleu");
								handle_branch_in_fetch_stage
									(__locals.cond_leu);
							end
							PkgInstrDecoder::CtGtu:
							begin
								//$display("bgtu");
								handle_branch_in_fetch_stage
									(__locals.cond_gtu);
							end

							PkgInstrDecoder::CtLts:
							begin
								//$display("blts");
								handle_branch_in_fetch_stage
									(__locals.cond_lts);
							end
							PkgInstrDecoder::CtGes:
							begin
								//$display("bges");
								$display("bges stuff:  %h %h %h",
									__locals.cond_ges,
									__stage_instr_decode_data
									.from_stage_execute_rfile_ra_data,
									__stage_instr_decode_data
									.from_stage_execute_rfile_rb_data);
								handle_branch_in_fetch_stage
									(__locals.cond_ges);
							end

							PkgInstrDecoder::CtLes:
							begin
								//$display("bles");
								handle_branch_in_fetch_stage
									(__locals.cond_les);
							end
							PkgInstrDecoder::CtGts:
							begin
								//$display("bgts");
								handle_branch_in_fetch_stage
									(__locals.cond_gts);
							end

							default:
							begin
								//// Eek!
								//__locals.pc <= __following_pc;
								//prep_mem_read(__following_pc,
								//	PkgFrost32Cpu::Dias32);
								//__locals.dest_of_ctrl_flow_if_condition
								//	<= __following_pc;

								$display("branch eek!");
								prep_load_instruction
									(__following_pc_stage_execute);
							end
						endcase
					end
				endcase
			end

			PkgFrost32Cpu::StCtrlFlowJumpCall:
			begin
				case (__stage_instr_decode_data.stall_counter)
					2:
					begin
						$display("in StCtrlFlowJumpCall");
						case (__multi_stage_data_execute
							.instr_condition_type)
						//case (__multi_stage_data_execute
						//	.instr_condition_type[0])
							PkgInstrDecoder::CtNe:
							begin
								handle_jump_or_call_in_fetch_stage
									(__locals.cond_ne);
							end

							PkgInstrDecoder::CtEq:
							begin
								handle_jump_or_call_in_fetch_stage
									(__locals.cond_eq);
							end

							PkgInstrDecoder::CtLtu:
							begin
								handle_jump_or_call_in_fetch_stage
									(__locals.cond_ltu);
							end
							PkgInstrDecoder::CtGeu:
							begin
								handle_jump_or_call_in_fetch_stage
									(__locals.cond_geu);
							end

							PkgInstrDecoder::CtLeu:
							begin
								handle_jump_or_call_in_fetch_stage
									(__locals.cond_leu);
							end
							PkgInstrDecoder::CtGtu:
							begin
								handle_jump_or_call_in_fetch_stage
									(__locals.cond_gtu);
							end

							PkgInstrDecoder::CtLts:
							begin
								handle_jump_or_call_in_fetch_stage
									(__locals.cond_lts);
							end
							PkgInstrDecoder::CtGes:
							begin
								handle_jump_or_call_in_fetch_stage
									(__locals.cond_ges);
							end

							PkgInstrDecoder::CtLes:
							begin
								handle_jump_or_call_in_fetch_stage
									(__locals.cond_les);
							end
							PkgInstrDecoder::CtGts:
							begin
								handle_jump_or_call_in_fetch_stage
									(__locals.cond_gts);
							end

							default:
							begin
								// Eek!
							$display("Jump or call in fetch stage:  %s",
								"Eek!");
								prep_load_instruction
									(__following_pc_stage_execute);
							end
						endcase
					end

				endcase
			end

			PkgFrost32Cpu::StInit:
			begin
				$display("StInit:  %h",
					__stage_instr_decode_data.stall_counter);
				case (__stage_instr_decode_data.stall_counter)
					2:
					begin
						//prep_load_instruction
						//	(__following_pc);
						//prep_load_instruction
						//	(__locals.pc);
						//$display("Stuffs:  2");
						prep_load_instruction(0);
					end
				endcase
			end

			PkgFrost32Cpu::StReti:
			begin
				case (__stage_instr_decode_data.stall_counter)
					2:
					begin
						//__locals.ie <= 1;
						//$display("StReti:  %h", __locals.ireta);
						prep_load_instruction(__locals.ireta);
					end
				endcase
			end
			PkgFrost32Cpu::StRespondToInterrupt:
			begin
				$display("StRespondToInterrupt");
				//prep_load_instruction(__locals.pc + 4);
				//prep_load_following_instruction();
				//case (__stage_instr_decode_data.stall_counter)
				//	2:
				//	begin
				//		
				//	end
				//endcase
			end

			//PkgFrost32Cpu::StMul:
			//begin
			//	
			//end
			PkgFrost32Cpu::StMulDiv:
			begin
				$display("StMulDiv stall_counter:  %h",
					__stage_instr_decode_data.stall_counter);
				case (__stage_instr_decode_data.stall_counter)
					2:
					begin
						prep_load_instruction
							(__following_pc_stage_execute);
					end
				endcase
			end
			endcase
		end

		//else // if (__stage_instr_decode_data.stall_counter == 0)
		else // if (!in_stall())
		begin
			if (!__locals.should_service_interrupt_if_not_in_stall)
			begin
				if (__multi_stage_data_instr_decode.instr_causes_stall)
				begin
					//__multi_stage_data_instr_decode.raw_instruction
					//	<= in.data;
					//$display("!in_stall(), instr causes stall");
				end

				else // if (!__multi_stage_data_instr_decode
					// .instr_causes_stall)
				begin
					//prep_load_instruction(__locals.pc);
					prep_load_instruction(__locals.pc + 4);
					//__locals.pc <= __locals.pc + 4;
					//__multi_stage_data_instr_decode.raw_instruction
					//	<= in.data;
				end
			end

			else // if (__locals.should_service_interrupt_if_not_in_stall)
			begin
				//__locals.pc <= __locals.idsta;
				$display("fetch stage:  Servicing interrupt:  %h",
					__locals.idsta);
				prep_load_instruction(__locals.idsta);
			end
		end
	end

	else // if (in.wait_for_mem)
	begin
		stop_mem_access();
	end
	end

	// Stage 1:  Instruction Decode
	always @ (posedge clk)
	begin
	if (!in.wait_for_mem)
	begin
		if (in_stall())
		begin
			// Decrement the stall counter
			__stage_instr_decode_data.stall_counter
				<= __stage_instr_decode_data.stall_counter - 1;

			// Make a bubble while we wait for memory
			if (__stage_instr_decode_data.stall_counter == 1)
			begin
				make_bubble();
			end

			//if (__stage_instr_decode_data.stall_counter == 1)
			//begin
			//	__multi_stage_data_instr_decode.pc_val
			//		<= __locals.pc;
			//end

			case (__stage_instr_decode_data.stall_state)
				PkgFrost32Cpu::StCpyRaToInterruptsRelatedAddr:
				begin
					case (__stage_instr_decode_data.stall_counter)
					2:
					begin
						// "cpy ireta, rA"
						if (__multi_stage_data_execute.instr_opcode
							== PkgInstrDecoder::Cpy_OneIretaOneReg)
						begin
							__locals.ireta 
								<= __stage_instr_decode_data
								.from_stage_execute_rfile_ra_data;
						end

						// "cpy idsta, rA"
						else
						begin
							__locals.idsta 
								<= __stage_instr_decode_data
								.from_stage_execute_rfile_ra_data;
						end

						////prep_load_instruction(__following_pc);
						//prep_load_instruction
						//	(__following_pc_stage_execute);
					end

					//1:
					//begin
					//	//prep_load_following_instruction();
					//end
					endcase
				end

			endcase
		end

		//else // if (__stage_instr_decode_data.stall_counter == 0)
		else // if (!in_stall())
		begin
			//if (!(in.interrupt && __locals.ie))
			//if ((in.interrupt && !__locals.ie) || (!in.interrupt))
			if (!__locals.should_service_interrupt_if_not_in_stall)
			begin
				if (__multi_stage_data_instr_decode.instr_causes_stall)
				begin
					// Multiply or divide
					case (__multi_stage_data_instr_decode.instr_group)
					0:
					begin
						//$display("Stalling instruction from group 0");
						if (__multi_stage_data_instr_decode.instr_opcode
							== PkgInstrDecoder::Mul_ThreeRegs)
						begin
							//__stage_instr_decode_data.stall_state
							//	<= PkgFrost32Cpu::StMul;
							__stage_instr_decode_data.stall_counter
								<= __STALL_COUNTER_MULTIPLY_32;
							//__stage_instr_decode_data.stall_counter
							//	<= __STALL_COUNTER_MULTIPLY_32;
						end

						else // if (udiv or sdiv)
						begin
							//$display("udiv or sdiv");
							__stage_instr_decode_data.stall_counter
								<= __STALL_COUNTER_DIVIDE_32;
						end
						__stage_instr_decode_data.stall_state
							<= PkgFrost32Cpu::StMulDiv;
					end

					// Multiply rB by zero-extended immediate
					1:
					begin
						__stage_instr_decode_data.stall_counter
							<= __STALL_COUNTER_MULTIPLY_32;
					end

					// Conditional branch 
					2:
					begin
						$display("Stage 1:  conditional branch:  %h",
							__STALL_COUNTER_RELATIVE_BRANCH);
						__stage_instr_decode_data.stall_state
							<= PkgFrost32Cpu::StCtrlFlowBranch;

						//__stage_instr_decode_data.stall_counter <= 1;
						__stage_instr_decode_data.stall_counter
							<= __STALL_COUNTER_RELATIVE_BRANCH;
						//__stage_instr_decode_data.stall_counter <= 2;
					end

					// Conditional jump or conditional call
					3:
					begin
						__stage_instr_decode_data.stall_state
							<= PkgFrost32Cpu::StCtrlFlowJumpCall;

						//__stage_instr_decode_data.stall_counter <= 2;
						__stage_instr_decode_data.stall_counter
							<= __STALL_COUNTER_JUMP_OR_CALL;
					end
					4:
					begin
						$display("The instruction stalls:  call");
						__stage_instr_decode_data.stall_state
							<= PkgFrost32Cpu::StCtrlFlowJumpCall;

						//__stage_instr_decode_data.stall_counter <= 2;
						__stage_instr_decode_data.stall_counter
							<= __STALL_COUNTER_JUMP_OR_CALL;
					end

					// All loads and stores are in group 5
					5:
					begin
						__stage_instr_decode_data.stall_state 
							<= PkgFrost32Cpu::StMemAccess;
						__stage_instr_decode_data.stall_counter
							<= __STALL_COUNTER_MEM_ACCESS;
					end

					// "cpy ireta, rA"
					// "cpy idsta, rA"
					// "reti"
					6:
					begin
						if (__multi_stage_data_instr_decode.instr_opcode
							!= PkgInstrDecoder::Reti_NoArgs)
						begin
							__stage_instr_decode_data.stall_state
								<= PkgFrost32Cpu
								::StCpyRaToInterruptsRelatedAddr;
							__stage_instr_decode_data.stall_counter
								<= __STALL_COUNTER_INTERRUPTS_STUFF;
						end

						else
						begin
							__stage_instr_decode_data.stall_state
								<= PkgFrost32Cpu::StReti;
							__stage_instr_decode_data.stall_counter
								<= __STALL_COUNTER_RETI;
							__locals.ie <= 1;
							//$display("StReti:  %h %h", __locals.ireta,
							//	__out_debug_reg_sp);
						end

					end

					// Eek!
					//else
					default:
					begin
						$display("instr_causes_stall:  Eek!");
						__stage_instr_decode_data.stall_state 
							<= PkgFrost32Cpu::StInit;
						__stage_instr_decode_data.stall_counter
							<= __STALL_COUNTER_EEK;
					end
					endcase
				end

				// Handle what the execute stage sees next
				if ((__multi_stage_data_instr_decode.instr_group == 6)
					&& ((__multi_stage_data_instr_decode.instr_opcode 
					== PkgInstrDecoder::Ei_NoArgs)
					|| (__multi_stage_data_instr_decode.instr_opcode
					== PkgInstrDecoder::Di_NoArgs)))
				begin
					__locals.ie <= (__multi_stage_data_instr_decode
						.instr_opcode == PkgInstrDecoder::Ei_NoArgs);

					// Just send a bubble through to the later stage(s)
					// since they don't really need to know anything about
					// "ei" and "di"
					make_bubble();
				end

				else
				begin
					send_instr_through();
				end
			end

			else // if (__locals.should_service_interrupt_if_not_in_stall)
			begin
				//// Send a bubble through 
				//make_bubble();
				$display("Interrupt happened:  %h %h %h",
					//__locals.pc,
					__multi_stage_data_instr_decode.pc_val,
					__locals.idsta,
					__locals.ireta);

				__locals.ireta <= __multi_stage_data_instr_decode.pc_val;
				//__locals.ireta <= __locals.pc;
				__locals.ie <= 0;

				__stage_instr_decode_data.stall_state
					<= PkgFrost32Cpu::StRespondToInterrupt;
				__stage_instr_decode_data.stall_counter
					<= __STALL_COUNTER_RESPOND_TO_INTERRUPTS;

				make_bubble();
			end
		end
	end

	end

	//// Stage 2:  Register read
	//always @ (posedge clk)
	//begin
	//if (!in.wait_for_mem)
	//begin
	//	//__stage_register_read_output_data.rfile_ra_data
	//	//	<= __regfile[__multi_stage_data_register_read.instr_ra_index];
	//	//__stage_register_read_output_data.rfile_rb_data
	//	//	<= __regfile[__multi_stage_data_register_read.instr_rb_index];
	//	//__stage_register_read_output_data.rfile_rc_data
	//	//	<= __regfile[__multi_stage_data_register_read.instr_rc_index];

	//	__stage_execute_input_data.ireta_data
	//		<= __stage_register_read_input_data.ireta_data;
	//	__stage_execute_input_data.idsta_data
	//		<= __stage_register_read_input_data.idsta_data;

	//	//$display("Register read:  Sending opcode through:  %h",
	//	//	__multi_stage_data_register_read.instr_opcode);
	//	__multi_stage_data_execute <= __multi_stage_data_register_read;

	//end
	//end


	// Stage 2:  Execute

	always @ (posedge clk)
	begin
	if (!in.wait_for_mem)
	begin
		__multi_stage_data_write_back <= __multi_stage_data_execute;
		case (__multi_stage_data_execute.instr_group)
			// Group 0:  Three register ALU operations
			4'd0:
			begin
				//if (__multi_stage_data_execute.instr_opcode 
				//	!= PkgInstrDecoder::Mul_ThreeRegs)
				case (__multi_stage_data_execute.instr_opcode)
					PkgInstrDecoder::Mul_ThreeRegs:
					begin
						ctrl_multiply_32
							(__stage_execute_input_data.rfile_rb_data,
							__stage_execute_input_data.rfile_rc_data);
					end

					//PkgInstrDecoder::Bad0_Iog0:
					//begin
					//	// Eek!
					//	//stop_reg_write();
					//	stop_operand_forwarding_or_write_back();
					//	//stop_register_read_operand_forwarding();
					//end

					//PkgInstrDecoder::Bad1_Iog0:
					//begin
					//	// Eek!
					//	//stop_reg_write();
					//	stop_operand_forwarding_or_write_back();
					//	//stop_register_read_operand_forwarding();
					//end
					PkgInstrDecoder::Udiv_ThreeRegs:
					begin
						//$display("execute stage:  udiv");
						ctrl_divide_32(0);
					end

					PkgInstrDecoder::Sdiv_ThreeRegs:
					begin
						//$display("execute stage:  sdiv");
						ctrl_divide_32(1);
					end

					default:
					begin
						//$display("Three registers ALU operation:  %h",
						//	__out_alu.data);
						//__stage_write_back_input_data.n_reg_data 
						//	<= __out_alu.data;
						prep_ra_wb(__out_alu.data);
						//use_ra_for_stage_execute_generated_data
						//	(__out_alu.data);
					end
				endcase
			end

			// Group 1:  instructions that use immediate values
			4'd1:
			begin
				// Imply to synthesis tools that we want a decoder to be
				// formed.
				//$display("Execute stage opcode:  %h",
				//	__multi_stage_data_execute.instr_opcode);
				case (__multi_stage_data_execute.instr_opcode)
					PkgInstrDecoder::Cpyhi_OneRegOneImm:
					begin
						prep_ra_wb(__locals.cpyhi_data);
						//use_ra_for_stage_execute_generated_data
						//	(__locals.cpyhi_data);
					end

					PkgInstrDecoder::Addsi_OneRegOnePcOneSimm:
					begin
						prep_ra_wb(__multi_stage_data_execute.pc_val
						// Sign extend the immediate value with the funky
						// SystemVerilog feature for replicating a single
						// bit.
						 
							+ {{16{__multi_stage_data_execute.instr_imm_val
							[15]}}, 
							__multi_stage_data_execute.instr_imm_val});
						//use_ra_for_stage_execute_generated_data
						//	(__multi_stage_data_execute.pc_val
						//// Sign extend the immediate value with the funky
						//// SystemVerilog feature for replicating a single
						//// bit.
						// 
						//	+ {{16{__multi_stage_data_execute.instr_imm_val
						//	[15]}}, 
						//	__multi_stage_data_execute.instr_imm_val});
					end

					PkgInstrDecoder::Muli_TwoRegsOneImm:
					begin
						ctrl_multiply_32
							(__stage_execute_input_data.rfile_rb_data,
							__multi_stage_data_execute.instr_imm_val);
					end

					// All group 1 instructions opcodes are for valid
					// instructions, so it's okay to have a "default" case
					// here (instead of checking them all individually
					default:
					begin
						prep_ra_wb(__out_alu.data);
						//use_ra_for_stage_execute_generated_data
						//	(__out_alu.data);
					end
				endcase

			end

			4'd2:
			begin
				stop_operand_forwarding_or_write_back();
				//stop_register_read_operand_forwarding();
			end

			4'd3:
			begin
				stop_operand_forwarding_or_write_back();
				//stop_register_read_operand_forwarding();
			end

			// Group 4:  Calls
			4'd4:
			begin
				case (__multi_stage_data_execute.instr_condition_type)
				//case (__multi_stage_data_execute.instr_condition_type[0])
					PkgInstrDecoder::CtNe:
					begin
						handle_call_in_execute_stage(__locals.cond_ne);
					end

					PkgInstrDecoder::CtEq:
					begin
						handle_call_in_execute_stage(__locals.cond_eq);
					end

					PkgInstrDecoder::CtLtu:
					begin
						handle_call_in_execute_stage(__locals.cond_ltu);
					end
					PkgInstrDecoder::CtGeu:
					begin
						handle_call_in_execute_stage(__locals.cond_geu);
					end

					PkgInstrDecoder::CtLeu:
					begin
						handle_call_in_execute_stage(__locals.cond_leu);
					end
					PkgInstrDecoder::CtGtu:
					begin
						handle_call_in_execute_stage(__locals.cond_gtu);
					end

					PkgInstrDecoder::CtLts:
					begin
						handle_call_in_execute_stage(__locals.cond_lts);
					end
					PkgInstrDecoder::CtGes:
					begin
						handle_call_in_execute_stage(__locals.cond_ges);
					end

					PkgInstrDecoder::CtLes:
					begin
						handle_call_in_execute_stage(__locals.cond_les);
					end
					PkgInstrDecoder::CtGts:
					begin
						handle_call_in_execute_stage(__locals.cond_gts);
					end

					default:
					begin
						//// Prevent "lr" write back for bad opcodes
						//__stage_write_back_input_data.do_write_lr <= 0;
						stop_operand_forwarding_or_write_back();
						//stop_register_read_operand_forwarding();
					end
				endcase


			end


			// Group 5:  Loads and stores
			4'd5:
			begin
				// When stall_counter == 1, we know we have got the data
				// from memory, and thus we can then write to the register
				// file.
				// It's actually okay if we just write (most likely
				// invalid) data to rA during the execute stage because
				// the last stall_counter value (== 1) will have the right
				// data ready.
				// 
				// This prevents the need for an extra if statement, and
				// thus should increase my maximum clock rate a little bit.

				if (__stage_instr_decode_data.stall_counter == 1)
				begin
					case (__multi_stage_data_execute.instr_ldst_type)
						PkgInstrDecoder::Ld32:
						begin
							$display("Load into r%d:  %h", 
								__multi_stage_data_execute.instr_ra_index,
								in.data);
							prep_ra_wb(in.data);
							//use_ra_for_stage_execute_generated_data
							//	(in.data);
						end

						PkgInstrDecoder::Ldh_ThreeRegsLdst:
						begin
							// Zero extend
							prep_ra_wb({16'h0000, in.data[15:0]});
							//use_ra_for_stage_execute_generated_data
							//	({16'h0000, in.data[15:0]});
						end

						PkgInstrDecoder::Ldsh_ThreeRegsLdst:
						begin
							// Sign extend with the funky SystemVerilog
							// feature for replicating bits.
							prep_ra_wb({{16{in.data[15]}}, in.data[15:0]});
							//use_ra_for_stage_execute_generated_data
							//	({{16{in.data[15]}}, in.data[15:0]});
						end

						PkgInstrDecoder::Ldb_ThreeRegsLdst:
						begin
							// Zero extend
							prep_ra_wb({24'h000000, in.data[7:0]});
							//use_ra_for_stage_execute_generated_data
							//	({24'h000000, in.data[7:0]});
						end

						PkgInstrDecoder::Ldsb_ThreeRegsLdst:
						begin
							// Sign extend with the funky SystemVerilog
							// feature for replicating bits.
							prep_ra_wb({{24{in.data[7]}}, in.data[7:0]});
							//use_ra_for_stage_execute_generated_data
							//	({{24{in.data[7]}}, in.data[7:0]});
						end

						default:
						begin
							stop_operand_forwarding_or_write_back();
							//stop_register_read_operand_forwarding();
						end
					endcase
				end

				else
				begin
					stop_operand_forwarding_or_write_back();
					//stop_register_read_operand_forwarding();
				end
			end

			// Group 6:  Interrupts stuff
			4'd6:
			begin
				case (__multi_stage_data_execute.instr_opcode)
					// For group 6 instructions, we only perform write back
					// for 
					// "cpy rA, ireta"
					// and
					// "cpy rA, idsta"
					PkgInstrDecoder::Cpy_OneRegOneIreta:
					begin
						prep_ra_wb(__stage_execute_input_data.ireta_data);
						//use_ra_for_stage_execute_generated_data
						//	(__stage_execute_input_data.ireta_data);
					end
					PkgInstrDecoder::Cpy_OneRegOneIdsta:
					begin
						prep_ra_wb(__stage_execute_input_data.idsta_data);
						//use_ra_for_stage_execute_generated_data
						//	(__stage_execute_input_data.idsta_data);
					end

					default:
					begin
						stop_operand_forwarding_or_write_back();
						//stop_register_read_operand_forwarding();
					end
				endcase
			end
		endcase
	end

	else // if (in.wait_for_mem)
	begin
		stop_operand_forwarding_or_write_back();
		//stop_register_read_operand_forwarding();
	end
	end


	// Stage 3:  Write Back
	always @ (posedge clk)
	begin
	if (!in.wait_for_mem)
	begin
		// It's okay if we try to write to register zero.
		prep_reg_write(__stage_execute_output_data
			.prev_written_reg_index,
			__stage_execute_output_data.n_reg_data);
	end
	end


	// ALU input stuff
	always_comb
	begin
	if (!in.wait_for_mem)
	begin
		case (__multi_stage_data_execute.instr_group)
			// Group 0:  Three-register ALU operations
			0:
			begin
				__in_alu.a = __stage_execute_input_data.rfile_rb_data;
				// It's okay if the ALU performs a bogus operation, so
				// let's decode the ALU opcode directly from the
				// instruction for group 0 instructions.
				__in_alu.b = __stage_execute_input_data.rfile_rc_data;
				__in_alu.oper = __multi_stage_data_execute.instr_opcode;

				//$display("group 0 ALU stuff:  %h %h %h",
				//	__in_alu.a, __in_alu.b, __in_alu.oper);
			end

			// Group 1:  Immediates
			1:
			begin
				__in_alu.a = __stage_execute_input_data.rfile_rb_data;
				__in_alu.oper = __multi_stage_data_execute.instr_opcode;
				//__in_alu.oper = __multi_stage_data_execute.instr_opcode;

				case (__multi_stage_data_execute.instr_opcode)
					PkgInstrDecoder::Sltsi_TwoRegsOneSimm:
					begin
						// Sign extend the immediate value
						__in_alu.b 
							= {{16{__multi_stage_data_execute.instr_imm_val
							[15]}}, 
							__multi_stage_data_execute.instr_imm_val};

						//__in_alu.oper = PkgAlu::Slts;
					end
					PkgInstrDecoder::Sgtsi_TwoRegsOneSimm:
					begin
						// Sign extend the immediate value
						__in_alu.b 
							= {{16{__multi_stage_data_execute.instr_imm_val
							[15]}}, 
							__multi_stage_data_execute.instr_imm_val};

						//__in_alu.oper = PkgAlu::Slts;
					end

					// Let's decode the ALU opcode directly from the
					// instruction for the remainder of the
					// instructions from group 1
					default:
					begin
						// Zero-extend the immediate value
						__in_alu.b = {16'h0000,
							__multi_stage_data_execute.instr_imm_val};
						//__in_alu.oper = __multi_stage_data_execute
						//	.instr_opcode;
					end
				endcase

				$display("group 1 immediate stuff:  %h %h %h",
					__in_alu.a, __in_alu.b, __in_alu.oper);
			end


			default:
			begin
				__in_alu.a = 0;
				__in_alu.oper = 0;
				__in_alu.b = 0;
				//__in_alu.oper = 0;
			end
		endcase
		//__in_alu.a = __stage_execute_input_data.rfile_rb_data
	end

	else // if (in.wait_for_mem)
	begin
		__in_alu.a = 0;
		__in_alu.oper = 0;
		__in_alu.b = 0;
		//__in_alu.oper = 0;
	end
	end

endmodule
