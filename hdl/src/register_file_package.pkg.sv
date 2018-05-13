`include "src/register_file_defines.header.sv"

package PkgRegisterFile;

typedef struct packed
{
	// Which registers to read from
	logic [`MSB_POS__REG_FILE_SEL:0] 
		read_sel[0 : `LAST_INDEX__REG_FILE_NUM_PORTS];

	// Which register to write to
	logic [`MSB_POS__REG_FILE_SEL:0] write_sel;

	// Whether or not to write at all
	logic write_en;

	// Data to write to the specific register
	logic [`MSB_POS__REG_FILE_DATA:0] write_data;

} PortIn_RegFile;

typedef struct packed
{
	logic [`MSB_POS__REG_FILE_DATA:0] 
		read_data[0 : `LAST_INDEX__REG_FILE_NUM_PORTS];
} PortOut_RegFile;

endpackage : PkgRegisterFile
