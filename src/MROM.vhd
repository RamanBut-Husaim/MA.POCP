library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use Sorting_Design.all;

entity MROM is 
	port (
		RE: in std_logic;
		ADR: in std_logic_vector(5 downto 0);
		DOUT: out std_logic_vector(8 downto 0)
		);
end MROM;

architecture Beh_Sorting of MROM is
	subtype inst is std_logic_vector(8 downto 0);
	type tROM is array (0 to 63) of inst;
	
	constant ADDR_ONE: std_logic_vector(5 downto 0) := "001110";
	constant ADDR_ZERO: std_logic_vector(5 downto 0) := "001111";
	constant ADDR_LENGTH: std_logic_vector(5 downto 0) := "001010";
	constant ADDR_LENGTH_1: std_logic_vector(5 downto 0) := "001011";
	constant ADDR_I: std_logic_vector(5 downto 0) := "001100";
	constant ADDR_J: std_logic_vector(5 downto 0) := "001101";
	
	constant ROM: tROM :=(
--   	OP CODE | RAM ADDR         | N BIN        | N DEC  | Info
		OP_LOAD  & ADDR_ZERO,      -- 000000      | 000    | 
		OP_STORE & ADDR_I,         -- 000001	  | 001    |
		OP_STORE & ADDR_J,         -- 000010	  | 002    |
		OP_LOAD  & ADDR_LENGTH_1,  -- 000011      | 003    | m2
		OP_SUB   & ADDR_I,         -- 000100      | 004    |
		OP_JZ    & "001011",       -- 000101	  | 005	   | jump to m1 [if i == length - 1 - finish outer loop]
		OP_LOAD  & ADDR_I,         -- 000110      | 006    | 
		OP_ADD   & ADDR_ONE,       -- 000111      | 007    | 
		OP_STORE & ADDR_I,		   -- 001000      | 008	   | i++
		OP_LOAD  & ADDR_ZERO,      -- 001001      | 009	   |
		OP_JZ    & "000011",       -- 001010      | 010    | go to m2
		OP_LOAD  & ADDR_I,         -- 001011      | 011    | m1
		OP_STORE & "010000",	   -- 001100      | 012    | store to temp1
		others => OP_HALT & "000000"
	);
	signal data: inst;
begin
	data <= ROM(conv_integer(adr));
	
	zbufs: process (RE, data)
	begin
		if (RE = '1') then
			DOUT <= data;
		else
			DOUT <= (others => 'Z');
		end if;
	end process;
end Beh_Sorting;

architecture Beh_Max of MROM is
	subtype inst is std_logic_vector(8 downto 0);
	type tROM is array (0 to 63) of inst;
	constant ROM: tROM :=(
--	OP_CODE | RAM ADR |  N Hex  | N DEC | instruction 
	"000" & "000001", -- 000000 | 00 	|LOAD a[0]
	"001" & "000110", -- 000001 | 01 	|STORE res
	"011" & "000010", -- 000010 | 02 	|SUB a[1]
	"110" & "000110", -- 000011 | 03 	|JNSB m1
	"000" & "000010", -- 000100 | 04 	|LOAD a[1]
	"001" & "000110", -- 000101 | 05 	|STORE res
	"000" & "000110", -- 000110 | 06 	|LOAD res	: m1
	"011" & "000011", -- 000111 | 07 	|SUB a[2]
	"110" & "001011", -- 001000 | 08 	|JNSB m2
	"000" & "000011", -- 001001 | 09 	|LOAD a[2]
	"001" & "000110", -- 001010 | 10 	|STORE res
	"000" & "000110", -- 001011 | 11 	|LOAD res	: m2
	"011" & "000100", -- 001100 | 12 	|SUB a[3]
	"110" & "010000", -- 001101 | 13 	|JNSB m3
	"000" & "000100", -- 001110 | 14 	|LOAD a[3]
	"001" & "000110", -- 001111 | 15 	|STORE res
	"000" & "000110", -- 010000 | 16 	|LOAD res	: m3
	"011" & "000101", -- 010001 | 17 	|SUB a[4]
	"110" & "010101", -- 010010 | 18 	|JNSB m4
	"000" & "000101", -- 010011 | 19 	|LOAD a[4]
	"001" & "000110", -- 010100 | 20 	|STORE res
	"000" & "000110", -- 010101 | 21 	|LOAD res	: m4
	"101" & "000001",
	"100" & "000000", -- 010110 | 22 	|HALT
	others => "100" & "000000"
	);
	signal data: inst;
begin
	data <= ROM(conv_integer(adr));
	
	zbufs: process (RE, data)
	begin
		if (RE = '1') then
			DOUT <= data;
		else
			DOUT <= (others => 'Z');
		end if;
	end process;
end Beh_Max;