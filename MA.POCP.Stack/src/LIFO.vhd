library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity LIFO is
	generic(
		-- address bus
		m: integer := 2;
		-- data bus
		n: integer := 2
	);
	port (
		EN: in std_logic;
		-- synchronization
		CLK: in std_logic;
		-- write/read operation type
		WR: in std_logic;
		-- read data bus
		RB: out std_logic_vector(n-1 downto 0);
		-- write data bus
		WB:	in std_logic_vector(n-1 downto 0)
	);
end LIFO;

architecture Beh of LIFO is
	-- word type
	subtype word is std_logic_vector (n-1 downto 0);
	-- storage
	type tRam is array (0 to 2**m - 1) of word;
	
	signal sRAM: tRam;
	signal head: integer := 0;
	signal data_rb: std_logic_vector(n-1 downto 0);
	signal data_wb: std_logic_vector(n-1 downto 0); 
Begin
	SH: process (CLK)
	begin
		if (EN = '1') then
			if rising_edge(CLK) then
				if (WR = '0') then
					head <= head + 1;
				elsif (WR = '1') then
					head <= head - 1;
				end if;
			end if;
		end if;
	end process;
	
	data_wb <= WB;
	
	WRP: process (CLK, head, data_wb)
	begin
		if (EN = '1') then
			if rising_edge(CLK) then
				if WR = '0' then
					sRAM(head) <= data_wb;
				end if;
			end if;
		end if;
	end process;
	
	RDP: process(CLK, head)
	begin
		if (EN = '1') then
			if rising_edge(CLK) then
				if WR = '1' then
					data_rb <= sRAM (head - 1);
				end if;
			end if;
		end if;
	end process;
	
	RB <= data_rb;
end Beh;