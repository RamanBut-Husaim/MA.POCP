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
--          BIN |   DEC   | ADR BIN | ADR DEC | Meaninng
        "00000011", -- 3  | 000000  |     0   | a[0]
        "00000001", -- 1  | 000001  |     1   | a[1]
        "00000111", -- 7  | 000010  |     2   | a[2]
        "00010011", -- 19 | 000011  |     3   | a[3]
        "00000000", -- 0  | 000100  |     4   | [empty]
        "00000000", -- 0  | 000101  |     5   | [empty]
        "00000000", -- 0  | 000110  |     6   | [empty]
        "00000000", -- 0  | 000111  |     7   | [empty]
        "00000000", -- 0  | 001000  |     8   | [empty]
        "00000000", -- 0  | 001001  |     9   | [empty]
        "00000100", -- 4  | 001010  |    10   | array length
        "00000011", -- 3  | 001011  |    11   | outer loop length [array length - 1]
        "00000000", -- 0  | 001100  |    12   | i: outer loop index [address for array element] [for (int i = 0; i < outer loop index; ++i)]
        "00000000", -- 0  | 001101  |    13   | j: inner loop index [address for array element] [for (int j = i + 1; j < array length; ++j)]
        "00000001", -- 1  | 001110  |    14   | 1 for add
        "00000000", -- 0  | 001111  |    15   | 0 for initialization
        "00000000", -- 0  | 010000  |    16   | temp1
        "00000000", -- 0  | 010001  |    17   | temp2
        "00000000", -- 0  | 010010  |    18   | temp3
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
