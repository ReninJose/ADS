library ieee;
use ieee.std_logic_1164.all;

use work.project_pkg.all;


entity synchronizer is
	generic (
		input_width:	positive := 16
	);
	port (
		bin_in:	in	std_logic_vector(input_width - 1 downto 0);
		clk_1:	in std_logic;
		clk_2:	in std_logic;
		reset:	in std_logic;
		bin_out:	out	std_logic_vector(input_width - 1 downto 0)
	);
end entity synchronizer;

architecture rtl of synchronizer is
	signal	gray_output:	std_logic_vector(input_width - 1 downto 0);
	signal	sig_a:	std_logic_vector(input_width - 1 downto 0);
	signal	sig_b:	std_logic_vector(input_width - 1 downto 0);
	signal	sig_c:	std_logic_vector(input_width - 1 downto 0);
begin
	
	b2g: bin_to_gray
		generic map (
			input_width => input_width
		)
		port map(
			bin_in => bin_in,
			gray_out => gray_output
		);
		
	g2b: gray_to_bin
		generic map (
			input_width => input_width
		)
		port map(
			gray_in => sig_c,
			bin_out => bin_out
		);
		
	sync_a: process( clk_1, reset) is
	begin
		if reset = '0' then
			sig_a <= (others => '0');
		elsif rising_edge(clk_1) then
			sig_a <= gray_output;
		end if;	
	end process sync_a;

	sync_b: process( clk_2, reset) is
	begin
		if reset = '0' then
			sig_b <= (others => '0');
			sig_c <= (others => '0');
		elsif rising_edge(clk_2) then
			sig_b <= sig_a;
			sig_c <= sig_b;
		end if;		
	end process sync_b;
	
end architecture rtl;
