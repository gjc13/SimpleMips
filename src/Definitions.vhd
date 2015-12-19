library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package Definitions is
	constant ALU_NONE : INTEGER := 0;
	constant ALU_ADD : INTEGER := 1;
	constant ALU_SUB : INTEGER := 2;
	constant ALU_AND : INTEGER := 3;
	constant ALU_OR  : INTEGER := 4;
	constant ALU_NOT : INTEGER := 5;
	constant ALU_XOR : INTEGER := 6;
	constant ALU_SRAV : INTEGER := 7;
	constant ALU_SLL : INTEGER := 8;
	constant ALU_SRA : INTEGER := 9;
	constant ALU_SRL : INTEGER := 10;
	constant ALU_NOR : INTEGER := 11;
	constant ALU_LS : INTEGER := 12; --less signed
	constant ALU_LU : INTEGER := 13; --less unsigned
	constant ALU_SLLV : INTEGER := 14;
	constant ALU_SRLV : INTEGER := 15;

	-- all branch compare is signed compare
	constant B_ALL: INTEGER := 0;
	constant B_EQ : INTEGER := 1;
	constant B_NE : INTEGER := 2;
	constant B_G  : INTEGER := 3;
	constant B_GE : INTEGER := 4;
	constant B_L  : INTEGER := 5;
	constant B_LE : INTEGER := 6;

    --word, byte signed/unsigned, half signed/unsigned
	constant MEM_W : INTEGER := 0;
	constant MEM_BU : INTEGER := 1;
	constant MEM_BS : INTEGER := 2;
	constant MEM_HU : INTEGER := 3;
	constant MEM_HS : INTEGER := 4;

    --save byte, save half
    constant MEM_SB : INTEGER := 5;
    constant MEM_SH : INTEGER := 6;

    --hi, lo
    constant REG_HI : INTEGER := 64;
    constant REG_LO : INTEGER := 65;

	constant START_ADDR : STD_LOGIC_VECTOR := X"80000000";
	constant PRE_START_ADDR : STD_LOGIC_VECTOR := X"7FFFFFFC";

end Definitions;
