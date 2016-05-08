library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use Sorting_Design.all;

entity CTRL1 is
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
		--datapath
		DP_op1: out std_logic_vector(7 downto 0);
		DP_ot: out std_logic_vector(3 downto 0);
		DP_en: out std_logic;
		DP_res: in std_logic_vector(7 downto 0);
		DP_sbf: in std_logic;
		DP_zf: in std_logic
		);
end CTRL1;

architecture Beh of CTRL1 is
	type states is (I, F, D, R, L, S, A, SB, H, JSB, RIN, LIN, JZ, SIN);
	-- I - idle
	-- F - fetch
	-- D - decode
	-- R - read
	-- L - load
	-- S - store
	-- A - add
	-- SB - sub
	-- H - halt
	-- JSB - jump if not sign bit set
	-- RIN - read after load indirect
    -- LIN - load indirect
	-- JZ -  jump if sign bit set
	-- SIN - store indirect
	signal nxt_state, cur_state: states;
	-- instruction register
	signal RI: std_logic_vector(9 downto 0);
	-- instruction counter
	signal IC: std_logic_vector(5 downto 0);
	-- operation type register
	signal RO: std_logic_vector(3 downto 0);
	-- memory address register
	signal RA: std_logic_vector(5 downto 0);
	-- data register
	signal RD: std_logic_vector(7 downto 0);
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
				elsif (RO = OP_STORE) then
					nxt_state <= S;
				elsif (RO = OP_JZ) then
					nxt_state <= JZ;
				elsif (RO = OP_JNSB) then
					nxt_state <= JSB;
				else
					nxt_state <= R;
			end if;
			when R => 
				if (RO = OP_LOAD) then 
					nxt_state <= L;
				elsif (RO = OP_ADD) then
					nxt_state <= A;
				elsif (RO = OP_SUB) then
					nxt_state <= SB;
				elsif (RO = OP_LOADIN) then
					nxt_state <= LIN;
				elsif (RO = OP_STOREIN) then
					nxt_state <= SIN;
				else
					nxt_state <= I;
			end if;
			when LIN => nxt_state <= RIN;
			when RIN => nxt_state <= L;
			when SIN => nxt_state <= S;
			when L | S | A | SB | JSB | JZ => nxt_state <= F;
			when H => nxt_state <= H;
			when others => nxt_state <= I;
		end case;
	end process;
	
	-- stop signal
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
			IC <= "000000";
		elsif falling_edge(CLK) then
			if (cur_state = D) then
				IC <= IC + 1;
			elsif (cur_state = JZ and DP_ZF = '1') then
				IC <= RA;
			elsif (cur_state = JSB and DP_SBF = '0') then
				IC <= RA;
			end if;
		end if;
	end process;
	
	ROM_addr <= IC;
	
	-- ROM read signal
	PROMREAD: process (nxt_state, cur_state)
	begin
		if (nxt_state = F or cur_state = F) then
			ROM_re <= '1';
		else
			ROM_re <= '0';
		end if;
	end process;
	
	-- read ROM value and put it into RI
	PROMDAT: process (RST, cur_state, ROM_dout)
	begin
		if (RST = '1') then
			RI <= "0000000000";
		elsif (cur_state = F) then
			RI <= ROM_dout;
		end if;
	end process;
	
	-- RO and RA control
	PRORA: process (RST, nxt_state, RI)
	begin
		if (RST = '1') then
			RO <= "0000";
			RA <= "000000";
		elsif (nxt_state = D) then
			RO <= RI (9 downto 6);
			RA <= RI (5 downto 0);
		elsif (nxt_state = LIN or nxt_state = SIN) then
			RA <= RD (5 downto 0);
		end if;
	end process;
	
	PRAMST: process (RA)
	begin
		if (cur_state /= JSB and cur_state /= JZ) then
			RAM_addr <= RA;
		end if;
	end process;
	
	-- RAM read/write control
	PRAMREAD: process (cur_state)
	begin
		if (cur_state = S) then
			RAM_rw <= '0';
		else
			RAM_rw <= '1';
		end if;
	end process;
	
	-- read value from RAM and put it into RD
	PRAMDAR: process (cur_state)
	begin
		if (cur_state = R or cur_state = RIN) then
			RD <= RAM_dout;
		end if;
	end process;
	
	-- move the value from DPATH to RAM input bus
	RAM_din <= DP_res;
	-- move the value from RD to datapath
	DP_op1 <= RD;
	-- move RO value to DP operation bus
	DP_ot <= RO;
	
	paddsuben: process (cur_state)
	begin
		if (cur_state = A or cur_state = SB or cur_state = L) then
			DP_en <= '1';
		else
			DP_en <= '0';
		end if;
	end process;
end Beh;