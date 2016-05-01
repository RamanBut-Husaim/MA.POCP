library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use SortingGPR.all;

entity MROM is 
	port (
		RE: in std_logic;
		ADDR: in std_logic_vector(5 downto 0);
		DOUT: out std_logic_vector(20 downto 0)
	);
end MROM;

architecture Beh_GPR of MROM is
	subtype inst is std_logic_vector(20 downto 0);
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
	constant ADDR_TEMP3: std_logic_vector(5 downto 0) := "010010";
	
	constant ROM: tROM :=(
--   	OP CODE   | RAM ADDRA       | RAM ADDRB       | RAM ADDRW       |   N BIN       | N DEC  | Info
		OP_ADD    & ADDR_ZERO       & ADDR_ZERO       & ADDR_I,		    -- 000000		| 000    | zero i
		OP_ADD    & ADDR_ZERO       & ADDR_ZERO       & ADDR_J,			-- 000001       | 001    | zero j
		-- Start: outer loop
		OP_SUB    & ADDR_LENGTH_1   & ADDR_I          & ADDR_TEMP1,     -- 000010       | 002    | m2: [Start outer loop]
		OP_JZ     & "010011"        & EMPTY_ADDR      & EMPTY_ADDR,     -- 000011       | 003    | jump to m1 [if i == length - 1 - finish outer loop]
		-- Start: inner loop
		OP_ADD    & ADDR_I          & ADDR_ONE        & ADDR_J,         -- 000100       | 004    | j = i + 1  
		OP_SUB    & ADDR_LENGTH     & ADDR_J          & ADDR_TEMP1,     -- 000101       | 005    | m4: [Start inner loop]
		OP_JZ     & "010000"        & EMPTY_ADDR      & EMPTY_ADDR,     -- 000110       | 006    | jump to m3
		
		OP_COPYINTO & ADDR_I        & EMPTY_ADDR      & ADDR_TEMP1,     -- 000111       | 007    | copy a[i] to temp1
		OP_COPYINTO & ADDR_J       	& EMPTY_ADDR      & ADDR_TEMP2,     -- 001000       | 008    | copy a[j] to temp2
		OP_SUB    &	ADDR_TEMP1      & ADDR_TEMP2      &	ADDR_TEMP3,     -- 001001       | 009    | a[i] - a[j]
		OP_JNSB   & "001101"        & EMPTY_ADDR      & EMPTY_ADDR,     -- 001010       | 010    | jump to m5
		-- Swap values
		OP_COPYTOIN & ADDR_TEMP1    & ADDR_J          & EMPTY_ADDR,     -- 001011       | 011    | copy temp1 (a[i]) to a[j]
		OP_COPYTOIN & ADDR_TEMP2    & ADDR_I          & EMPTY_ADDR,     -- 001100       | 012    | copy temp2 (a[j]) to a[i]
		
		OP_ADD    & ADDR_J          & ADDR_ONE        & ADDR_J,         -- 001101       | 013    | m5: j++
		OP_ADD    & ADDR_ZERO       & ADDR_ZERO		  & ADDR_ZERO,      -- 001110       | 014    |
		OP_JZ     & "000101"        & EMPTY_ADDR      & EMPTY_ADDR,		-- 001111       | 015    | jump to m4: end inner loop
		-- End: inner loop
			
		OP_ADD    & ADDR_I          & ADDR_ONE        & ADDR_I,         -- 010000       | 016    | m3: i++
		OP_ADD    & ADDR_ZERO       & ADDR_ZERO       & ADDR_ZERO,      -- 010001       | 017    |
		OP_JZ     & "000010"        & EMPTY_ADDR      & EMPTY_ADDR,     -- 010010       | 018    | jump to m2
		-- End: outer loop
		OP_ADD    & ADDR_ZERO       & ADDR_ZERO       & ADDR_TEMP1,     -- 010011       | 019    | m1	
		
		others => OP_HALT & "000000000000000000"
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
end Beh_GPR;
	