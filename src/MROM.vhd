library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use Sorting_Design.all;

entity MROM is 
	port (
		RE: in std_logic;
		ADR: in std_logic_vector(5 downto 0);
		DOUT: out std_logic_vector(9 downto 0)
		);
end MROM;

architecture Beh_Sorting of MROM is
	subtype inst is std_logic_vector(9 downto 0);
	type tROM is array (0 to 63) of inst;
	
	constant ADDR_ONE: std_logic_vector(5 downto 0) := "001110";
	constant ADDR_ZERO: std_logic_vector(5 downto 0) := "001111";
	constant ADDR_LENGTH: std_logic_vector(5 downto 0) := "001010";
	constant ADDR_LENGTH_1: std_logic_vector(5 downto 0) := "001011";
	constant ADDR_I: std_logic_vector(5 downto 0) := "001100";
	constant ADDR_J: std_logic_vector(5 downto 0) := "001101";
	constant ADDR_TEMP1: std_logic_vector(5 downto 0) := "001100";
	
	constant ROM: tROM :=(
--   	OP CODE   | RAM ADDR       |   N BIN       | N DEC  | Info
		OP_LOAD    & ADDR_ONE,
		OP_STOREIN & "000010",
--		OP_LOAD   & ADDR_ZERO,      -- 000000      | 000    | 
--		OP_STORE  & ADDR_I,         -- 000001	   | 001    |
--		OP_STORE  & ADDR_J,         -- 000010	   | 002    |
--		-- Start: outer loop
--		OP_LOAD   & ADDR_LENGTH_1,  -- 000011      | 003    | m2: [Start outer loop]
--		OP_SUB    & ADDR_I,         -- 000100      | 004    |
--		OP_JZ     & "011010",       -- 000101	   | 005	| jump to m1 [if i == length - 1 - finish outer loop]
--		-- Start: inner loop
--		OP_LOAD   & ADDR_I,		    -- 000110      | 006    | m4: [Start inner loop]
--		OP_ADD    & ADDR_ONE,       -- 000111      | 007    |
--		OP_STORE  & ADDR_J,         -- 001000	   | 008    |
--		OP_SUB    & ADDR_LENGTH,    -- 001001      | 009    |
--		OP_JZ     & "010101",       -- 001010      | 010    | jump to m3
--		
--		OP_LOADIN &	ADDR_J,			-- 001011      | 011    |
--		OP_STORE  & ADDR_TEMP1,		-- 001100      | 012    |
--		OP_LOADIN & ADDR_I,			-- 001101      | 013	|
--		OP_SUB    & ADDR_TEMP1,		-- 001110      | 014    |
--		OP_JNSB   &	"010000",	    -- 001111      | 015	| jump to m5
--		-- Swap values
--		
--		-- Ens swap
--		
--		
--		OP_LOAD   & ADDR_J,		    -- 010000      | 016	| m5
--		OP_ADD    & ADDR_ONE,	    -- 010001      | 017
--		OP_STORE  & ADDR_J,		    -- 010010      | 018
--		OP_LOAD   & ADDR_ZERO,	    -- 010011      | 019
--		OP_JZ     & "000110",       -- 010100      | 020    | go to m4: [End inner loop]
--		-- End: inner loop
--		OP_LOAD   & ADDR_I,         -- 010101      | 021    | m3: [Start i++] 
--		OP_ADD    & ADDR_ONE,       -- 010110      | 022    | 
--		OP_STORE  & ADDR_I,		    -- 010111      | 023	| [End i++]
--		OP_LOAD   & ADDR_ZERO,      -- 011000      | 024	|
--		OP_JZ     & "000011",       -- 011001      | 025    | go to m2
--		-- End: outer loop
--		OP_LOAD   & ADDR_I,         -- 011010      | 026    | m1
--		OP_STORE  & "010000",	    -- 011011      | 027    | store to temp1
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
	subtype inst is std_logic_vector(9 downto 0);
	type tROM is array (0 to 63) of inst;
	constant ROM: tROM :=(
--	OP_CODE | RAM ADR |  N Hex  | N DEC | instruction 
	"0000" & "000001", -- 000000 | 00 	|LOAD a[0]
	"0001" & "000110", -- 000001 | 01 	|STORE res
	"0011" & "000010", -- 000010 | 02 	|SUB a[1]
	"0110" & "000110", -- 000011 | 03 	|JNSB m1
	"0000" & "000010", -- 000100 | 04 	|LOAD a[1]
	"0001" & "000110", -- 000101 | 05 	|STORE res
	"0000" & "000110", -- 000110 | 06 	|LOAD res	: m1
	"0011" & "000011", -- 000111 | 07 	|SUB a[2]
	"0110" & "001011", -- 001000 | 08 	|JNSB m2
	"0000" & "000011", -- 001001 | 09 	|LOAD a[2]
	"0001" & "000110", -- 001010 | 10 	|STORE res
	"0000" & "000110", -- 001011 | 11 	|LOAD res	: m2
	"0011" & "000100", -- 001100 | 12 	|SUB a[3]
	"0110" & "010000", -- 001101 | 13 	|JNSB m3
	"0000" & "000100", -- 001110 | 14 	|LOAD a[3]
	"0001" & "000110", -- 001111 | 15 	|STORE res
	"0000" & "000110", -- 010000 | 16 	|LOAD res	: m3
	"0011" & "000101", -- 010001 | 17 	|SUB a[4]
	"0110" & "010101", -- 010010 | 18 	|JNSB m4
	"0000" & "000101", -- 010011 | 19 	|LOAD a[4]
	"0001" & "000110", -- 010100 | 20 	|STORE res
	"0000" & "000110", -- 010101 | 21 	|LOAD res	: m4
	"0101" & "000001",
	"0100" & "000000", -- 010110 | 22 	|HALT
	others => "0100" & "000000"
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