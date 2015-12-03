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
    Port (  data_in : in  STD_LOGIC_VECTOR (31 downto 0);
			mem_op_code : in integer range 0 to 7;
			data_out : out  STD_LOGIC_VECTOR (31 downto 0));
end DataMasker;

architecture Behavioral of DataMasker is

begin
	process(data_in, mem_op_code)
	begin
		case mem_op_code is
			when MEM_W => data_out <= data_in;
			when MEM_BU => 
				data_out <= std_logic_vector(resize(unsigned(data_in(7 downto 0)), data_out'length));
			when MEM_BS =>
				data_out <= std_logic_vector(resize(signed(data_in(7 downto 0)), data_out'length));
			when MEM_HU =>
				data_out <= std_logic_vector(resize(unsigned(data_in(15 downto 0)), data_out'length));
			when MEM_HS =>
				data_out <= std_logic_vector(resize(signed(data_in(15 downto 0)), data_out'length));
			when others => 
                data_out <= X"00000000";
		end case;
	end process;
end Behavioral;

