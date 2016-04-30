library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use SortingGPR.all;

entity MROM is 
	port (
		RE: in std_logic;
		ADDR: in std_logic_vector(5 downto 0);
		DOUT: out std_logic_vector(17 downto 0)
	);
end MROM;

architecture Beh_GPR of MROM is
	subtype inst is std_logic_vector(17 downto 0);
	type tROM is array (0 to 63) of inst;
	
	constant ROM: tROM :=(
--   	OP CODE   | RAM ADDRA       | RAM ADDRB       | RAM ADDRC       |   N BIN       | N DEC  | Info
		
		others => OP_HALT & "000000000000000"
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
	