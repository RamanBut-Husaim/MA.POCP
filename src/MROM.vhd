library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;

-- LOAD - 000
-- STORE - 001
-- ADD - 010
-- SUB - 011
-- HALT - 100
-- JNZ - 101
-- JNSB - 110

entity MROM is 
	port (
		RE: in std_logic;
		ADR: in std_logic_vector(5 downto 0);
		DOUT: out std_logic_vector(8 downto 0)
		);
end MROM;

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