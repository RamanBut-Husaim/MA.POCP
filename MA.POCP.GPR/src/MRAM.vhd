library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;

entity MRAM is
	port(
		RW: in std_logic; -- 0 - write; 1 - read
		CLK: in std_logic;
		ADDRA: in std_logic_vector(5 downto 0);
		ADDRB: in std_logic_vector(5 downto 0);
		ADDRC: in std_logic_vector(5 downto 0);
		DAOUT: out std_logic_vector(7 downto 0);
		DBOUT: out std_logic_vector(7 downto 0);
		DCIN: in std_logic_vector(7 downto 0)
	);
end MRAM;

architecture Beh_GPR of MRAM is
	subtype byte is std_logic_vector(7 downto 0);
	type tRAM is array (0 to 63) of byte;
	signal RAM: tRAM:= (
--        BIN |	DEC   | ADR BIN | ADR DEC | Meaninng
		others => "00000000"
	);
	
	signal data_cin: std_logic_vector(7 downto 0);
	signal data_aout: std_logic_vector(7 downto 0);
	signal data_bout: std_logic_vector(7 downto 0);
Begin
	data_cin <= DCIN;
	
	WRITE: process(CLK)
	begin
		if (rising_edge(CLK)) then
			if (RW = '0') then
				RAM(conv_integer(ADDRC)) <= data_cin;
			end if;
		end if;
	end process;
	
	data_aout <= RAM (conv_integer(ADDRA));
	data_bout <= RAM (conv_integer(ADDRB));
	
	READ: process(CLK)
	begin
		if (rising_edge(CLK)) then
			if (RW = '1') then
				DAOUT <= data_aout;
				DBOUT <= data_bout;
			else
				DAOUT <= (others => 'Z');
				DBOUT <= (others => 'Z');
			end if; 
		end if;
	end process;
End Beh_GPR;
