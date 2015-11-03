library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.all;

package Utilities is
function to_std_logic(L: BOOLEAN) return std_logic;
procedure print_hex(data : std_logic_vector(31 downto 0));
end Utilities;

package body Utilities is
	function to_std_logic(L: BOOLEAN) return std_logic is 
	begin 
		if L then return('1'); 
			else return('0'); 
		end if; 
	end function To_Std_Logic;
	
	procedure print_hex(data :  std_logic_vector(31 downto 0)) is
		variable debugline: line;
	begin
		hwrite(debugline, data);
		writeline(OUTPUT, debugline);
	end procedure print_hex;
end Utilities;
