library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity SortManager is
    port (
        CLK, RST, Start: in std_logic;
        Stop: out std_logic
    );
end SortManager;

architecture Beh of SortManager is
    component MROM is
        port (
            RE: in std_logic;
            ADDR: in std_logic_vector(5 downto 0);
            DOUT: out std_logic_vector(9 downto 0)
        );
    end component;

    component MRAM is
        port (
            CLK: in std_logic;
            RW: in std_logic;
            ADDR: in std_logic_vector(5 downto 0);
            DIN: in std_logic_vector (7 downto 0);
            DOUT: out std_logic_vector (7 downto 0)
        );
    end component;

    component DPATH is
        port(
            EN: in std_logic;
            -- operation type
            OT: in std_logic_vector(3 downto 0);
            -- operand
            OP1 : in std_logic_vector(7 downto 0);
            RES: out std_logic_vector(7 downto 0);
            -- zero flag
            ZF: out std_logic;
            -- significant bit set flag
            SBF: out std_logic
        );
    end component;

    component CTRL1 is
        port(
            CLK, RST, Start: in std_logic;
            Stop: out std_logic;

            -- ROM
            ROM_re: out std_logic;
            ROM_addr: out std_logic_vector(5 downto 0);
            ROM_dout: in std_logic_vector(9 downto 0);

            -- RAM
            RAM_rw: out std_logic;
            RAM_addr: out std_logic_vector(5 downto 0);
            RAM_din: out std_logic_vector(7 downto 0);
            RAM_dout: in std_logic_vector(7 downto 0);

            -- datapath
            DP_op1: out std_logic_vector(7 downto 0);
            DP_ot: out std_logic_vector(3 downto 0);
            DP_en: out std_logic;
            DP_res: in std_logic_vector(7 downto 0);
            DP_zf: in std_logic;
            DP_sbf: in std_logic
        );
    end component;

    signal rom_re: std_logic;
    signal rom_addr: std_logic_vector(5 downto 0);
    signal rom_dout: std_logic_vector(9 downto 0);
    signal ram_rw: std_logic;
    signal ram_addr: std_logic_vector(5 downto 0);
    signal ram_din: std_logic_vector(7 downto 0);
    signal ram_dout: std_logic_vector(7 downto 0);
    signal dp_op1: std_logic_vector(7 downto 0);
    signal dp_ot: std_logic_vector(3 downto 0);
    signal dp_en: std_logic;
    signal dp_res: std_logic_vector(7 downto 0);
    signal dp_zf: std_logic;
    signal dp_sbf: std_logic;
begin
    UMRAM: MRAM 
        port map(
            CLK => CLK,
            RW => ram_rw,
            ADDR => ram_addr,
            DIN => ram_din,
            DOUT => ram_dout
        );
    UMROM: MROM 
        port map (
            RE => rom_re,
            ADDR => rom_addr,
            DOUT => rom_dout
        );
    UDPATH: DPATH 
        port map(
            EN => dp_en,
            OT => dp_ot,
            OP1 => dp_op1,
            RES => dp_res,
            ZF => dp_zf,
            SBF => dp_sbf
        );
    UCTRL1: CTRL1 
        port map(
            CLK => CLK,
            RST => RST,
            START => Start,
            STOP => STOP,
            ROM_RE => rom_re,
            ROM_ADDR => rom_addr,
            ROM_DOUT => rom_dout,
            RAM_RW => ram_rw,
            RAM_ADDR => ram_addr,
            RAM_DIN => ram_din,
            RAM_DOUT => ram_dout,
            DP_EN => dp_en,
            DP_OT => dp_ot,
            DP_OP1 => dp_op1,
            DP_RES => dp_res,
            DP_ZF => dp_zf,
            DP_SBF => dp_sbf
        );
end Beh;
