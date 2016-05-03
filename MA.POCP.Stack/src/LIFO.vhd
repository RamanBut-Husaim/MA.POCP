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
	
	constant Limit: integer := 2 ** m -1;
Begin
	SH: process (CLK)
	begin
		if rising_edge(CLK) then
			if (WR = '0') then
				if (head <= Limit) then
					head <= head + 1;
				end if;
			elsif (WR = '1') then
				if (head > 0) then
					head <= head - 1;
				end if;
			end if;
		end if;
	end process;
	
	data_wb <= WB;
	
	WRP: process (head)
	begin
		if rising_edge(CLK) then
			if WR = '0' then
				if (head > 0 and head <= Limit + 1) then 
					sRAM(head - 1) <= data_wb;
				end if;
			end if;
		end if;
	end process;
	
	RDP: process(head)
	begin
		if rising_edge(CLK) then
			if WR = '1' then
				if (head >= 0 and head <= Limit) then
					data_rb <= sRAM (head);
				else
					data_rb <= (others => 'Z');
				end if;
			else
				data_rb <= (others => 'Z');
			end if;
		end if;
	end process;
	
	RB <= data_rb;
end Beh;