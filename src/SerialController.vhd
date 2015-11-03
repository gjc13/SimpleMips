----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:00:06 11/03/2015 
-- Design Name: 
-- Module Name:    SerialController - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SerialController is
    Port ( addr_bus : in  STD_LOGIC_VECTOR (31 downto 0);
           r_bus : in  STD_LOGIC;
           w_bus : in  STD_LOGIC;
           addr_serial : out  STD_LOGIC_VECTOR (31 downto 0);
           r_serial : out  STD_LOGIC;
           w_serial : out  STD_LOGIC);
end SerialController;

architecture Behavioral of SerialController is
begin
	process(addr_bus, r_bus, w_bus)
	begin
		if(addr_bus = X"bfd00000") then
			r_serial <= r_bus;
			w_serial <= w_bus;
			addr_serial <= X"00000000";
		elsif(addr_bus = X"bfd00004") then
			r_serial <= r_bus;
			w_serial <= w_bus;
			addr_serial <= X"00000004";
		else
			r_serial <= '0';
			w_serial <= '0';
		end if;
	end process;


end Behavioral;

