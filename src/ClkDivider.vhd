----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:24:21 12/19/2015 
-- Design Name: 
-- Module Name:    ClkDivider - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ClkDivider is
    Port ( clk : in  STD_LOGIC;
           clk_div : out  STD_LOGIC);
end ClkDivider;

architecture Behavioral of ClkDivider is
    constant ADDER : unsigned := X"00000001";
    signal count : std_logic_vector(31 downto 0);
begin
    clk_div <= count(1);
    process(clk)
    begin
        if(clk'event and clk = '1') then
            count <= std_logic_vector(unsigned(count) + ADDER);
        end if;
    end process;
end Behavioral;

