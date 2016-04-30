library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;

entity MRAM is
	port(
		-- 0 - write; 1 - read
		RW: in std_logic; 
		CLK: in std_logic;
		-- address for the first operand
		ADDR1: in std_logic_vector(5 downto 0);
		-- address for the second operand
		ADDR2: in std_logic_vector(5 downto 0);
		-- address to write
		ADDRW: in std_logic_vector(5 downto 0);
		-- first operand
		D1OUT: out std_logic_vector(7 downto 0);
		-- second operand
		D2OUT: out std_logic_vector(7 downto 0);
		-- data to write
		DWIN: in std_logic_vector(7 downto 0)
	);
end MRAM;

architecture Beh_GPR of MRAM is
	subtype byte is std_logic_vector(7 downto 0);
	type tRAM is array (0 to 63) of byte;
	signal RAM: tRAM:= (
--        BIN |	DEC   | ADR BIN | ADR DEC | Meaninng
		others => "00000000"
	);
	
	signal data_win: std_logic_vector(7 downto 0);
	signal data_1out: std_logic_vector(7 downto 0);
	signal data_2out: std_logic_vector(7 downto 0);
Begin
	data_win <= DWIN;
	
	WRITE: process(CLK)
	begin
		if (rising_edge(CLK)) then
			if (RW = '0') then
				RAM(conv_integer(ADDRW)) <= data_win;
			end if;
		end if;
	end process;
	
	data_1out <= RAM (conv_integer(ADDR1));
	data_2out <= RAM (conv_integer(ADDR2));
	
	READ: process(CLK)
	begin
		if (rising_edge(CLK)) then
			if (RW = '1') then
				D1OUT <= data_1out;
				D2OUT <= data_2out;
			else
				D1OUT <= (others => 'Z');
				D2OUT <= (others => 'Z');
			end if; 
		end if;
	end process;
End Beh_GPR;
