library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use Sorting_Design.all;

entity MROM is
    port (
        RE: in std_logic;
        ADDR: in std_logic_vector(5 downto 0);
        DOUT: out std_logic_vector(9 downto 0)
    );
end MROM;

architecture Beh_Sorting of MROM is
    subtype inst is std_logic_vector(9 downto 0);
    type tROM is array (0 to 63) of inst;

    constant ADDR_ONE: std_logic_vector(5 downto 0) := "001110";
    constant ADDR_ZERO: std_logic_vector(5 downto 0) := "001111";
    constant ADDR_LENGTH: std_logic_vector(5 downto 0) := "001010";
    constant ADDR_LENGTH_1: std_logic_vector(5 downto 0) := "001011";
    constant ADDR_I: std_logic_vector(5 downto 0) := "001100";
    constant ADDR_J: std_logic_vector(5 downto 0) := "001101";
    constant ADDR_TEMP1: std_logic_vector(5 downto 0) := "010000";
    constant ADDR_TEMP2: std_logic_vector(5 downto 0) := "010001";

    constant ROM: tROM :=(
--      OP CODE   | RAM ADDR       |   N BIN       | N DEC  | Info
        OP_LOAD   & ADDR_ZERO,      -- 000000      | 000    |
        OP_STORE  & ADDR_I,         -- 000001      | 001    |
        OP_STORE  & ADDR_J,         -- 000010      | 002    |
        -- Start: outer loop
        OP_LOAD   & ADDR_LENGTH_1,  -- 000011      | 003    | m2: [Start outer loop]
        OP_SUB    & ADDR_I,         -- 000100      | 004    |
        OP_JZ     & "100100",       -- 000101      | 005    | jump to m1 [if i == length - 1 - finish outer loop]
        -- Start: inner loop
        OP_LOAD   & ADDR_I,         -- 000110      | 006    | j = i + 1
        OP_ADD    & ADDR_ONE,       -- 000111      | 007    |
        OP_STORE  & ADDR_J,         -- 001000      | 008    |
        OP_LOAD   & ADDR_LENGTH,    -- 001001      | 009    | m4: [Start inner loop]
        OP_SUB    & ADDR_J,         -- 001010      | 010    |
        OP_JZ     & "011111",       -- 001011      | 011    | jump to m3

        OP_LOADIN & ADDR_J,         -- 001100      | 012    | temp1 stores value for arr[j]
        OP_STORE  & ADDR_TEMP1,     -- 001101      | 013    |
        OP_LOADIN & ADDR_I,         -- 001110      | 014    |
        OP_STORE  & ADDR_TEMP2,     -- 001111      | 015    | temp2 stores value for arr[i]
        OP_SUB    & ADDR_TEMP1,     -- 010000      | 016    |
        OP_JNSB   & "010110",       -- 010001      | 017    | jump to m5
        -- Swap values
        OP_LOAD   & ADDR_TEMP1,     -- 010010      | 018    | here we swap temp1 and temp2
        OP_STORE  & ADDR_TEMP2,     -- 010011      | 019    |
        OP_LOADIN & ADDR_I,         -- 010100      | 020    |
        OP_STORE  & ADDR_TEMP1,     -- 010101      | 021    |
        -- End swap
        OP_LOAD   & ADDR_TEMP1,     -- 010110      | 022    | m5
        OP_STOREIN & ADDR_J,        -- 010111      | 023    | We load value from temp1 to arr[j] and temp2 to arr[i].
        OP_LOAD   & ADDR_TEMP2,     -- 011000      | 024    |
        OP_STOREIN & ADDR_I,        -- 011001      | 025    |

        OP_LOAD   & ADDR_J,         -- 011010      | 026    | [Start j++]
        OP_ADD    & ADDR_ONE,       -- 011011      | 027    |
        OP_STORE  & ADDR_J,         -- 011100      | 028    | [End j++]
        OP_LOAD   & ADDR_ZERO,      -- 011101      | 029    |
        OP_JZ     & "001001",       -- 011110      | 030    | go to m4: [End inner loop]
        -- End: inner loop
        OP_LOAD   & ADDR_I,         -- 011111      | 031    | m3: [Start i++]
        OP_ADD    & ADDR_ONE,       -- 100000      | 032    |
        OP_STORE  & ADDR_I,         -- 100001      | 033    | [End i++]
        OP_LOAD   & ADDR_ZERO,      -- 100010      | 034    |
        OP_JZ     & "000011",       -- 100011      | 035    | go to m2
        -- End: outer loop
        OP_LOAD   & ADDR_I,         -- 100100      | 036    | m1
        OP_STORE  & "010000",       -- 100101      | 037    | store to temp1
        others => OP_HALT & "000000"
    );
    signal data: inst;
begin
    data <= ROM(conv_integer(addr));

    zbufs: process (RE, data)
    begin
        if (RE = '1') then
            DOUT <= data;
        else
            DOUT <= (others => 'Z');
        end if;
    end process;
end Beh_Sorting;