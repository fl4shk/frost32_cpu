`include "src/misc_defines.header.sv"
`include "src/instr_decoder_defines.header.sv"
`include "src/alu_defines.header.sv"
`include "src/register_file_defines.header.sv"

`ifdef HAVE_REGISTER_READ_STAGE
`define MULTI_STAGE_DATA_AFTER_INSTR_DECODE \
	__multi_stage_data_register_read
`define STAGE_AFTER_INSTR_DECODE_INPUT_DATA \
	__stage_register_read_input_data
`define LOCALS_CONDITION_ALWAYS_BLOCK_TYPE always @ (posedge clk)
`define LOCALS_CONDITION_ASSIGNMENT_TYPE <=
`else
`define MULTI_STAGE_DATA_AFTER_INSTR_DECODE \
	__multi_stage_data_execute
`define STAGE_AFTER_INSTR_DECODE_INPUT_DATA \
	__stage_execute_input_data
`define LOCALS_CONDITION_ALWAYS_BLOCK_TYPE always_comb
`define LOCALS_CONDITION_ASSIGNMENT_TYPE =
`endif

module Frost32Cpu(input logic clk,
	input PkgFrost32Cpu::PortIn_Frost32Cpu in,
	output PkgFrost32Cpu::PortOut_Frost32Cpu out);


	import PkgInstrDecoder::*;
	import PkgAlu::*;
	import PkgRegisterFile::*;
	import PkgFrost32Cpu::*;

	parameter __REG_LR_INDEX = 13;
	parameter __REG_SP_INDEX = 15;

	`ifdef HAVE_REGISTER_READ_STAGE
	//parameter __STALL_COUNTER_RELATIVE_BRANCH = 2;
	parameter __STALL_COUNTER_RELATIVE_BRANCH = 1;
	parameter __STALL_COUNTER_JUMP_OR_CALL = 3;
	parameter __STALL_COUNTER_MEM_ACCESS = 3;
	parameter __STALL_COUNTER_CPY_TO_IRETA_IDSTA = 2;
	parameter __STALL_COUNTER_EEK = 3;
	`else
	parameter __STALL_COUNTER_RELATIVE_BRANCH = 1;
	parameter __STALL_COUNTER_JUMP_OR_CALL = 2;
	parameter __STALL_COUNTER_MEM_ACCESS = 2;
	parameter __STALL_COUNTER_CPY_TO_IRETA_IDSTA = 1;
	parameter __STALL_COUNTER_EEK = 2;
	`endif		// HAVE_REGISTER_READ_STAGE


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

		logic [`MSB_POS__REG_FILE_DATA:0] 
			from_stage_execute_rfile_ra_data,
			from_stage_execute_rfile_rb_data,
			from_stage_execute_rfile_rc_data;

		logic [`MSB_POS__REG_FILE_DATA:0]
			from_stage_register_read_rfile_cond_ra_data,
			from_stage_register_read_rfile_cond_rb_data;
	} __stage_instr_decode_data;

	// Data input to the execute stage
	struct packed
	{
		logic [`MSB_POS__REG_FILE_DATA:0] rfile_ra_data, rfile_rb_data,
			rfile_rc_data;

		logic [`MSB_POS__FROST32_CPU_ADDR:0] ireta_data, idsta_data;

		//logic [`MSB_POS__FROST32_CPU_ADDR:0] next_pc;
	} 
	`ifdef HAVE_REGISTER_READ_STAGE
		__stage_register_read_input_data, 
	`endif
		//__stage_use_alu_input_data,
		__stage_execute_input_data;

	`ifdef HAVE_REGISTER_READ_STAGE
	struct packed
	{
		logic [`MSB_POS__REG_FILE_SEL:0] prev_written_reg_index;
	} __stage_register_read_output_data;
	`endif		// HAVE_REGISTER_READ_STAGE

	struct packed
	{
		// The next program counter for load and store instructions that
		// stall (read by the instruction decode stage for updating the
		// program counter in the case of these instructions)
		logic [`MSB_POS__FROST32_CPU_ADDR:0] next_pc_after_ldst;

		logic [`MSB_POS__REG_FILE_SEL:0] prev_written_reg_index;

		//logic perform_operand_forwarding;
	} __stage_execute_output_data;

	// Data input to the write back stage (output
	struct packed
	{
		// These are written by the execute stage
		logic [`MSB_POS__REG_FILE_DATA:0] rfile_ra_data, rfile_rb_data,
			rfile_rc_data;

		logic [`MSB_POS__ALU_INOUT:0] n_reg_data;

		logic do_write_lr;

	} __stage_write_back_input_data;

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

		// Split up 32-bit by 32-bit multiplications into three 16-bit by
		// 16-bit multiplications (which I believe can be synthesized into
		// combinational logic) and some adds.
		logic [`MSB_POS__ALU_INOUT:0] mul_partial_result_x0_y0,
			mul_partial_result_x1_y0, mul_partial_result_x0_y1;

		logic [`MSB_POS__FROST32_CPU_ADDR:0] 
			branch_adder_a, branch_adder_b;
		logic [`MSB_POS__FROST32_CPU_ADDR:0] 
			dest_of_ctrl_flow_if_condition, next_pc_after_jump_or_call;
		logic [`MSB_POS__FROST32_CPU_ADDR:0] 
			ldst_adder_a, ldst_adder_b;
		logic [`MSB_POS__FROST32_CPU_ADDR:0] ldst_address;


		// Conditions (put them all in one place so I don't make a mistake)
		`ifdef HAVE_REGISTER_READ_STAGE
		logic cond_branch_ne, cond_branch_eq, 
			cond_branch_ltu, cond_branch_geu, 
			cond_branch_leu, cond_branch_gtu,
			cond_branch_lts, cond_branch_ges, 
			cond_branch_les, cond_branch_gts;
		`endif		// HAVE_REGISTER_READ_STAGE

		logic cond_ne, cond_eq, 
			cond_ltu, cond_geu, cond_leu, cond_gtu,
			cond_lts, cond_ges, cond_les, cond_gts;


		logic [`MSB_POS__REG_FILE_DATA:0] cpyhi_data;

		`ifdef DEBUG
		// Debugging thing
		logic [31:0] cycles_counter;
		`endif		// DEBUG


	} __locals;


	logic [`MSB_POS__FROST32_CPU_ADDR:0] __following_pc,
		// Used if there's a register read stage
		__following_pc_branch;

	PkgFrost32Cpu::MultiStageData __multi_stage_data_instr_decode, 
		`ifdef HAVE_REGISTER_READ_STAGE
		__multi_stage_data_register_read, 
		`endif		// HAVE_REGISTER_READ_STAGE
		__multi_stage_data_execute, 
		__multi_stage_data_write_back;



	`ifdef DEBUG_REGISTER_FILE
	logic [`MSB_POS__REG_FILE_DATA:0] 
		__out_debug_reg_zero, __out_debug_reg_u0,
		__out_debug_reg_u1, __out_debug_reg_u2, 
		__out_debug_reg_u3, __out_debug_reg_u4,
		__out_debug_reg_u5, __out_debug_reg_u6, 
		__out_debug_reg_u7, __out_debug_reg_u8,
		__out_debug_reg_u9, __out_debug_reg_u10, 
		__out_debug_reg_temp, __out_debug_reg_lr,
		__out_debug_reg_fp, __out_debug_reg_sp;
	`endif


	// Module instantiations
	logic [`MSB_POS__INSTRUCTION:0] __in_instr_decoder;
	PkgInstrDecoder::PortOut_InstrDecoder __out_instr_decoder;
	InstrDecoder __inst_instr_decoder(.in(__in_instr_decoder), 
		.out(__out_instr_decoder));

	PkgRegisterFile::PortIn_RegFile __in_reg_file;
	PkgRegisterFile::PortOut_RegFile __out_reg_file;
	RegisterFile __inst_reg_file(.clk(clk), .in(__in_reg_file),
		.out(__out_reg_file)
		`ifdef DEBUG_REGISTER_FILE
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
		`endif		// DEBUG_REGISTER_FILE
		);

	`ifdef DEBUG_REGISTER_FILE
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

	`ifdef DEBUG
	always @ (posedge clk)
	begin
		//__locals.cycles_counter <= __locals.cycles_counter + 1;

		//$display("Frost32Cpu __locals.cycles_counter:  %h", 
		//	__locals.cycles_counter);
	if (!in.wait_for_mem)
	begin
		`ifdef HAVE_REGISTER_READ_STAGE
		$display("Frost32Cpu pc's:  %h %h %h %h", 
			__multi_stage_data_instr_decode.pc_val, 
			__multi_stage_data_register_read.pc_val,
			__multi_stage_data_execute.pc_val,
			__multi_stage_data_write_back.pc_val);
		`else
		$display("Frost32Cpu pc's:  %h %h %h", 
			__multi_stage_data_instr_decode.pc_val, 
			__multi_stage_data_execute.pc_val,
			__multi_stage_data_write_back.pc_val);
		`endif		// HAVE_REGISTER_READ_STAGE
		`ifdef DEBUG_REGISTER_FILE
		$display("Frost32Cpu special purpose regs:  %h %h %h",
			__locals.ireta, __locals.idsta, __locals.ie);

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

		`ifdef DEBUG_INSTR_DECODER
		`include "src/debug_instr_decoder.header.sv"
		`endif		// DEBUG_INSTR_DECODER
		$display();
	end

		//$display();
	end
	`endif		// DEBUG

	// Assignments
	assign __following_pc = __multi_stage_data_execute.pc_val + 4;
	`ifdef HAVE_REGISTER_READ_STAGE
	assign __following_pc_branch 
		= __multi_stage_data_register_read.pc_val + 4;
	`endif		// HAVE_REGISTER_READ_STAGE
	assign __in_instr_decoder = in.data;
	assign __multi_stage_data_instr_decode.raw_instruction 
		= __in_instr_decoder;
	assign __multi_stage_data_instr_decode.instr_ra_index
		= __out_instr_decoder.ra_index;
	assign __multi_stage_data_instr_decode.instr_rb_index
		= __out_instr_decoder.rb_index;
	assign __multi_stage_data_instr_decode.instr_rc_index
		= __out_instr_decoder.rc_index;
	assign __multi_stage_data_instr_decode.instr_imm_val
		= __out_instr_decoder.imm_val;
	assign __multi_stage_data_instr_decode.instr_group
		= __out_instr_decoder.group;
	assign __multi_stage_data_instr_decode.instr_opcode
		= __out_instr_decoder.opcode;
	assign __multi_stage_data_instr_decode.instr_ldst_type
		= __out_instr_decoder.ldst_type;
	assign __multi_stage_data_instr_decode.instr_causes_stall
		= __out_instr_decoder.causes_stall;
	assign __multi_stage_data_instr_decode.instr_condition_type
		= __out_instr_decoder.condition_type;
	assign __multi_stage_data_instr_decode.pc_val
		= __locals.pc;

	assign __multi_stage_data_instr_decode.nop = 0;


	always_comb
	begin
		__in_reg_file.read_sel_cond_ra 
			= __multi_stage_data_instr_decode.instr_ra_index;
	end

	always_comb
	begin
		__in_reg_file.read_sel_cond_rb 
			= __multi_stage_data_instr_decode.instr_rb_index;
	end

	// This is the operand forwarding.  It's so simple!
	// We only write to one register at a time, so we only need one
	// multiplexer per rfile_r..._data
	always_comb
	begin
		__stage_execute_input_data.rfile_ra_data
			= ((__stage_execute_output_data.prev_written_reg_index
			== __multi_stage_data_execute.instr_ra_index)
			&& (__stage_execute_output_data.prev_written_reg_index != 0))
			? __stage_write_back_input_data.n_reg_data
			: __out_reg_file.read_data_ra;
	end
	always_comb
	begin
		__stage_execute_input_data.rfile_rb_data
			= ((__stage_execute_output_data.prev_written_reg_index
			== __multi_stage_data_execute.instr_rb_index)
			&& (__stage_execute_output_data.prev_written_reg_index != 0))
			? __stage_write_back_input_data.n_reg_data
			: __out_reg_file.read_data_rb;
	end
	always_comb
	begin
		__stage_execute_input_data.rfile_rc_data
			= ((__stage_execute_output_data.prev_written_reg_index
			== __multi_stage_data_execute.instr_rc_index)
			&& (__stage_execute_output_data.prev_written_reg_index != 0))
			? __stage_write_back_input_data.n_reg_data
			: __out_reg_file.read_data_rc;
	end

	always_comb
	begin
		`ifdef HAVE_REGISTER_READ_STAGE
		if ((__stage_execute_output_data.prev_written_reg_index
			== __multi_stage_data_execute.instr_ra_index)
			&& (__stage_register_read_output_data.prev_written_reg_index
			== __multi_stage_data_register_read.instr_ra_index)
			&& (__multi_stage_data_register_read.instr_ra_index
			== __stage_register_read_output_data.prev_written_reg_index)
			&& (__stage_register_read_output_data.prev_written_reg_index
			!= 0))
		begin
			__stage_instr_decode_data
				.from_stage_register_read_rfile_cond_ra_data
				= __stage_write_back_input_data.n_reg_data;
		end

		else
		begin
			__stage_instr_decode_data
				.from_stage_register_read_rfile_cond_ra_data
				= __out_reg_file.read_data_cond_ra;
		end
		`else
		__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_ra_data
			= __stage_instr_decode_data.from_stage_execute_rfile_ra_data;
		`endif		// HAVE_REGISTER_READ_STAGE
	end
	always_comb
	begin
		`ifdef HAVE_REGISTER_READ_STAGE
		if ((__stage_execute_output_data.prev_written_reg_index
			== __multi_stage_data_execute.instr_rb_index)
			&& (__stage_register_read_output_data.prev_written_reg_index
			== __multi_stage_data_register_read.instr_rb_index)
			&& (__multi_stage_data_register_read.instr_rb_index
			== __stage_register_read_output_data.prev_written_reg_index)
			&& (__stage_register_read_output_data.prev_written_reg_index
			!= 0))
		begin
			__stage_instr_decode_data
				.from_stage_register_read_rfile_cond_rb_data
				= __stage_write_back_input_data.n_reg_data;
		end

		else
		begin
			__stage_instr_decode_data
				.from_stage_register_read_rfile_cond_rb_data
				= __out_reg_file.read_data_cond_rb;
		end
		`else
		__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_rb_data
			= __stage_instr_decode_data.from_stage_execute_rfile_rb_data;
		`endif		// HAVE_REGISTER_READ_STAGE
	end

	// Just some copies for use in the decode stage.
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
	`ifdef HAVE_REGISTER_READ_STAGE
	always_comb
	begin
		__locals.cond_branch_ne
			= (__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_ra_data
			!= __stage_instr_decode_data
			.from_stage_register_read_rfile_cond_rb_data);
	end
	always_comb
	begin
		__locals.cond_branch_eq
			= (__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_ra_data
			== __stage_instr_decode_data
			.from_stage_register_read_rfile_cond_rb_data);
	end
	always_comb
	begin
		//__locals.cond_branch_ltu = __out_compare_ctrl_flow.ltu;
		__locals.cond_branch_ltu
			= (__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_ra_data
			< __stage_instr_decode_data
			.from_stage_register_read_rfile_cond_rb_data);
	end
	always_comb
	begin
		//__locals.cond_branch_geu = !__out_compare_ctrl_flow.ltu;
		//__locals.cond_branch_geu
		//	= (__stage_instr_decode_data
		//	.from_stage_register_read_rfile_cond_ra_data
		//	>= __stage_instr_decode_data
		//	.from_stage_register_read_rfile_cond_rb_data);
		__locals.cond_branch_geu
			= !__locals.cond_branch_ltu;
	end

	always_comb
	begin
		//__locals.cond_branch_leu = !__out_compare_ctrl_flow.gtu;
		__locals.cond_branch_leu
			= (__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_ra_data
			<= __stage_instr_decode_data
			.from_stage_register_read_rfile_cond_rb_data);
	end

	always_comb
	begin
		//__locals.cond_branch_gtu = __out_compare_ctrl_flow.gtu;
		//__locals.cond_branch_gtu
		//	= (__stage_instr_decode_data
		//	.from_stage_register_read_rfile_cond_ra_data
		//	> __stage_instr_decode_data
		//	.from_stage_register_read_rfile_cond_rb_data);
		__locals.cond_branch_gtu
			= !__locals.cond_branch_leu;
	end

	always_comb
	begin
		//__locals.cond_branch_lts = __out_compare_ctrl_flow.lts;
		__locals.cond_branch_lts
			= ($signed(__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_ra_data)
			< $signed(__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_rb_data));
	end

	always_comb
	begin
		//__locals.cond_branch_ges = !__out_compare_ctrl_flow.lts;
		//__locals.cond_branch_ges
		//	= ($signed(__stage_instr_decode_data
		//	.from_stage_register_read_rfile_cond_ra_data)
		//	>= $signed(__stage_instr_decode_data
		//	.from_stage_register_read_rfile_cond_rb_data));
		__locals.cond_branch_ges
			= !__locals.cond_branch_ges;
	end

	always_comb
	begin
		//__locals.cond_branch_les = !__out_compare_ctrl_flow.gts;
		__locals.cond_branch_les
			= ($signed(__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_ra_data)
			<= $signed(__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_rb_data));
	end

	always_comb
	begin
		//__locals.cond_branch_gts = __out_compare_ctrl_flow.gts;
		__locals.cond_branch_gts
			= ($signed(__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_ra_data)
			> $signed(__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_rb_data));
	end
	`endif		// HAVE_REGISTER_READ_STAGE

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
	end


	`LOCALS_CONDITION_ALWAYS_BLOCK_TYPE
	begin
		__locals.cond_ltu
			`LOCALS_CONDITION_ASSIGNMENT_TYPE
			(__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_ra_data
			< __stage_instr_decode_data
			.from_stage_register_read_rfile_cond_rb_data);
	end

	`LOCALS_CONDITION_ALWAYS_BLOCK_TYPE
	begin
		__locals.cond_geu
			`LOCALS_CONDITION_ASSIGNMENT_TYPE
			(__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_ra_data
			>= __stage_instr_decode_data
			.from_stage_register_read_rfile_cond_rb_data);
		//__locals.cond_geu
		//	`LOCALS_CONDITION_ASSIGNMENT_TYPE
		//	!(__stage_instr_decode_data
		//	.from_stage_register_read_rfile_cond_ra_data}
		//	+ (~__stage_instr_decode_data
		//	.from_stage_register_read_rfile_cond_rb_data))
	end

	`LOCALS_CONDITION_ALWAYS_BLOCK_TYPE
	begin
		//__locals.cond_leu = !__out_compare_ctrl_flow.gtu;
		__locals.cond_leu
			`LOCALS_CONDITION_ASSIGNMENT_TYPE
			(__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_ra_data
			<= __stage_instr_decode_data
			.from_stage_register_read_rfile_cond_rb_data);
	end

	`LOCALS_CONDITION_ALWAYS_BLOCK_TYPE
	begin
		//__locals.cond_gtu = __out_compare_ctrl_flow.gtu;
		__locals.cond_gtu
			`LOCALS_CONDITION_ASSIGNMENT_TYPE
			(__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_ra_data
			> __stage_instr_decode_data
			.from_stage_register_read_rfile_cond_rb_data);
	end

	`LOCALS_CONDITION_ALWAYS_BLOCK_TYPE
	begin
		//__locals.cond_lts = __out_compare_ctrl_flow.lts;
		__locals.cond_lts
			`LOCALS_CONDITION_ASSIGNMENT_TYPE
			($signed(__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_ra_data)
			< $signed(__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_rb_data));
	end

	`LOCALS_CONDITION_ALWAYS_BLOCK_TYPE
	begin
		//__locals.cond_ges = !__out_compare_ctrl_flow.lts;
		__locals.cond_ges
			`LOCALS_CONDITION_ASSIGNMENT_TYPE
			($signed(__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_ra_data)
			>= $signed(__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_rb_data));
	end

	`LOCALS_CONDITION_ALWAYS_BLOCK_TYPE
	begin
		//__locals.cond_les = !__out_compare_ctrl_flow.gts;
		__locals.cond_les
			`LOCALS_CONDITION_ASSIGNMENT_TYPE
			($signed(__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_ra_data)
			<= $signed(__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_rb_data));
	end

	`LOCALS_CONDITION_ALWAYS_BLOCK_TYPE
	begin
		//__locals.cond_gts = __out_compare_ctrl_flow.gts;
		__locals.cond_gts
			`LOCALS_CONDITION_ASSIGNMENT_TYPE
			($signed(__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_ra_data)
			> $signed(__stage_instr_decode_data
			.from_stage_register_read_rfile_cond_rb_data));
	end

	always_comb
	begin
		`ifdef HAVE_REGISTER_READ_STAGE
		__locals.branch_adder_a = __following_pc_branch;
		`else
		__locals.branch_adder_a = __following_pc;
		`endif		// HAVE_REGISTER_READ_STAGE
	end

	always_comb
	begin
		// Sign extend the immediate value
		//__in_alu.b 
		//	= {{16{__multi_stage_data_execute.instr_imm_val[15]}}, 
		//	__multi_stage_data_execute.instr_imm_val};

		__locals.branch_adder_b
			= {{16{`MULTI_STAGE_DATA_AFTER_INSTR_DECODE.instr_imm_val
			[15]}}, 
			`MULTI_STAGE_DATA_AFTER_INSTR_DECODE.instr_imm_val};
	end

	//always_comb
	//begin
	//	__locals.dest_of_ctrl_flow_if_condition
	//		= __locals.branch_adder_a + __locals.branch_adder_b;
	//end

	always_comb
	begin
		__locals.ldst_adder_a = __stage_execute_input_data.rfile_rb_data;
	end

	always_comb
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

	//always_comb
	//begin
	//	__locals.ldst_address = __locals.ldst_adder_a
	//		+ __locals.ldst_adder_b;
	//end

	always_comb
	begin
		__in_alu.a = __stage_execute_input_data.rfile_rb_data;
	end

	always_comb
	begin
		__locals.cpyhi_data
			= {__multi_stage_data_execute.instr_imm_val,
			__stage_execute_input_data.rfile_ra_data[15:0]};
	end


	// Tasks and functions
	function logic in_stall();
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

	task prep_load_next_instruction;
		input [`MSB_POS__FROST32_CPU_ADDR:0] addr;

		// Every instruction is 4 bytes long (...for now)
		__locals.pc <= addr;

		prep_mem_read(addr, PkgFrost32Cpu::Dias32);
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

	task prep_reg_write;
		input [`MSB_POS__REG_FILE_SEL:0] s_sel;
		input [`MSB_POS__REG_FILE_DATA:0] s_data;

		__in_reg_file.write_sel <= s_sel;
		__in_reg_file.write_data <= s_data;
		__in_reg_file.write_en <= 1;
	endtask

	task prep_ra_write;
		input [`MSB_POS__REG_FILE_DATA:0] s_data;

		$display("prep_ra_write:  %h %h",
			__multi_stage_data_write_back.instr_ra_index, s_data);
		__in_reg_file.write_sel 
			<= __multi_stage_data_write_back.instr_ra_index;
		__in_reg_file.write_data <= s_data;
		__in_reg_file.write_en <= 1;
	endtask



	task stop_reg_write;
		__in_reg_file.write_en <= 0;
	endtask

	task make_bubble;
		// Send a bubble through while we're stalled a (actually
		// performs "add zero, zero, zero", but that does nothing
		// interesting anyway... besides maybe power consumption)
		__in_reg_file.read_sel_ra <= 0;
		__in_reg_file.read_sel_rb <= 0;
		__in_reg_file.read_sel_rc <= 0;

		//`MULTI_STAGE_DATA_AFTER_INSTR_DECODE <= 0;
		`MULTI_STAGE_DATA_AFTER_INSTR_DECODE.instr_ra_index <= 0;
		`MULTI_STAGE_DATA_AFTER_INSTR_DECODE.instr_rb_index <= 0;
		`MULTI_STAGE_DATA_AFTER_INSTR_DECODE.instr_rc_index <= 0;
		`MULTI_STAGE_DATA_AFTER_INSTR_DECODE.instr_group <= 0;
		`MULTI_STAGE_DATA_AFTER_INSTR_DECODE.instr_opcode <= 0;
		`MULTI_STAGE_DATA_AFTER_INSTR_DECODE.instr_ldst_type <= 0;
		`MULTI_STAGE_DATA_AFTER_INSTR_DECODE.instr_causes_stall <= 0;
		`MULTI_STAGE_DATA_AFTER_INSTR_DECODE.instr_condition_type <= 0;
		//`MULTI_STAGE_DATA_AFTER_INSTR_DECODE.nop <= 1'b1;

	endtask

	//task handle_ctrl_flow_in_decode_stage_part_1;
	task handle_branch_in_decode_stage;
		input condition;

		if (condition)
		begin
			$display("handle_ctrl_flow_in_decode_stage_part_1:  %s",
				"taking branch");
			//prep_load_next_instruction(__out_alu.data);
			//prep_load_next_instruction
			//	(__locals.dest_of_ctrl_flow_if_condition);
			prep_load_next_instruction
				(__locals.branch_adder_a + __locals.branch_adder_b);
			//__locals.dest_of_ctrl_flow_if_condition <= __out_alu.data;
		end

		else // if (!condition)
		begin
			$display("handle_ctrl_flow_in_decode_stage_part_1:  %s",
				"NOT taking branch");
			//__locals.pc <= __following_pc;
			//prep_mem_read(__following_pc, PkgFrost32Cpu::Dias32);
			`ifdef HAVE_REGISTER_READ_STAGE
			prep_load_next_instruction(__following_pc_branch);
			`else
			prep_load_next_instruction(__following_pc);
			`endif		// HAVE_REGISTER_READ_STAGE
			//__locals.dest_of_ctrl_flow_if_condition <= __following_pc;
		end
	endtask

	task handle_jump_or_call_in_decode_stage_part_1;
		input condition;
		
		if (condition)
		begin
			//__locals.next_pc_after_jump_or_call
			//	<= __locals.dest_of_ctrl_flow_if_condition;
			__locals.next_pc_after_jump_or_call
				<= __stage_instr_decode_data
				.from_stage_execute_rfile_rc_data;
		end

		else
		begin
			__locals.next_pc_after_jump_or_call <= __following_pc;
		end
	endtask
	//task handle_ctrl_flow_in_decode_stage_part_2;
	//	prep_load_next_instruction(__locals.dest_of_ctrl_flow_if_condition);
	//endtask

	task handle_call_in_execute_stage;
		input condition;

		if (condition)
		begin
			// We want to store the value of __following_pc in "lr".
			__stage_write_back_input_data.n_reg_data <= __following_pc;
			__stage_write_back_input_data.do_write_lr <= 1;
		end

		else
		begin
			// We want to leave "lr" alone.
			__stage_write_back_input_data.do_write_lr <= 0;
		end
	endtask




	initial
	begin
		// Put NOPs into the stages after decode
		`ifdef HAVE_REGISTER_READ_STAGE
		__multi_stage_data_register_read = 0;
		`endif		// HAVE_REGISTER_READ_STAGE
		__multi_stage_data_execute = 0;
		__multi_stage_data_write_back = 0;

		__stage_instr_decode_data = 0;
		`ifdef HAVE_REGISTER_READ_STAGE
		__stage_register_read_input_data = 0;
		__stage_register_read_output_data = 0;
		`endif		// HAVE_REGISTER_READ_STAGE
		__stage_execute_output_data = 0;
		__stage_write_back_input_data = 0;
		//__stage_instr_decode_data.state = PkgFrost32Cpu::StInit;

		//__locals.pc = 0;
		//__locals.cycles_counter = 0;
		__locals = 0;

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
		__stage_instr_decode_data.stall_counter = 1;
		__stage_instr_decode_data.stall_state = PkgFrost32Cpu::StInit;
	end

	// Stage 0:  Instruction Decode
	always @ (posedge clk)
	begin
	if (!in.wait_for_mem)
	begin
		//$display("Decode:  next_pc:  %h",
		//	__stage_execute_output_data.next_pc);
		//if (__stage_instr_decode_data.stall_counter > 0)
		if (in_stall())
		begin
			// Decrement the stall counter
			__stage_instr_decode_data.stall_counter
				<= __stage_instr_decode_data.stall_counter - 1;
			//$display("in_stall():  %d",
			//	__stage_instr_decode_data.stall_counter);

			make_bubble();


			// The last stall_counter value before it hits zero (this is
			// where the PC should be changed).
			if (__stage_instr_decode_data.stall_counter == 1)
			begin
				__stage_instr_decode_data.stall_state 
					<= PkgFrost32Cpu::StInit;


				if (__stage_instr_decode_data.stall_state
					== PkgFrost32Cpu::StCpyRaToInterruptsRelatedAddr)
				begin
					// Need to use
					// __stage_execute_input_data.rfile_ra_data
					// for operand forwarding purposes

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

					prep_load_next_instruction(__following_pc);
				end

				else if (__stage_instr_decode_data.stall_state
					== PkgFrost32Cpu::StMemAccess)
				begin
					// Prepare a load from memory of the next
					// instruction.  "prep_mem_read()" and
					// "prep_mem_write()" are **ONLY** performed in the
					// decode stage.
					prep_load_next_instruction
						(__stage_execute_output_data.next_pc_after_ldst);
				end


				// For branches, completely resolve conditional execution
				// in this stage
				else if (__stage_instr_decode_data.stall_state
					== PkgFrost32Cpu::StCtrlFlowBranch)
				begin
					//case (__multi_stage_data_execute.instr_condition_type)
					case (`MULTI_STAGE_DATA_AFTER_INSTR_DECODE
						.instr_condition_type)
						PkgInstrDecoder::CtNe:
						begin
							`ifdef HAVE_REGISTER_READ_STAGE
							handle_branch_in_decode_stage
								(__locals.cond_branch_ne);
							`else
							handle_branch_in_decode_stage
								(__locals.cond_ne);
							`endif		// HAVE_REGISTER_READ_STAGE
						end

						PkgInstrDecoder::CtEq:
						begin
							`ifdef HAVE_REGISTER_READ_STAGE
							handle_branch_in_decode_stage
								(__locals.cond_branch_eq);
							`else
							handle_branch_in_decode_stage
								(__locals.cond_eq);
							`endif		// HAVE_REGISTER_READ_STAGE
						end

						PkgInstrDecoder::CtLtu:
						begin
							`ifdef HAVE_REGISTER_READ_STAGE
							handle_branch_in_decode_stage
								(__locals.cond_branch_ltu);
							`else
							handle_branch_in_decode_stage
								(__locals.cond_ltu);
							`endif		// HAVE_REGISTER_READ_STAGE
						end
						PkgInstrDecoder::CtGeu:
						begin
							`ifdef HAVE_REGISTER_READ_STAGE
							handle_branch_in_decode_stage
								(__locals.cond_branch_geu);
							`else
							handle_branch_in_decode_stage
								(__locals.cond_geu);
							`endif		// HAVE_REGISTER_READ_STAGE
						end

						PkgInstrDecoder::CtLeu:
						begin
							`ifdef HAVE_REGISTER_READ_STAGE
							handle_branch_in_decode_stage
								(__locals.cond_branch_leu);
							`else
							handle_branch_in_decode_stage
								(__locals.cond_leu);
							`endif		// HAVE_REGISTER_READ_STAGE
						end
						PkgInstrDecoder::CtGtu:
						begin
							`ifdef HAVE_REGISTER_READ_STAGE
							handle_branch_in_decode_stage
								(__locals.cond_branch_gtu);
							`else
							handle_branch_in_decode_stage
								(__locals.cond_gtu);
							`endif		// HAVE_REGISTER_READ_STAGE
						end

						PkgInstrDecoder::CtLts:
						begin
							`ifdef HAVE_REGISTER_READ_STAGE
							handle_branch_in_decode_stage
								(__locals.cond_branch_lts);
							`else
							handle_branch_in_decode_stage
								(__locals.cond_lts);
							`endif		// HAVE_REGISTER_READ_STAGE
						end
						PkgInstrDecoder::CtGes:
						begin
							`ifdef HAVE_REGISTER_READ_STAGE
							handle_branch_in_decode_stage
								(__locals.cond_branch_ges);
							`else
							handle_branch_in_decode_stage
								(__locals.cond_ges);
							`endif		// HAVE_REGISTER_READ_STAGE
						end

						PkgInstrDecoder::CtLes:
						begin
							`ifdef HAVE_REGISTER_READ_STAGE
							handle_branch_in_decode_stage
								(__locals.cond_branch_les);
							`else
							handle_branch_in_decode_stage
								(__locals.cond_les);
							`endif		// HAVE_REGISTER_READ_STAGE
						end
						PkgInstrDecoder::CtGts:
						begin
							`ifdef HAVE_REGISTER_READ_STAGE
							handle_branch_in_decode_stage
								(__locals.cond_branch_gts);
							`else
							handle_branch_in_decode_stage
								(__locals.cond_gts);
							`endif		// HAVE_REGISTER_READ_STAGE
						end

						default:
						begin
							//// Eek!
							//__locals.pc <= __following_pc;
							//prep_mem_read(__following_pc,
							//	PkgFrost32Cpu::Dias32);
							//__locals.dest_of_ctrl_flow_if_condition
							//	<= __following_pc;

							`ifdef HAVE_REGISTER_READ_STAGE
							prep_load_next_instruction
								(__following_pc_branch);
							`else
							prep_load_next_instruction
								(__following_pc);
							`endif
						end
					endcase
				end

				else if (__stage_instr_decode_data.stall_state
					== PkgFrost32Cpu::StCtrlFlowJumpCall)
				begin
					prep_load_next_instruction
						(__locals.next_pc_after_jump_or_call);
				end

				else if (__stage_instr_decode_data.stall_state
					== PkgFrost32Cpu::StInit)
				begin
					
				end

				else
				begin
					$display("stall_counter == 1:  Eek!");
				end
			end

			else if (__stage_instr_decode_data.stall_counter == 2)
			begin
				if (__stage_instr_decode_data.stall_state
					== PkgFrost32Cpu::StCtrlFlowJumpCall)
				begin
					//__locals.next_pc_after_jump_or_call
					//	<= __stage_instr_decode_data
					//	.from_stage_execute_rfile_rc_data;
					case (__multi_stage_data_execute.instr_condition_type)
						PkgInstrDecoder::CtNe:
						begin
							handle_jump_or_call_in_decode_stage_part_1
								(__locals.cond_ne);
						end

						PkgInstrDecoder::CtEq:
						begin
							handle_jump_or_call_in_decode_stage_part_1
								(__locals.cond_eq);
						end

						PkgInstrDecoder::CtLtu:
						begin
							//handle_jump_or_call_in_decode_stage
							//	(__out_compare_ctrl_flow.ltu);
							handle_jump_or_call_in_decode_stage_part_1
								(__locals.cond_ltu);
						end
						PkgInstrDecoder::CtGeu:
						begin
							handle_jump_or_call_in_decode_stage_part_1
								(__locals.cond_geu);
						end

						PkgInstrDecoder::CtLeu:
						begin
							handle_jump_or_call_in_decode_stage_part_1
								(__locals.cond_leu);
						end
						PkgInstrDecoder::CtGtu:
						begin
							handle_jump_or_call_in_decode_stage_part_1
								(__locals.cond_gtu);
						end

						PkgInstrDecoder::CtLts:
						begin
							handle_jump_or_call_in_decode_stage_part_1
								(__locals.cond_lts);
						end
						PkgInstrDecoder::CtGes:
						begin
							handle_jump_or_call_in_decode_stage_part_1
								(__locals.cond_ges);
						end

						PkgInstrDecoder::CtLes:
						begin
							handle_jump_or_call_in_decode_stage_part_1
								(__locals.cond_les);
						end
						PkgInstrDecoder::CtGts:
						begin
							handle_jump_or_call_in_decode_stage_part_1
								(__locals.cond_gts);
						end

						default:
						begin
							// Eek!
							__locals.next_pc_after_jump_or_call
								<= __following_pc;
						end
					endcase
				end
				// Memory access:  We've done the address computation in
				// the execute stage (within the "always_comb" block
				// located after the "always" block that performs the
				// write back stage)
				else if (__stage_instr_decode_data.stall_state
					== PkgFrost32Cpu::StMemAccess)
				begin
					//// We're in the first cycle after initiating a
					//// multi-cycle load/store instruction.
					//// 
					//// The computed address is in __out_alu.data, and (for
					//// stores) the value to store is in
					//// __stage_execute_input_data.rfile_ra_data.
					case (__multi_stage_data_execute.instr_ldst_type)
						PkgInstrDecoder::Ld32:
						begin
							// Write-back handles the store to the register
							//prep_mem_read(__out_alu.data,
							//	PkgFrost32Cpu::Dias32);
							//$display("Ld32:  %h", __locals.ldst_address);
							//prep_mem_read(__locals.ldst_address,
							//	PkgFrost32Cpu::Dias32);
							$display("Ld32:  %h", 
								__locals.ldst_adder_a 
								+ __locals.ldst_adder_b);
							prep_mem_read((__locals.ldst_adder_a 
								+ __locals.ldst_adder_b),
								PkgFrost32Cpu::Dias32);
						end
						PkgInstrDecoder::LdU16:
						begin
							// Write-back handles the store to the register
							//prep_mem_read(__locals.ldst_address,
							//	PkgFrost32Cpu::Dias16);
							prep_mem_read((__locals.ldst_adder_a 
								+ __locals.ldst_adder_b),
								PkgFrost32Cpu::Dias16);
						end
						PkgInstrDecoder::LdS16:
						begin
							// Write-back handles the store to the register
							//prep_mem_read(__locals.ldst_address,
							//	PkgFrost32Cpu::Dias16);
							prep_mem_read((__locals.ldst_adder_a 
								+ __locals.ldst_adder_b),
								PkgFrost32Cpu::Dias16);
						end
						PkgInstrDecoder::LdU8:
						begin
							// Write-back handles the store to the register
							//prep_mem_read(__locals.ldst_address,
							//	PkgFrost32Cpu::Dias8);
							prep_mem_read((__locals.ldst_adder_a 
								+ __locals.ldst_adder_b),
								PkgFrost32Cpu::Dias8);
						end
						PkgInstrDecoder::LdS8:
						begin
							// Write-back handles the store to the register
							//prep_mem_read(__locals.ldst_address,
							//	PkgFrost32Cpu::Dias8);
							prep_mem_read((__locals.ldst_adder_a 
								+ __locals.ldst_adder_b),
								PkgFrost32Cpu::Dias8);
						end
						PkgInstrDecoder::St32:
						begin
							//$display("Storing %h to address %h",
							//	__stage_execute_input_data.rfile_ra_data,
							//	__locals.ldst_address);
							//prep_mem_write(__locals.ldst_address,
							//	PkgFrost32Cpu::Dias32,
							//	__stage_execute_input_data.rfile_ra_data);
							$display("Storing %h to address %h",
								__stage_execute_input_data.rfile_ra_data,
								(__locals.ldst_adder_a 
								+ __locals.ldst_adder_b));
							prep_mem_write((__locals.ldst_adder_a 
								+ __locals.ldst_adder_b),
								PkgFrost32Cpu::Dias32,
								__stage_execute_input_data.rfile_ra_data);
						end
						PkgInstrDecoder::St16:
						begin
							//prep_mem_write(__locals.ldst_address,
							//	PkgFrost32Cpu::Dias16,
							//	__stage_execute_input_data.rfile_ra_data);
							prep_mem_write((__locals.ldst_adder_a 
								+ __locals.ldst_adder_b),
								PkgFrost32Cpu::Dias16,
								__stage_execute_input_data.rfile_ra_data);
						end
						PkgInstrDecoder::St8:
						begin
							//prep_mem_write(__locals.ldst_address,
							//	PkgFrost32Cpu::Dias8,
							//	__stage_execute_input_data.rfile_ra_data);
							prep_mem_write((__locals.ldst_adder_a 
								+ __locals.ldst_adder_b),
								PkgFrost32Cpu::Dias8,
								__stage_execute_input_data.rfile_ra_data);
						end
					endcase
				end
			end
		end

		//else // if (__stage_instr_decode_data.stall_counter == 0)
		else // if (!in_stall())
		begin
			//if (!(in.interrupt && __locals.ie))
			if ((in.interrupt && !__locals.ie) || (!in.interrupt))
			begin
				// Update the program counter via owner computes (only this
				// always block can perform an actual change to the program
				// counter).
				if (!__multi_stage_data_instr_decode.instr_causes_stall)
				begin
					if ((__multi_stage_data_instr_decode.instr_group == 6)
						&& (__multi_stage_data_instr_decode.instr_opcode
						== PkgInstrDecoder::Reti_NoArgs))
					begin
						//__stage_instr_decode_data.stall_state
						//	<= PkgFrost32Cpu::StReti;
						// "reti" gets the new program counter from
						// __locals.ireta, and also enables interrupts.

						$display("reti:  %h %h", __locals.ie, 
							__locals.ireta);
						// This is a valid instruction even when *not* in
						// an interrupt
						__locals.ie <= 1;
						prep_load_next_instruction(__locals.ireta);

						// Send a bubble through
						make_bubble();
					end

					//else
					begin
						// Every instruction is 4 bytes long (...for now)
						prep_load_next_instruction(__locals.pc + 4);
					end
				end

				else // if (__multi_stage_data_instr_decode
					// .instr_causes_stall)
				begin
					// Conditional branch 
					if (__multi_stage_data_instr_decode.instr_group == 2)
					begin
						__stage_instr_decode_data.stall_state
							<= PkgFrost32Cpu::StCtrlFlowBranch;

						//__stage_instr_decode_data.stall_counter <= 1;
						__stage_instr_decode_data.stall_counter
							<= __STALL_COUNTER_RELATIVE_BRANCH;
						//__stage_instr_decode_data.stall_counter <= 2;
					end

					// Conditional jump or conditional call
					else if ((__multi_stage_data_instr_decode.instr_group 
						== 3)
						|| (__multi_stage_data_instr_decode.instr_group 
						== 4))
					begin
						__stage_instr_decode_data.stall_state
							<= PkgFrost32Cpu::StCtrlFlowJumpCall;

						//__stage_instr_decode_data.stall_counter <= 2;
						__stage_instr_decode_data.stall_counter
							<= __STALL_COUNTER_JUMP_OR_CALL;
					end

					// All loads and stores are in group 5, and they take
					// three cycles each to complete (find out that there's
					// a memory access instruction, prep mem access for
					// instruction itself, prep mem read of next
					// instruction)
					else if (__multi_stage_data_instr_decode.instr_group 
						== 5)
					begin
						__stage_instr_decode_data.stall_state 
							<= PkgFrost32Cpu::StMemAccess;
						//__stage_instr_decode_data.stall_counter <= 2;
						__stage_instr_decode_data.stall_counter
							<= __STALL_COUNTER_MEM_ACCESS;
					end

					// "cpy ireta, rA"
					// "cpy idsta, rA"
					else if (__multi_stage_data_instr_decode.instr_group 
						== 6)
					begin
						//$display("instr_causes_stall:  instr group 6");
						//__stage_instr_decode_data.stall_counter <= 1;

						__stage_instr_decode_data.stall_state
							<= PkgFrost32Cpu
							::StCpyRaToInterruptsRelatedAddr;
						__stage_instr_decode_data.stall_counter
							<= __STALL_COUNTER_CPY_TO_IRETA_IDSTA;
					end

					// Eek!
					else
					begin
						$display("instr_causes_stall:  Eek!");
						__stage_instr_decode_data.stall_state 
							<= PkgFrost32Cpu::StInit;
						__stage_instr_decode_data.stall_counter <= 3;
					end
				end

				// Handle what the execute stage sees next
				//if ((__multi_stage_data_instr_decode.instr_group == 6)
				//	&& ((__multi_stage_data_instr_decode.instr_opcode 
				//	== PkgInstrDecoder::Ei_NoArgs)
				//	|| (__multi_stage_data_instr_decode.instr_opcode
				//	== PkgInstrDecoder::Di_NoArgs)
				//	|| (__multi_stage_data_instr_decode.instr_opcode
				//	== PkgInstrDecoder::Reti_NoArgs)))
				if ((__multi_stage_data_instr_decode.instr_group == 6)
					&& ((__multi_stage_data_instr_decode.instr_opcode 
					== PkgInstrDecoder::Ei_NoArgs)
					|| (__multi_stage_data_instr_decode.instr_opcode
					== PkgInstrDecoder::Di_NoArgs)))
				begin
					//if (__multi_stage_data_instr_decode.instr_opcode
					//	!= PkgInstrDecoder::Reti_NoArgs)
					//begin
					//	__locals.ie <= (__multi_stage_data_instr_decode
					//		.instr_opcode == PkgInstrDecoder::Ei_NoArgs);
					//end
					__locals.ie <= (__multi_stage_data_instr_decode
						.instr_opcode == PkgInstrDecoder::Ei_NoArgs);

					// Just send a bubble through to the later stages since
					// they don't really need to know anything about "ei",
					// "di", and "reti"
					make_bubble();
				end

				// The instruction is **NOT** "ei", "di", or "reti", which
				// are all single cycle and completely resolved in the
				// decode stage.
				else
				begin
					// We only send a non-bubble instruction to
					// `MULTI_STAGE_DATA_AFTER_INSTR_DECODE when there's a
					// new instruction that is NOT "ei" or "di"
					`MULTI_STAGE_DATA_AFTER_INSTR_DECODE 
						<= __multi_stage_data_instr_decode;
					`MULTI_STAGE_DATA_AFTER_INSTR_DECODE 
						<= __multi_stage_data_instr_decode;

					`STAGE_AFTER_INSTR_DECODE_INPUT_DATA.ireta_data 
						<= __locals.ireta;
					`STAGE_AFTER_INSTR_DECODE_INPUT_DATA.idsta_data 
						<= __locals.idsta;

					// Use all three register file read ports.
					// Do this whenever we're not in a stall.
					__in_reg_file.read_sel_ra 
						<= __multi_stage_data_instr_decode.instr_ra_index;
					__in_reg_file.read_sel_rb 
						<= __multi_stage_data_instr_decode.instr_rb_index;
					__in_reg_file.read_sel_rc 
						<= __multi_stage_data_instr_decode.instr_rc_index;
				end
			end

			else
			begin
				$display("Interrupt happened:  %h %h %h",
					__locals.idsta,
					__locals.pc,
					__locals.ireta);
				//__locals.pc <= __locals.idsta;
				__locals.ireta <= __locals.pc;
				__locals.ie <= 0;

				prep_load_next_instruction(__locals.idsta);
			end
		end
	end

	else // if (in.wait_for_mem)
	begin
		stop_mem_access();
	end
	end

	`ifdef HAVE_REGISTER_READ_STAGE
	// Stage 1:  Register Read
	always @ (posedge clk)
	begin
		__multi_stage_data_execute <= __multi_stage_data_register_read;
		//__stage_execute_input_data <= __stage_register_read_input_data;
		__stage_execute_input_data.ireta_data
			<= __stage_register_read_input_data.ireta_data;
		__stage_execute_input_data.idsta_data
			<= __stage_register_read_input_data.idsta_data;

		case (__multi_stage_data_register_read.instr_group)
			4'd0:
			begin
				__stage_register_read_output_data.prev_written_reg_index
					<= __multi_stage_data_register_read.instr_ra_index;
			end

			4'd1:
			begin
				__stage_register_read_output_data.prev_written_reg_index
					<= __multi_stage_data_register_read.instr_ra_index;
			end

			4'd6:
			begin
				case (__multi_stage_data_execute.instr_opcode)
					PkgInstrDecoder::Cpy_OneRegOneIreta:
					begin
						__stage_register_read_output_data
							.prev_written_reg_index
							<= __multi_stage_data_register_read
							.instr_ra_index;
					end
					PkgInstrDecoder::Cpy_OneRegOneIdsta:
					begin
						__stage_register_read_output_data
							.prev_written_reg_index
							<= __multi_stage_data_register_read
							.instr_ra_index;
					end
					default:
					begin
						__stage_register_read_output_data
							.prev_written_reg_index
							<= 0;
					end
				endcase

			end

			default:
			begin
				__stage_register_read_output_data.prev_written_reg_index
					<= 0;
			end
		endcase

	end
	`endif		// HAVE_REGISTER_READ_STAGE

	// Stage 2 (1 if no Register Read stage):  Execute 
	always @ (posedge clk)
	begin
	if (!in.wait_for_mem)
	begin
	//if (!__multi_stage_data_execute.nop)
	//begin
		//$display("Execute stage (part 1):  %h %h\t\t%h %h",
		//	__multi_stage_data_execute.pc_val,
		//	__multi_stage_data_execute.raw_instruction,
		//	__multi_stage_data_execute.instr_group,
		//	__multi_stage_data_execute.instr_opcode);

		// For load and store instructions
		__stage_execute_output_data.next_pc_after_ldst <= __following_pc;

		__multi_stage_data_write_back <= __multi_stage_data_execute;

		//$display("Execute stage:  %h %h %h",
		//	__stage_execute_input_data.rfile_ra_data,
		//	__stage_execute_input_data.rfile_rb_data,
		//	__stage_execute_input_data.rfile_rc_data);

		__stage_write_back_input_data.rfile_ra_data 
			<= __stage_execute_input_data.rfile_ra_data;
		__stage_write_back_input_data.rfile_rb_data 
			<= __stage_execute_input_data.rfile_rb_data;
		__stage_write_back_input_data.rfile_rc_data 
			<= __stage_execute_input_data.rfile_rc_data;

		//__stage_write_back_input_data.alu_out <= __out_alu.data;

		//// For operand forwarding
		//__stage_execute_output_data.prev_written_reg_index
		//	<= __multi_stage_data_execute.instr_ra_index;

		case (__multi_stage_data_execute.instr_group)
			// Group 0:  Three register ALU operations
			4'd0:
			begin
				// For operand forwarding
				__stage_execute_output_data.prev_written_reg_index
					<= __multi_stage_data_execute.instr_ra_index;

				__stage_write_back_input_data.n_reg_data 
					<= __out_alu.data;
				//if (__multi_stage_data_execute.instr_opcode 
				//	!= PkgInstrDecoder::Mul_ThreeRegs)
				//begin
				//	//$display("Three registers ALU operation:  %h",
				//	//	__out_alu.data);
				//	__stage_write_back_input_data.n_reg_data 
				//		<= __out_alu.data;
				//end

				//else
				//begin
				//	`ifdef USE_SINGLE_CYCLE_MULTIPLY
				//	__stage_write_back_input_data.n_reg_data
				//		<= ({(__locals.mul_partial_result_x1_y0
				//		+ __locals.mul_partial_result_x0_y1),
				//		16'h0000})
				//		+ __locals.mul_partial_result_x0_y0;
				//	`else
				//	__stage_write_back_input_data.n_reg_data <= 0;
				//	`endif		// USE_SINGLE_CYCLE_MULTIPLY
				//end
			end

			4'd1:
			begin
				// For operand forwarding
				__stage_execute_output_data.prev_written_reg_index
					<= __multi_stage_data_execute.instr_ra_index;
				////__stage_execute_output_data
				////	.perform_operand_forwarding <= 1;
				//if (__multi_stage_data_execute.instr_opcode
				//	== PkgInstrDecoder::Cpyhi_OneRegOneImm)
				//begin
				//	// cpyhi only changes the high 15 bits of rA
				//	__stage_write_back_input_data.n_reg_data
				//		<= {__multi_stage_data_execute.instr_imm_val,
				//		__stage_execute_input_data.rfile_ra_data[15:0]};
				//end

				////else if (__multi_stage_data_execute.instr_opcode
				////	== PkgInstrDecoder::Muli_TwoRegsOneImm)
				////begin
				////	`ifdef USE_SINGLE_CYCLE_MULTIPLY
				////	__stage_write_back_input_data.n_reg_data
				////		<= ({(__locals.mul_partial_result_x1_y0
				////		+ __locals.mul_partial_result_x0_y1),
				////		16'h0000})
				////		+ __locals.mul_partial_result_x0_y0;
				////	`else
				////	__stage_write_back_input_data.n_reg_data <= 0;
				////	`endif		// USE_SINGLE_CYCLE_MULTIPLY
				////end

				//else
				//begin
				//	__stage_write_back_input_data.n_reg_data 
				//		<= __out_alu.data;
				//	//$display("Two registers, one imm ALU op:  %h",
				//	//	__out_alu.data);
				//end

				if (__multi_stage_data_execute.instr_opcode
					== PkgInstrDecoder::Cpyhi_OneRegOneImm)
				begin
					__stage_write_back_input_data.n_reg_data
						<= __locals.cpyhi_data;
				end

				else if (__multi_stage_data_execute.instr_opcode
					== PkgInstrDecoder::Addsi_OneRegOnePcOneSimm)
				begin
					__stage_write_back_input_data.n_reg_data
						<= __multi_stage_data_execute.pc_val
					// Sign extend the immediate value
					 
						+ {{16{__multi_stage_data_execute.instr_imm_val
						[15]}}, 
						__multi_stage_data_execute.instr_imm_val};
				end

				else
				begin
					__stage_write_back_input_data.n_reg_data 
						<= __out_alu.data;
				end

			end

			// Group 2:  Branches
			4'd2:
			begin
				// Prevent operand forwarding
				__stage_execute_output_data.prev_written_reg_index <= 0;
				//__stage_execute_output_data.perform_operand_forwarding 
				//	<= 0;
			end
			// Group 3:  Jumps 
			4'd3:
			begin
				// Prevent operand forwarding
				__stage_execute_output_data.prev_written_reg_index <= 0;
				//__stage_execute_output_data.perform_operand_forwarding 
				//	<= 0;
			end

			// Group 4:  Calls
			4'd4:
			begin
				// Prevent operand forwarding
				__stage_execute_output_data.prev_written_reg_index <= 0;
				//__stage_write_back_input_data.n_reg_data 
				//	<= __following_pc;
				//__stage_write_back_input_data.do_write_lr <= 1;

				case (__multi_stage_data_execute.instr_condition_type)
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
						// Prevent "lr" write back for bad opcodes
						__stage_write_back_input_data.do_write_lr <= 0;
					end
				endcase


			end


			// Group 5:  Loads and stores
			4'd5:
			begin
				////$display("5:  Changing next_pc to %h", __following_pc);
				//__stage_execute_output_data.next_pc <= __following_pc;

				// Prevent operand forwarding (none needed for loads since
				// they stall until the new value has **really** been
				// written, and of course stores don't need operand
				// forwarding either)
				__stage_execute_output_data.prev_written_reg_index <= 0;
				//__stage_execute_output_data.perform_operand_forwarding 
				//	<= 0;
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
						__stage_write_back_input_data.n_reg_data 
							<= __stage_execute_input_data.ireta_data;

						// For operand forwarding
						__stage_execute_output_data.prev_written_reg_index
							<= __multi_stage_data_execute.instr_ra_index;
						//__stage_execute_output_data
						//	.perform_operand_forwarding <= 1;
					end
					PkgInstrDecoder::Cpy_OneRegOneIdsta:
					begin
						__stage_write_back_input_data.n_reg_data 
							<= __stage_execute_input_data.idsta_data;

						// For operand forwarding
						__stage_execute_output_data.prev_written_reg_index
							<= __multi_stage_data_execute.instr_ra_index;
						//__stage_execute_output_data
						//	.perform_operand_forwarding <= 1;
					end

					default:
					begin
						// Prevent operand forwarding
						__stage_execute_output_data.prev_written_reg_index
							<= 0;
						//__stage_execute_output_data
						//	.perform_operand_forwarding <= 0;
					end
				endcase
			end
		endcase
	//end
	end
	end


	// Stage 3 (2 if no Register Read stage):  Write Back
	always @ (posedge clk)
	begin
	if (!in.wait_for_mem)
	begin
	//if (!__multi_stage_data_write_back.nop)
	//begin
		case (__multi_stage_data_write_back.instr_group)
			// Group 0:  Three register ALU operations
			4'd0:
			begin
				//if (__multi_stage_data_write_back.instr_opcode
				//	< PkgInstrDecoder::Bad0_Iog0)
				if ((__multi_stage_data_write_back.instr_opcode
					!= PkgInstrDecoder::Bad0_Iog0)
					&& (__multi_stage_data_write_back.instr_opcode
					!= PkgInstrDecoder::Bad1_Iog0))
				begin
					prep_ra_write
						(__stage_write_back_input_data.n_reg_data);
				end

				else
				begin
					// Treat this instruction as a NOP (no write-back)
				end
			end

			// Group 1 Instructions:  Immediates
			// All group 1 opcodes are valid instructions, and they all
			// require a write back.
			4'd1:
			begin
				prep_ra_write(__stage_write_back_input_data.n_reg_data);
			end

			// Group 2:  Branches
			// We don't need to do any actual write back for this group.
			4'd2:
			begin

			end

			// Group 3:  Jumps
			// We don't need to do any actual write back for this group.
			4'd3:
			begin
				
			end

			// Group 4:  Calls
			// We need to write back lr for these instructions
			4'd4:
			begin
				if (__stage_write_back_input_data.do_write_lr)
				begin
					// Make sure to write back to lr!
					prep_reg_write(__REG_LR_INDEX,
						__stage_write_back_input_data.n_reg_data);
				end
			end


			// Group 5:  Loads and Stores
			4'd5:
			begin
				case (__multi_stage_data_write_back.instr_opcode)
					PkgInstrDecoder::Ldr_ThreeRegsLdst:
					begin
						$display("Load into r%d:  %h", 
							__multi_stage_data_write_back.instr_ra_index,
							in.data);
						prep_ra_write(in.data);
					end

					PkgInstrDecoder::Ldh_ThreeRegsLdst:
					begin
						// Zero extend
						prep_ra_write({16'h0000, in.data[15:0]});
					end

					PkgInstrDecoder::Ldsh_ThreeRegsLdst:
					begin
						// Sign extend
						//prep_ra_write(in.data[15]
						//	? {16'hffff, in.data[15:0]}
						//	: {16'h0000, in.data[15:0]});
						prep_ra_write({{16{in.data[15]}}, 
							in.data[15:0]});
					end

					PkgInstrDecoder::Ldb_ThreeRegsLdst:
					begin
						// Zero extend
						prep_ra_write({24'h000000, in.data[7:0]});
					end

					PkgInstrDecoder::Ldsb_ThreeRegsLdst:
					begin
						// Sign extend
						//prep_ra_write(in.data[7]
						//	? {24'hffffff, in.data[7:0]}
						//	: {24'h000000, in.data[7:0]});
						prep_ra_write({{24{in.data[7]}}, in.data[7:0]});
					end

					PkgInstrDecoder::Ldri_TwoRegsOneSimm12Ldst:
					begin
						prep_ra_write(in.data);
					end

					PkgInstrDecoder::Ldhi_TwoRegsOneSimm12Ldst:
					begin
						// Zero extend
						prep_ra_write({16'h0000, in.data[15:0]});
					end

					PkgInstrDecoder::Ldshi_TwoRegsOneSimm12Ldst:
					begin
						// Sign extend
						//prep_ra_write(in.data[15]
						//	? {16'hffff, in.data[15:0]}
						//	: {16'h0000, in.data[15:0]});
						prep_ra_write({{16{in.data[15]}}, 
							in.data[15:0]});
					end

					PkgInstrDecoder::Ldbi_TwoRegsOneSimm12Ldst:
					begin
						// Zero extend
						prep_ra_write({24'h000000, in.data[7:0]});
					end

					PkgInstrDecoder::Ldsbi_TwoRegsOneSimm12Ldst:
					begin
						// Sign extend
						//prep_ra_write(in.data[7]
						//	? {24'hffffff, in.data[7:0]}
						//	: {24'h000000, in.data[7:0]});
						prep_ra_write({{24{in.data[7]}}, in.data[7:0]});
					end

					default:
					begin
						
					end
				endcase
			end

			// Group 6:  Interrupts stuff
			4'd6:
			begin
				case (__multi_stage_data_write_back.instr_opcode)
					//PkgInstrDecoder::Ei_NoArgs:
					//begin
					//	
					//end
					//PkgInstrDecoder::Di_NoArgs:
					//begin
					//	
					//end
					//PkgInstrDecoder::Cpy_OneIretaOneReg:
					//begin
					//	
					//end
					PkgInstrDecoder::Cpy_OneRegOneIreta:
					begin
						prep_ra_write
							(__stage_write_back_input_data.n_reg_data);
					end

					//PkgInstrDecoder::Cpy_OneIdstaOneReg:
					//begin
					//	
					//end
					PkgInstrDecoder::Cpy_OneRegOneIdsta:
					begin
						prep_ra_write
							(__stage_write_back_input_data.n_reg_data);
					end
					//PkgInstrDecoder::Reti_NoArgs:
					//begin
					//	
					//end
					default:
					begin
						
					end
				endcase
			end

			default:
			begin
				// Eek!
			end
		endcase
	//end
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
				// It's okay if the ALU performs a bogus operation, so
				// let's decode the ALU opcode directly from the
				// instruction for group 0 instructions.
				//__in_alu.a = __stage_execute_input_data.rfile_rb_data;
				//__locals.cpyhi_data = 0;
				__in_alu.b = __stage_execute_input_data.rfile_rc_data;
				__in_alu.oper = __multi_stage_data_execute.instr_opcode;
				$display("group 0 always_comb thing:  %h %h %h",
					__in_alu.a, __in_alu.b, __in_alu.oper);

				//// We just always perform the temporary multiplications
				`ifdef USE_SINGLE_CYCLE_MULTIPLY
				__locals.mul_partial_result_x0_y0
					= __stage_execute_input_data.rfile_rb_data[15:0]
					* __stage_execute_input_data.rfile_rc_data[15:0];
				__locals.mul_partial_result_x0_y1 
					= __stage_execute_input_data.rfile_rb_data[15:0]
					* __stage_execute_input_data.rfile_rc_data[31:16];
				__locals.mul_partial_result_x1_y0
					= __stage_execute_input_data.rfile_rb_data[31:16]
					* __stage_execute_input_data.rfile_rc_data[15:0];
				//`else
				//__locals.mul_partial_result_x0_y0 = 0;
				//__locals.mul_partial_result_x0_y1 = 0;
				//__locals.mul_partial_result_x1_y0 = 0;
				`endif		// USE_SINGLE_CYCLE_MULTIPLY

				//__locals.branch_adder_a = 0;
				//__locals.branch_adder_b = 0;
				//__locals.dest_of_ctrl_flow_if_condition = 0;
				//__locals.ldst_adder_a = 0;
				//__locals.ldst_adder_b = 0;
				//__locals.ldst_address = 0;
			end

			// Group 1:  Immediates
			1:
			begin
				//__in_alu.oper = __multi_stage_data_execute.instr_opcode;

				//// We just always perform the temporary multiplications
				`ifdef USE_SINGLE_CYCLE_MULTIPLY
				__locals.mul_partial_result_x0_y0
					= __stage_execute_input_data.rfile_rb_data[15:0]
					* __multi_stage_data_execute.instr_imm_val;
				__locals.mul_partial_result_x0_y1 
					= __stage_execute_input_data.rfile_rb_data[15:0]
					* 16'h0000;
				__locals.mul_partial_result_x1_y0
					= __stage_execute_input_data.rfile_rb_data[31:16]
					* __multi_stage_data_execute.instr_imm_val;
				//`else
				//__locals.mul_partial_result_x0_y0 = 0;
				//__locals.mul_partial_result_x0_y1 = 0;
				//__locals.mul_partial_result_x1_y0 = 0;
				`endif		// USE_SINGLE_CYCLE_MULTIPLY

				case (__multi_stage_data_execute.instr_opcode)
					PkgInstrDecoder::Sltsi_TwoRegsOneSimm:
					begin
						//__locals.cpyhi_data = 0;
						//__in_alu.a
						//	= __stage_execute_input_data.rfile_rb_data;

						// Sign extend the immediate value
						__in_alu.b 
							= {{16{__multi_stage_data_execute.instr_imm_val
							[15]}}, 
							__multi_stage_data_execute.instr_imm_val};

						__in_alu.oper = PkgAlu::Slts;
					end
					PkgInstrDecoder::Sgtsi_TwoRegsOneSimm:
					begin
						//__in_alu.a
						//	= __stage_execute_input_data.rfile_rb_data;
						//__locals.cpyhi_data = 0;

						// Sign extend the immediate value
						__in_alu.b 
							= {{16{__multi_stage_data_execute.instr_imm_val
							[15]}}, 
							__multi_stage_data_execute.instr_imm_val};

						__in_alu.oper = PkgAlu::Slts;
					end

					//PkgInstrDecoder::Addsi_OneRegOnePcOneSimm:
					//begin
					//	//__in_alu.a = __multi_stage_data_execute.pc_val;
					//	//__locals.cpyhi_data = 0;

					//	// Sign extend the immediate value
					//	__in_alu.b 
					//		= {{16{__multi_stage_data_execute.instr_imm_val
					//		[15]}}, 
					//		__multi_stage_data_execute.instr_imm_val};

					//	__in_alu.oper = PkgAlu::Add;
					//end

					PkgInstrDecoder::Cpyhi_OneRegOneImm:
					begin
						// cpyhi only changes the high 15 bits of rA
						//__in_alu.a
						//	= {__multi_stage_data_execute.instr_imm_val,
						//	__stage_execute_input_data
						//	.rfile_ra_data[15:0]};
						//__locals.cpyhi_data
						//	= {__multi_stage_data_execute.instr_imm_val,
						//	__stage_execute_input_data
						//	.rfile_ra_data[15:0]};

						__in_alu.b = 0;
						//__in_alu.oper = PkgAlu::Add;
						__in_alu.oper = 0;

						//__in_alu.a 
						//	= __stage_execute_input_data.rfile_ra_data;

						//__in_alu.b
						//	= __multi_stage_data_execute.instr_imm_val;

						////$display("Cpyhi:  %h %h",
						////	__in_alu.a, __in_alu.b);
						//__in_alu.oper = PkgAlu::Cpyhi;
					end


					// Let's decode the ALU opcode directly from the
					// instruction for the remainder of the
					// instructions from group 1
					default:
					begin
						//__in_alu.a 
						//	= __stage_execute_input_data.rfile_rb_data;
						//__locals.cpyhi_data = 0;

						// Zero-extend the immediate value
						__in_alu.b = {16'h0000,
							__multi_stage_data_execute.instr_imm_val};
						__in_alu.oper = __multi_stage_data_execute
							.instr_opcode;
					end
				endcase
				//$display("always_comb thing:  %h %h %h",
				//	__in_alu.a, __in_alu.b, __in_alu.oper);

				//__locals.branch_adder_a = 0;
				//__locals.branch_adder_b = 0;
				//__locals.dest_of_ctrl_flow_if_condition = 0;
				//__locals.ldst_adder_a = 0;
				//__locals.ldst_adder_b = 0;
				//__locals.ldst_address = 0;
			end

			//// Group 2:  Branches
			//2:
			//begin
			//	//__locals.mul_partial_result_x0_y0 = 0;
			//	//__locals.mul_partial_result_x0_y1 = 0;
			//	//__locals.mul_partial_result_x1_y0 = 0;

			//	////__in_alu.a = __multi_stage_data_execute.pc_val + 4;
			//	////__in_alu.a = __following_pc;
			//	//__locals.branch_adder_a = __following_pc;

			//	//// Sign extend the immediate value
			//	////__in_alu.b 
			//	////	= {{16{__multi_stage_data_execute.instr_imm_val[15]}}, 
			//	////	__multi_stage_data_execute.instr_imm_val};
			//	//__locals.branch_adder_b
			//	//	= {{16{__multi_stage_data_execute.instr_imm_val[15]}}, 
			//	//	__multi_stage_data_execute.instr_imm_val};

			//	////__in_alu.oper = PkgAlu::Add;

			//	//__locals.dest_of_ctrl_flow_if_condition
			//	//	= __locals.branch_adder_a + __locals.branch_adder_b;
			//	//__locals.ldst_adder_a = 0;
			//	//__locals.ldst_adder_b = 0;
			//	//__locals.ldst_address = 0;

			//	__in_alu = 0;
			//end

			//// Group 3:  Jumps
			//3:
			//begin
			//	//__locals.mul_partial_result_x0_y0 = 0;
			//	//__locals.mul_partial_result_x0_y1 = 0;
			//	//__locals.mul_partial_result_x1_y0 = 0;

			//	//__locals.branch_adder_a = 0;
			//	//__locals.branch_adder_b = 0;
			//	//__locals.dest_of_ctrl_flow_if_condition 
			//	//	= __stage_execute_input_data.rfile_rc_data;
			//	//__locals.ldst_adder_a = 0;
			//	//__locals.ldst_adder_b = 0;
			//	//__locals.ldst_address = 0;

			//	__in_alu = 0;
			//end

			//// Group 4:  Calls
			//4:
			//begin
			//	//__locals.mul_partial_result_x0_y0 = 0;
			//	//__locals.mul_partial_result_x0_y1 = 0;
			//	//__locals.mul_partial_result_x1_y0 = 0;


			//	//__locals.branch_adder_a = 0;
			//	//__locals.branch_adder_b = 0;
			//	//__locals.dest_of_ctrl_flow_if_condition
			//	//	= __stage_execute_input_data.rfile_rc_data;
			//	//__locals.ldst_adder_a = 0;
			//	//__locals.ldst_adder_b = 0;
			//	//__locals.ldst_address = 0;

			//	__in_alu = 0;
			//end

			//// Group 5:  Loads and stores
			//5:
			//begin
			//	//__locals.mul_partial_result_x0_y0 = 0;
			//	//__locals.mul_partial_result_x0_y1 = 0;
			//	//__locals.mul_partial_result_x1_y0 = 0;

			//	__in_alu = 0;
			//	//__locals.branch_adder_a = 0;
			//	//__locals.branch_adder_b = 0;
			//	//__locals.dest_of_ctrl_flow_if_condition = 0;

			//	//__locals.ldst_adder_a 
			//	//	= __stage_execute_input_data.rfile_rb_data;

			//	//// Immediate-indexed loads and stores have
			//	//// (__multi_stage_data_execute.instr_opcode[3] == 1)
			//	//if (__multi_stage_data_execute.instr_opcode[3])
			//	//begin
			//	//	// memory address computation:  rB + sign-extended
			//	//	// immediate (actually sign extended twice since
			//	//	// the instruction decoder **also** performed a
			//	//	// sign extend, from 12-bit to 16-bit)
			//	//	__locals.ldst_adder_b 
			//	//		= {{16{__multi_stage_data_execute.instr_imm_val
			//	//		[15]}},
			//	//		__multi_stage_data_execute.instr_imm_val};
			//	//end

			//	//else
			//	//begin
			//	//	// memory address computation:  rB + rC
			//	//	__locals.ldst_adder_b 
			//	//		= __stage_execute_input_data.rfile_rc_data;
			//	//end
			//	////__in_alu.oper = PkgAlu::Add;

			//	//__locals.ldst_address = __locals.ldst_adder_a
			//	//	+ __locals.ldst_adder_b;
			//end

			default:
			begin
				//__locals.mul_partial_result_x0_y0 = 0;
				//__locals.mul_partial_result_x0_y1 = 0;
				//__locals.mul_partial_result_x1_y0 = 0;

				//__locals.branch_adder_a = 0;
				//__locals.branch_adder_b = 0;
				//__locals.dest_of_ctrl_flow_if_condition = 0;
				//__locals.ldst_adder_a = 0;
				//__locals.ldst_adder_b = 0;
				//__locals.ldst_address = 0;

				// Perform a bogus add
				//__in_alu = 0;
				//__locals.cpyhi_data = 0;
				__in_alu.b = 0;
				__in_alu.oper = 0;
			end
		endcase
		//__in_alu.a = __stage_execute_input_data.rfile_rb_data
	end

	else // if (in.wait_for_mem)
	begin
		//__locals.mul_partial_result_x0_y0 = 0;
		//__locals.mul_partial_result_x0_y1 = 0;
		//__locals.mul_partial_result_x1_y0 = 0;
		//__in_alu = 0;
		//__locals.cpyhi_data = 0;
		__in_alu.b = 0;
		__in_alu.oper = 0;

		//__locals.branch_adder_a = 0;
		//__locals.branch_adder_b = 0;
		//__locals.dest_of_ctrl_flow_if_condition = 0;
		//__locals.ldst_adder_a = 0;
		//__locals.ldst_adder_b = 0;
		//__locals.ldst_address = 0;
	end
	end

endmodule
