----------------------------------------------------------------------------------
-- Company: 
-- Engineer: gjc13
-- 
-- Create Date:    13:36:12 10/24/2015 
-- Design Name:	 men_stub
-- Module Name:    mem_stub - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 	a sram stub for simualtion
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Utilities.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mem_stub is
    Port (  addr : in  STD_LOGIC_VECTOR (19 downto 0);
            data : inout  STD_LOGIC_VECTOR (31 downto 0);
			r : in STD_LOGIC;
            w : in  STD_LOGIC;
			reset : in STD_LOGIC);
end mem_stub;

architecture Behavioral of mem_stub is
	type RamType is array(0 to 2**14-1) of STD_LOGIC_VECTOR(31 downto 0);

	impure function InitRamFromFile(RamFileName: in string) return RamType is
		FILE ramFile : text is in RamFileName;
		variable ramFileLine : line;
		variable ram : RamType;
	begin
		for i in RamType'range loop
			readline(ramFile, ramFileLine);
			hread(ramFileLine, ram(i));
		end loop;
		return ram;
	end function;

begin
	process(w, r, reset)
		variable ram: RamType := InitRamFromFile("lab_flash.data");
		variable addr_masked : integer;
	begin
		addr_masked := to_integer(unsigned(addr) and X"03fff");
		if reset = '1' then
			data <= (others => 'Z');
		elsif w = '0' and r = '1' then
			--report "write memory";
			--print_hex(ram(addr_masked));
			ram(addr_masked) := data;
			data <= (others => 'Z');
		elsif r = '0' and w = '1' then
			--report "read memory";
			--print_hex(ram(addr_masked));
			data <= ram(addr_masked);
		else
			data <= (others => 'Z');
		end if;
	end process;
end Behavioral;

