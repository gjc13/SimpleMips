----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:10:35 12/11/2015 
-- Design Name: 
-- Module Name:    FlashReader - Behavioral 
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

entity FlashReader is
    Port ( en : in  STD_LOGIC;
           complete : out  STD_LOGIC;
           we : out  STD_LOGIC;
           oe : out  STD_LOGIC;
           can_read : out  STD_LOGIC_VECTOR (16 downto 0);
           clk : in  STD_LOGIC);
end FlashReader;

architecture Behavioral of FlashReader is
    type State is (IDLE, READ_WAIT, READ_END);
    signal pr_state : State;
begin
    process(clk)
    begin
        if clk'event and clk = '1' then
            if en = '0' then
                complete <= '0';
                we <= '1';
                oe <= '1';
                data_out <= (others => '0');
                pr_state <= IDLE;
            else
                case pr_state is
                    when IDLE =>
                        oe <= '0';
                        pr_state <= READ_WAIT;
                    when 
                end case;
    end process;
end Behavioral;

