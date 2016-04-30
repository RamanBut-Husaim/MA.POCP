library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use SortingGPR.all;

entity CTRL1 is
	port(
		CLK, RST, Start: in std_logic;
		Stop: out std_logic;
		
		-- ROM
		ROM_re: out std_logic;
		ROM_addr: out std_logic_vector(5 downto 0);
		ROM_dout: in std_logic_vector(20 downto 0);
		
		-- RAM
		RAM_rw: out std_logic;
		RAM_addr1: out std_logic_vector(5 downto 0);
		RAM_addr2: out std_logic_vector(5 downto 0);
		RAM_addrw: out std_logic_vector(5 downto 0);
		RAM_dwin: out std_logic_vector(7 downto 0);
		RAM_d1out: in std_logic_vector(7 downto 0);
		RAM_d2out: in std_logic_vector(7 downto 0);
		
		--datapath
		DP_op1: out std_logic_vector(7 downto 0);
		DP_op2: out std_logic_vector(7 downto 0);
		DP_ot: out std_logic_vector(2 downto 0);
		DP_en: out std_logic;
		DP_res: in std_logic_vector(7 downto 0);
		DP_sbf: in std_logic;
		DP_zf: in std_logic
	);
end CTRL1;

architecture Beh_GPR of CTRL1 is
	type states is (I, F, D, R, W, A, SB, H, JSB, RIN, LIN, XIN, JZ);
	-- I - idle
	-- F - fetch
	-- D - decode
	-- R - read
	-- W - write
	-- A - add
	-- SB - sub
	-- H - halt
	-- JSB - jump if not sign bit set
	-- RIN - read after load indirect
    -- LIN - load indirect
	-- XIN - xor indirect
	-- JZ -  jump if sign bit set
	signal nxt_state, cur_state: states;
	-- instruction register
	signal RI: std_logic_vector(20 downto 0);
	-- instruction counter
	signal IC: std_logic_vector(5 downto 0);
	-- operation type register
	signal RO: std_logic_vector(2 downto 0);
	-- memory address register for the first operand
	signal RA_1: std_logic_vector(5 downto 0);
	-- memory address register for the second operand
	signal RA_2: std_logic_vector(5 downto 0);
	-- memory address register for the result
	signal RA_W: std_logic_vector(5 downto 0);
	-- data register for the first operand
	signal RD_1: std_logic_vector(7 downto 0);
	-- data register for the second operand
	signal RD_2: std_logic_vector(7 downto 0);
	-- data register for the result
	signal RD_W: std_logic_vector(7 downto 0);
begin
	-- synchronous memory
	FSM: process(CLK, RST, nxt_state)
	begin
		if (RST = '1') then
			cur_state <= I;
		elsif rising_edge(CLK) then
			cur_state <= nxt_state;
		end if;
	end process;
	
	-- Next state
	COMB: process(cur_state, start, RO)
	begin
		case cur_state is 
			when I => 
				if (start = '1') then 
					nxt_state <= F;
				else
					nxt_state <= I;
				end if;
			when F => nxt_state <= D;
			when D => 
				if (RO = OP_HALT) then
					nxt_state <= H;
				elsif (RO = OP_JZ) then
					nxt_state <= JZ;
				elsif (RO = OP_JNSB) then
					nxt_state <= JSB;
				else
					nxt_state <= R;
				end if;
			when R => 
				if (RO = OP_ADD) then
					nxt_state <= A;
				elsif (RO = OP_SUB) then
					nxt_state <= SB;
				elsif (RO = OP_XORIN) then
					nxt_state <= LIN;
				else
					nxt_state <= I;
				end if;
			when LIN => nxt_state <= RIN;
			when RIN => nxt_state <= XIN;
			when A | SB | JSB | JZ | XIN => nxt_state <= W;
			when W => nxt_state <= F;
			when H => nxt_state <= H;
			when others => nxt_state <= I;
		end case;
	end process;
	
	-- stop signal handler
	PSTOP: process (cur_state)
	begin
		if (cur_state = H) then
			stop <= '1';
		else
			stop <= '0';
		end if;
	end process;
	
	-- instruction counter
	PMC: process (CLK, RST, cur_state)
	begin
		if (RST = '1') then
			IC <= (others => '0');
		elsif falling_edge(CLK) then
			if (cur_state = D) then
				IC <= IC + 1;
			elsif (cur_state = JZ and DP_ZF = '1') then
				IC <= RA_1;
			elsif (cur_state = JSB and DP_SBF = '0') then
				IC <= RA_1;
			end if;
		end if;
	end process;
	
	ROM_addr <= IC;
	
	-- reading from ROM
	PROMREAD: process (nxt_state, cur_state)
	begin
		if (nxt_state = F or cur_state = F) then
			ROM_re <= '1';
		else
			ROM_re <= '0';
		end if;
	end process;
	
	-- reading the instruction from ROM and put it into RI
	PROMDAT: process (RST, cur_state, ROM_dout)
	begin
		if (RST = '1') then
			RI <= (others => '0');
		elsif (cur_state = F) then
			RI <= ROM_dout;
		end if;
	end process;
	
	-- fill RO and RA_1, RA_2, RA_W registers
	PRORA: process (RST, nxt_state, RI)
	begin
		if (RST = '1') then
			RO <= (others => '0');
			RA_1 <= (others => '0');
			RA_2 <= (others => '0');
			RA_W <= (others => '0');
		elsif (nxt_state = D) then
			RO <= RI (20 downto 18);
			RA_1 <= RI (17 downto 12);
			RA_2 <= RI (11 downto 6);
			RA_W <= RI (5 downto 0);
		elsif (nxt_state = LIN) then
			RA_1 <= RD_1 (5 downto 0);
			RA_2 <= RD_2 (5 downto 0);
			RA_W <= RD_1 (5 downto 0);
		end if;
	end process;
	
	PRAMST: process (RA_1, RA_2, RA_W)
	begin
		if (cur_state /= JSB and cur_state /= JZ) then
			RAM_addr1 <= RA_1;
			RAM_addr2 <= RA_2;
			RAM_addrw <= RA_W;
		end if;
	end process;
	
	-- control read/write signal for RAM
	PRAMREAD: process (cur_state)
	begin
		if (cur_state = W) then
			RAM_rw <= '0';
		else
			RAM_rw <= '1';
		end if;
	end process;
	
	-- read values from RAM and store them in RD_1 and RD_2 registers
	PRAMDAR: process (cur_state)
	begin
		if (cur_state = R or cur_state = RIN) then
			RD_1 <= RAM_d1out;
			RD_2 <= RAM_d2out;
		end if;
	end process;
	
	-- pass the value from data path to RAM data bus
	RAM_dwin <= DP_res;
	-- pass the value from RD_1 register to the data path first operand
	DP_op1 <= RD_1;
	-- pass the value from RD_2 register to the data path second operand
	DP_op2 <= RD_2;
	-- pass the value from RO register to the data path operation type
	DP_ot <= RO;
	
	paddsuben: process (cur_state)
	begin
		if (cur_state = A or cur_state = SB or cur_state = XIN) then
			DP_en <= '1';
		else
			DP_en <= '0';
		end if;
	end process;
	
end Beh_GPR;