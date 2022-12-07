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
	
	component synchronizer is
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
	end component synchronizer;
	
	component control_head is
		generic(
			buffer_size:  positive:= 20
		);
		port(
			clk_10: 	in	std_logic;
			reset: 	in	std_logic;
			tail:		in	natural range 0 to buffer_size-1;
			
			data_out: 	out	natural range 0 to 2**12 - 1;
			head: 		out	natural range 0 to buffer_size-1;
			write_en:	out	std_logic;
			clk_1:		out	std_logic
		);
	end component control_head;
	
	component ram_buffer is

		generic 
		(
			DATA_WIDTH : natural := 8;
			ADDR_WIDTH : natural := 6
		);

		port 
		(
			clk_a	: in std_logic;
			clk_b	: in std_logic;
			addr_a	: in natural range 0 to 2**ADDR_WIDTH - 1;
			addr_b	: in natural range 0 to 2**ADDR_WIDTH - 1;
			data_a	: in std_logic_vector((DATA_WIDTH-1) downto 0);
			data_b	: in std_logic_vector((DATA_WIDTH-1) downto 0);
			we_a	: in std_logic := '1';
			we_b	: in std_logic := '1';
			q_a		: out std_logic_vector((DATA_WIDTH -1) downto 0);
			q_b		: out std_logic_vector((DATA_WIDTH -1) downto 0)
		);

	end component ram_buffer;
	
	component control_tail is
		generic(
			buffer_size:  positive:= 20
		);
		port(
			clock_50: 	in	std_logic;
			reset: 	in	std_logic;
			head:		in	natural range 0 to buffer_size-1;
			
			tail: 	out	natural range 0 to buffer_size-1
		);
	end component control_tail;
		
end package project_pkg;