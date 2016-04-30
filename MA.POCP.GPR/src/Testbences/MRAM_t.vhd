library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity MRAM_T is
end MRAM_T;

architecture Beh of MRAM_T is
	component MRAM
		port (
			RW, CLK: in std_logic;
			ADDR1, ADDR2, ADDRW: in std_logic_vector(5 downto 0);
			D1OUT, D2OUT: out std_logic_vector(7 downto 0);
			DWIN: in std_logic_vector(7 downto 0)
		);
	end component;
	
	signal rw: std_logic := '0';
	signal clk: std_logic := '0';
	signal addr1, addr2: std_logic_vector(5 downto 0) := "000000";
	signal addrw: std_logic_vector(5 downto 0) := "000001";
	signal d1out, d2out: std_logic_vector(7 downto 0) := "00000000";
	signal dwin: std_logic_vector(7 downto 0) := "00000011";
	constant CLK_period: time := 10 ns;
begin
	UMRAM: MRAM port map(
		RW => rw,
		CLK => clk,
		ADDR1 => addr1,
		ADDR2 => addr2,
		ADDRW => addrW,
		D1OUT => d1out,
		D2OUT => d2out,
		DWIN => dwin
	);
	
	CLK_Process: process
	begin
		CLK <= '0';
		wait for CLK_Period/2;
		CLK <= '1';
		wait for CLK_Period/2;
	end process;
	
	main: process
	begin
		wait for 1 * CLK_PERIOD;
		
		addrw <= "000010";
		dwin <= "00000100";
		
		wait for 1 * CLK_PERIOD;
		
		addr1 <= "000001";
		addr2 <= "000010";
		rw <= '1';
		
		wait for 1 * CLK_PERIOD;
		
		addrw <= "000000";
		dwin <= "00010000";
		rw <= '0';
		
		wait for 1 * CLK_PERIOD;
		
		wait for 100 * CLK_PERIOD;
		wait;
	end process;
end Beh;

