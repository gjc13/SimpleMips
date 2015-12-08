----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:38:20 12/07/2015 
-- Design Name: 
-- Module Name:    sram_check - Behavioral 
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

entity sram_check is
    port(
        addr_in : in std_logic_vector(19 downto 0);
        w_in : std_logic;
        r_in : std_logic;
        --sram
        addr_sram:out std_logic_vector(19 downto 0);
        data_bus:inout std_logic_vector(31 downto 0);
        ce: out std_logic;
        oe: out std_logic;
        we: out std_logic;
        selector : in std_logic
    );
end sram_check;

architecture Behavioral of sram_check is

begin
    ce <= '0';
    addr_sram <= addr_in;
    oe <= r_in;
    we <= w_in;
    
    process(w_in, selector)
    begin
        if w_in = '0' and selector = '1' then
            data_bus <= X"12345678";
        elsif w_in ='0' then
            data_bus <= X"00000001";
        else
            data_bus <= (others => 'Z');
        end if;
    end process;

end Behavioral;

