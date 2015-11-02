package Definitions is
	constant ALU_NONE : INTEGER := 0;
	constant ALU_ADD : INTEGER := 1;
	constant ALU_SUB : INTEGER := 2;
	constant ALU_AND : INTEGER := 3;
	constant ALU_OR  : INTEGER := 4;
	constant ALU_NOT : INTEGER := 5;
	constant ALU_SHL : INTEGER := 6;
	constant ALU_SHR : INTEGER := 7;
	constant ALU_LS : INTEGER := 12; --less signed
	constant ALU_LU : INTEGER := 13; --less unsigned

	-- all branch compare is signed compare
	constant B_ALL: INTEGER := 0;
	constant B_EQ : INTEGER := 1;
	constant B_NE : INTEGER := 2;
	constant B_G  : INTEGER := 3;
	constant B_GE : INTEGER := 4;
	constant B_L  : INTEGER := 5;
	constant B_LE : INTEGER := 6;

	constant MEM_W : INTEGER := 0;
	constant MEM_BU : INTEGER := 1;
	constant MEM_BS : INTEGER := 2;
	constant MEM_HU : INTEGER := 3;
	constant MEM_HS : INTEGER := 4;

end Definitions;
