library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use SortingStack.all;

entity MROM is 
	port (
		RE: in std_logic;
		ADDR: in std_logic_vector(5 downto 0);
		DOUT: out std_logic_vector(9 downto 0)
	);
end MROM;

architecture Beh_Stack of MROM is
	subtype inst is std_logic_vector(9 downto 0);
	type tROM is array (0 to 63) of inst;
	
	constant EMPTY_ADDR: std_logic_vector(5 downto 0) := "111111";
	constant ADDR_ONE: std_logic_vector(5 downto 0) := "001110";
	constant ADDR_ZERO: std_logic_vector(5 downto 0) := "001111";
	constant ADDR_LENGTH: std_logic_vector(5 downto 0) := "001010";
	constant ADDR_LENGTH_1: std_logic_vector(5 downto 0) := "001011";
	constant ADDR_I: std_logic_vector(5 downto 0) := "001100";
	constant ADDR_J: std_logic_vector(5 downto 0) := "001101";
	constant ADDR_TEMP1: std_logic_vector(5 downto 0) := "010000";
	constant ADDR_TEMP2: std_logic_vector(5 downto 0) := "010001";
	
	constant ROM: tROM :=(
--   	OP CODE   | RAM ADDR       |   N BIN       | N DEC  | Info
--		OP_PUSH   & ADDR_ZERO,
--		OP_PUSH   & ADDR_ZERO,
--		OP_PUSH   & ADDR_ONE,
--		OP_PUSH   & ADDR_ONE,
--		OP_ADD    & EMPTY_ADDR,
		OP_PUSHIN & ADDR_ZERO,
		OP_POPIN  & "000010",
		
		others => OP_HALT & "000000"
	);
	signal data: inst;
begin
	data <= ROM(conv_integer(ADDR));
	
	zbufs: process (RE, data)
	begin
		if (RE = '1') then
			DOUT <= data;
		else
			DOUT <= (others => 'Z');
		end if;
	end process;
end Beh_Stack;