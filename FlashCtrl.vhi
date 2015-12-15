
-- VHDL Instantiation Created from source file FlashCtrl.vhd -- 11:19:13 12/15/2015
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT FlashCtrl
	PORT(
		ctrl_addr : IN std_logic_vector(31 downto 0);
		data_in : IN std_logic_vector(31 downto 0);
		r : IN std_logic;
		w : IN std_logic;
		next_pend : IN std_logic;
		mem_data_in : IN std_logic_vector(31 downto 0);
		clk : IN std_logic;
		reset : IN std_logic;    
		flash_data : INOUT std_logic_vector(15 downto 0);      
		data_out : OUT std_logic_vector(31 downto 0);
		intr : OUT std_logic;
		need_mem : OUT std_logic;
		flash_ce : OUT std_logic;
		flash_byte_mode : OUT std_logic;
		flash_oe : OUT std_logic;
		flash_we : OUT std_logic;
		flash_addr : OUT std_logic_vector(22 downto 0);
		flash_vpen : OUT std_logic;
		flash_rp : OUT std_logic;
		mem_addr : OUT std_logic_vector(31 downto 0);
		mem_data_out : OUT std_logic_vector(31 downto 0);
		mem_r : OUT std_logic;
		mem_w : OUT std_logic
		);
	END COMPONENT;

	Inst_FlashCtrl: FlashCtrl PORT MAP(
		ctrl_addr => ,
		data_in => ,
		data_out => ,
		intr => ,
		r => ,
		w => ,
		next_pend => ,
		need_mem => ,
		flash_ce => ,
		flash_byte_mode => ,
		flash_oe => ,
		flash_we => ,
		flash_addr => ,
		flash_data => ,
		flash_vpen => ,
		flash_rp => ,
		mem_addr => ,
		mem_data_out => ,
		mem_data_in => ,
		mem_r => ,
		mem_w => ,
		clk => ,
		reset => 
	);


