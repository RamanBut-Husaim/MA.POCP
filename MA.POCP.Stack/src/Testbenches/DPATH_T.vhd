library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use SortingStack.all;

entity DPATH_T is
end DPATH_T;

architecture Beh of DPATH_T is
    component DPATH
      port(
        EN: in std_logic;
        -- synchronization
        CLK: in std_logic;
        -- operation type
        OT: in std_logic_vector(3 downto 0);
        -- operand
        OP: in std_logic_vector(7 downto 0);
        -- result
        RES: out std_logic_vector(7 downto 0);
        -- zero flag
        ZF: out std_logic;
        -- significant bit set flag
        SBF: out std_logic;
        -- stop - the processing is finished
        Stop: out std_logic
    );
    end component;

    signal i_en: std_logic := '0';
    signal CLK: std_logic;
    signal i_ot: std_logic_vector(3 downto 0) := "0110";
    signal i_op: std_logic_vector(7 downto 0) := "00000001";
    signal i_res: std_logic_vector(7 downto 0);
    signal i_zf: std_logic;
    signal i_sbf: std_logic;
    signal i_stop: std_logic;

    constant CLK_Period: time := 10 ns;
begin
    UDPATH: DPATH
    port map(
        EN => i_en,
        CLK => CLK,
        OT => i_ot,
        OP => i_op,
        RES => i_res,
        ZF => i_zf,
        SBF => i_sbf,
        STOP => i_stop
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

        i_en <= '1';
        wait for clk_period;
        i_en <= '0';
        wait for clk_period;
        wait for clk_period;
        wait for clk_period;

        i_op <= "00000010";
        i_en <= '1';
        wait for clk_period;
        i_en <= '0';

        wait for clk_period;
        wait for clk_period;
        wait for clk_period;

        i_op <= "00000000";
        i_ot <= OP_ADD;
        i_en <= '1';
        wait for clk_period;
        i_en <= '0';

        wait for clk_period;
        wait for clk_period;
        wait for clk_period;
        wait for clk_period;
        wait for clk_period;
        wait for clk_period;

        i_ot <= OP_POP;
        i_en <= '1';
        wait for clk_period;
        i_en <= '0';

        wait for clk_period;

        wait;
    end process;
end Beh;