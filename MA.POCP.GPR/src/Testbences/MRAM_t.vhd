library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity MRAM_T is
end MRAM_T;

architecture Beh of MRAM_T is
	component MRAM
		port (
			RW, CLK: in std_logic;
			ADDRA, ADDRB, ADDRC: in std_logic_vector(5 downto 0);
			DAOUT, DBOUT: out std_logic_vector(7 downto 0);
			DCIN: in std_logic_vector(7 downto 0)
		);
	end component;
	
	signal rw: std_logic := '0';
	signal clk: std_logic := '0';
	signal addra, addrb: std_logic_vector(5 downto 0) := "000000";
	signal addrc: std_logic_vector(5 downto 0) := "000001";
	signal daout, dbout: std_logic_vector(7 downto 0) := "00000000";
	signal dcin: std_logic_vector(7 downto 0) := "00000011";
	constant CLK_period: time := 10 ns;
begin
	UMRAM: MRAM port map(
		RW => rw,
		CLK => clk,
		ADDRA => addra,
		ADDRB => addrb,
		ADDRC => addrc,
		DAOUT => daout,
		DBOUT => dbout,
		DCIN => dcin
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
		
		addrc <= "000010";
		dcin <= "00000100";
		
		wait for 1 * CLK_PERIOD;
		
		addra <= "000001";
		addrb <= "000010";
		rw <= '1';
		
		wait for 1 * CLK_PERIOD;
		
		addrc <= "000000";
		dcin <= "00010000";
		rw <= '0';
		
		wait for 1 * CLK_PERIOD;
		
		wait for 100 * CLK_PERIOD;
		wait;
	end process;
end Beh;

