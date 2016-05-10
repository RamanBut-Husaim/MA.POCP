library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity LIFO_T is
end LIFO_T;

architecture Beh of LIFO_T is
    component LIFO is
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
            WB: in std_logic_vector(n-1 downto 0)
        );
    end component;

    signal CLK: std_logic := '0';
    signal WR: std_logic := '0';
    signal data_rb: std_logic_vector(7 downto 0);
    signal data_wb: std_logic_vector(7 downto 0);
    signal en: std_logic := '0';

    constant CLK_Period: time := 10 ns;
begin
    ULIFO: LIFO
    generic map(
        m => 2,
        n => 8
    )
    port map(
        EN => en,
        CLK => CLK,
        WR => WR,
        RB => data_rb,
        WB => data_wb
    );

    CLK_Process: process
    begin
        CLK <= '0';
        wait for CLK_Period/2;
        CLK <= '1';
        wait for CLK_Period/2;
    end process;

    MAIN: process
    begin
        wait for clk_period;
        en <= '1';
        WR <= '0';
        data_wb <= "00000001";
        wait for clk_period;
        data_wb <= "00000010";
        wait for clk_period;
        data_wb <= "00000011";
        wait for clk_period;
        WR <= '1';
        wait for clk_period;
        wait for clk_period;
        wait for clk_period;
        en <= '0';

        wait for clk_period;
        en <= '1';
        WR <= '0';
        data_wb <= "00001001";
        wait for clk_period;
        data_wb <= "00001010";
        wait for clk_period;
        data_wb <= "00001011";
        wait for clk_period;
        data_wb <= "00001100";
        wait for clk_period;
        data_wb <= "00001101";
        wait for clk_period;
        en <= '0';
        wait for clk_period;
        WR <= '1';
        en <= '1';
        wait for clk_period;
        wait for clk_period;
        wait for clk_period;
        en <= '0';

        wait;
    end process;
end Beh;