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
	
	constant ADDR_ONE: std_logic_vector(5 downto 0) := "001110";
	constant ADDR_ZERO: std_logic_vector(5 downto 0) := "001111";
	constant ADDR_LENGTH: std_logic_vector(5 downto 0) := "001010";
	constant ADDR_LENGTH_1: std_logic_vector(5 downto 0) := "001011";
	constant ADDR_I: std_logic_vector(5 downto 0) := "001100";
	constant ADDR_J: std_logic_vector(5 downto 0) := "001101";
	constant ADDR_TEMP1: std_logic_vector(5 downto 0) := "010000";
	constant ADDR_TEMP2: std_logic_vector(5 downto 0) := "010001";
	
	constant ROM: tROM :=(
--   	OP CODE   | RAM ADDRA       | RAM ADDRB       | RAM ADDRC       |   N BIN       | N DEC  | Info
		OP_ADD    & ADDR_ZERO       & ADDR_ZERO       & ADDR_I,		    -- 000001		| 001    | zero i
		OP_ADD    & ADDR_ZERO       & ADDR_ZERO       & ADDR_J,			-- 000010       | 002    | zero j
		
		
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
	