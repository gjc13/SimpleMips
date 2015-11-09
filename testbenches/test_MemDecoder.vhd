--------------------------------------------------------------------------------
-- Company: 
-- Engineer: gjc13
--
-- Create Date:   09:57:03 11/03/2015
-- Design Name:   
-- Module Name:   /home/shs/ucore_mips/cpu0/testbenches/test_MemDecoder.vhd
-- Project Name:  cpu0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MemDecoder
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_MemDecoder IS
END test_MemDecoder;
 
ARCHITECTURE behavior OF test_MemDecoder IS 
	function checkZ(data : std_logic_vector(31 downto 0)) return boolean is
	begin
		for i in 0 to 31 loop
			if data(i) /= 'Z' then
				return False;
			end if;
		end loop;
		return True;
	end checkZ;
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MemDecoder
    PORT(
         addr : IN  std_logic_vector(31 downto 0);
         r : IN  std_logic;
         w : IN  std_logic;
         data_in : IN  std_logic_vector(31 downto 0);
         data_out : OUT  std_logic_vector(31 downto 0);
         addr_bus : OUT  std_logic_vector(31 downto 0);
         r_bus : OUT  std_logic;
         w_bus : OUT  std_logic;
         data_bus : INOUT  std_logic_vector(31 downto 0);
         reset : IN  std_logic;
         clk : IN  std_logic;
         cpu_clk : IN  std_logic
        );
    END COMPONENT;

	component SerialController 
    Port ( addr_bus : in  STD_LOGIC_VECTOR (31 downto 0);
           r_bus : in  STD_LOGIC;
           w_bus : in  STD_LOGIC;
           addr_serial : out  STD_LOGIC_VECTOR (31 downto 0);
           r_serial : out STD_LOGIC;
           w_serial : out STD_LOGIC);
	end component;

	COMPONENT SRAMController 
    Port ( addr_bus : in  STD_LOGIC_VECTOR (31 downto 0);
           r_bus : in  STD_LOGIC;
           w_bus : in  STD_LOGIC;
           addr_sram : out  STD_LOGIC_VECTOR (19 downto 0);
           r_sram : out  STD_LOGIC;
           w_sram : out  STD_LOGIC);
	end component;

	COMPONENT mem_stub 
    Port (   addr : in  STD_LOGIC_VECTOR (19 downto 0);
            data : inout  STD_LOGIC_VECTOR (31 downto 0);
				r : in STD_LOGIC;
            w : in  STD_LOGIC;
				reset : in STD_LOGIC);
	end component;

	COMPONENT serial_stub
    Port (  addr : in STD_LOGIC_VECTOR(31 downto 0);
				data : inout  STD_LOGIC_VECTOR(31 downto 0);
				intr : in  STD_LOGIC;
				w : in  STD_LOGIC;
				r : in STD_LOGIC;
				clk : in STD_LOGIC;
				reset : in STD_LOGIC);
	end component;

	--Inputs
	signal addr : std_logic_vector(31 downto 0) := (others => '0');
	signal addr_serial : std_logic_vector(31 downto 0);
	signal addr_sram : std_logic_vector(19 downto 0);
	signal r : std_logic := '0';
	signal w : std_logic := '0';
	signal data_in : std_logic_vector(31 downto 0) := (others => '0');
	signal reset : std_logic := '0';
	signal clk : std_logic := '0';
	signal sub_clk: std_logic := '0';
	signal cpu_clk : std_logic := '0';

	--BiDirs
	signal data_bus : std_logic_vector(31 downto 0);

	--Outputs
	signal data_out : std_logic_vector(31 downto 0);
	signal addr_bus : std_logic_vector(31 downto 0);
	signal r_bus : std_logic;
	signal w_bus : std_logic;
	signal r_serial : std_logic;
	signal w_serial : std_logic;
	signal r_sram : std_logic;
	signal w_sram : std_logic;
	signal intr : std_logic;

	-- Clock period definitions
	constant clk_period : time := 10 ns;
	constant cpu_clk_period : time := 40 ns;

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MemDecoder PORT MAP (
          addr => addr,
          r => r,
          w => w,
          data_in => data_in,
          data_out => data_out,
          addr_bus => addr_bus,
          r_bus => r_bus,
          w_bus => w_bus,
          data_bus => data_bus,
          reset => reset,
          clk => clk,
          cpu_clk => cpu_clk
        );

    serial_control : SerialController Port map(
			addr_bus => addr_bus,
			r_bus => r_bus,
			w_bus => w_bus,
			addr_serial => addr_serial,
			r_serial => r_serial,
			w_serial => w_serial );

    sram_control : SRAMController Port map(
			addr_bus => addr_bus,
			r_bus => r_bus,
			w_bus => w_bus,
			addr_sram => addr_sram,
			r_sram => r_sram,
			w_sram => w_sram );

    mem: mem_stub Port map(  
			addr => addr_sram,
         data => data_bus,
			r => r_sram,
         w => w_sram,
			reset => reset );

	serial : serial_stub Port map(
    		addr => addr_serial,
			data => data_bus,
			intr => intr, 
			w => w_serial,
			r => r_serial,
			clk => clk,
			reset => reset);

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
	
   sub_clk_process :process(clk)
   begin
		if clk'event and clk = '1' then
			sub_clk <= not sub_clk;
		end if;
   end process;
 
   cpu_clk_process :process(sub_clk)
   begin
		if sub_clk'event and sub_clk = '1' then
			cpu_clk <= not cpu_clk;
		end if;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
	   reset <= '1';
	   wait for 40 ns;
		reset <= '0';
	   wait for 50 ns;
	   report "test write ram";
		assert checkZ(data_bus) report "data_bus error" severity error;
	   assert r_bus = '0' report "r_bus error" severity error;
	   assert w_bus = '0' report "w_bus error" severity error;
	   addr <= X"80000000";
	   r <= '0';
	   w <= '1';
	   data_in <= X"01234567";
	   wait for 10 ns;
	   assert addr_bus = X"00000000" report "addr_bus error" severity error;
	   assert data_bus = X"01234567" report "data_bus error" severity error;
	   assert r_bus = '0' report "r_bus error" severity error;
	   assert w_bus = '1' report "w_bus error" severity error;
	   assert r_sram = '0' report "r_sram error" severity error;
	   assert w_sram = '1' report "w_sram error" severity error;
	   assert r_serial = '0' report "r_serial error" severity error;
	   assert w_serial = '0' report "w_serial error" severity error;

	   wait for 10 ns;
	   assert addr_bus = X"00000000" report "addr_bus error" severity error;
	   assert checkZ(data_bus) report "data_bus error" severity error;
	   assert r_bus = '0' report "r_bus error" severity error;
	   assert w_bus = '0' report "w_bus error" severity error;
	   assert r_sram = '0' report "r_sram error" severity error;
	   assert w_sram = '0' report "w_serial error" severity error;
	   assert r_serial = '0' report "r_serial error" severity error;
	   assert w_serial = '0' report "w_serial error" severity error;

	   wait for 10 ns;
	   assert addr_bus = X"00000000" report "addr_bus error" severity error;
	   assert checkZ(data_bus) report "data_bus error" severity error;
	   assert r_bus = '0' report "r_bus error" severity error;
	   assert w_bus = '0' report "w_bus error" severity error;
	   assert r_sram = '0' report "r_sram error" severity error;
	   assert w_sram = '0' report "w_serial error" severity error;
	   assert r_serial = '0' report "r_serial error" severity error;
	   assert w_serial = '0' report "w_serial error" severity error;

	   report "test read ram";
	   wait for 10 ns;
	   assert addr_bus = X"00000000" report "addr_bus error" severity error;
	   assert checkZ(data_bus) report "data_bus error" severity error;
	   assert r_bus = '0' report "r_bus error" severity error;
	   assert w_bus = '0' report "w_bus error" severity error;
	   assert r_sram = '0' report "r_sram error" severity error;
	   assert w_sram = '0' report "w_serial error" severity error;
	   assert r_serial = '0' report "r_serial error" severity error;
	   assert w_serial = '0' report "w_serial error" severity error;
	   r <= '1';
	   w <= '0';
	   wait for 10 ns;
	   assert addr_bus = X"00000000" report "addr_bus error" severity error;
	   assert r_bus = '1' report "r_bus error" severity error;
	   assert w_bus = '0' report "w_bus error" severity error;
	   assert r_sram = '1' report "r_sram error" severity error;
	   assert w_sram = '0' report "w_serial error" severity error;
	   assert r_serial = '0' report "r_serial error" severity error;
	   assert w_serial = '0' report "w_serial error" severity error;

	   wait for 10 ns;
	   assert addr_bus = X"00000000" report "addr_bus error" severity error;
	   assert data_out = X"01234567" report "data_out error" severity error;
	   assert r_bus = '0' report "r_bus error" severity error;
	   assert w_bus = '0' report "w_bus error" severity error;
	   assert r_sram = '0' report "r_sram error" severity error;
	   assert w_sram = '0' report "w_serial error" severity error;
	   assert r_serial = '0' report "r_serial error" severity error;
	   assert w_serial = '0' report "w_serial error" severity error;

	   wait for 10 ns;
	   assert addr_bus = X"00000000" report "addr_bus error" severity error;
	   assert data_out = X"01234567" report "data_out error" severity error;
	   assert r_bus = '0' report "r_bus error" severity error;
	   assert w_bus = '0' report "w_bus error" severity error;
	   assert r_sram = '0' report "r_sram error" severity error;
	   assert w_sram = '0' report "w_serial error" severity error;
	   assert r_serial = '0' report "r_serial error" severity error;
	   assert w_serial = '0' report "w_serial error" severity error;


	   report "test write serial data";
	   wait for 10 ns;
	   assert addr_bus = X"00000000" report "addr_bus error" severity error;
	   assert checkZ(data_bus) report "data_bus error" severity error;
	   assert data_out = X"01234567" report "data_out error" severity error;
	   assert r_bus = '0' report "r_bus error" severity error;
	   assert w_bus = '0' report "w_bus error" severity error;
	   assert r_sram = '0' report "r_sram error" severity error;
	   assert w_sram = '0' report "w_serial error" severity error;
	   assert r_serial = '0' report "r_serial error" severity error;
	   assert w_serial = '0' report "w_serial error" severity error;

	   r <= '0';
	   w <= '1';
	   data_in <= X"FFFFFFFF";
	   addr <= X"bfd00000";

	   wait for 10 ns;
	   assert addr_bus = X"bfd00000" report "addr_bus error" severity error;
	   assert addr_serial = X"00000000" report "addr_serial error" severity error;
	   assert data_bus = X"FFFFFFFF" report "data_bus error" severity error;
	   assert r_bus = '0' report "r_bus error" severity error;
	   assert w_bus = '1' report "w_bus error" severity error;
	   assert r_sram = '0' report "r_sram error" severity error;
	   assert w_sram = '0' report "w_serial error" severity error;
	   assert r_serial = '0' report "r_serial error" severity error;
	   assert w_serial = '1' report "w_serial error" severity error;

	   wait for 10 ns;
	   assert addr_bus = X"bfd00000" report "addr_bus error" severity error;
	   assert addr_serial = X"00000000" report "addr_serial error" severity error;
	   assert r_bus = '0' report "r_bus error" severity error;
	   assert w_bus = '0' report "w_bus error" severity error;
	   assert r_sram = '0' report "r_sram error" severity error;
	   assert w_sram = '0' report "w_serial error" severity error;
	   assert r_serial = '0' report "r_serial error" severity error;
	   assert w_serial = '0' report "w_serial error" severity error;

	   wait for 10 ns;
	   assert addr_bus = X"bfd00000" report "addr_bus error" severity error;
	   assert addr_serial = X"00000000" report "addr_serial error" severity error;
	   assert checkZ(data_bus) report "data_bus error" severity error;
	   assert r_bus = '0' report "r_bus error" severity error;
	   assert w_bus = '0' report "w_bus error" severity error;
	   assert r_sram = '0' report "r_sram error" severity error;
	   assert w_sram = '0' report "w_serial error" severity error;
	   assert r_serial = '0' report "r_serial error" severity error;
	   assert w_serial = '0' report "w_serial error" severity error;


	   report "test read serial data"; 
	   wait for 10 ns;
	   assert addr_bus = X"bfd00000" report "addr_bus error" severity error;
	   assert addr_serial = X"00000000" report "addr_serial error" severity error;
	   assert checkZ(data_bus) report "data_bus error" severity error;
	   assert r_bus = '0' report "r_bus error" severity error;
	   assert w_bus = '0' report "w_bus error" severity error;
	   assert r_sram = '0' report "r_sram error" severity error;
	   assert w_sram = '0' report "w_serial error" severity error;
	   assert r_serial = '0' report "r_serial error" severity error;
	   assert w_serial = '0' report "w_serial error" severity error;

	   r <= '1';
	   w <= '0';
	   wait for 10 ns;
	   assert addr_bus = X"bfd00000" report "addr_bus error" severity error;
	   assert addr_serial = X"00000000" report "addr_serial error" severity error;
	   assert r_bus = '1' report "r_bus error" severity error;
	   assert w_bus = '0' report "w_bus error" severity error;
	   assert r_sram = '0' report "r_sram error" severity error;
	   assert w_sram = '0' report "w_serial error" severity error;
	   assert r_serial = '1' report "r_serial error" severity error;
	   assert w_serial = '0' report "w_serial error" severity error;

	   wait for 10 ns;
	   assert addr_bus = X"bfd00000" report "addr_bus error" severity error;
	   assert addr_serial = X"00000000" report "addr_serial error" severity error;
	   assert data_bus = X"00000031" report "data_bus error" severity error;
	   assert r_bus = '0' report "r_bus error" severity error;
	   assert w_bus = '0' report "w_bus error" severity error;
	   assert r_sram = '0' report "r_sram error" severity error;
	   assert w_sram = '0' report "w_serial error" severity error;
	   assert r_serial = '0' report "r_serial error" severity error;
	   assert w_serial = '0' report "w_serial error" severity error;

	   wait for 10 ns;
	   assert addr_bus = X"bfd00000" report "addr_bus error" severity error;
	   assert addr_serial = X"00000000" report "addr_serial error" severity error;
	   assert data_out = X"00000031" report "data_out error" severity error;
	   assert r_bus = '0' report "r_bus error" severity error;
	   assert w_bus = '0' report "w_bus error" severity error;
	   assert r_sram = '0' report "r_sram error" severity error;
	   assert w_sram = '0' report "w_serial error" severity error;
	   assert r_serial = '0' report "r_serial error" severity error;
	   assert w_serial = '0' report "w_serial error" severity error;


	   report "test read setial state";
	   wait for 10 ns;
	   assert addr_bus = X"bfd00000" report "addr_bus error" severity error;
	   assert addr_serial = X"00000000" report "addr_serial error" severity error;
	   assert checkZ(data_bus) report "data_bus error" severity error;
	   assert data_out = X"00000031" report "data_out error" severity error;
	   assert r_bus = '0' report "r_bus error" severity error;
	   assert w_bus = '0' report "w_bus error" severity error;
	   assert r_sram = '0' report "r_sram error" severity error;
	   assert w_sram = '0' report "w_serial error" severity error;
	   assert r_serial = '0' report "r_serial error" severity error;
	   assert w_serial = '0' report "w_serial error" severity error;

	   addr <= X"bfd00004";
	   wait for 10 ns;
	   assert addr_bus = X"bfd00004" report "addr_bus error" severity error;
	   assert addr_serial = X"00000004" report "addr_serial error" severity error;
	   assert r_bus = '1' report "r_bus error" severity error;
	   assert w_bus = '0' report "w_bus error" severity error;
	   assert r_sram = '0' report "r_sram error" severity error;
	   assert w_sram = '0' report "w_serial error" severity error;
	   assert r_serial = '1' report "r_serial error" severity error;
	   assert w_serial = '0' report "w_serial error" severity error;

	   wait for 10 ns;
	   assert addr_bus = X"bfd00004" report "addr_bus error" severity error;
	   assert addr_serial = X"00000004" report "addr_serial error" severity error;
	   assert data_bus = X"00000001" report "data_bus error" severity error;
	   assert r_bus = '0' report "r_bus error" severity error;
	   assert w_bus = '0' report "w_bus error" severity error;
	   assert r_sram = '0' report "r_sram error" severity error;
	   assert w_sram = '0' report "w_serial error" severity error;
	   assert r_serial = '0' report "r_serial error" severity error;
	   assert w_serial = '0' report "w_serial error" severity error;

	   wait for 10 ns;
	   assert addr_bus = X"bfd00004" report "addr_bus error" severity error;
	   assert addr_serial = X"00000004" report "addr_serial error" severity error;
	   assert data_out = X"00000001" report "data_out error" severity error;
	   assert r_bus = '0' report "r_bus error" severity error;
	   assert w_bus = '0' report "w_bus error" severity error;
	   assert r_sram = '0' report "r_sram error" severity error;
	   assert w_sram = '0' report "w_serial error" severity error;
	   assert r_serial = '0' report "r_serial error" severity error;
	   assert w_serial = '0' report "w_serial error" severity error;
		
		wait;
	   
   end process;

END;
