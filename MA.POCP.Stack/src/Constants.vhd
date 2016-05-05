library IEEE;
use IEEE.STD_LOGIC_1164.all;

package SortingStack is
	-- OP Codes
	constant OP_ADD: std_logic_vector(3 downto 0) := "0001";
	constant OP_SUB: std_logic_vector(3 downto 0) := "0010";
	constant OP_HALT: std_logic_vector(3 downto 0) := "0011";
	constant OP_JNSB: std_logic_vector(3 downto 0) := "0100";
	constant OP_JZ: std_logic_vector(3 downto 0) := "0101";
	constant OP_PUSH: std_logic_vector(3 downto 0) := "0110";
	constant OP_POP: std_logic_vector(3 downto 0) := "0111";
	constant OP_PUSHIN: std_logic_vector(3 downto 0) := "1000";
	constant OP_POPIN: std_logic_vector(3 downto 0) := "1001";
	-- End OP Codes
end SortingStack;