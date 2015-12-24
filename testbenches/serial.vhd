----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:06:45 10/24/2015 
-- Design Name: 
-- Module Name:    serial - serialBehavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
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
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
entity serial_stub is
    Port (  addr : in STD_LOGIC_VECTOR(31 downto 0);
			data_in : in  STD_LOGIC_VECTOR(31 downto 0);
			data_out : out  STD_LOGIC_VECTOR(31 downto 0);
			intr : in  STD_LOGIC;
			w : in  STD_LOGIC;
			r : in STD_LOGIC;
			clk : in STD_LOGIC;
			reset : in STD_LOGIC);
end serial_stub;


architecture serialBehavioral of serial_stub is
begin
	process(clk)
        variable s: String(1 to 1);
	begin
		if (reset = '1') then
			data_out <= (others => 'Z');
		elsif (clk'event and clk = '1') then
			if (w = '1' and r = '0') then
				if (addr = X"00000000") then
                    s(1) := character'val(to_integer(unsigned(data_in)));
                    write(OUTPUT, s); 
				end if;
				data_out <= (others => 'Z');
			elsif (r = '1' and w = '0') then
				if (addr = X"00000000") then
					data_out <= X"00000031";
				elsif (addr = X"00000004") then
					data_out <= X"00000000";
				end if;
			else
				data_out <= (others => 'Z');
			end if;
		end if;
	end process;

end serialBehavioral;

