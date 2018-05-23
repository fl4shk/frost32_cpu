`include "src/misc_defines.header.sv"
`include "src/instr_decoder_defines.header.sv"
`include "src/alu_defines.header.sv"
`include "src/register_file_defines.header.sv"

`ifdef OPT_HAVE_STAGE_REGISTER_READ
`define MULTI_STAGE_DATA_AFTER_INSTR_DECODE \
	__multi_stage_data_register_read
`define STAGE_AFTER_INSTR_DECODE_INPUT_DATA \
	__stage_register_read_input_data
//`define LOCALS_CONDITION_ALWAYS_BLOCK_TYPE always @ (posedge clk)
//`define LOCALS_CONDITION_ASSIGNMENT_TYPE <=
`else
`define MULTI_STAGE_DATA_AFTER_INSTR_DECODE \
	__multi_stage_data_execute
`define STAGE_AFTER_INSTR_DECODE_INPUT_DATA \
	__stage_execute_input_data
//`define LOCALS_CONDITION_ALWAYS_BLOCK_TYPE always_comb
//`define LOCALS_CONDITION_ASSIGNMENT_TYPE =
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

	parameter __STALL_COUNTER_RELATIVE_BRANCH = 2;
	parameter __STALL_COUNTER_JUMP_OR_CALL = 2;
	parameter __STALL_COUNTER_MEM_ACCESS = 3;
	parameter __STALL_COUNTER_INTERRUPTS_STUFF = 2;
	//parameter __STALL_COUNTER_MULTIPLY = 4;
	parameter __STALL_COUNTER_EEK = 2;
	parameter __STALL_COUNTER_RESPOND_TO_INTERRUPTS = 1;


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

	} __stage_instr_decode_data;

	// Data input to the execute stage
	struct packed
	{
		logic [`MSB_POS__REG_FILE_DATA:0] rfile_ra_data, rfile_rb_data,
			rfile_rc_data;

		logic [`MSB_POS__FROST32_CPU_ADDR:0] ireta_data, idsta_data;

		//logic [`MSB_POS__FROST32_CPU_ADDR:0] next_pc;
	}
		__stage_execute_input_data;

	`ifdef OPT_HAVE_STAGE_REGISTER_READ
	struct packed
	{
		logic [`MSB_POS__REG_FILE_SEL:0] prev_written_reg_index;
	} __stage_register_read_output_data;
	`endif		// OPT_HAVE_STAGE_REGISTER_READ

	//struct packed
	//{
	//	// The next program counter for load and store instructions that
	//	// stall (read by the instruction decode stage for updating the
	//	// program counter in the case of these instructions)
	//	logic [`MSB_POS__FROST32_CPU_ADDR:0] next_pc_after_ldst;

	//	logic [`MSB_POS__REG_FILE_SEL:0] prev_written_reg_index;

	//	//logic perform_operand_forwarding;
	//} __stage_execute_output_data;


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


		logic [`MSB_POS__REG_FILE_DATA:0] cpyhi_data;

		`ifdef OPT_DEBUG
		// Debugging thing
		logic [31:0] cycles_counter;
		`endif		// OPT_DEBUG


	} __locals;


	logic [`MSB_POS__FROST32_CPU_ADDR:0] __following_pc,
		// Used if there's a register read stage
		__following_pc_branch;

	PkgFrost32Cpu::MultiStageData 
		__multi_stage_data_instr_decode, 
		`ifdef OPT_HAVE_STAGE_REGISTER_READ
		__multi_stage_data_register_read,
		`endif		// OPT_HAVE_STAGE_REGISTER_READ
		__multi_stage_data_execute;



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
	always @ (posedge clk)
	begin
	if (!in.wait_for_mem)
	begin
		`ifdef OPT_HAVE_STAGE_REGISTER_READ
		$display("Frost32Cpu pc's:  %h %h %h %h", 
			__locals.pc,
			__multi_stage_data_instr_decode.pc_val, 
			__multi_stage_data_register_read.pc_val,
			__multi_stage_data_execute.pc_val);
		`else
		$display("Frost32Cpu pc's:  %h %h %h", 
			__locals.pc,
			__multi_stage_data_instr_decode.pc_val, 
			__multi_stage_data_execute.pc_val);
		`endif		// OPT_HAVE_STAGE_REGISTER_READ
		`ifdef OPT_DEBUG_REGISTER_FILE
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

		`ifdef OPT_DEBUG_INSTR_DECODER
		`include "src/debug_instr_decoder.header.sv"
		`endif		// OPT_DEBUG_INSTR_DECODER
		$display();
	end

		//$display();
	end
	`endif		// OPT_DEBUG

	// Assignments
	assign __following_pc = __multi_stage_data_execute.pc_val + 4;
	`ifdef OPT_HAVE_STAGE_REGISTER_READ
	assign __following_pc_branch 
		= __multi_stage_data_register_read.pc_val + 4;
	`endif		// OPT_HAVE_STAGE_REGISTER_READ

	always_comb
	begin
		if (!in_stall())
		begin
			__in_instr_decoder = in.data;
		end

		else
		begin
			__in_instr_decoder
				= `MULTI_STAGE_DATA_AFTER_INSTR_DECODE.raw_instruction;
		end
	end

	always_comb
	begin
		__in_reg_file.read_sel_ra 
			= __multi_stage_data_instr_decode.instr_ra_index;
		//$display("__in_reg_file.read_sel_ra:  %h",
		//	__in_reg_file.read_sel_ra);
	end

	always_comb
	begin
		__in_reg_file.read_sel_rb 
			= __multi_stage_data_instr_decode.instr_rb_index;
		//$display("__in_reg_file.read_sel_rb:  %h",
		//	__in_reg_file.read_sel_rb);
	end

	always_comb
	begin
		__in_reg_file.read_sel_rc 
			= __multi_stage_data_instr_decode.instr_rc_index;
		//$display("__in_reg_file.read_sel_rc:  %h",
		//	__in_reg_file.read_sel_rc);
	end

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


	always_comb
	begin
		if (!in_stall())
		begin
			__multi_stage_data_instr_decode.pc_val = __locals.pc;
		end

		else
		begin
			//__multi_stage_data_instr_decode.pc_val
			//	= `STAGE_AFTER_INSTR_DECODE_INPUT_DATA.pc_val;
			__multi_stage_data_instr_decode.pc_val
				= __multi_stage_data_execute.pc_val;
		end
	end

	//always_comb
	//	__multi_stage_data_instr_decode.nop = 0;



	//// This is the operand forwarding.  It's so simple!
	//// We only write to one register at a time, so we only need one
	//// multiplexer per rfile_r..._data
	//always_comb
	//begin
	//	__stage_execute_input_data.rfile_ra_data
	//		= ((__stage_execute_output_data.prev_written_reg_index
	//		== __multi_stage_data_execute.instr_ra_index)
	//		&& (__stage_execute_output_data.prev_written_reg_index != 0))
	//		? __stage_write_back_input_data.n_reg_data
	//		: __out_reg_file.read_data_ra;
	//end
	//always_comb
	//begin
	//	__stage_execute_input_data.rfile_rb_data
	//		= ((__stage_execute_output_data.prev_written_reg_index
	//		== __multi_stage_data_execute.instr_rb_index)
	//		&& (__stage_execute_output_data.prev_written_reg_index != 0))
	//		? __stage_write_back_input_data.n_reg_data
	//		: __out_reg_file.read_data_rb;
	//end
	//always_comb
	//begin
	//	__stage_execute_input_data.rfile_rc_data
	//		= ((__stage_execute_output_data.prev_written_reg_index
	//		== __multi_stage_data_execute.instr_rc_index)
	//		&& (__stage_execute_output_data.prev_written_reg_index != 0))
	//		? __stage_write_back_input_data.n_reg_data
	//		: __out_reg_file.read_data_rc;
	//end

	always_comb
	begin
		__stage_execute_input_data.rfile_ra_data
			= __out_reg_file.read_data_ra;
	end
	always_comb
	begin
		__stage_execute_input_data.rfile_rb_data
			= __out_reg_file.read_data_rb;
	end
	always_comb
	begin
		__stage_execute_input_data.rfile_rc_data
			= __out_reg_file.read_data_rc;
	end

	// Just some copies for use in the decode stage.
	always_comb
		__stage_instr_decode_data.from_stage_execute_rfile_ra_data
			= __stage_execute_input_data.rfile_ra_data;

	always_comb
		__stage_instr_decode_data.from_stage_execute_rfile_rb_data
			= __stage_execute_input_data.rfile_rb_data;
	always_comb
		__stage_instr_decode_data.from_stage_execute_rfile_rc_data
			= __stage_execute_input_data.rfile_rc_data;

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
	end


	always_comb
	begin
		__locals.cond_ltu
			=
			(__stage_instr_decode_data
			.from_stage_execute_rfile_ra_data
			< __stage_instr_decode_data
			.from_stage_execute_rfile_rb_data);
	end

	always_comb
	begin
		__locals.cond_geu
			=
			(__stage_instr_decode_data
			.from_stage_execute_rfile_ra_data
			>= __stage_instr_decode_data
			.from_stage_execute_rfile_rb_data);
		//__locals.cond_geu
		//	=
		//	!(__stage_instr_decode_data
		//	.from_stage_execute_rfile_ra_data}
		//	+ (~__stage_instr_decode_data
		//	.from_stage_execute_rfile_rb_data))
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

	always_comb
	begin
		__locals.branch_adder_a = __following_pc;
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
	//always @ (posedge clk)
	begin
		__locals.ldst_adder_a = __stage_execute_input_data.rfile_rb_data;
		//__locals.ldst_adder_a <= __stage_instr_decode_data
		//	.from_stage_register_read_rfile_cond_rb_data;
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

		//$display("prep_ra_write:  %h %h",
		//	__multi_stage_data_write_back.instr_ra_index, s_data);
		//__in_reg_file.write_sel 
		//	<= __multi_stage_data_write_back.instr_ra_index;
		//__in_reg_file.write_data <= s_data;
		//__in_reg_file.write_en <= 1;
		$display("prep_ra_write:  %h %h",
			__multi_stage_data_execute.instr_ra_index, s_data);
		prep_reg_write(__multi_stage_data_execute.instr_ra_index, s_data);
	endtask



	task stop_reg_write;
		__in_reg_file.write_en <= 0;
	endtask

	task send_instr_through;
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

		//// Use all three register file read ports.
		//// Do this whenever we're not in a stall.
		//__in_reg_file.read_sel_ra 
		//	<= __multi_stage_data_instr_decode.instr_ra_index;
		//__in_reg_file.read_sel_rb 
		//	<= __multi_stage_data_instr_decode.instr_rb_index;
		//__in_reg_file.read_sel_rc 
		//	<= __multi_stage_data_instr_decode.instr_rc_index;
	endtask

	task make_bubble;
		//// Send a bubble through while we're stalled a (actually
		//// performs "add zero, zero, zero", but that does nothing
		//// interesting anyway... besides maybe power consumption)
		//__in_reg_file.read_sel_ra <= 0;
		//__in_reg_file.read_sel_rb <= 0;
		//__in_reg_file.read_sel_rc <= 0;

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
	task handle_branch_in_fetch_stage;
		input condition;

		if (condition)
		begin
			$display("handle_ctrl_flow_in_fetch_stage_part_1:  %s%h %h %h",
				"taking branch:  ", 
				__locals.branch_adder_a,
				__locals.branch_adder_b,
				__locals.branch_adder_a + __locals.branch_adder_b);
			prep_load_next_instruction
				(__locals.branch_adder_a + __locals.branch_adder_b);
		end

		else // if (!condition)
		begin
			$display("handle_ctrl_flow_in_fetch_stage_part_1:  %s%h",
				"NOT taking branch:  ",
				__following_pc);
			prep_load_next_instruction(__following_pc);
		end
	endtask

	task handle_jump_or_call_in_fetch_stage;
		input condition;

		//__locals.jump_or_call_condition <= condition;
		//__locals.next_pc_after_jump_or_call_cond
		//	<= __stage_instr_decode_data.from_stage_execute_rfile_rc_data;
		//__locals.next_pc_after_jump_or_call_not_cond
		//	<= __following_pc;

		if (condition)
		begin
			//__locals.next_pc_after_jump_or_call
			//	<= __locals.dest_of_ctrl_flow_if_condition;
			//__locals.next_pc_after_jump_or_call
			//	<= __stage_instr_decode_data
			//	.from_stage_execute_rfile_rc_data;
			prep_load_next_instruction(__stage_instr_decode_data
				.from_stage_execute_rfile_rc_data);
		end

		else
		begin
			//__locals.next_pc_after_jump_or_call <= __following_pc;
			prep_load_next_instruction(__following_pc);
		end
	endtask
	//task handle_ctrl_flow_in_decode_stage_part_2;
	//	prep_load_next_instruction(__locals.dest_of_ctrl_flow_if_condition);
	//endtask

	task handle_call_in_execute_stage;
		input condition;

		//__stage_write_back_input_data.n_reg_data <= __following_pc;
		//__stage_write_back_input_data.do_write_lr <= condition;

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

		if (condition)
		begin
			prep_reg_write(__REG_LR_INDEX, __following_pc);
		end
	endtask




	initial
	begin
		// Put NOPs into the stages after decode
		__multi_stage_data_execute = 0;

		__stage_instr_decode_data = 0;
		//__stage_execute_output_data = 0;
		//__stage_write_back_input_data = 0;
		//__stage_instr_decode_data.state = PkgFrost32Cpu::StInit;

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
		__stage_instr_decode_data.stall_counter = 2;
		__stage_instr_decode_data.stall_state = PkgFrost32Cpu::StInit;
	end

	// Stage 0:  Instruction Fetch
	// Instruction fetch now controls the program counter
	always @ (posedge clk)
	begin
	if (!in.wait_for_mem)
	begin
		// Prevent sending stuff through to the instruction decode stage
		if (in_stall())
		begin
			case (__stage_instr_decode_data.stall_state)
			PkgFrost32Cpu::StCpyRaToInterruptsRelatedAddr:
			begin
				case (__stage_instr_decode_data.stall_counter)
					2:
					begin
						// The fetch stage now controls access to the
						// memory buses, and also now controls writes to
						// the program counter.
						prep_load_next_instruction(__following_pc);
					end

					1:
					begin
						prep_load_next_instruction
							(__locals.pc + 4);
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
							$display("Ld32:  %h", 
								__locals.ldst_adder_a 
								+ __locals.ldst_adder_b);
							prep_mem_read((__locals.ldst_adder_a 
								+ __locals.ldst_adder_b),
								PkgFrost32Cpu::Dias32);
						end
						PkgInstrDecoder::LdU16:
						begin
							// Execute handles the store to the register
							prep_mem_read((__locals.ldst_adder_a 
								+ __locals.ldst_adder_b),
								PkgFrost32Cpu::Dias16);
						end
						PkgInstrDecoder::LdS16:
						begin
							// Execute handles the store to the register
							prep_mem_read((__locals.ldst_adder_a 
								+ __locals.ldst_adder_b),
								PkgFrost32Cpu::Dias16);
						end
						PkgInstrDecoder::LdU8:
						begin
							// Execute handles the store to the register
							prep_mem_read((__locals.ldst_adder_a 
								+ __locals.ldst_adder_b),
								PkgFrost32Cpu::Dias8);
						end
						PkgInstrDecoder::LdS8:
						begin
							// Execute handles the store to the register
							prep_mem_read((__locals.ldst_adder_a 
								+ __locals.ldst_adder_b),
								PkgFrost32Cpu::Dias8);
						end
						PkgInstrDecoder::St32:
						begin
							$display("Storing %h to address %h",
								__stage_execute_input_data.rfile_ra_data,
								__locals.ldst_address);
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
							prep_mem_write((__locals.ldst_adder_a 
								+ __locals.ldst_adder_b),
								PkgFrost32Cpu::Dias16,
								__stage_execute_input_data.rfile_ra_data);
						end
						PkgInstrDecoder::St8:
						begin
							prep_mem_write((__locals.ldst_adder_a 
								+ __locals.ldst_adder_b),
								PkgFrost32Cpu::Dias8,
								__stage_execute_input_data.rfile_ra_data);
						end
					endcase
					end

					2:
					begin
						prep_load_next_instruction(__following_pc);
					end

					1:
					begin
						// write back to rA happens here, and also we wait
						// for the instruction to be fetched.
						prep_load_next_instruction
							(__locals.pc + 4);
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
							PkgInstrDecoder::CtNe:
							begin
								handle_branch_in_fetch_stage
									(__locals.cond_ne);
							end

							PkgInstrDecoder::CtEq:
							begin
								handle_branch_in_fetch_stage
									(__locals.cond_eq);
							end

							PkgInstrDecoder::CtLtu:
							begin
								handle_branch_in_fetch_stage
									(__locals.cond_ltu);
							end
							PkgInstrDecoder::CtGeu:
							begin
								handle_branch_in_fetch_stage
									(__locals.cond_geu);
							end

							PkgInstrDecoder::CtLeu:
							begin
								handle_branch_in_fetch_stage
									(__locals.cond_leu);
							end
							PkgInstrDecoder::CtGtu:
							begin
								handle_branch_in_fetch_stage
									(__locals.cond_gtu);
							end

							PkgInstrDecoder::CtLts:
							begin
								handle_branch_in_fetch_stage
									(__locals.cond_lts);
							end
							PkgInstrDecoder::CtGes:
							begin
								handle_branch_in_fetch_stage
									(__locals.cond_ges);
							end

							PkgInstrDecoder::CtLes:
							begin
								handle_branch_in_fetch_stage
									(__locals.cond_les);
							end
							PkgInstrDecoder::CtGts:
							begin
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

								//`ifdef OPT_HAVE_STAGE_REGISTER_READ
								//prep_load_next_instruction
								//	(__following_pc_branch);
								//`else
								//prep_load_next_instruction
								//	(__following_pc);
								//`endif
								prep_load_next_instruction
									(__following_pc);
							end
						endcase
					end
					1:
					begin
						prep_load_next_instruction
							(__locals.pc + 4);
					end
				endcase
			end

			PkgFrost32Cpu::StCtrlFlowJumpCall:
			begin
				case (__stage_instr_decode_data.stall_counter)
					2:
					begin
						case (__multi_stage_data_execute
							.instr_condition_type)
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
								prep_load_next_instruction
									(__following_pc);
							end
						endcase
					end

					1:
					begin
						prep_load_next_instruction(__locals.pc + 4);
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
						//prep_load_next_instruction
						//	(__following_pc);
						//prep_load_next_instruction
						//	(__locals.pc);
						$display("Stuffs:  2");
						prep_load_next_instruction(0);
					end

					1:
					begin
						$display("AAAA GGGG");
						prep_load_next_instruction(__locals.pc + 4);
					end
				endcase
			end

			PkgFrost32Cpu::StReti:
			begin
				case (__stage_instr_decode_data.stall_counter)
					2:
					begin
						prep_load_next_instruction(__locals.ireta);
					end

					1:
					begin
						prep_load_next_instruction(__locals.pc + 4);
					end
				endcase
			end
				
			PkgFrost32Cpu::StRespondToInterrupt:
			begin
				prep_load_next_instruction(__locals.pc + 4);
			end
			endcase
		end

		else // if (!in_stall())
		begin
			if ((in.interrupt && !__locals.ie) || (!in.interrupt))
			begin
				if (!__multi_stage_data_instr_decode.instr_causes_stall)
				begin
					//if ((__multi_stage_data_instr_decode.instr_group == 6)
					//	&& (__multi_stage_data_instr_decode.instr_opcode
					//	== PkgInstrDecoder::Reti_NoArgs))
					//begin
					//	prep_load_next_instruction(__locals.ireta);
					//end

					//else
					//begin
					//	// Every instruction is 4 bytes long (...for now)
					//end
				$display("Every instruction is 4 bytes long:  %h -> %h",
							__locals.pc, __locals.pc + 4);
						prep_load_next_instruction(__locals.pc + 4);
				end
			end

			else
			begin
				prep_load_next_instruction(__locals.idsta);
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

			// With the execute stage doing things on multiple steps
			// of multi-cycle instructions, we no longer need to send a
			// bubble through the pipeline when the CPU stalls.
			// (We also no longer need operand forwarding since the execute
			// stage performs the write back stuff now.)
			make_bubble();


			// The last stall_counter value before it hits zero (this is
			// where the PC should be changed).
			if (__stage_instr_decode_data.stall_counter == 1)
			begin
				__stage_instr_decode_data.stall_state 
					<= PkgFrost32Cpu::StOther;


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

					//prep_load_next_instruction(__following_pc);
				end


				//else if (__stage_instr_decode_data.stall_state
				//	== PkgFrost32Cpu::StInit)
				//begin
				//	
				//end

				//else
				//begin
				//	$display("stall_counter == 1:  Eek!");
				//end
			end

			//else if (__stage_instr_decode_data.stall_counter == 2)
			//begin
			//end
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

						//prep_load_next_instruction(__locals.ireta);

						// Send a bubble to the execute stage
						make_bubble();
					end

					////else
					//begin
					//	// Every instruction is 4 bytes long (...for now)
					//	prep_load_next_instruction(__locals.pc + 4);
					//end
				end

				else // if (__multi_stage_data_instr_decode
					// .instr_causes_stall)
				begin
					// Conditional branch 
					if (__multi_stage_data_instr_decode.instr_group == 2)
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
						__stage_instr_decode_data.stall_counter
							<= __STALL_COUNTER_MEM_ACCESS;
					end

					// "cpy ireta, rA"
					// "cpy idsta, rA"
					else if (__multi_stage_data_instr_decode.instr_group 
						== 6)
					begin
						if (__multi_stage_data_instr_decode.instr_opcode
							!= PkgInstrDecoder::Reti_NoArgs)
						begin
							__stage_instr_decode_data.stall_state
								<= PkgFrost32Cpu
								::StCpyRaToInterruptsRelatedAddr;
						end

						else
						begin
							__stage_instr_decode_data.stall_state
								<= PkgFrost32Cpu::StReti;
						end
						__stage_instr_decode_data.stall_counter
							<= __STALL_COUNTER_INTERRUPTS_STUFF;
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

				// Handle what the stage after instruction decoding sees
				// next
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
					// "ei", "di", and "reti"
					make_bubble();
				end

				else
				begin
					send_instr_through();
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
				make_bubble();

				__stage_instr_decode_data.stall_state
					<= PkgFrost32Cpu::StRespondToInterrupt;
				__stage_instr_decode_data.stall_counter
					<= __STALL_COUNTER_RESPOND_TO_INTERRUPTS;
			end
		end
	end

	//else // if (in.wait_for_mem)
	//begin
	//	stop_mem_access();
	//end
	end

	//`ifdef OPT_HAVE_STAGE_REGISTER_READ
	//// Stage 2:  Register Read
	//always @ (posedge clk)
	//begin
	//	__multi_stage_data_execute <= __multi_stage_data_register_read;
	//	//__stage_execute_input_data <= __stage_register_read_input_data;
	//	__stage_execute_input_data.ireta_data
	//		<= __stage_register_read_input_data.ireta_data;
	//	__stage_execute_input_data.idsta_data
	//		<= __stage_register_read_input_data.idsta_data;

	//	case (__multi_stage_data_register_read.instr_group)
	//		4'd0:
	//		begin
	//			__stage_register_read_output_data.prev_written_reg_index
	//				<= __multi_stage_data_register_read.instr_ra_index;
	//		end

	//		4'd1:
	//		begin
	//			__stage_register_read_output_data.prev_written_reg_index
	//				<= __multi_stage_data_register_read.instr_ra_index;
	//		end

	//		4'd6:
	//		begin
	//			case (__multi_stage_data_execute.instr_opcode)
	//				PkgInstrDecoder::Cpy_OneRegOneIreta:
	//				begin
	//					__stage_register_read_output_data
	//						.prev_written_reg_index
	//						<= __multi_stage_data_register_read
	//						.instr_ra_index;
	//				end
	//				PkgInstrDecoder::Cpy_OneRegOneIdsta:
	//				begin
	//					__stage_register_read_output_data
	//						.prev_written_reg_index
	//						<= __multi_stage_data_register_read
	//						.instr_ra_index;
	//				end
	//				default:
	//				begin
	//					__stage_register_read_output_data
	//						.prev_written_reg_index
	//						<= 0;
	//				end
	//			endcase

	//		end

	//		default:
	//		begin
	//			__stage_register_read_output_data.prev_written_reg_index
	//				<= 0;
	//		end
	//	endcase

	//end
	//`endif		// OPT_HAVE_STAGE_REGISTER_READ

	// Stage 3 (2 if no Register Read stage):  Execute 
	always @ (posedge clk)
	begin
	if (!in.wait_for_mem)
	begin
		case (__multi_stage_data_execute.instr_group)
			// Group 0:  Three register ALU operations
			4'd0:
			begin
				//if (__multi_stage_data_execute.instr_opcode 
				//	!= PkgInstrDecoder::Mul_ThreeRegs)
				case (__multi_stage_data_execute.instr_opcode)
					PkgInstrDecoder::Mul_ThreeRegs:
					begin
						prep_ra_write({(__locals.mul_partial_result_x1_y0
							+ __locals.mul_partial_result_x0_y1),
							16'h0000}
							+ __locals.mul_partial_result_x0_y0);
					end

					PkgInstrDecoder::Bad0_Iog0:
					begin
						// Eek!
					end

					PkgInstrDecoder::Bad1_Iog0:
					begin
						// Eek!
					end

					default:
					begin
						//$display("Three registers ALU operation:  %h",
						//	__out_alu.data);
						//__stage_write_back_input_data.n_reg_data 
						//	<= __out_alu.data;
						prep_ra_write(__out_alu.data);
					end
				endcase
			end

			// Group 1:  instructions that use immediate values
			4'd1:
			begin
				// Imply to synthesis tools that we want a decoder to be
				// formed.
				case (__multi_stage_data_execute.instr_opcode)
					PkgInstrDecoder::Cpyhi_OneRegOneImm:
					begin
						prep_ra_write(__locals.cpyhi_data);
					end

					PkgInstrDecoder::Addsi_OneRegOnePcOneSimm:
					begin
						prep_ra_write(__multi_stage_data_execute.pc_val
						// Sign extend the immediate value with the funky
						// SystemVerilog feature for replicating a single
						// bit.
						 
							+ {{16{__multi_stage_data_execute.instr_imm_val
							[15]}}, 
							__multi_stage_data_execute.instr_imm_val});
					end

					PkgInstrDecoder::Muli_TwoRegsOneImm:
					begin
						prep_ra_write(({(__locals.mul_partial_result_x1_y0
							+ __locals.mul_partial_result_x0_y1),
							16'h0000})
							+ __locals.mul_partial_result_x0_y0);
					end

					// All group 1 instructions opcodes are for valid
					// instructions, so it's okay to have a "default" case
					// here (instead of checking them all individually
					default:
					begin
						prep_ra_write(__out_alu.data);
					end
				endcase

			end

			// Group 4:  Calls
			4'd4:
			begin
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
						//// Prevent "lr" write back for bad opcodes
						//__stage_write_back_input_data.do_write_lr <= 0;
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
				case (__multi_stage_data_execute.instr_ldst_type)
					PkgInstrDecoder::Ld32:
					begin
						$display("Load into r%d:  %h", 
							__multi_stage_data_execute.instr_ra_index,
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
						// Sign extend with the funky SystemVerilog feature
						// for replicating bits.
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
						// Sign extend with the funky SystemVerilog feature
						// for replicating bits.
						prep_ra_write({{24{in.data[7]}}, 
							in.data[7:0]});
					end

					default:
					begin
						
					end
				endcase

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
						prep_ra_write(__stage_execute_input_data
							.ireta_data);
					end
					PkgInstrDecoder::Cpy_OneRegOneIdsta:
					begin
						prep_ra_write(__stage_execute_input_data
							.idsta_data);
					end

					default:
					begin
					end
				endcase
			end
		endcase
	//end
	end
	end


	//// Stage 4 (3 if no Register Read stage):  Write Back
	//always @ (posedge clk)
	//begin
	//if (!in.wait_for_mem)
	//begin
	////if (!__multi_stage_data_write_back.nop)
	////begin
	//	case (__multi_stage_data_write_back.instr_group)
	//		// Group 0:  Three register ALU operations
	//		4'd0:
	//		begin
	//			//if (__multi_stage_data_write_back.instr_opcode
	//			//	< PkgInstrDecoder::Bad0_Iog0)
	//			if ((__multi_stage_data_write_back.instr_opcode
	//				!= PkgInstrDecoder::Bad0_Iog0)
	//				&& (__multi_stage_data_write_back.instr_opcode
	//				!= PkgInstrDecoder::Bad1_Iog0))
	//			begin
	//				prep_ra_write
	//					(__stage_write_back_input_data.n_reg_data);
	//			end

	//			else
	//			begin
	//				// Treat this instruction as a NOP (no write-back)
	//			end
	//		end

	//		// Group 1 Instructions:  Immediates
	//		// All group 1 opcodes are valid instructions, and they all
	//		// require a write back.
	//		4'd1:
	//		begin
	//			prep_ra_write(__stage_write_back_input_data.n_reg_data);
	//		end

	//		// Group 2:  Branches
	//		// We don't need to do any actual write back for this group.
	//		4'd2:
	//		begin

	//		end

	//		// Group 3:  Jumps
	//		// We don't need to do any actual write back for this group.
	//		4'd3:
	//		begin
	//			
	//		end

	//		// Group 4:  Calls
	//		// We need to write back lr for these instructions
	//		4'd4:
	//		begin
	//			if (__stage_write_back_input_data.do_write_lr)
	//			begin
	//				// Make sure to write back to lr!
	//				prep_reg_write(__REG_LR_INDEX,
	//					__stage_write_back_input_data.n_reg_data);
	//			end
	//		end


	//		// Group 5:  Loads and Stores
	//		4'd5:
	//		begin
	//			case (__multi_stage_data_write_back.instr_opcode)
	//				PkgInstrDecoder::Ldr_ThreeRegsLdst:
	//				begin
	//					$display("Load into r%d:  %h", 
	//						__multi_stage_data_write_back.instr_ra_index,
	//						in.data);
	//					prep_ra_write(in.data);
	//				end

	//				PkgInstrDecoder::Ldh_ThreeRegsLdst:
	//				begin
	//					// Zero extend
	//					prep_ra_write({16'h0000, in.data[15:0]});
	//				end

	//				PkgInstrDecoder::Ldsh_ThreeRegsLdst:
	//				begin
	//					// Sign extend
	//					//prep_ra_write(in.data[15]
	//					//	? {16'hffff, in.data[15:0]}
	//					//	: {16'h0000, in.data[15:0]});
	//					prep_ra_write({{16{in.data[15]}}, 
	//						in.data[15:0]});
	//				end

	//				PkgInstrDecoder::Ldb_ThreeRegsLdst:
	//				begin
	//					// Zero extend
	//					prep_ra_write({24'h000000, in.data[7:0]});
	//				end

	//				PkgInstrDecoder::Ldsb_ThreeRegsLdst:
	//				begin
	//					// Sign extend
	//					//prep_ra_write(in.data[7]
	//					//	? {24'hffffff, in.data[7:0]}
	//					//	: {24'h000000, in.data[7:0]});
	//					prep_ra_write({{24{in.data[7]}}, in.data[7:0]});
	//				end

	//				PkgInstrDecoder::Ldri_TwoRegsOneSimm12Ldst:
	//				begin
	//					prep_ra_write(in.data);
	//				end

	//				PkgInstrDecoder::Ldhi_TwoRegsOneSimm12Ldst:
	//				begin
	//					// Zero extend
	//					prep_ra_write({16'h0000, in.data[15:0]});
	//				end

	//				PkgInstrDecoder::Ldshi_TwoRegsOneSimm12Ldst:
	//				begin
	//					// Sign extend
	//					//prep_ra_write(in.data[15]
	//					//	? {16'hffff, in.data[15:0]}
	//					//	: {16'h0000, in.data[15:0]});
	//					prep_ra_write({{16{in.data[15]}}, 
	//						in.data[15:0]});
	//				end

	//				PkgInstrDecoder::Ldbi_TwoRegsOneSimm12Ldst:
	//				begin
	//					// Zero extend
	//					prep_ra_write({24'h000000, in.data[7:0]});
	//				end

	//				PkgInstrDecoder::Ldsbi_TwoRegsOneSimm12Ldst:
	//				begin
	//					// Sign extend
	//					//prep_ra_write(in.data[7]
	//					//	? {24'hffffff, in.data[7:0]}
	//					//	: {24'h000000, in.data[7:0]});
	//					prep_ra_write({{24{in.data[7]}}, in.data[7:0]});
	//				end

	//				default:
	//				begin
	//					
	//				end
	//			endcase
	//		end

	//		// Group 6:  Interrupts stuff
	//		4'd6:
	//		begin
	//			case (__multi_stage_data_write_back.instr_opcode)
	//				//PkgInstrDecoder::Ei_NoArgs:
	//				//begin
	//				//	
	//				//end
	//				//PkgInstrDecoder::Di_NoArgs:
	//				//begin
	//				//	
	//				//end
	//				//PkgInstrDecoder::Cpy_OneIretaOneReg:
	//				//begin
	//				//	
	//				//end
	//				PkgInstrDecoder::Cpy_OneRegOneIreta:
	//				begin
	//					prep_ra_write
	//						(__stage_write_back_input_data.n_reg_data);
	//				end

	//				//PkgInstrDecoder::Cpy_OneIdstaOneReg:
	//				//begin
	//				//	
	//				//end
	//				PkgInstrDecoder::Cpy_OneRegOneIdsta:
	//				begin
	//					prep_ra_write
	//						(__stage_write_back_input_data.n_reg_data);
	//				end
	//				//PkgInstrDecoder::Reti_NoArgs:
	//				//begin
	//				//	
	//				//end
	//				default:
	//				begin
	//					
	//				end
	//			endcase
	//		end

	//		default:
	//		begin
	//			// Eek!
	//		end
	//	endcase
	////end
	//end
	//end

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
				//__in_alu.oper = __multi_stage_data_execute.instr_opcode;

				//// We just always perform the temporary multiplications
				//`ifdef OPT_HAVE_SINGLE_CYCLE_MULTIPLY
				//__locals.mul_partial_result_x0_y0
				//	= __stage_execute_input_data.rfile_rb_data[15:0]
				//	* __stage_execute_input_data.rfile_rc_data[15:0];
				//__locals.mul_partial_result_x0_y1 
				//	= __stage_execute_input_data.rfile_rb_data[15:0]
				//	* __stage_execute_input_data.rfile_rc_data[31:16];
				//__locals.mul_partial_result_x1_y0
				//	= __stage_execute_input_data.rfile_rb_data[31:16]
				//	* __stage_execute_input_data.rfile_rc_data[15:0];
				//`endif		// OPT_HAVE_SINGLE_CYCLE_MULTIPLY
			end

			// Group 1:  Immediates
			1:
			begin
				__in_alu.a = __stage_execute_input_data.rfile_rb_data;
				__in_alu.oper = __multi_stage_data_execute.instr_opcode;
				//__in_alu.oper = __multi_stage_data_execute.instr_opcode;

				//// We just always perform the temporary multiplications
				//`ifdef OPT_HAVE_SINGLE_CYCLE_MULTIPLY
				//__locals.mul_partial_result_x0_y0
				//	= __stage_execute_input_data.rfile_rb_data[15:0]
				//	* __multi_stage_data_execute.instr_imm_val;
				//__locals.mul_partial_result_x0_y1 
				//	= __stage_execute_input_data.rfile_rb_data[15:0]
				//	* 16'h0000;
				//__locals.mul_partial_result_x1_y0
				//	= __stage_execute_input_data.rfile_rb_data[31:16]
				//	* __multi_stage_data_execute.instr_imm_val;
				//`endif		// OPT_HAVE_SINGLE_CYCLE_MULTIPLY

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
