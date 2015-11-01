library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package Utilities is
function to_std_logic(L: BOOLEAN) return std_logic;
end Utilities;

package body Utilities is
	function to_std_logic(L: BOOLEAN) return std_logic is 
		begin 
			if L then return('1'); 
			else return('0'); 
		end if; 
	end function To_Std_Logic;
end Utilities;
