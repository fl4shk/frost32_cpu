


// src/register_file_defines.header.sv




// src/misc_defines.header.sv




// src/options_defines.header.sv






//`define OPT_HAVE_SINGLE_CYCLE_MULTIPLY
		// ICARUS

// Temporary




// For low clock rates (such as 50 MHz)
//`define OPT_VERY_FAST_DIV

//`define OPT_HAVE_STAGE_REGISTER_READ

//`ifdef OPT_NEW_PIPELINE
//`define OPT_HAVE_STAGE_INSTR_FETCH
//
//`else
//`define OPT_HAVE_STAGE_REGISTER_READ
//
//`ifndef OPT_HAVE_STAGE_REGISTER_READ
//`define OPT_HAVE_SINGLE_CYCLE_MULTIPLY
//`endif		// !OPT_HAVE_STAGE_REGISTER_READ
`default_nettype none

		// src__slash__misc_defines_header_sv







		// src__slash__register_file_defines_header_sv

package PkgRegisterFile;

typedef struct packed
{
	// Which registers to read from
	logic [((4) - 1):0] read_sel_ra, read_sel_rb, read_sel_rc;

	//logic [`MSB_POS__REG_FILE_SEL:0] read_sel_cond_ra, read_sel_cond_rb;

	// Which register to write to
	logic [((4) - 1):0] write_sel;

	// Data to write to the specific register
	logic [((32) - 1):0] write_data;

	// Whether or not to write at all
	logic write_en;

} PortIn_RegFile;

typedef struct packed
{
	logic [((32) - 1):0] read_data_ra, read_data_rb, 
		read_data_rc;

	//logic [`MSB_POS__REG_FILE_DATA:0] read_data_cond_ra, read_data_cond_rb;
} PortOut_RegFile;

endpackage : PkgRegisterFile



// src/frost32_cpu_defines.header.sv












		// src__slash__misc_defines_header_sv













//`define WIDTH__FROST32_CPU_DECODE_STAGE_STALL_COUNTER 3
//`define WIDTH__FROST32_CPU_DECODE_STAGE_STALL_COUNTER 8




		// OPT_FAST_DIV











// Used because Icarus Verilog doesn't support (as of this comment being
// written) packed structs inside other packed structs.







		// src__slash__frost32_cpu_defines_header_sv













		// src__slash__register_file_defines_header_sv



// src/instr_decoder_defines.header.sv












		// src__slash__misc_defines_header_sv







//`define WIDTH__INSTR_REG_INDEX 4
//`define MSB_POS__INSTR_REG_INDEX 

























		// src__slash__instr_decoder_defines_header_sv

package PkgFrost32Cpu;

typedef enum logic [
	((4) - 1):0]
{
	StInit,
	StRespondToInterrupt,
	StReti,
	StOther,
	//StMul,
	//StDiv,
	StMulDiv,
	StCtrlFlowBranch,
	StCtrlFlowJumpCall,
	StCpyRaToInterruptsRelatedAddr,
	StMemAccess
} StallState;

// Data used by more than one pipeline stage
typedef struct packed
{
	// For debugging
	logic [((32) - 1):0] raw_instruction;

	// Decoded instruction stuff
	logic [((4) - 1):0] instr_ra_index, instr_rb_index,
		instr_rc_index;
	logic [((16) - 1):0] instr_imm_val;
	logic [((4) - 1):0] instr_group;
	logic [((4) - 1):0] instr_opcode;
	logic [((3) - 1):0] instr_ldst_type;
	logic instr_causes_stall;
	logic [
	((4) - 1):0] instr_condition_type;


	// What the PC was for this instruction
	logic [((32) - 1):0] pc_val;

	logic nop;



} MultiStageData;



typedef struct packed
{
	logic [
	((32) - 1):0] data;

	logic wait_for_mem;
	logic interrupt;
} PortIn_Frost32Cpu;

typedef enum logic
{
	DiatRead,
	DiatWrite
} DataInoutAccessType;

typedef enum logic [
	((2) - 1):0]
{
	Dias32,
	Dias16,
	Dias8,
	DiasBad
} DataInoutAccessSize;

typedef struct packed
{
	//logic [`MSB_POS__FROST32_CPU_DATA_INOUT:0] data;
	//logic [`MSB_POS__FROST32_CPU_ADDR:0] addr;
	//logic data_inout_access_type;
	//logic [`MSB_POS__FROST32_CPU_DATA_ACCESS_SIZE:0]
	//	data_inout_access_size;
	//logic req_mem_access;
	
	logic [
	((32) - 1):0] data;
	logic [
	((32) - 1):0] addr;
	logic data_inout_access_type;
	logic [
	((2) - 1):0] data_inout_access_size;
	logic req_mem_access;

	
	logic [((32) - 1):0] debug_reg_zero, debug_reg_u0,
		debug_reg_u1, debug_reg_u2, debug_reg_u3, debug_reg_u4,
		debug_reg_u5, debug_reg_u6, debug_reg_u7, debug_reg_u8,
		debug_reg_u9, debug_reg_u10, debug_reg_temp, debug_reg_lr,
		debug_reg_fp, debug_reg_sp;
			// OPT_DEBUG_REGISTER_FILE
} PortOut_Frost32Cpu;

endpackage : PkgFrost32Cpu



// src/alu_defines.header.sv












		// src__slash__misc_defines_header_sv











		// src__slash__alu_defines_header_sv

package PkgAlu;


typedef struct packed
{
	logic [((32) - 1):0] data;
	logic [4:0] amount;
} PortIn_Shift;

typedef struct packed
{
	logic [((32) - 1):0] data;
} PortOut_Shift;

typedef struct packed
{
	// less than unsigned, less than signed
	logic ltu, lts;

	// greater than unsigned, greater than signed
	logic gtu, gts;
} PortOut_Compare;

typedef struct packed
{
	logic enable;
	logic [((32) - 1):0] x, y;
} PortIn_Multiplier32;

typedef struct packed
{
	logic can_accept_cmd, data_ready;
	logic [((32) - 1):0] prod;
} PortOut_Multiplier32;

typedef enum logic [((4) - 1):0]
{
	Add,
	Sub,
	Sltu,
	Slts,

	Sgtu,
	Sgts,
	AndN,
	And,

	Or,
	Xor,
	Nor,
	Lsl,

	Lsr,
	Asr,
	OrN,
	Nand
	//Cpyhi
} AluOper;

typedef struct packed
{
	logic [((32) - 1):0] a, b;
	//AluOper oper;
	logic [((4) - 1):0] oper;
} PortIn_Alu;

typedef struct packed
{
	logic [((32) - 1):0] data;
} PortOut_Alu;

endpackage : PkgAlu



// src/main_mem_defines.header.sv












		// src__slash__misc_defines_header_sv

		// src__slash__main_mem_defines_header_sv














































		// src__slash__frost32_cpu_defines_header_sv













		// src__slash__register_file_defines_header_sv








































		// src__slash__instr_decoder_defines_header_sv

package PkgMainMem;

typedef struct packed
{
	
	logic [
	((32) - 1):0] data;
	logic [
	((32) - 1):0] addr;
	logic data_inout_access_type;
	logic [
	((2) - 1):0] data_inout_access_size;
	logic req_mem_access;
} PortIn_MainMem;

typedef struct packed
{
	logic [
	((32) - 1):0] data;
	logic wait_for_mem;
} PortOut_MainMem;


endpackage : PkgMainMem



// src/cache_defines.header.sv












		// src__slash__misc_defines_header_sv














		// src__slash__cache_defines_header_sv








































		// src__slash__instr_decoder_defines_header_sv

package PkgInstrDecoder;


//parameter POS_HIGH__INSTR_GROUP = 31;
//parameter POS_LOW__INSTR_GROUP = 28;
//
//parameter POS_HIGH__RA_INDEX = 27;
//parameter POS_LOW__RA_INDEX = 24;
//
//parameter POS_HIGH__RB_INDEX = 23;
//parameter POS_LOW__RB_INDEX = 20;

typedef enum logic [((3) - 1):0]
{
	Ld32,
	LdU16,
	LdS16,
	LdU8,
	LdS8,
	St32,
	St16,
	St8
} LdstType;

typedef enum logic [
	((4) - 1):0]
{
	CtNe,
	CtEq,
	CtLtu,
	CtGeu,

	CtLeu,
	CtGtu,
	CtLts,
	CtGes,

	CtLes,
	CtGts,
	CtBad0,
	CtBad1,

	CtBad2,
	CtBad3,
	CtBad4,
	CtBad5
} CondType;


typedef struct packed
{
	logic [((4) - 1):0] group;
	logic [((4) - 1):0] ra_index, rb_index, rc_index;
	logic [((4) - 1):0] opcode;
	logic [((16) - 1):0] imm_val;
	logic [((3) - 1):0] ldst_type;
	logic causes_stall;
	logic [
	((4) - 1):0] condition_type;
} PortOut_InstrDecoder;

typedef struct packed
{
	// should be 4'b0000
	logic [((4) - 1):0] group;
	logic [((4) - 1):0] ra_index, rb_index, rc_index;

	// blank (should be filled with zeroes)
	logic [((12) - 1):0] fill;
	logic [((4) - 1):0] opcode;
} Iog0Instr;

typedef struct packed
{
	// should be 0b0001
	logic [((4) - 1):0] group;
	logic [((4) - 1):0] ra_index, rb_index;
	logic [((4) - 1):0] opcode;
	logic [((16) - 1):0] imm_val;
} Iog1Instr;

// Group 2:  Branches
typedef struct packed
{
	// should be 0b0010
	logic [((4) - 1):0] group;
	logic [((4) - 1):0] ra_index, rb_index;
	logic [((4) - 1):0] opcode;
	logic [((16) - 1):0] imm_val;
} Iog2Instr;

// Group 3:  Jumps
typedef struct packed
{
	// should be 4'b0011
	logic [((4) - 1):0] group;
	logic [((4) - 1):0] ra_index, rb_index, rc_index;

	// blank (should be filled with zeroes)
	logic [((12) - 1):0] fill;
	logic [((4) - 1):0] opcode;
} Iog3Instr;

// Group 4:  Calls
typedef struct packed
{
	// should be 4'b0100
	logic [((4) - 1):0] group;
	logic [((4) - 1):0] ra_index, rb_index, rc_index;

	// blank (should be filled with zeroes)
	logic [((12) - 1):0] fill;
	logic [((4) - 1):0] opcode;
} Iog4Instr;


// Group 5:  Loads and stores
typedef struct packed
{
	// should be 0b0101
	logic [((4) - 1):0] group;
	logic [((4) - 1):0] ra_index, rb_index, rc_index;

	//// blank (should be filled with zeroes)
	//logic [`MSB_POS__INSTR_FILL:0] fill;
	logic [
	((12) - 1):0] imm_val_12;
	logic [((4) - 1):0] opcode;
} Iog5Instr;


// Group 6:  Interrupts stuff
typedef struct packed
{
	// should be 4'b0110
	logic [((4) - 1):0] group;
	logic [((4) - 1):0] ra_index, rb_index, rc_index;

	// blank (should be filled with zeroes)
	logic [((12) - 1):0] fill;
	logic [((4) - 1):0] opcode;
} Iog6Instr;

typedef enum logic [((4) - 1):0]
{
	Add_ThreeRegs,
	Sub_ThreeRegs,
	Sltu_ThreeRegs,
	Slts_ThreeRegs,

	Sgtu_ThreeRegs,
	Sgts_ThreeRegs,
	Mul_ThreeRegs,
	And_ThreeRegs,

	Orr_ThreeRegs,
	Xor_ThreeRegs,
	Nor_ThreeRegs,
	Lsl_ThreeRegs,

	Lsr_ThreeRegs,
	Asr_ThreeRegs,
	//Bad0_Iog0,
	//Bad1_Iog0
	Udiv_ThreeRegs,
	Sdiv_ThreeRegs
} Iog0Oper;

typedef enum logic [((4) - 1):0]
{
	Addi_TwoRegsOneImm,
	Subi_TwoRegsOneImm,
	Sltui_TwoRegsOneImm,
	Sltsi_TwoRegsOneSimm,

	Sgtui_TwoRegsOneImm,
	Sgtsi_TwoRegsOneSimm,
	Muli_TwoRegsOneImm,
	Andi_TwoRegsOneImm,

	Orri_TwoRegsOneImm,
	Xori_TwoRegsOneImm,
	Nori_TwoRegsOneImm,
	Lsli_TwoRegsOneImm,

	Lsri_TwoRegsOneImm,
	Asri_TwoRegsOneImm,
	Addsi_OneRegOnePcOneSimm,
	Cpyhi_OneRegOneImm
} Iog1Oper;

typedef enum logic [((4) - 1):0]
{
	Bne_TwoRegsOneSimm,
	Beq_TwoRegsOneSimm,
	Bltu_TwoRegsOneSimm,
	Bgeu_TwoRegsOneSimm,

	Bleu_TwoRegsOneSimm,
	Bgtu_TwoRegsOneSimm,
	Blts_TwoRegsOneSimm,
	Bges_TwoRegsOneSimm,

	Bles_TwoRegsOneSimm,
	Bgts_TwoRegsOneSimm,
	Bad0_Iog2,
	Bad1_Iog2,

	Bad2_Iog2,
	Bad3_Iog2,
	Bad4_Iog2,
	Bad5_Iog2
} Iog2Oper;

typedef enum logic [((4) - 1):0]
{
	Jne_TwoRegsOneSimm,
	Jeq_TwoRegsOneSimm,
	Jltu_TwoRegsOneSimm,
	Jgeu_TwoRegsOneSimm,

	Jleu_TwoRegsOneSimm,
	Jgtu_TwoRegsOneSimm,
	Jlts_TwoRegsOneSimm,
	Jges_TwoRegsOneSimm,

	Jles_TwoRegsOneSimm,
	Jgts_TwoRegsOneSimm,
	Bad0_Iog3,
	Bad1_Iog3,

	Bad2_Iog3,
	Bad3_Iog3,
	Bad4_Iog3,
	Bad5_Iog3
} Iog3Oper;

typedef enum logic [((4) - 1):0]
{
	Cne_TwoRegsOneSimm,
	Ceq_TwoRegsOneSimm,
	Cltu_TwoRegsOneSimm,
	Cgeu_TwoRegsOneSimm,

	Cleu_TwoRegsOneSimm,
	Cgtu_TwoRegsOneSimm,
	Clts_TwoRegsOneSimm,
	Cges_TwoRegsOneSimm,

	Cles_TwoRegsOneSimm,
	Cgts_TwoRegsOneSimm,
	Bad0_Iog4,
	Bad1_Iog4,

	Bad2_Iog4,
	Bad3_Iog4,
	Bad4_Iog4,
	Bad5_Iog4
} Iog4Oper;

typedef enum logic [((4) - 1):0]
{
	Ldr_ThreeRegsLdst,
	Ldh_ThreeRegsLdst,
	Ldsh_ThreeRegsLdst,
	Ldb_ThreeRegsLdst,

	Ldsb_ThreeRegsLdst,
	Str_ThreeRegsLdst,
	Sth_ThreeRegsLdst,
	Stb_ThreeRegsLdst,

	Ldri_TwoRegsOneSimm12Ldst,
	Ldhi_TwoRegsOneSimm12Ldst,
	Ldshi_TwoRegsOneSimm12Ldst,
	Ldbi_TwoRegsOneSimm12Ldst,

	Ldsbi_TwoRegsOneSimm12Ldst,
	Stri_TwoRegsOneSimm12Ldst,
	Sthi_TwoRegsOneSimm12Ldst,
	Stbi_TwoRegsOneSimm12Ldst
} Iog5Oper;

typedef enum logic [((4) - 1):0]
{
	Ei_NoArgs,
	Di_NoArgs,
	Cpy_OneIretaOneReg,
	Cpy_OneRegOneIreta,

	Cpy_OneIdstaOneReg,
	Cpy_OneRegOneIdsta,
	Reti_NoArgs,
	Bad0_Iog6,

	Bad1_Iog6,
	Bad2_Iog6,
	Bad3_Iog6,
	Bad4_Iog6,

	Bad5_Iog6,
	Bad6_Iog6,
	Bad7_Iog6,
	Bad8_Iog6
} Iog6Oper;


endpackage : PkgInstrDecoder
//`include "src/misc_defines.header.sv"
//
//module TestBench;
//
//	import PkgFrost32Cpu::*;
//	import PkgMainMem::*;
//
//	logic __clk, __half_clk;
//	MainClockGenerator __inst_main_clk_gen(.clk(__clk));
//	HalfClockGenerator __inst_half_clk_gen(.clk(__half_clk));
//
//	struct packed
//	{
//		logic interrupt;
//		logic can_interrupt;
//	} __locals;
//
//	PkgFrost32Cpu::PortIn_Frost32Cpu __in_frost32_cpu;
//	PkgFrost32Cpu::PortOut_Frost32Cpu __out_frost32_cpu;
//
//	//Frost32Cpu __inst_frost32_cpu(.clk(__half_clk), .in(__in_frost32_cpu),
//	//	.out(__out_frost32_cpu));
//	//Frost32Cpu __inst_frost32_cpu(.clk(__clk), .in(__in_frost32_cpu),
//	//	.out(__out_frost32_cpu));
//
//	Frost32Cpu __inst_frost32_cpu(.clk(__clk), 
//		.in_data(__in_frost32_cpu.data),
//		.in_wait_for_mem(__in_frost32_cpu.wait_for_mem),
//		.in_interrupt(__in_frost32_cpu.interrupt),
//		.out_data(__out_frost32_cpu.data),
//		.out_addr(__out_frost32_cpu.addr),
//		.out_data_inout_access_type
//			(__out_frost32_cpu.data_inout_access_type),
//		.out_data_inout_access_size
//			(__out_frost32_cpu.data_inout_access_size),
//		.out_req_mem_access(__out_frost32_cpu.req_mem_access)
//		`ifdef OPT_DEBUG_REGISTER_FILE
//		,
//		.out_debug_reg_zero(__out_frost32_cpu.debug_reg_zero),
//		.out_debug_reg_u0(__out_frost32_cpu.debug_reg_u0),
//		.out_debug_reg_u1(__out_frost32_cpu.debug_reg_u1),
//		.out_debug_reg_u2(__out_frost32_cpu.debug_reg_u2),
//
//		.out_debug_reg_u3(__out_frost32_cpu.debug_reg_u3),
//		.out_debug_reg_u4(__out_frost32_cpu.debug_reg_u4),
//		.out_debug_reg_u5(__out_frost32_cpu.debug_reg_u5),
//		.out_debug_reg_u6(__out_frost32_cpu.debug_reg_u6),
//
//		.out_debug_reg_u7(__out_frost32_cpu.debug_reg_u7),
//		.out_debug_reg_u8(__out_frost32_cpu.debug_reg_u8),
//		.out_debug_reg_u9(__out_frost32_cpu.debug_reg_u9),
//		.out_debug_reg_u10(__out_frost32_cpu.debug_reg_u10),
//
//		.out_debug_reg_temp(__out_frost32_cpu.debug_reg_temp),
//		.out_debug_reg_lr(__out_frost32_cpu.debug_reg_lr),
//		.out_debug_reg_fp(__out_frost32_cpu.debug_reg_fp),
//		.out_debug_reg_sp(__out_frost32_cpu.debug_reg_sp)
//		`endif		// OPT_DEBUG_REGISTER_FILE
//		);
//
//	PkgMainMem::PortIn_MainMem __in_main_mem;
//	PkgMainMem::PortOut_MainMem __out_main_mem;
//	MainMem __inst_main_mem(.clk(__clk), 
//		`ifdef OPT_DEBUG_MEM_ACCESS
//		.half_clk(__half_clk),
//		`endif		// OPT_DEBUG_MEM_ACCESS
//		.in(__in_main_mem), .out(__out_main_mem));
//
//
//	assign __in_frost32_cpu.data = __out_main_mem.data;
//	//assign __in_frost32_cpu.wait_for_mem = __out_main_mem.wait_for_mem;
//
//	assign __in_main_mem.data = __out_frost32_cpu.data;
//	assign __in_main_mem.addr = __out_frost32_cpu.addr;
//	assign __in_main_mem.data_inout_access_type
//		= __out_frost32_cpu.data_inout_access_type;
//	assign __in_main_mem.data_inout_access_size
//		= __out_frost32_cpu.data_inout_access_size;
//	assign __in_main_mem.req_mem_access = __out_frost32_cpu.req_mem_access;
//
//	// I'm not sure this will work
//	//assign __in_frost32_cpu.wait_for_mem 
//	//	= __out_frost32_cpu.req_mem_access || __out_main_mem.wait_for_mem;
//	assign __in_frost32_cpu.wait_for_mem = __out_main_mem.wait_for_mem;
//
//	assign __in_frost32_cpu.interrupt = __locals.interrupt;
//
//	//always @ (posedge __clk)
//	//begin
//	//	//$display("TestBench:  %h\t\t%h %h\t\t%h %h",
//	//	//	__in_frost32_cpu.wait_for_mem,
//	//	//	__out_frost32_cpu.data, __out_frost32_cpu.addr,
//	//	//	__out_frost32_cpu.data_inout_access_type,
//	//	//	__out_frost32_cpu.data_inout_access_size);
//	//	$display("TestBench:  %h", __in_frost32_cpu.wait_for_mem);
//	//end
//
//
//	initial
//	begin
//		$dumpfile("test.vcd");
//		$dumpvars(0, TestBench);
//
//		__locals = 0;
//
//		////#500
//		////#50
//		//#100
//		//#2000
//		//#200
//		//#1000
//		//$finish;
//
//		#1000
//		#104
//		__locals.interrupt = 1;
//
//		//__locals.interrupt = 0;
//
//		//#160
//		#60
//		__locals.interrupt = 0;
//
//		#2000
//
//		#104
//		__locals.interrupt = 1;
//
//		#60
//		__locals.interrupt = 0;
//
//		#1000
//		$finish;
//	end
//
//	//always @ (posedge __clk)
//	//begin
//	//	//if (__locals.can_interrupt && !__in_frost32_cpu.wait_for_mem)
//	//	//begin
//	//	//	if (!__locals.interrupt)
//	//	//	begin
//	//	//		
//	//	//	end
//	//	//end
//	//end
//
//	//initial
//	//begin
//	//	#500
//	//	$display("test bench finish");
//	//	$finish;
//	//end
//
//	//always @ (posedge __half_clk)
//	//begin
//	//	
//	//end
//
//
//endmodule













		// src__slash__register_file_defines_header_sv

//`define GEN_REG_FILE_READ_SYNCHRONOUS(read_sel_name, read_data_name) \
//	always_ff @ (posedge clk) \
//	begin \
//		if (in.write_en && (in.write_sel == in.read_sel_name) \
//			&& (in.write_sel != 0)) \
//		begin \
//			$display("RegisterFile:  Reading written data:  %h %h %h %h", \
//				in.read_sel_name, in.read_sel_name, in.write_data, \
//				__regfile[in.read_sel_name]); \
//			out.read_data_name <= in.write_data; \
//		end \
//\
//		else \
//		begin \
//			$display("RegisterFile:  Reading existing data:  %h %h %h %h", \
//				in.read_sel_name, in.read_sel_name, in.write_data, \
//				__regfile[in.read_sel_name]); \
//			out.read_data_name <= __regfile[in.read_sel_name]; \
//		end \
//	end














//`define GEN_REG_FILE_READ_SYNCHRONOUS(read_sel_name, read_data_name) \
//	always_ff @ (posedge clk) \
//	begin \
//		$display("RegisterFile read:  __regfile[%h] == %h", \
//			in.read_sel_name, __regfile[in.read_sel_name]); \
//		out.read_data_name <= __regfile[in.read_sel_name]; \
//	end
//`define GEN_REG_FILE_READ_SYNCHRONOUS(read_sel_name, read_data_name) \
//	always_ff @ (posedge clk) \
//	begin \
//		out.read_data_name <= __regfile[in.read_sel_name]; \
//	end
//`define GEN_REG_FILE_READ_SYNCHRONOUS(read_sel_name, read_data_name) \
//	always_ff @ (posedge clk) \
//	begin \
//		if (in.read_sel_name == 0) \
//		begin \
//			out.read_data_name <= 0; \
//		end \
//\
//		else \
//		begin \
//			out.read_data_name <= __regfile[in.read_sel_name]; \
//		end \
//	end














//`define GEN_REG_FILE_READ_ASYNCHRONOUS(read_sel_name, read_data_name) \
//	always_comb \
//	begin \
//		if (in.read_sel_name == 0) \
//		begin \
//			out.read_data_name = 0; \
//		end \
//\
//		else \
//		begin \
//			out.read_data_name = __regfile[in.read_sel_name]; \
//		end \
//	end

//`ifdef OPT_HAVE_STAGE_REGISTER_READ


//`else
//`define GEN_REG_FILE_READ(read_sel_name, read_data_name) \
//	`GEN_REG_FILE_READ_ASYNCHRONOUS(read_sel_name, read_data_name)
//`endif		// OPT_HAVE_STAGE_REGISTER_READ

// No register read stage:  Asynchronous reads (three ports), synchronous
// writes (one port)
// With register read stage:  Synchronous reads (three ports), synchronous
// writes (one port)
module RegisterFile(input logic clk,
	input PkgRegisterFile::PortIn_RegFile in,
	output PkgRegisterFile::PortOut_RegFile out
	
	,
	output logic [((32) - 1):0] 
		out_debug_zero, 
		out_debug_u0, out_debug_u1, out_debug_u2, out_debug_u3,
		out_debug_u4, out_debug_u5, out_debug_u6, out_debug_u7,
		out_debug_u8, out_debug_u9, out_debug_u10, 
		out_debug_temp, out_debug_lr, out_debug_fp, out_debug_sp
			// OPT_DEBUG_REGISTER_FILE
	);

	import PkgRegisterFile::*;

	parameter __ARR_SIZE__NUM_REGISTERS = 16;
	parameter __LAST_INDEX__NUM_REGISTERS 
		= ((__ARR_SIZE__NUM_REGISTERS) - 1);


	
	logic [((32) - 1):0]
		__regfile[0 : __LAST_INDEX__NUM_REGISTERS];
	


		// ICARUS


	
	assign out_debug_zero = __regfile[0];
	assign out_debug_u0 = __regfile[1];
	assign out_debug_u1 = __regfile[2];
	assign out_debug_u2 = __regfile[3];
	assign out_debug_u3 = __regfile[4];
	assign out_debug_u4 = __regfile[5];
	assign out_debug_u5 = __regfile[6];
	assign out_debug_u6 = __regfile[7];
	assign out_debug_u7 = __regfile[8];
	assign out_debug_u8 = __regfile[9];
	assign out_debug_u9 = __regfile[10];
	assign out_debug_u10 = __regfile[11];
	assign out_debug_temp = __regfile[12];
	assign out_debug_lr = __regfile[13];
	assign out_debug_fp = __regfile[14];
	assign out_debug_sp = __regfile[15];
			// OPT_DEBUG_REGISTER_FILE

	initial
	begin
		for (int i=0; i<__ARR_SIZE__NUM_REGISTERS; ++i)
		begin
			__regfile[i] = 0;
		end

		out = 0;
	end

	// Reading
	
	
	always_ff @ (posedge clk)
	begin
		if (in.write_en && (in.write_sel == in.read_sel_ra)
			&& (in.write_sel != 0))
		begin
			out.read_data_ra <= in.write_data;
		end

		else
		begin
			out.read_data_ra <= __regfile[in.read_sel_ra];
		end
	end
	
	
	always_ff @ (posedge clk)
	begin
		if (in.write_en && (in.write_sel == in.read_sel_rb)
			&& (in.write_sel != 0))
		begin
			out.read_data_rb <= in.write_data;
		end

		else
		begin
			out.read_data_rb <= __regfile[in.read_sel_rb];
		end
	end
	
	
	always_ff @ (posedge clk)
	begin
		if (in.write_en && (in.write_sel == in.read_sel_rc)
			&& (in.write_sel != 0))
		begin
			out.read_data_rc <= in.write_data;
		end

		else
		begin
			out.read_data_rc <= __regfile[in.read_sel_rc];
		end
	end

	////`ifdef OPT_HAVE_STAGE_REGISTER_READ
	////`GEN_REG_FILE_READ_SYNCHRONOUS(read_sel_cond_ra, read_data_cond_ra)
	////`GEN_REG_FILE_READ_SYNCHRONOUS(read_sel_cond_rb, read_data_cond_rb)
	//`GEN_REG_FILE_READ_ASYNCHRONOUS(read_sel_ra, read_data_cond_ra)
	//`GEN_REG_FILE_READ_ASYNCHRONOUS(read_sel_rb, read_data_cond_rb)
	////`endif		// OPT_HAVE_STAGE_REGISTER_READ

	always_ff @ (posedge clk)
	begin
		if (in.write_en && (in.write_sel != 0))
		begin
			//$display("RegisterFile:  write_sel, write_data:  %h, %h",
			//	in.write_sel, in.write_data);
			__regfile[in.write_sel] <= in.write_data;
		end

		//$display("RegisterFile:  inputs:  %h %h %h", 
		//	in.write_en, in.write_sel, in.write_data);
		//$display("RegisterFile (0 to 3):  %h %h %h %h",
		//	__regfile[0], __regfile[1], __regfile[2], __regfile[3]);
		//$display("RegisterFile (4 to 7):  %h %h %h %h",
		//	__regfile[4], __regfile[5], __regfile[6], __regfile[7]);
		//$display("RegisterFile (8 to 11):  %h %h %h %h",
		//	__regfile[8], __regfile[9], __regfile[10], __regfile[11]);
		//$display("RegisterFile (12 to 15):  %h %h %h %h",
		//	__regfile[12], __regfile[13], __regfile[14], __regfile[15]);

		//$display();
	end

	//always @ (posedge clk)
	//begin
	//end
endmodule











		// src__slash__misc_defines_header_sv








































		// src__slash__instr_decoder_defines_header_sv

















		// src__slash__alu_defines_header_sv













		// src__slash__register_file_defines_header_sv

	


//module Frost32Cpu(input logic clk,
//	input PkgFrost32Cpu::PortIn_Frost32Cpu in,
//	output PkgFrost32Cpu::PortOut_Frost32Cpu out);
module Frost32Cpu(input logic clk,
	input logic [
	((32) - 1):0] in_data,
	input logic in_wait_for_mem, in_interrupt,

	output logic [
	((32) - 1):0] out_data,
	output logic [
	((32) - 1):0] out_addr,
	output logic out_data_inout_access_type,
	output logic [
	((2) - 1):0]
		out_data_inout_access_size,
	output logic out_req_mem_access
	
	,
	output logic [((32) - 1):0] 
		out_debug_reg_zero, out_debug_reg_u0,
		out_debug_reg_u1, out_debug_reg_u2, 
		out_debug_reg_u3, out_debug_reg_u4,
		out_debug_reg_u5, out_debug_reg_u6, 
		out_debug_reg_u7, out_debug_reg_u8,
		out_debug_reg_u9, out_debug_reg_u10, 
		out_debug_reg_temp, out_debug_reg_lr,
		out_debug_reg_fp, out_debug_reg_sp
			// OPT_DEBUG_REGISTER_FILE
	);



	import PkgInstrDecoder::*;
	import PkgAlu::*;
	import PkgRegisterFile::*;
	import PkgFrost32Cpu::*;

	PkgFrost32Cpu::PortIn_Frost32Cpu in;
	PkgFrost32Cpu::PortOut_Frost32Cpu out;

	assign in = {in_data, in_wait_for_mem, in_interrupt};

	assign {out_data, out_addr, out_data_inout_access_type,
		out_data_inout_access_size, out_req_mem_access
		
		,
		out_debug_reg_zero, out_debug_reg_u0,
		out_debug_reg_u1, out_debug_reg_u2, 
		out_debug_reg_u3, out_debug_reg_u4,
		out_debug_reg_u5, out_debug_reg_u6, 
		out_debug_reg_u7, out_debug_reg_u8,
		out_debug_reg_u9, out_debug_reg_u10, 
		out_debug_reg_temp, out_debug_reg_lr,
		out_debug_reg_fp, out_debug_reg_sp
				// OPT_DEBUG_REGISTER_FILE
		} = out;

	parameter __REG_LR_INDEX = 13;
	parameter __REG_SP_INDEX = 15;

	//parameter __STALL_COUNTER_RELATIVE_BRANCH = 4;
	//parameter __STALL_COUNTER_RELATIVE_BRANCH = 3;
	parameter __STALL_COUNTER_RELATIVE_BRANCH = 2;
	parameter __STALL_COUNTER_JUMP_OR_CALL = 3;

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
	


	
	// Hardcoded, though not the cleanest.
	parameter __STALL_COUNTER_DIVIDE_32 = 21;
	

		// OPT_FAST_DIV
			// OPT_VERY_FAST_DIV


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
		logic [
	((5) - 1):0]
			stall_counter;

		logic [
	((4) - 1):0] stall_state;
		//PkgFrost32Cpu::StallState stall_state;

		logic [((32) - 1):0] 
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
		logic [((32) - 1):0] rfile_ra_data, rfile_rb_data,
			rfile_rc_data;

		logic [
	((32) - 1):0] ireta_data, idsta_data;

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
	struct packed
	{
		logic [((4) - 1):0] to_write_reg_index;

		logic [((32) - 1):0] n_reg_data;
	} __stage_execute_generated_data;

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

		logic [((4) - 1):0] prev_written_reg_index;

		logic [((32) - 1):0] n_reg_data;

		//logic do_write_lr;

		//logic perform_operand_forwarding;
	}
		__stage_execute_output_data,
		__stage_write_back_output_data;


	struct packed
	{
		// The program counter (written to ONLY by the instruction decode
		// stage)
		logic [
	((32) - 1):0] pc;

		// Interrupt return address (where to return to when an interrupt
		// happens (set to the program counter of the instruction in the
		// decode stage when )
		logic [
	((32) - 1):0] ireta;

		// Interrupt destination address (the program counter gets set to
		// this when an interrutp happens)
		logic [
	((32) - 1):0] idsta;

		// Interrupt enable
		logic ie;

		//// Split up 32-bit by 32-bit multiplications into three 16-bit by
		//// 16-bit multiplications (which I believe can be synthesized into
		//// combinational logic) and some adds.
		//logic [`MSB_POS__MUL32_INOUT:0] 
		//	mul32_result,
		//	mul32_partial_result_x0_y0, mul32_partial_result_x1_y0, 
		//	mul32_partial_result_x0_y1;

		//logic [`MSB_POS__MUL32_INOUT:0] 
		//	mul32_partial_result_0, mul32_partial_result_1, 
		//	mul32_partial_result_2, mul32_partial_result_3;

		logic [
	((32) - 1):0] 
			branch_adder_a, branch_adder_b;
		//logic [`MSB_POS__FROST32_CPU_ADDR:0] 
		//	dest_of_ctrl_flow_if_condition, 
		//	next_pc_after_jump_or_call_cond,
		//	next_pc_after_jump_or_call_not_cond;
		//	//next_pc_after_jump_or_call;
		//logic jump_or_call_condition;
		logic [
	((32) - 1):0] 
			ldst_adder_a, ldst_adder_b;
		logic [
	((32) - 1):0] ldst_address;

		logic cond_ne, cond_eq, 
			cond_ltu, cond_geu, cond_leu, cond_gtu,
			cond_lts, cond_ges, cond_les, cond_gts;

		//logic cond_branch_ne, cond_branch_eq, 
		//	cond_branch_ltu, cond_branch_geu, 
		//	cond_branch_leu, cond_branch_gtu,
		//	cond_branch_lts, cond_branch_ges, 
		//	cond_branch_les, cond_branch_gts;


		logic [((32) - 1):0] cpyhi_data;

		logic should_service_interrupt_if_not_in_stall;

		
		// Debugging thing
		logic [31:0] cycles_counter;
				// OPT_DEBUG


	} __locals;


	logic [
	((32) - 1):0] __following_pc_stage_instr_decode,
		//__following_pc_stage_register_read,
		__following_pc_stage_execute;

	PkgFrost32Cpu::MultiStageData 
		__multi_stage_data_instr_decode, 
		//__multi_stage_data_register_read,
		__multi_stage_data_execute,
		__multi_stage_data_write_back;





	// Module instantiations
	logic [((32) - 1):0] __in_instr_decoder;
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
		logic [((32) - 1):0] num, denom;
	} __in_div_32;

	struct packed
	{
		logic can_accept_cmd, data_ready;
		logic [((32) - 1):0] quot, rem;
	} __out_div_32;

	// NonRestoringDivider was determined to allow higher clock rates than
	// LongDivider, so we use that module here.
	NonRestoringDivider #(.ARGS_WIDTH(32),
		


		
		.NUM_ITERATIONS_PER_CYCLE(2))
		

		// OPT_FAST_DIV
				// OPT_VERY_FAST_DIV
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
	//bit [`MSB_POS__REG_FILE_DATA:0]
	//	__regfile[0 : __LAST_INDEX__NUM_REGISTERS];
	//`endif		// ICARUS

	//initial
	//begin
	//	for (int i=0; i<__ARR_SIZE__NUM_REGISTERS; ++i)
	//	begin
	//		__regfile[i] = 0;
	//	end
	//end

	
	logic [((32) - 1):0] 
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
				// OPT_DEBUG_REGISTER_FILE
		);

	
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
		

		

	if (__stage_instr_decode_data.stall_counter != 1)
	begin
	$display();
	$display();
	$display("Program counter:  %h", __locals.pc);
	case (__out_instr_decoder.group)
		0:
		begin
			case (__out_instr_decoder.opcode)
				PkgInstrDecoder::Add_ThreeRegs:
				begin
					$display("add r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Sub_ThreeRegs:
				begin
					$display("sub r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Sltu_ThreeRegs:
				begin
					$display("sltu r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Slts_ThreeRegs:
				begin
					$display("slts r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end

				PkgInstrDecoder::Sgtu_ThreeRegs:
				begin
					$display("sgtu r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Sgts_ThreeRegs:
				begin
					$display("sgts r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Mul_ThreeRegs:
				begin
					$display("mul r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::And_ThreeRegs:
				begin
					$display("and r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end

				PkgInstrDecoder::Orr_ThreeRegs:
				begin
					$display("orr r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Xor_ThreeRegs:
				begin
					$display("xor r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Nor_ThreeRegs:
				begin
					$display("nor r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Lsl_ThreeRegs:
				begin
					$display("lsl r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end

				PkgInstrDecoder::Lsr_ThreeRegs:
				begin
					$display("lsr r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Asr_ThreeRegs:
				begin
					$display("asr r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				//PkgInstrDecoder::Bad0_Iog0:
				//begin
				//	$display("bad0_iog0");
				//end
				//PkgInstrDecoder::Bad1_Iog0:
				//begin
				//	$display("bad1_iog0");
				//end
				PkgInstrDecoder::Udiv_ThreeRegs:
				begin
					$display("udiv r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Sdiv_ThreeRegs:
				begin
					$display("sdiv r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
			endcase
		end

		1:
		begin
			case (__out_instr_decoder.opcode)
				PkgInstrDecoder::Addi_TwoRegsOneImm:
				begin
					$display("addi r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Subi_TwoRegsOneImm:
				begin
					$display("subi r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Sltui_TwoRegsOneImm:
				begin
					$display("sltui r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Sltsi_TwoRegsOneSimm:
				begin
					$display("sltsi r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end

				PkgInstrDecoder::Sgtui_TwoRegsOneImm:
				begin
					$display("sgtui r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Sgtsi_TwoRegsOneSimm:
				begin
					$display("sgtsi r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Muli_TwoRegsOneImm:
				begin
					$display("muli r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Andi_TwoRegsOneImm:
				begin
					$display("andi r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end

				PkgInstrDecoder::Orri_TwoRegsOneImm:
				begin
					$display("orri r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Xori_TwoRegsOneImm:
				begin
					$display("xori r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Nori_TwoRegsOneImm:
				begin
					$display("nori r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Lsli_TwoRegsOneImm:
				begin
					$display("lsli r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end

				PkgInstrDecoder::Lsri_TwoRegsOneImm:
				begin
					$display("lsri r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Asri_TwoRegsOneImm:
				begin
					$display("asri r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Addsi_OneRegOnePcOneSimm:
				begin
					$display("addsi r%d, pc, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Cpyhi_OneRegOneImm:
				begin
					$display("cpyhi r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.imm_val);
				end
			endcase
		end

		2:
		begin
			case (__out_instr_decoder.opcode)
				PkgInstrDecoder::Bne_TwoRegsOneSimm:
				begin
					$display("bne r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Beq_TwoRegsOneSimm:
				begin
					$display("beq r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Bltu_TwoRegsOneSimm:
				begin
					$display("bltu r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Bgeu_TwoRegsOneSimm:
				begin
					$display("bgeu r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end

				PkgInstrDecoder::Bleu_TwoRegsOneSimm:
				begin
					$display("bleu r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Bgtu_TwoRegsOneSimm:
				begin
					$display("bgtu r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Blts_TwoRegsOneSimm:
				begin
					$display("blts r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Bges_TwoRegsOneSimm:
				begin
					$display("bges r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end

				PkgInstrDecoder::Bles_TwoRegsOneSimm:
				begin
					$display("bles r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Bgts_TwoRegsOneSimm:
				begin
					$display("bgts r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Bad0_Iog2:
				begin
					$display("bad0_iog2");
				end
				PkgInstrDecoder::Bad1_Iog2:
				begin
					$display("bad1_iog2");
				end

				PkgInstrDecoder::Bad2_Iog2:
				begin
					$display("bad2_iog2");
				end
				PkgInstrDecoder::Bad3_Iog2:
				begin
					$display("bad3_iog2");
				end
				PkgInstrDecoder::Bad4_Iog2:
				begin
					$display("bad4_iog2");
				end
				PkgInstrDecoder::Bad5_Iog2:
				begin
					$display("bad5_iog2");
				end
			endcase
		end

		3:
		begin
			case (__out_instr_decoder.opcode)
				PkgInstrDecoder::Jne_TwoRegsOneSimm:
				begin
					$display("jne r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Jeq_TwoRegsOneSimm:
				begin
					$display("jeq r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Jltu_TwoRegsOneSimm:
				begin
					$display("jltu r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Jgeu_TwoRegsOneSimm:
				begin
					$display("jgeu r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end

				PkgInstrDecoder::Jleu_TwoRegsOneSimm:
				begin
					$display("jleu r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Jgtu_TwoRegsOneSimm:
				begin
					$display("jgtu r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Jlts_TwoRegsOneSimm:
				begin
					$display("jlts r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Jges_TwoRegsOneSimm:
				begin
					$display("jges r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end

				PkgInstrDecoder::Jles_TwoRegsOneSimm:
				begin
					$display("jles r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Jgts_TwoRegsOneSimm:
				begin
					$display("jgts r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Bad0_Iog3:
				begin
					$display("bad0_iog3");
				end
				PkgInstrDecoder::Bad1_Iog3:
				begin
					$display("bad1_iog3");
				end

				PkgInstrDecoder::Bad2_Iog3:
				begin
					$display("bad2_iog3");
				end
				PkgInstrDecoder::Bad3_Iog3:
				begin
					$display("bad3_iog3");
				end
				PkgInstrDecoder::Bad4_Iog3:
				begin
					$display("bad4_iog3");
				end
				PkgInstrDecoder::Bad5_Iog3:
				begin
					$display("bad5_iog3");
				end
			endcase
		end

		4:
		begin
			case (__out_instr_decoder.opcode)
				PkgInstrDecoder::Cne_TwoRegsOneSimm:
				begin
					$display("cne r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Ceq_TwoRegsOneSimm:
				begin
					$display("ceq r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Cltu_TwoRegsOneSimm:
				begin
					$display("cltu r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Cgeu_TwoRegsOneSimm:
				begin
					$display("cgeu r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end

				PkgInstrDecoder::Cleu_TwoRegsOneSimm:
				begin
					$display("cleu r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Cgtu_TwoRegsOneSimm:
				begin
					$display("cgtu r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Clts_TwoRegsOneSimm:
				begin
					$display("clts r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Cges_TwoRegsOneSimm:
				begin
					$display("cges r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end

				PkgInstrDecoder::Cles_TwoRegsOneSimm:
				begin
					$display("cles r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Cgts_TwoRegsOneSimm:
				begin
					$display("cgts r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Bad0_Iog4:
				begin
					$display("bad0_iog4");
				end
				PkgInstrDecoder::Bad1_Iog4:
				begin
					$display("bad1_iog4");
				end

				PkgInstrDecoder::Bad2_Iog4:
				begin
					$display("bad2_iog4");
				end
				PkgInstrDecoder::Bad3_Iog4:
				begin
					$display("bad3_iog4");
				end
				PkgInstrDecoder::Bad4_Iog4:
				begin
					$display("bad4_iog4");
				end
				PkgInstrDecoder::Bad5_Iog4:
				begin
					$display("bad5_iog4");
				end
			endcase
		end

		5:
		begin
			case (__out_instr_decoder.opcode)
				PkgInstrDecoder::Ldr_ThreeRegsLdst:
				begin
					$display("ldr r%d, [r%d, r%d]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Ldh_ThreeRegsLdst:
				begin
					$display("ldh r%d, [r%d, r%d]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Ldsh_ThreeRegsLdst:
				begin
					$display("ldsh r%d, [r%d, r%d]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Ldb_ThreeRegsLdst:
				begin
					$display("ldb r%d, [r%d, r%d]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end

				PkgInstrDecoder::Ldsb_ThreeRegsLdst:
				begin
					$display("ldsb r%d, [r%d, r%d]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Str_ThreeRegsLdst:
				begin
					$display("str r%d, [r%d, r%d]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Sth_ThreeRegsLdst:
				begin
					$display("sth r%d, [r%d, r%d]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Stb_ThreeRegsLdst:
				begin
					$display("stb r%d, [r%d, r%d]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end

				PkgInstrDecoder::Ldri_TwoRegsOneSimm12Ldst:
				begin
					$display("ldri r%d, [r%d, 0x%x]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Ldhi_TwoRegsOneSimm12Ldst:
				begin
					$display("ldhi r%d, [r%d, 0x%x]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Ldshi_TwoRegsOneSimm12Ldst:
				begin
					$display("ldshi r%d, [r%d, 0x%x]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Ldbi_TwoRegsOneSimm12Ldst:
				begin
					$display("ldbi r%d, [r%d, 0x%x]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end

				PkgInstrDecoder::Ldsbi_TwoRegsOneSimm12Ldst:
				begin
					$display("ldsbi r%d, [r%d, 0x%x]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Stri_TwoRegsOneSimm12Ldst:
				begin
					$display("stri r%d, [r%d, 0x%x]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Sthi_TwoRegsOneSimm12Ldst:
				begin
					$display("sthi r%d, [r%d, 0x%x]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Stbi_TwoRegsOneSimm12Ldst:
				begin
					$display("stbi r%d, [r%d, 0x%x]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
			endcase
		end

		6:
		begin
			case (__out_instr_decoder.opcode)
				PkgInstrDecoder::Ei_NoArgs:
				begin
					$display("ei");
				end
				PkgInstrDecoder::Di_NoArgs:
				begin
					$display("di");
				end
				PkgInstrDecoder::Cpy_OneIretaOneReg:
				begin
					$display("cpy ireta, r%d",
						__out_instr_decoder.ra_index);
				end
				PkgInstrDecoder::Cpy_OneRegOneIreta:
				begin
					$display("cpy r%d, ireta",
						__out_instr_decoder.ra_index);
				end

				PkgInstrDecoder::Cpy_OneIdstaOneReg:
				begin
					$display("cpy idsta, r%d",
						__out_instr_decoder.ra_index);
				end
				PkgInstrDecoder::Cpy_OneRegOneIdsta:
				begin
					$display("cpy r%d, idsta",
						__out_instr_decoder.ra_index);
				end
				PkgInstrDecoder::Reti_NoArgs:
				begin
					$display("reti");
				end
				PkgInstrDecoder::Bad0_Iog6:
				begin
					$display("bad0_iog6");
				end

				PkgInstrDecoder::Bad1_Iog6:
				begin
					$display("bad1_iog6");
				end
				PkgInstrDecoder::Bad2_Iog6:
				begin
					$display("bad2_iog6");
				end
				PkgInstrDecoder::Bad3_Iog6:
				begin
					$display("bad3_iog6");
				end
				PkgInstrDecoder::Bad4_Iog6:
				begin
					$display("bad4_iog6");
				end

				PkgInstrDecoder::Bad5_Iog6:
				begin
					$display("bad5_iog6");
				end
				PkgInstrDecoder::Bad6_Iog6:
				begin
					$display("bad6_iog6");
				end
				PkgInstrDecoder::Bad7_Iog6:
				begin
					$display("bad7_iog6");
				end
				PkgInstrDecoder::Bad8_Iog6:
				begin
					$display("bad8_iog6");
				end
			endcase
		end

		default:
		begin
			$display("unknown");
		end
	endcase
	end

	else
	begin
		$display();
		$display();
		$display("__stage_instr_decode_data.stall_counter == 1");
	end
				// OPT_DEBUG_INSTR_DECODER
		$display();
	end

		//$display();
	end
			// OPT_DEBUG

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
		if (
		(__stage_instr_decode_data.stall_counter != 0))
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
	//	//if (`in_stall || (!`in_stall 
	//	//	&& __locals.should_service_interrupt_if_not_in_stall))

	//	// If in a stall, use the execute stage's program counter.
	//	if (`in_stall)
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
	always_comb
	begin
		//__stage_execute_input_data.rfile_ra_data
		//	= ((__stage_execute_output_data.prev_written_reg_index
		//	== __multi_stage_data_execute.instr_ra_index)
		//	&& (__stage_execute_output_data.prev_written_reg_index != 0))
		//	? __stage_write_back_input_data.n_reg_data
		//	: __out_reg_file.read_data_ra;

		//$display("_ra:  %h %h %h",
		//	__multi_stage_data_execute.instr_ra_index,
		//	__stage_execute_output_data.prev_written_reg_index,
		//	__stage_write_back_output_data.prev_written_reg_index);

		// No forwarding
		if (__multi_stage_data_execute.instr_ra_index == 0)
		begin
			__stage_execute_input_data.rfile_ra_data = 0;
		end

		// Forward from last instruction 
		else if (__multi_stage_data_execute.instr_ra_index
			== __stage_execute_output_data.prev_written_reg_index)
		begin
			__stage_execute_input_data.rfile_ra_data
				= __stage_execute_output_data.n_reg_data;
			//$display("_ra:  forwarding from execute stage:  %h",
			//	__stage_execute_input_data.rfile_ra_data);
		end

		// Forward from two instructions ago
		else if (__multi_stage_data_execute.instr_ra_index
			== __stage_write_back_output_data.prev_written_reg_index)
		begin
			__stage_execute_input_data.rfile_ra_data
				= __stage_write_back_output_data.n_reg_data;
			//$display("_ra:  forwarding from write back stage:  %h",
			//	__stage_execute_input_data.rfile_ra_data);
		end

		//// Forward from three instructions ago
		//else if (__multi_stage_data_execute.instr_ra_index
		//	== __stage_write_back_output_data.prev_prev_written_reg_index)
		//begin
		//	__stage_execute_input_data.rfile_ra_data
		//		= __stage_write_back_output_data.prev_prev_n_reg_data;
		//	$display("_ra:  forwarding from three instrs ago:  %h",
		//		__stage_execute_input_data.rfile_ra_data);
		//end

		// No forwarding
		else
		begin
			__stage_execute_input_data.rfile_ra_data
				= __out_reg_file.read_data_ra;
			//$display("_ra:  no forwarding:  Read from register file:  %h",
			//	__stage_execute_input_data.rfile_ra_data);
		end


		//__stage_execute_input_data.rfile_ra_data
		//	= ((__stage_execute_output_data.prev_written_reg_index
		//	== __multi_stage_data_execute.instr_ra_index)
		//	&& (__stage_execute_output_data.prev_written_reg_index != 0))
		//	? __stage_execute_output_data.n_reg_data
		//	: __out_reg_file.read_data_ra;

		//$display("(Maybe) operand forwarding (_ra):  %h %h %h %h %h",
		//	__stage_execute_input_data.rfile_ra_data,
		//	__stage_execute_output_data.prev_written_reg_index,
		//	__multi_stage_data_execute.instr_ra_index,
		//	__stage_execute_output_data.n_reg_data,
		//	__out_reg_file.read_data_ra);
	end
	always_comb
	begin
		//__stage_execute_input_data.rfile_rb_data
		//	= ((__stage_execute_output_data.prev_written_reg_index
		//	== __multi_stage_data_execute.instr_rb_index)
		//	&& (__stage_execute_output_data.prev_written_reg_index != 0))
		//	? __stage_write_back_input_data.n_reg_data
		//	: __out_reg_file.read_data_rb;

		// No forwarding
		if (__multi_stage_data_execute.instr_rb_index == 0)
		begin
			__stage_execute_input_data.rfile_rb_data = 0;
		end

		// Forward from last instruction 
		else if (__multi_stage_data_execute.instr_rb_index
			== __stage_execute_output_data.prev_written_reg_index)
		begin
			__stage_execute_input_data.rfile_rb_data
				= __stage_execute_output_data.n_reg_data;
		end

		// Forward from two instructions ago
		else if (__multi_stage_data_execute.instr_rb_index
			== __stage_write_back_output_data.prev_written_reg_index)
		begin
			__stage_execute_input_data.rfile_rb_data
				= __stage_write_back_output_data.n_reg_data;
		end

		// No forwarding
		else
		begin
			__stage_execute_input_data.rfile_rb_data
				= __out_reg_file.read_data_rb;
		end


		//__stage_execute_input_data.rfile_rb_data
		//	= ((__stage_execute_output_data.prev_written_reg_index
		//	== __multi_stage_data_execute.instr_rb_index)
		//	&& (__stage_execute_output_data.prev_written_reg_index != 0))
		//	? __stage_execute_output_data.n_reg_data
		//	: __out_reg_file.read_data_rb;

		//$display("(Maybe) operand forwarding (_rb):  %h %h %h %h %h",
		//	__stage_execute_input_data.rfile_rb_data,
		//	__stage_execute_output_data.prev_written_reg_index,
		//	__multi_stage_data_execute.instr_rb_index,
		//	__stage_execute_output_data.n_reg_data,
		//	__out_reg_file.read_data_rb);
	end
	always_comb
	begin
		//__stage_execute_input_data.rfile_rc_data
		//	= ((__stage_execute_output_data.prev_written_reg_index
		//	== __multi_stage_data_execute.instr_rc_index)
		//	&& (__stage_execute_output_data.prev_written_reg_index != 0))
		//	? __stage_write_back_input_data.n_reg_data
		//	: __out_reg_file.read_data_rc;

		// No forwarding
		if (__multi_stage_data_execute.instr_rc_index == 0)
		begin
			__stage_execute_input_data.rfile_rc_data = 0;
		end

		// Forward from last instruction 
		else if (__multi_stage_data_execute.instr_rc_index
			== __stage_execute_output_data.prev_written_reg_index)
		begin
			__stage_execute_input_data.rfile_rc_data
				= __stage_execute_output_data.n_reg_data;
		end

		// Forward from two instructions ago
		else if (__multi_stage_data_execute.instr_rc_index
			== __stage_write_back_output_data.prev_written_reg_index)
		begin
			__stage_execute_input_data.rfile_rc_data
				= __stage_write_back_output_data.n_reg_data;
		end

		// No forwarding
		else
		begin
			__stage_execute_input_data.rfile_rc_data
				= __out_reg_file.read_data_rc;
		end


		//__stage_execute_input_data.rfile_rc_data
		//	= ((__stage_execute_output_data.prev_written_reg_index
		//	== __multi_stage_data_execute.instr_rc_index)
		//	&& (__stage_execute_output_data.prev_written_reg_index != 0))
		//	? __stage_execute_output_data.n_reg_data
		//	: __out_reg_file.read_data_rc;

		//$display("(Maybe) operand forwarding (_rc):  %h %h %h %h %h",
		//	__stage_execute_input_data.rfile_rc_data,
		//	__stage_execute_output_data.prev_written_reg_index,
		//	__multi_stage_data_execute.instr_rc_index,
		//	__stage_execute_output_data.n_reg_data,
		//	__out_reg_file.read_data_rc);
	end

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


	//// Tasks and functions
	//function logic in_stall();
	//	return (__stage_instr_decode_data.stall_counter != 0);
	//endfunction

	task prep_mem_read;
		input [
	((32) - 1):0] addr;
		//input PkgFrost32Cpu::DataInoutAccessSize size;
		input [
	((2) - 1):0] size;

		out.data <= 0;
		out.addr <= addr;
		out.data_inout_access_type <= PkgFrost32Cpu::DiatRead; 
		out.data_inout_access_size <= size;
		out.req_mem_access <= 1;
	endtask

	task prep_load_instruction;
		input [
	((32) - 1):0] addr;

		// Every instruction is 4 bytes long (...for now)
		__locals.pc <= addr;
		__multi_stage_data_instr_decode.pc_val <= __locals.pc;

		prep_mem_read(addr, PkgFrost32Cpu::Dias32);
	endtask

	task prep_load_following_instruction;
		prep_load_instruction(__locals.pc + 4);
	endtask

	task prep_mem_write;
		input [
	((32) - 1):0] addr;
		//input PkgFrost32Cpu::DataInoutAccessSize size;
		input [
	((2) - 1):0] size;
		input [
	((32) - 1):0] data;

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
		input [((4) - 1):0] n_sel;
		input [((32) - 1):0] n_data;

		__stage_execute_output_data.prev_written_reg_index <= n_sel;
		__stage_execute_output_data.n_reg_data <= n_data;

		$display("prep_reg_wb:  %h %h", n_sel, n_data);
	endtask

	task prep_ra_wb;
		input [((32) - 1):0] n_data;

		//$display("prep_ra_wb:  %h %h",
		//	__multi_stage_data_execute.instr_ra_index, n_data);
		prep_reg_wb(__multi_stage_data_execute.instr_ra_index, n_data);
	endtask

	task prep_reg_write;
		input [((4) - 1):0] n_sel;
		input [((32) - 1):0] n_data;

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
		input [((32) - 1):0] x, y;

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
			else
			begin
				stop_operand_forwarding_or_write_back();
			end
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
		if (
		(__stage_instr_decode_data.stall_counter != 0))
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
		else // if (!`in_stall)
		begin
			if (!__locals.should_service_interrupt_if_not_in_stall)
			begin
				if (__multi_stage_data_instr_decode.instr_causes_stall)
				begin
					//__multi_stage_data_instr_decode.raw_instruction
					//	<= in.data;
					//$display("!`in_stall, instr causes stall");
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
		if (
		(__stage_instr_decode_data.stall_counter != 0))
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
		else // if (!`in_stall)
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
//`include "src/misc_defines.header.sv"
//
//module MainClockGenerator(output logic clk);
//
//	initial
//	begin
//		clk = 1'b0;
//	end
//
//	always
//	begin
//		#1
//		clk = !clk;
//	end
//
//endmodule
//
//module HalfClockGenerator(output logic clk);
//	initial
//	begin
//		clk = 1'b0;
//	end
//
//	always
//	begin
//		#2
//		clk = !clk;
//	end
//endmodule

















		// src__slash__alu_defines_header_sv

module Alu(input PkgAlu::PortIn_Alu in, output PkgAlu::PortOut_Alu out);

	import PkgAlu::*;

	parameter __WIDTH_INOUT = 32;
	parameter __MSB_POS_INOUT = ((32) - 1);

	//// sltu, slts, sgtu, sgts
	//PkgAlu::PortOut_Compare  __out_compare;

	//Compare #(.DATA_WIDTH(__WIDTH_INOUT)) __inst_compare(.a(in.a),
	//	.b(in.b), .out(__out_compare));

	//// Barrel shifters
	//PkgAlu::PortIn_Shift __in_any_shift;
	//assign __in_any_shift.data = in.a;
	//assign __in_any_shift.amount = in.b;

	//PkgAlu::PortOut_Shift __out_lsl32;
	//PkgAlu::PortOut_Shift __out_lsr32;
	//PkgAlu::PortOut_Shift __out_asr32;

	//LogicalShiftLeft32 __inst_lsl32(.in(__in_any_shift),
	//	.out(__out_lsl32));
	//LogicalShiftRight32 __inst_lsr32(.in(__in_any_shift),
	//	.out(__out_lsr32));
	//ArithmeticShiftRight32 __inst_asr32(.in(__in_any_shift),
	//	.out(__out_asr32));

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
				//out.data = __out_compare.ltu;
				out.data = in.a < in.b;
			end
			PkgAlu::Slts:
			begin
				//out.data = {{__MSB_POS_INOUT{1'b0}}, __out_compare.lts};
				//out.data = __out_compare.lts;
				out.data = $signed(in.a) < $signed(in.b);
			end


			PkgAlu::Sgtu:
			begin
				//out.data = {{__MSB_POS_INOUT{1'b0}}, __out_compare.gtu};
				//out.data = __out_compare.gtu;
				//out.data = 0;
				out.data = in.a > in.b;
				//out.data = 0;
			end
			PkgAlu::Sgts:
			begin
				//out.data = {{__MSB_POS_INOUT{1'b0}}, __out_compare.gts};
				//out.data = __out_compare.gts;
				//out.data = 0;
				out.data = $signed(in.a) > $signed(in.b);
				//out.data = 0;
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
				////if (in.b[__MSB_POS_INOUT : 5])
				////begin
				////	out.data = {__WIDTH_INOUT{1'b0}};
				////end

				////else
				////begin
				//	out.data = __out_lsl32.data;
				////end
				out.data = in.a << in.b;
			end




			PkgAlu::Lsr:
			begin
				////if (in.b[__MSB_POS_INOUT : 5])
				////begin
				////	out.data = {__WIDTH_INOUT{1'b0}};
				////end

				////else
				////begin
				//	out.data = __out_lsr32.data;
				////end
				out.data = in.a >> in.b;
			end
			PkgAlu::Asr:
			begin
				////if (in.b[__MSB_POS_INOUT : 5])
				////begin
				////	if (in.a[__MSB_POS_INOUT])
				////	begin
				////		out.data = {__WIDTH_INOUT{1'b1}};
				////	end

				////	else
				////	begin
				////		out.data = {__WIDTH_INOUT{1'b0}};
				////	end
				////end

				////else
				////begin
				//	out.data = __out_asr32.data;
				////end
				out.data = $signed(in.a) >>> in.b;
			end

			// The processor probably doesn't actually use this operation
			PkgAlu::OrN:
			begin
				//out.data = in.a | (~in.b);
				out.data = 0;
			end

			// The processor probably doesn't actually use this operation
			PkgAlu::Nand:
			begin
				//out.data = ~(in.a & in.b);
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
//`include "src/misc_defines.header.sv"
//
////`define WIDTH__TRUE_DUAL_PORT_RAM_DATA_INOUT 8
////`define MSB_POS__TRUE_DUAL_PORT_RAM_DATA_INOUT \
////	`WIDTH_TO_MSB_POS(`WIDTH__TRUE_DUAL_PORT_RAM_DATA_INOUT)
////
////`define WIDTH__TRUE_DUAL_PORT_RAM_ADDR 15
////`define MSB_POS__TRUE_DUAL_PORT_RAM_ADDR \
////	`WIDTH_TO_MSB_POS(`WIDTH__TRUE_DUAL_PORT_RAM_ADDR)
////
////
////// Synthesizeable block RAM (32 kiB), with two 8-bit read ports and two
////// 8-bit write ports.
////module TrueDualPortRam(input logic clk,
////	input logic [`MSB_POS__TRUE_DUAL_PORT_RAM_DATA_INOUT:0] 
////		in_data_a, in_data_b,
////	input logic [`MSB_POS__TRUE_DUAL_PORT_RAM_ADDR:0] in_addr_a, in_addr_b,
////	input logic in_we_a, in_we_b,
////
////	output logic [`MSB_POS__TRUE_DUAL_PORT_RAM_DATA_INOUT:0] 
////		out_data_a, out_data_b);
////
////	//parameter __ARR_SIZE__MAIN_MEM = 1 << 16;
////	parameter __ARR_SIZE__MAIN_MEM = 1 << 15;
////	parameter __LAST_INDEX__MAIN_MEM 
////		= `ARR_SIZE_TO_LAST_INDEX(__ARR_SIZE__MAIN_MEM);
////
////	bit [`MSB_POS__TRUE_DUAL_PORT_RAM_DATA_INOUT:0] 
////		__mem[0 : __LAST_INDEX__MAIN_MEM];
////
////
////	//parameter __MOD_THING = 32'hffff;
////
////
////
////	initial
////	begin
////		$readmemh("main_mem.txt.ignore", __mem);
////
////		////$dumpfile("test.vcd");
////		////$dumpvars(0, TestBench);
////
////		out_data_a = 0;
////		out_data_b = 0;
////	end
////
////	//always @ (posedge clk)
////	//begin
////	//	$display("TrueDualPortRam (port a):  %h %h", 
////	//		in_addr_a, __mem[in_addr_a]);
////	//	$display("TrueDualPortRam (port b):  %h %h", 
////	//		in_addr_b, __mem[in_addr_b]);
////	//end
////
////	always_ff @ (posedge clk)
////	begin
////		if (in_we_a)
////		begin
////			__mem[in_addr_a] <= in_data_a;
////		end
////
////		//else
////		begin
////			out_data_a <= __mem[in_addr_a];
////		end
////	end
////
////	always_ff @ (posedge clk)
////	begin
////		if (in_we_b)
////		begin
////			__mem[in_addr_b] <= in_data_b;
////		end
////
////		//else
////		begin
////			out_data_b <= __mem[in_addr_b];
////		end
////	end
////
////endmodule
//
//
////module MainMem(input logic clk,
////	`ifdef OPT_DEBUG_MEM_ACCESS
////	input logic half_clk,
////	`endif		// OPT_DEBUG_MEM_ACCESS
////	input PkgMainMem::PortIn_MainMem in,
////	output PkgMainMem::PortOut_MainMem out);
////
////	import PkgFrost32Cpu::*;
////	import PkgMainMem::*;
////
////	parameter __WIDTH_COUNTER = 3;
////	//parameter __WIDTH_COUNTER = 1;
////	parameter __MSB_POS_COUNTER = `WIDTH_TO_MSB_POS(__WIDTH_COUNTER);
////
////	//parameter __ARR_SIZE__NUM_ADDRESSES = 4;
////	//parameter __LAST_INDEX__NUM_ADDRESSES 
////	//	= `ARR_SIZE_TO_LAST_INDEX(__ARR_SIZE__NUM_ADDRESSES);
////
////	//parameter __MOD_THING = 32'hffff;
////	parameter __MOD_THING = 32'h7fff;
////	//parameter __MOD_THING = 32'hff_ffff;
////
////	logic [`MSB_POS__TRUE_DUAL_PORT_RAM_DATA_INOUT:0] 
////		__in_true_dual_port_ram_data_a, __in_true_dual_port_ram_data_b;
////	logic [`MSB_POS__TRUE_DUAL_PORT_RAM_ADDR:0]
////		__in_true_dual_port_ram_addr_a, __in_true_dual_port_ram_addr_b;
////	logic __in_true_dual_port_ram_we_a, __in_true_dual_port_ram_we_b;
////	logic [`MSB_POS__TRUE_DUAL_PORT_RAM_DATA_INOUT:0] 
////		__out_true_dual_port_ram_data_a, __out_true_dual_port_ram_data_b;
////
////	TrueDualPortRam __inst_true_dual_port_ram(.clk(clk),
////		.in_data_a(__in_true_dual_port_ram_data_a),
////		.in_data_b(__in_true_dual_port_ram_data_b),
////		.in_addr_a(__in_true_dual_port_ram_addr_a),
////		.in_addr_b(__in_true_dual_port_ram_addr_b),
////		.in_we_a(__in_true_dual_port_ram_we_a),
////		.in_we_b(__in_true_dual_port_ram_we_b),
////		.out_data_a(__out_true_dual_port_ram_data_a),
////		.out_data_b(__out_true_dual_port_ram_data_b));
////
////	logic [__MSB_POS_COUNTER:0] __counter;
////	logic __wait_for_mem;
////
////	//logic [`MSB_POS__TRUE_DUAL_PORT_RAM_ADDR:0] 
////	//	__addresses[0 : __LAST_INDEX__NUM_ADDRESSES];
////
////	//assign out.wait_for_mem = (in.req_mem_access || __wait_for_mem);
////	always_comb
////	begin
////		out.wait_for_mem = (in.req_mem_access || __wait_for_mem);
////	end
////
////	initial
////	begin
////		__counter = 0;
////
////
////		__in_true_dual_port_ram_data_a = 0;
////		__in_true_dual_port_ram_data_b = 0;
////		__in_true_dual_port_ram_addr_a = 0;
////		__in_true_dual_port_ram_addr_b = 0;
////		__in_true_dual_port_ram_we_a = 0;
////		__in_true_dual_port_ram_we_b = 0;
////		//out.wait_for_mem = 0;
////		__wait_for_mem = 0;
////		out.data = 0;
////	end
////
////
////	//always_ff @ (posedge clk)
////	always @ (posedge clk)
////	begin
////		//$display("Stuff:  %h %h\t\t%h %h\t\t%h %h\t\t%h %h",
////		//	__counter, __wait_for_mem,
////		//	in.addr, out.data,
////		//	__in_true_dual_port_ram_addr_a,
////		//	__in_true_dual_port_ram_addr_b,
////		//	__out_true_dual_port_ram_data_a,
////		//	__out_true_dual_port_ram_data_b);
////		if (__counter == 0)
////		begin
////			if (in.req_mem_access)
////			begin
////				//$display("in.req_mem_access == 1");
////				__wait_for_mem <= 1;
////
////				// Temporarily assume 32-bit memory access
////				__counter <= 3;
////
////				if (in.data_inout_access_type
////					== PkgFrost32Cpu::DiatRead)
////				begin
////					__in_true_dual_port_ram_we_a <= 0;
////					__in_true_dual_port_ram_we_b <= 0;
////
////				end
////
////				else // if (in.data_inout_access_type 
////					// == PkgFrost32Cpu::DiatWrite)
////				begin
////					__in_true_dual_port_ram_we_a <= 1;
////					__in_true_dual_port_ram_we_b <= 1;
////				end
////				// Two cycle delay
////				__in_true_dual_port_ram_data_a <= in.data[31:24];
////				__in_true_dual_port_ram_data_b <= in.data[23:16];
////				__in_true_dual_port_ram_addr_a 
////					<= (in.addr[`MSB_POS__TRUE_DUAL_PORT_RAM_ADDR:0] 
////					& __MOD_THING);
////				__in_true_dual_port_ram_addr_b 
////					<= ((in.addr[`MSB_POS__TRUE_DUAL_PORT_RAM_ADDR:0] 
////					+ 16'h1) & __MOD_THING);
////				//$display("__counter == 4:  %h %h",
////				//	__in_true_dual_port_ram_addr_a,
////				//	__in_true_dual_port_ram_addr_b);
////				out.data <= 0;
////
////			end
////
////			else
////			begin
////				__wait_for_mem <= 0;
////			end
////
////			//__in_true_dual_port_ram_we_a <= 0;
////			//__in_true_dual_port_ram_we_b <= 0;
////		end
////
////		else // if (__counter != 0)
////		begin
////			__counter <= __counter - 1;
////			if (__counter == 3)
////			begin
////				__in_true_dual_port_ram_data_a <= in.data[15:8];
////				__in_true_dual_port_ram_data_b <= in.data[7:0];
////				__in_true_dual_port_ram_addr_a 
////					<= ((in.addr[`MSB_POS__TRUE_DUAL_PORT_RAM_ADDR:0] 
////					+ 16'h2) & __MOD_THING);
////				__in_true_dual_port_ram_addr_b 
////					<= ((in.addr[`MSB_POS__TRUE_DUAL_PORT_RAM_ADDR:0] 
////					+ 16'h3) & __MOD_THING);
////				//get_out_data_high();
////				//$display("__counter == 3:  %h %h",
////				//	__in_true_dual_port_ram_addr_a,
////				//	__in_true_dual_port_ram_addr_b);
////			end
////
////			else if (__counter == 2)
////			begin
////				// Just disable writes now
////				__in_true_dual_port_ram_we_a <= 0;
////				__in_true_dual_port_ram_we_b <= 0;
////
////				out.data[31] <= __out_true_dual_port_ram_data_a[7];
////				out.data[30] <= __out_true_dual_port_ram_data_a[6];
////				out.data[29] <= __out_true_dual_port_ram_data_a[5];
////				out.data[28] <= __out_true_dual_port_ram_data_a[4];
////				out.data[27] <= __out_true_dual_port_ram_data_a[3];
////				out.data[26] <= __out_true_dual_port_ram_data_a[2];
////				out.data[25] <= __out_true_dual_port_ram_data_a[1];
////				out.data[24] <= __out_true_dual_port_ram_data_a[0];
////				out.data[23] <= __out_true_dual_port_ram_data_b[7];
////				out.data[22] <= __out_true_dual_port_ram_data_b[6];
////				out.data[21] <= __out_true_dual_port_ram_data_b[5];
////				out.data[20] <= __out_true_dual_port_ram_data_b[4];
////				out.data[19] <= __out_true_dual_port_ram_data_b[3];
////				out.data[18] <= __out_true_dual_port_ram_data_b[2];
////				out.data[17] <= __out_true_dual_port_ram_data_b[1];
////				out.data[16] <= __out_true_dual_port_ram_data_b[0];
////			end
////
////			else // if (__counter == 1)
////			begin
////				__in_true_dual_port_ram_data_a <= 0;
////				__in_true_dual_port_ram_data_b <= 0;
////				__in_true_dual_port_ram_addr_a <= 0;
////				__in_true_dual_port_ram_addr_b <= 0;
////				//get_out_data_low();
////				out.data[15] <= __out_true_dual_port_ram_data_a[7];
////				out.data[14] <= __out_true_dual_port_ram_data_a[6];
////				out.data[13] <= __out_true_dual_port_ram_data_a[5];
////				out.data[12] <= __out_true_dual_port_ram_data_a[4];
////				out.data[11] <= __out_true_dual_port_ram_data_a[3];
////				out.data[10] <= __out_true_dual_port_ram_data_a[2];
////				out.data[9] <= __out_true_dual_port_ram_data_a[1];
////				out.data[8] <= __out_true_dual_port_ram_data_a[0];
////				out.data[7] <= __out_true_dual_port_ram_data_b[7];
////				out.data[6] <= __out_true_dual_port_ram_data_b[6];
////				out.data[5] <= __out_true_dual_port_ram_data_b[5];
////				out.data[4] <= __out_true_dual_port_ram_data_b[4];
////				out.data[3] <= __out_true_dual_port_ram_data_b[3];
////				out.data[2] <= __out_true_dual_port_ram_data_b[2];
////				out.data[1] <= __out_true_dual_port_ram_data_b[1];
////				out.data[0] <= __out_true_dual_port_ram_data_b[0];
////				__wait_for_mem <= 0;
////			end
////		end
////	end
////
////	//always_comb
////	////always @ (*)
////	////always @ (__counter)
////	//begin
////	//end
////
////
////endmodule
//
//`define WIDTH__SINGLE_PORT_RAM_DATA_INOUT 32
//`define MSB_POS__SINGLE_PORT_RAM_DATA_INOUT \
//	`WIDTH_TO_MSB_POS(`WIDTH__SINGLE_PORT_RAM_DATA_INOUT)
//
//// 32 kiB
//`define WIDTH__SINGLE_PORT_RAM_ADDR 13
//`define MSB_POS__SINGLE_PORT_RAM_ADDR \
//	`WIDTH_TO_MSB_POS(`WIDTH__SINGLE_PORT_RAM_ADDR)
//
//
//// Synthesizeable block RAM (I think) with one 32-bit read port and one
//// 32-bit write port
//module SinglePortRam(input logic clk,
//	input logic [`MSB_POS__SINGLE_PORT_RAM_DATA_INOUT:0] in_data,
//	input logic [`MSB_POS__SINGLE_PORT_RAM_ADDR:0] in_addr,
//	input logic in_we,
//	output logic [`MSB_POS__SINGLE_PORT_RAM_DATA_INOUT:0] out_data);
//
//	parameter __ARR_SIZE__MAIN_MEM = 1 << `WIDTH__SINGLE_PORT_RAM_ADDR;
//	parameter __LAST_INDEX__MAIN_MEM 
//		= `ARR_SIZE_TO_LAST_INDEX(__ARR_SIZE__MAIN_MEM);
//
//	bit [`MSB_POS__SINGLE_PORT_RAM_DATA_INOUT:0] 
//		__mem[0 : __LAST_INDEX__MAIN_MEM];
//
//	initial
//	begin
//		$readmemh("main_mem.txt.ignore", __mem);
//	end
//
//	always_ff @ (posedge clk)
//	begin
//		$display("SinglePortRam:  %h %h %h %h",
//			in_data, in_addr, in_we, out_data);
//	end
//
//	//// Asynchronous reads
//	//assign out_data = __mem[in_addr];
//
//	always_ff @ (posedge clk)
//	begin
//		if (in_we)
//		begin
//			__mem[in_addr] <= in_data;
//		end
//
//		//else
//		begin
//			out_data <= __mem[in_addr];
//		end
//	end
//
//endmodule
//
//module MainMem(input logic clk,
//	`ifdef OPT_DEBUG_MEM_ACCESS
//	input logic half_clk,
//	`endif		// OPT_DEBUG_MEM_ACCESS
//	input PkgMainMem::PortIn_MainMem in,
//	output PkgMainMem::PortOut_MainMem out);
//
//	import PkgFrost32Cpu::*;
//	import PkgMainMem::*;
//
//	logic [`MSB_POS__SINGLE_PORT_RAM_DATA_INOUT:0]
//		__in_single_port_ram_data;
//	logic [`MSB_POS__SINGLE_PORT_RAM_ADDR:0] __in_single_port_ram_addr;
//	logic __in_single_port_ram_we;
//	logic [`MSB_POS__SINGLE_PORT_RAM_DATA_INOUT:0]
//		__out_single_port_ram_data;
//
//	SinglePortRam __inst_single_port_ram(.clk(clk),
//		.in_data(__in_single_port_ram_data),
//		.in_addr(__in_single_port_ram_addr),
//		.in_we(__in_single_port_ram_we),
//		.out_data(__out_single_port_ram_data));
//
//	//always_comb
//	//begin
//	//	out.data = __out_single_port_ram_data;
//	//end
//
//	//always_comb
//	//begin
//	//	//out.wait_for_mem = (in.req_mem_access
//	//	//	&& (in.data_inout_access_type == PkgFrost32Cpu::DiatWrite));
//	//	out.wait_for_mem = 0;
//	//end
//	assign out.data = __out_single_port_ram_data;
//	assign out.wait_for_mem = 0;
//
//	always_comb
//	begin
//		__in_single_port_ram_data = in.data;
//	end
//
//	always_comb
//	begin
//		//__in_single_port_ram_addr = in.addr[15:2];
//		//__in_single_port_ram_addr 
//		//	= in.addr[15 : 15 - `WIDTH__SINGLE_PORT_RAM_ADDR];
//		//__in_single_port_ram_addr
//		//	= in.addr[15 : 2];
//		__in_single_port_ram_addr = in.addr >> 2;
//	end
//
//	always_comb
//	begin
//		__in_single_port_ram_we 
//			= (in.req_mem_access && in.data_inout_access_type);
//	end
//
//
//endmodule








































		// src__slash__instr_decoder_defines_header_sv

module InstrDecoder(input logic [((32) - 1):0] in,
	output PkgInstrDecoder::PortOut_InstrDecoder out);

	import PkgInstrDecoder::*;
	import PkgAlu::PortOut_Compare;



	logic [((4) - 1):0] __in_compare_ctrl_flow_b;

	// This works because of symmetry between the control flow instructions
	// Bad instructions don't cause stalls
	//assign __in_compare_ctrl_flow_b = PkgInstrDecoder::Bad0_Iog0;
	assign __in_compare_ctrl_flow_b = PkgInstrDecoder::Bad0_Iog2;
	PkgAlu::PortOut_Compare __out_compare_ctrl_flow;

	Compare #(.DATA_WIDTH(4)) __inst_compare_ctrl_flow
		(.a(out.opcode), .b(__in_compare_ctrl_flow_b),
		.out(__out_compare_ctrl_flow));

	PkgInstrDecoder::Iog0Instr __iog0_instr;
	assign __iog0_instr = in;

	PkgInstrDecoder::Iog1Instr __iog1_instr;
	assign __iog1_instr = in;

	PkgInstrDecoder::Iog2Instr __iog2_instr;
	assign __iog2_instr = in;

	PkgInstrDecoder::Iog3Instr __iog3_instr;
	assign __iog3_instr = in;

	PkgInstrDecoder::Iog4Instr __iog4_instr;
	assign __iog4_instr = in;

	PkgInstrDecoder::Iog5Instr __iog5_instr;
	assign __iog5_instr = in;

	PkgInstrDecoder::Iog6Instr __iog6_instr;
	assign __iog6_instr = in;

	always_comb
	begin
		// Just use __iog0_instr.group because the "group" field is in the
		// same location for all instructions.
		case (__iog0_instr.group)
			// Group 0:  Three Registers
			0:
			begin
				out.group = __iog0_instr.group;
				out.ra_index = __iog0_instr.ra_index;
				out.rb_index = __iog0_instr.rb_index;
				out.rc_index = __iog0_instr.rc_index;
				out.opcode = __iog0_instr.opcode;
				out.imm_val = 0;
				out.ldst_type = 0;
				//out.causes_stall = 0;
				out.causes_stall 
					= ((out.opcode == PkgInstrDecoder::Mul_ThreeRegs)
					|| (out.opcode == PkgInstrDecoder::Udiv_ThreeRegs)
					|| (out.opcode == PkgInstrDecoder::Sdiv_ThreeRegs));

				out.condition_type = 0;
			end

			// Group 1:  Immediates
			1:
			begin
				out.group = __iog1_instr.group;
				out.ra_index = __iog1_instr.ra_index;
				out.rb_index = __iog1_instr.rb_index;
				out.rc_index = 0;
				out.opcode = __iog1_instr.opcode;
				out.imm_val = __iog1_instr.imm_val;
				out.ldst_type = 0;

				//out.causes_stall = 0;
				out.causes_stall
					= (out.opcode == PkgInstrDecoder::Muli_TwoRegsOneImm);
				out.condition_type = 0;
			end

			// Group 2:  Branches
			2:
			begin
				out.group = __iog2_instr.group;
				out.ra_index = __iog2_instr.ra_index;
				out.rb_index = __iog2_instr.rb_index;
				//out.rc_index = __iog2_instr.rc_index;
				out.rc_index = 0;
				out.opcode = __iog2_instr.opcode;
				out.imm_val = __iog2_instr.imm_val;
				out.ldst_type = 0;

				// Bad instructions don't cause stalls
				out.causes_stall = __out_compare_ctrl_flow.ltu;
				out.condition_type = __iog2_instr.opcode;

			end

			// Group 3:  Jumps
			3:
			begin
				out.group = __iog3_instr.group;
				out.ra_index = __iog3_instr.ra_index;
				out.rb_index = __iog3_instr.rb_index;
				out.rc_index = __iog3_instr.rc_index;
				out.opcode = __iog3_instr.opcode;
				out.imm_val = 0;
				out.ldst_type = 0;

				// Bad instructions don't cause stalls
				out.causes_stall = __out_compare_ctrl_flow.ltu;
				out.condition_type = __iog3_instr.opcode;

			end

			// Group 4:  Calls
			4:
			begin
				out.group = __iog4_instr.group;
				out.ra_index = __iog4_instr.ra_index;
				out.rb_index = __iog4_instr.rb_index;
				out.rc_index = __iog4_instr.rc_index;
				out.opcode = __iog4_instr.opcode;
				out.imm_val = 0;
				out.ldst_type = 0;

				// Bad instructions don't cause stalls
				out.causes_stall = __out_compare_ctrl_flow.ltu;
				out.condition_type = __iog4_instr.opcode;

			end

			// Group 5:  Loads and stores
			5:
			begin
				out.group = __iog5_instr.group;
				out.ra_index = __iog5_instr.ra_index;
				out.rb_index = __iog5_instr.rb_index;
				out.rc_index = __iog5_instr.rc_index;
				out.opcode = __iog5_instr.opcode;

				// Sign extend the 12-bit immediate value... to 16-bit
				out.imm_val = {{4{__iog5_instr.imm_val_12
					[
	((12) - 1)]}},
					__iog5_instr.imm_val_12};

				// Make use of the opcode ordering
				out.ldst_type = out.opcode[((3) - 1):0];

				// All load/store instructions cause a stall
				out.causes_stall = 1;
				out.condition_type = 0;
			end

			6:
			begin
				out.group = __iog5_instr.group;
				out.ra_index = __iog5_instr.ra_index;
				out.rb_index = __iog5_instr.rb_index;
				out.rc_index = __iog5_instr.rc_index;
				out.opcode = __iog5_instr.opcode;
				out.group = __iog6_instr.group;

				out.imm_val = 0;
				out.ldst_type = 0;

				// Instructions that stall (prevent interrupts)
				out.causes_stall 
					= ((out.opcode == PkgInstrDecoder::Cpy_OneIretaOneReg)
					|| (out.opcode 
					== PkgInstrDecoder::Cpy_OneIdstaOneReg)
					|| (out.opcode
					== PkgInstrDecoder::Reti_NoArgs));

				out.condition_type = 0;
			end

			default:
			begin
				// Eek!  Invalid instruction group!
				// ...Treat it as a NOP ("add zero, zero, zero")
				out = 0;

				//`ifdef OPT_DEBUG_INSTR_DECODER
				//$display("bad_invalid_group");
				//`endif		// OPT_DEBUG_INSTR_DECODER
			end
		endcase
	end

endmodule

















		// src__slash__alu_defines_header_sv

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
	(input logic[((DATA_WIDTH) - 1) : 0] a, b,
	output PkgAlu::PortOut_Compare out);

	import PkgAlu::*;

	parameter __DATA_MSB_POS = ((DATA_WIDTH) - 1);
	logic [__DATA_MSB_POS:0] __temp = 0;

	always_comb
	begin
		{out.ltu, __temp} = a + (~b) + {{__DATA_MSB_POS{1'b0}}, 1'b1};
	end

	always_comb
	begin
		out.lts = (__temp[__DATA_MSB_POS] 
			^ ((a[__DATA_MSB_POS] ^ b[__DATA_MSB_POS]) 
			& (a[__DATA_MSB_POS] ^ __temp[__DATA_MSB_POS])));
	end

		// (greater than or equal) and (not equal to zero)

		//out.gtu = ((!out.ltu) && (!__temp));
		//out.gts = ((!out.lts) && (!__temp));
		//out.gtu = a > b;
		//out.gts = $signed(a) > $signed(b);

		//$display("Compare:  %h %h\t\t%h\t\t%h %h\t\t%h %h\t\t%h %h %h",
		//	a, b, __temp, out.ltu, out.lts, out.gtu, out.gts,
		//	!out.ltu, !out.lts, !__temp);

	always_comb
	begin
		if (out.ltu || (a == b))
		begin
			out.gtu = 0;
		end

		else
		begin
			out.gtu = 1;
		end
	end

	always_comb
	begin
		if (out.lts || (a == b))
		begin
			out.gts = 0;
		end

		else
		begin
			out.gts = 1;
		end
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

		logic [((32) - 1):0] x, y;

		logic [((32) - 1):0] 
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
// Don't try to do larger than a 128-bit division with this without
// changing counter_msb_pos.

// Depending on the FPGA being used and the clock rate, it may be doable to
// perform more than one iterate() per cycle, obtaining faster divisions.

// For obvious reasons, this does not return a correct result upon division
// by zero.
////module LongDivider #(parameter ARGS_WIDTH=32,
////	parameter NUM_ITERATIONS_PER_CYCLE=1)
////	(input wire clk, in_enable, in_unsgn_or_sgn,
////	// Numerator, Denominator
////	input bit [`WIDTH_TO_MSB_POS(ARGS_WIDTH):0] in_num, in_denom,
////
////	// Quotient, Remainder
////	output bit [`WIDTH_TO_MSB_POS(ARGS_WIDTH):0] out_quot, out_rem,
////
////	output bit out_can_accept_cmd, out_data_ready);
////
////
////	parameter ARGS_MSB_POS = `WIDTH_TO_MSB_POS(ARGS_WIDTH);
////
////
////	// This assumes you aren't trying to do division of numbers larger than
////	// 128-bit.
////	parameter __COUNTER_MSB_POS = 7;
////
////
////
////	wire __num_is_negative, __denom_is_negative;
////	bit __num_was_negative, __denom_was_negative;
////	bit __unsgn_or_sgn_buf;
////
////
////
////	bit [__COUNTER_MSB_POS:0] __counter, __state_counter;
////
////	bit [ARGS_MSB_POS:0] __num_buf, __denom_buf;
////	bit [ARGS_MSB_POS:0] __quot_buf, __rem_buf;
////
////
////	wire __busy;
////
////
////
////	// Tasks
////
////	task iterate;
////		__rem_buf = __rem_buf << 1;
////		__rem_buf[0] = __num_buf[__counter];
////
////		if (__rem_buf >= __denom_buf)
////		begin
////			__rem_buf = __rem_buf - __denom_buf;
////			__quot_buf[__counter] = 1;
////		end
////
////		__counter = __counter - 1;
////	endtask
////
////
////
////	// Assignments
////	assign __num_is_negative = $signed(in_num) < $signed(0);
////	assign __denom_is_negative = $signed(in_denom) < $signed(0);
////	assign __busy = !out_can_accept_cmd;
////
////
////
////	initial
////	begin
////		__counter = 0;
////		__state_counter = 0;
////
////		out_quot = 0;
////		out_rem = 0;
////
////		out_can_accept_cmd = 1;
////		out_data_ready = 0;
////
////		__num_was_negative = 0;
////		__denom_was_negative = 0;
////	end
////
////
////	always @ (posedge clk)
////	begin
////		if (__state_counter[__COUNTER_MSB_POS])
////		begin
////			__quot_buf = 0;
////			__rem_buf = 0;
////
////			__counter = ARGS_MSB_POS;
////		end
////
////		else if (__busy)
////		begin
////			if ($signed(__counter) > $signed(-1))
////			begin
////				// At some clock rates, some FPGAs may be able to handle
////				// more than one iteration per clock cycle, which is why
////				// iterate() is a task.  Feel free to try more than one
////				// iteration per clock cycle.
////
////				for (int i=0; i<NUM_ITERATIONS_PER_CYCLE; i=i+1)
////				begin
////					iterate();
////				end
////			end
////		end
////
////	end
////
////
////	always @ (posedge clk)
////	begin
////		$display("LongDivider stuff:  %h\t\t%h / %h\t\t%h %h", 
////			in_unsgn_or_sgn, in_num, in_denom, out_quot, out_rem); 
////		if (in_enable && out_can_accept_cmd)
////		begin
////			$display("LongDivider starting:  %h\t\t%h / %h\t\t%h %h", 
////				in_unsgn_or_sgn, in_num, in_denom, out_quot, out_rem); 
////			out_can_accept_cmd <= 0;
////			out_data_ready <= 0;
////			__state_counter <= -1;
////
////			__unsgn_or_sgn_buf <= in_unsgn_or_sgn;
////			__num_buf <= (in_unsgn_or_sgn && __num_is_negative)
////				? (-in_num) : in_num;
////			__denom_buf <= (in_unsgn_or_sgn && __denom_is_negative)
////				? (-in_denom) : in_denom;
////
////			__num_was_negative <= __num_is_negative;
////			__denom_was_negative <= __denom_is_negative;
////		end
////
////		else if (__busy)
////		begin
////			$display("LongDivider busy:  %h\t\t%h / %h\t\t%h %h", 
////				in_unsgn_or_sgn, in_num, in_denom, out_quot, out_rem); 
////			if (!__counter[__COUNTER_MSB_POS])
////			begin
////				__state_counter <= __state_counter + 1;
////			end
////
////			else
////			begin
////				out_can_accept_cmd <= 1;
////				__state_counter <= -1;
////				out_data_ready <= 1;
////
////				out_quot <= (__unsgn_or_sgn_buf
////					&& (__num_was_negative ^ __denom_was_negative))
////					? (-__quot_buf) : __quot_buf;
////				out_rem <= (__unsgn_or_sgn_buf && __num_was_negative)
////					? (-__rem_buf) : __rem_buf;
////			end
////		end
////	end
////
////
////endmodule
//
// SystemVerilog would really do well to support parameterized structs.
// Icarus Verilog would really do well to fully support SystemVerilog
// interfaces.
module NonRestoringDivider #(parameter ARGS_WIDTH=32, 
	parameter NUM_ITERATIONS_PER_CYCLE=1)
	(input logic clk, in_enable, in_unsgn_or_sgn,
	// Numerator, Denominator
	input logic [((ARGS_WIDTH) - 1):0] in_num, in_denom,

	// Quotient, Remainder
	output logic [((ARGS_WIDTH) - 1):0] out_quot, out_rem,

	output logic out_can_accept_cmd, out_data_ready);


	parameter ARGS_MSB_POS = ((ARGS_WIDTH) - 1);


	parameter TEMP_WIDTH = (ARGS_WIDTH << 1) + 1;

	parameter TEMP_MSB_POS = ((TEMP_WIDTH) - 1);


	// This assumes you aren't trying to do division of numbers larger than
	// 128-logic.
	parameter COUNTER_MSB_POS = 7;




	logic [COUNTER_MSB_POS:0] __counter, __state_counter;

	logic [ARGS_MSB_POS:0] __num_buf, __denom_buf;
	logic [ARGS_MSB_POS:0] __quot_buf, __rem_buf;


	wire __busy;
	wire __num_is_negative, __denom_is_negative;
	logic __num_was_negative, __denom_was_negative;
	logic __unsgn_or_sgn_buf;



	// Temporaries
	logic [TEMP_MSB_POS:0] __P;
	logic [TEMP_MSB_POS:0] __D;



	// Tasks
	task iterate;
		// if (__P >= 0)
		if (!__P[TEMP_MSB_POS] || (__P == 0))
		begin
			__quot_buf[__counter] = 1;
			__P = (__P << 1) - __D;
		end

		else
		begin
			__quot_buf[__counter] = 0;
			__P = (__P << 1) + __D;
		end

		__counter = __counter - 1;
	endtask



	// Assignments
	assign __busy = !out_can_accept_cmd;

	assign __num_is_negative = $signed(in_num) < $signed(0);
	assign __denom_is_negative = $signed(in_denom) < $signed(0);



	initial
	begin
		__counter = 0;
		__state_counter = 0;
		__P = 0;
		__D = 0;

		__state_counter = 0;

		out_quot = 0;
		out_rem = 0;

		// "out_can_accept_cmd" and "out_data_ready" only differ at
		// initialization.  This is probably not a good distinction to
		// have, to be honest, but oh well.
		out_can_accept_cmd = 1;
		out_data_ready = 0;
	end


	always @ (posedge clk)
	//always_ff @ (posedge clk)
	begin
		if (__state_counter[COUNTER_MSB_POS])
		begin
			__quot_buf = 0;
			__rem_buf = 0;

			__counter = ARGS_MSB_POS;


			__P = __num_buf;
			__D = __denom_buf << ARGS_WIDTH;
		end

		else if (__busy)
		begin
			//if (!__state_counter[COUNTER_MSB_POS])
			if ($signed(__counter) > $signed(-1))
			begin
				// At some clock rates, some FPGAs may be able to handle
				// more than one iteration per clock cycle, which is why
				// iterate() is a task.  Feel free to try more than one
				// iteration per clock cycle.

				//for (int i=0; i<NUM_ITERATIONS_PER_CYCLE; i=i+1)
				//begin
				//	iterate();
				//end
				case (NUM_ITERATIONS_PER_CYCLE)
					1:
					begin
						iterate();
					end

					2:
					begin
						iterate();
						iterate();
					end

					3:
					begin
						iterate();
						iterate();
						iterate();
					end

					4:
					begin
						iterate();
						iterate();
						iterate();
						iterate();
					end

					default:
					begin
						iterate();
					end

				endcase
			end
		end

	end


	//always @ (posedge clk)
	always_ff @ (posedge clk)
	begin
		$display("NonRestoringDivider stuff:  %h\t\t%h / %h\t\t%h %h", 
			in_unsgn_or_sgn, in_num, in_denom, out_quot, out_rem); 
		if (in_enable && out_can_accept_cmd)
		begin
		$display("NonRestoringDivider starting:  %h\t\t%h / %h\t\t%h %h", 
				in_unsgn_or_sgn, in_num, in_denom, out_quot, out_rem); 
			out_can_accept_cmd <= 0;
			out_data_ready <= 0;
			__state_counter <= -1;


			__num_buf <= (in_unsgn_or_sgn && __num_is_negative)
				? (-in_num) : in_num;
			__denom_buf <= (in_unsgn_or_sgn && __denom_is_negative)
				? (-in_denom) : in_denom;

			__unsgn_or_sgn_buf <= in_unsgn_or_sgn;

			__num_was_negative <= __num_is_negative;
			__denom_was_negative <= __denom_is_negative;
		end

		else if (__busy)
		begin
			$display("NonRestoringDivider busy:  %h\t\t%h / %h\t\t%h %h", 
				in_unsgn_or_sgn, in_num, in_denom, out_quot, out_rem); 
			if (!__counter[COUNTER_MSB_POS])
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
				if (__P[TEMP_MSB_POS])
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
	end


endmodule

