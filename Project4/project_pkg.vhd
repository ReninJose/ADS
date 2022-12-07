library ieee;
use ieee.std_logic_1164.all;

package project_pkg is
	component bin_to_gray is
		generic(
			input_width:			positive := 16
		);
		port(
			bin_in:		in		std_logic_vector(input_width -1 downto 0);
			gray_out:	out	std_logic_vector(input_width -1 downto 0)
		);
	end component bin_to_gray;

	component gray_to_bin is
		generic (
			input_width:		positive := 16
		);
		port (
			gray_in: in std_logic_vector(input_width - 1 downto 0);
			bin_out: out std_logic_vector(input_width - 1 downto 0)
		);
	end component gray_to_bin;
	
	component max10_adc is
		port (
			pll_clk:	in	std_logic;
			chsel:		in	natural range 0 to 2**5 - 1;
			soc:		in	std_logic;
			tsen:		in	std_logic;
			dout:		out	natural range 0 to 2**12 - 1;
			eoc:		out	std_logic;
			clk_dft:	out	std_logic
		);
	end component max10_adc;
	
end package project_pkg;