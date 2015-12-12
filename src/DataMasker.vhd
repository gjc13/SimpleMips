----------------------------------------------------------------------------------
-- Company: 
-- Engineer: gjc13
-- 
-- Create Date:    14:44:12 11/09/2015 
-- Design Name: 
-- Module Name:    DataMasker - Behavioral 
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
use work.Definitions.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DataMasker is
    Port (  
			--data from mem data_mem
			data_in : in  STD_LOGIC_VECTOR (31 downto 0);
			data_in_masked : out STD_LOGIC_VECTOR (31 downto 0);
			
			--first,data resultwb
            data_old : in STD_LOGIC_VECTOR (31 downto 0);
			--data to write (8) rt_mem
			data_out : in STD_LOGIC_VECTOR (31 downto 0);
			data_out_masked : out STD_LOGIC_VECTOR (31 downto 0);
				
            mem_op_code : in integer range 0 to 7;
            addr : in  STD_LOGIC_VECTOR (31 downto 0));
end DataMasker;

architecture Behavioral of DataMasker is

begin
    process(data_in, mem_op_code,data_old,data_out)
    begin
        case mem_op_code is
            when MEM_W => 
					data_in_masked <= data_in;
					data_out_masked <= data_out;
            when MEM_BU => 
					data_out_masked <= data_out;
                case addr(1 downto 0) is
                    when "00" =>
                        data_in_masked <= std_logic_vector(resize(unsigned(data_in(7 downto 0)), data_in'length));
                    when "01" =>
                        data_in_masked <= std_logic_vector(resize(unsigned(data_in(15 downto 8)), data_in'length));
                    when "10" =>
                        data_in_masked <= std_logic_vector(resize(unsigned(data_in(23 downto 16)), data_in'length));
                    when "11" =>
                        data_in_masked <= std_logic_vector(resize(unsigned(data_in(31 downto 24)), data_in'length));
                    when others =>
                        data_in_masked <= data_in;
                end case;
            when MEM_BS =>
						data_out_masked <= data_out;
                case addr(1 downto 0) is
                    when "00" =>
                        data_in_masked <= std_logic_vector(resize(signed(data_in(7 downto 0)), data_in'length));
                    when "01" =>
                        data_in_masked <= std_logic_vector(resize(signed(data_in(15 downto 8)), data_in'length));
                    when "10" =>
                        data_in_masked <= std_logic_vector(resize(signed(data_in(23 downto 16)), data_in'length));
                    when "11" =>
                        data_in_masked <= std_logic_vector(resize(signed(data_in(31 downto 24)), data_in'length));
                    when others =>
                        data_in_masked <= data_in;
                end case;
            when MEM_HU =>
					data_out_masked <= data_out;
                data_in_masked <= std_logic_vector(resize(unsigned(data_in(15 downto 0)), data_in'length));
            when MEM_HS =>
					data_out_masked <= data_out;
                data_in_masked <= std_logic_vector(resize(signed(data_in(15 downto 0)), data_in'length));
            when MEM_SB =>
					data_in_masked <= data_in;
                case addr(1 downto 0) is
                    when "00" =>
                        data_out_masked <= data_old(31 downto 8) & data_out(7 downto 0);
                    when "01" =>
                        data_out_masked <= data_old(31 downto 16) & data_out(7 downto 0) & data_old(7 downto 0);
                    when "10" =>
                        data_out_masked <= data_old(31 downto 24) & data_out(7 downto 0) & data_old(15 downto 0);
                    when "11" =>
                        data_out_masked <= data_out(7 downto 0) & data_old(23 downto 0);
                    when others =>
                        data_out_masked <= data_out;
                end case;
            when MEM_SH =>
					data_in_masked <= data_in;
                data_out_masked <= data_old(31 downto 16) & data_out(15 downto 0);
            when others => 
					data_in_masked <= data_in;
                data_out_masked <= X"00000000";
        end case;
    end process;
end Behavioral;

