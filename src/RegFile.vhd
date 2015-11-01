----------------------------------------------------------------------------------
-- Company: 
-- Engineer: gjc13
-- 
-- Create Date:    09:54:59 11/01/2015 
-- Design Name: 
-- Module Name:    RegFile - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RegFile is
    Port (  rs_id : in  INTEGER RANGE 0 TO 127;
            rt_id : in  INTEGER RANGE 0 TO 127;
            rd_id : in  INTEGER RANGE 0 TO 127;
            is_regwrite : in  STD_LOGIC;
            rd_data : in  STD_LOGIC_VECTOR (31 downto 0);
            rs_data : out  STD_LOGIC_VECTOR (31 downto 0);
            rt_data : out  STD_LOGIC_VECTOR (31 downto 0);
	   		clk : in STD_LOGIC;
			reset : in STD_LOGIC);
end RegFile;

architecture Behavioral of RegFile is
	type RegsType is array(0 to 127) of std_logic_vector(31 downto 0);
	signal regs: RegsType;
begin
	process(clk)
	begin
		if(clk'event and clk = '1') then
			if(reset = '1') then
				for i in regs'range loop
					regs(i) <= (others => '0');
				end loop;
			else
				if(is_regwrite = '1' and rd_id /= 0) then
					regs(rd_id) <= rd_data;
				end if;
				if(rt_id = rd_id and rd_id /= 0 and is_regwrite = '1') then
					rt_data <= rd_data;
				else
					rt_data <= regs(rt_id);
				end if;
				if(rs_id = rd_id and rd_id /= 0 and is_regwrite = '1') then
					rs_data <= rd_data;
				else
					rs_data <= regs(rs_id);
				end if;
			end if;
		end if;
	end process;

end Behavioral;

