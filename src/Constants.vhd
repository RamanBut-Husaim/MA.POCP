library IEEE;
use IEEE.STD_LOGIC_1164.all;

package Sorting_Design is
	-- OP Codes
	constant OP_LOAD: std_logic_vector(3 downto 0) := "0000";
	constant OP_STORE: std_logic_vector(3 downto 0) := "0001";
	constant OP_ADD: std_logic_vector(3 downto 0) := "0010";
	constant OP_SUB: std_logic_vector(3 downto 0) := "0011";
	constant OP_HALT: std_logic_vector(3 downto 0) := "0100";
    constant OP_LOADIN: std_logic_vector(3 downto 0) := "0101";
	constant OP_JNSB: std_logic_vector(3 downto 0) := "0110";
	constant OP_JZ: std_logic_vector(3 downto 0) := "0111";
	constant OP_STOREIN: std_logic_vector(3 downto 0) := "1000";
	-- End OP Codes
end Sorting_Design;