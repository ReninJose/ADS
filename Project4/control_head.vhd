library ieee;
use ieee.std_logic_1164.all;

use work.project_pkg.all;

entity control_head is
	generic(
		buffer_size:  positive:= 20
	);
	port(
		clk_10: 	in	std_logic;
		reset: 	in	std_logic;
		tail:		in	natural range 0 to buffer_size-1;
		
		data_out: 	out	natural range 0 to 2**12 - 1;
		head: 		out	natural range 0 to buffer_size-1;
		clk_1:		out	std_logic
	);
end entity control_head;

architecture rtl of control_head is
	component pll
		PORT
		(
			inclk0		: IN STD_LOGIC  := '0';
			c0		: OUT STD_LOGIC 
		);
	end component;

	signal soc, eoc: std_logic;
	signal pll_clk, clk_dft: std_logic;
begin
	-- drive 1 MHz clock outputs
	clk_1 <= clk_dft;
	
	pll0: pll
		port map (
			inclk0	=> clk_10,
			c0			=> pll_clk
		);
	
	adc: max10_adc
		port map(
			pll_clk	=> pll_clk,
			chsel		=> 0,
			soc		=> soc,
			tsen		=> '1',
			dout		=> data_out,
			eoc		=> eoc,
			clk_dft	=> clk_dft
		);
end architecture rtl
