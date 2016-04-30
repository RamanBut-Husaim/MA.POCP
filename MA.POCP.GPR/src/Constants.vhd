library IEEE;
use IEEE.STD_LOGIC_1164.all;

package SortingGPR is
	-- OP Codes
	constant OP_ADD: std_logic_vector(2 downto 0) := "001";
	constant OP_SUB: std_logic_vector(2 downto 0) := "010";
	constant OP_XORIN: std_logic_vector(2 downto 0) := "011";
	constant OP_HALT: std_logic_vector(2 downto 0) := "100";
	constant OP_JNSB: std_logic_vector(2 downto 0) := "101";
	constant OP_JZ: std_logic_vector(2 downto 0) := "110";
	-- End OP Codes
end SortingGPR;