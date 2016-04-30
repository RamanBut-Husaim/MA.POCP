library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;

entity SortManager is 
	port (
		CLK, RST, Start: in std_logic;
		Stop: out std_logic
	);
end SortManager;

architecture Beh_GPR of SortManager is
	component MROM is
		port (
			RE: in std_logic;
			ADDR: in std_logic_vector(5 downto 0);
			DOUT: out std_logic_vector(20 downto 0)
			);
	end component;
	
	component MRAM is
		port (
			RW: in std_logic;
			CLK: in std_logic;
			ADDR1: in std_logic_vector(5 downto 0);
			ADDR2: in std_logic_vector(5 downto 0);
			ADDRW: in std_logic_vector(5 downto 0);
			DWIN: in std_logic_vector (7 downto 0);
			D1OUT: out std_logic_vector (7 downto 0);
			D2OUT: out std_logic_vector (7 downto 0)
		);
	end component;
	
	component DPATH is
		port(
			EN: in std_logic;
			-- operation type
			OT: in std_logic_vector(2 downto 0);
			-- operand 1
			OP1 : in std_logic_vector(7 downto 0);
			-- operand 2
			OP2 : in std_logic_vector(7 downto 0);
			-- result
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
			ROM_dout: in std_logic_vector(20 downto 0);
			
			-- RAM
			RAM_rw: out std_logic;
			RAM_addr1: out std_logic_vector(5 downto 0);
			RAM_addr2: out std_logic_vector(5 downto 0);
			RAM_addrw: out std_logic_vector(5 downto 0);
			RAM_dwin: out std_logic_vector(7 downto 0);
			RAM_d1out: in std_logic_vector(7 downto 0);
			RAM_d2out: in std_logic_vector(7 downto 0);
			
			-- datapath
			DP_op1: out std_logic_vector(7 downto 0);
			DP_op2: out std_logic_vector(7 downto 0);
			DP_ot: out std_logic_vector(2 downto 0);
			DP_en: out std_logic;
			DP_res: in std_logic_vector(7 downto 0);
			DP_sbf: in std_logic;
			DP_zf: in std_logic
		);
	end component;
	
	signal rom_re: std_logic;
	signal rom_addr: std_logic_vector(5 downto 0);
	signal rom_dout: std_logic_vector(20 downto 0);
	signal ram_rw: std_logic;
	signal ram_addr1: std_logic_vector(5 downto 0);
	signal ram_addr2: std_logic_vector(5 downto 0);
	signal ram_addrw: std_logic_vector(5 downto 0);
	signal ram_dwin: std_logic_vector(7 downto 0);
	signal ram_d1out: std_logic_vector(7 downto 0);
	signal ram_d2out: std_logic_vector(7 downto 0);
	signal dp_op1: std_logic_vector(7 downto 0);
	signal dp_op2: std_logic_vector(7 downto 0);
	signal dp_ot: std_logic_vector(2 downto 0);
	signal dp_en: std_logic;
	signal dp_res: std_logic_vector(7 downto 0);
	signal dp_zf: std_logic;
	signal dp_sbf: std_logic;
begin
	UMRAM: entity MRAM (Beh_GPR) port map(
		RW => ram_rw,
		CLK => CLK,
		ADDR1 => ram_addr1,
		ADDR2 => ram_addr2,
		ADDRW => ram_addrw,
		DWIN => ram_dWin,
		D1OUT => ram_d1out,
		D2OUT => ram_d2out
	);
	UMROM: entity MROM (Beh_GPR) port map (
		RE => rom_re,
		ADDR => rom_addr,
		DOUT => rom_dout
	);
	UDPATH: DPATH port map(
		EN => dp_en,
		OT => dp_ot,
		OP1 => dp_op1,
		OP2 => dp_op2,
		RES => dp_res,
		ZF => dp_zf,
		SBF => dp_sbf
	);
	UCTRL1: CTRL1 port map(
		CLK => CLK,
		RST => RST,
		START => Start,
		STOP => STOP,
		ROM_RE => rom_re,
		ROM_ADDR => rom_addr,
		ROM_DOUT => rom_dout,
		RAM_RW => ram_rw,
		RAM_ADDR1 => ram_addr1,
		RAM_ADDR2 => ram_addr2,
		RAM_ADDRW => ram_addrw,
		RAM_DWIN => ram_dwin,
		RAM_D1OUT => ram_d1out,
		RAM_D2OUT => ram_d2out,
		DP_EN => dp_en,
		DP_OT => dp_ot,
		DP_OP1 => dp_op1,
		DP_OP2 => dp_op2,
		DP_RES => dp_res,
		DP_ZF => dp_zf,
		DP_SBF => dp_sbf
	);
end Beh_GPR;
