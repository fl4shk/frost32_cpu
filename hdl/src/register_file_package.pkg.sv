`include "src/register_file_defines.header.sv"

package PkgRegisterFile;

typedef struct packed
{
	// Which registers to read from
	logic [`MSB_POS__REG_FILE_SEL:0] read_sel_ra, read_sel_rb, read_sel_rc;

	`ifdef HAVE_REGISTER_READ_STAGE
	logic [`MSB_POS__REG_FILE_SEL:0] read_sel_cond_ra, read_sel_cond_rb;
	`endif		// HAVE_REGISTER_READ_STAGE

	// Which register to write to
	logic [`MSB_POS__REG_FILE_SEL:0] write_sel;

	// Data to write to the specific register
	logic [`MSB_POS__REG_FILE_DATA:0] write_data;

	// Whether or not to write at all
	logic write_en;

} PortIn_RegFile;

typedef struct packed
{
	logic [`MSB_POS__REG_FILE_DATA:0] read_data_ra, read_data_rb, 
		read_data_rc;

	`ifdef HAVE_REGISTER_READ_STAGE
	logic [`MSB_POS__REG_FILE_DATA:0] read_data_cond_ra, read_data_cond_rb;
	`endif		// HAVE_REGISTER_READ_STAGE
} PortOut_RegFile;

endpackage : PkgRegisterFile
