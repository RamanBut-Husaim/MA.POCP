library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use SortingGPR.all;

entity DPATH is
	port(
		EN: in std_logic;
		-- operation type
		OT: in std_logic_vector(2 downto 0);
		-- operand 1
		OP1: in std_logic_vector(7 downto 0);
		-- operand 2
		OP2: in std_logic_vector(7 downto 0);
		-- result
		RES: out std_logic_vector(7 downto 0);
		-- zero flag
		ZF: out std_logic;
		-- significant bit set flag
		SBF: out std_logic
		);
end DPATH;

architecture Beh_GPR of DPATH is
	signal res_g: std_logic_vector(7 downto 0);
	signal res_add: std_logic_vector(7 downto 0);
	signal res_sub: std_logic_vector (7 downto 0);
	signal res_xor: std_logic_vector (7 downto 0);
	signal t_sbf, t_zf: std_logic;
Begin
	res_add <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(OP1) + CONV_INTEGER(OP2), 8);
	res_sub <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(OP1) - CONV_INTEGER(OP2), 8);
	res_xor <= OP1 XOR OP2;
	
	REGA: process (EN, OT, OP1, res_add, res_sub, res_xor)
	begin
		if rising_edge(EN) then
			case OT is
				when OP_ADD => res_g <= res_add;
				when OP_SUB => res_g <= res_sub;
				when OP_XORIN => res_g <= res_xor;
				when others => null;
			end case;
		end if;
	end process;
	
	FLAGS: process(res_g)
	begin
		if res_g = (res_g'range => '0') then
            t_zf <= '1';
        else
            t_zf <= '0';
        end if;
		 
		if res_g(7) = '1' then
			t_sbf <= '1';
		else
			t_sbf <= '0';
		end if;
	end process;
	
	RES <= res_g;
	SBF <= t_sbf;
	ZF <= t_zf;
End Beh_GPR;