library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity SortManager_t is
end SortManager_t;

architecture Beh_GPR of SortManager_t is
	component SortManager
		port (
			CLK, RST, Start: in std_logic;
			Stop: out std_logic
		);
	end component;
	
	signal clk: std_logic := '0';
	signal rst: std_logic := '0';
	signal start: std_logic := '0';
	signal stop: std_logic := '0';
	constant CLK_period: time := 10 ns;
begin
	USORTMANAGER: SortManager port map (
		CLK => clk,
		RST => rst,
		START => start,
		STOP => stop
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
		rst <= '1';
		wait for 1 * CLK_PERIOD;
		rst <= '0';
		start <= '1';
		wait for 100 * CLK_PERIOD;
		wait;
	end process;
end Beh_GPR;