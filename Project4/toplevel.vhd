library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.project_pkg.all;
use work.seven_segment_pkg.all;

entity toplevel is
	generic (
		address_width:	positive	:=  5
	);
	port(
		clock_10:	in std_logic;
		clock_50:	in std_logic;
		reset:		in	std_logic;
		
		hex_digits:	out seven_segment_output
	);
end entity toplevel;

architecture top of toplevel is

	signal clock_1: std_logic;

	signal head_50, head_1: natural range 0 to 2**address_width - 1;
	signal tail_50, tail_1: natural range 0 to 2**address_width - 1;
	
	signal adc_data_out: natural range 0 to 2**12 - 1;
	signal write_en: std_logic;
	
	signal ram_data_out: std_logic_vector(23 downto 0);
	
	signal tail_1_v, head_50_v: std_logic_vector(address_width - 1 downto 0);
begin

	drive_outs: for i in 0 to 5 generate
		hex_digits(i) <= get_hex_digit(to_integer(unsigned(ram_data_out(4*i + 3 downto 4*i))));
	end generate drive_outs;

	-- head control unit
	head_control: control_head
		generic map(
			buffer_size	=> 2**address_width
		)
		port map(
			clk_10		=> clock_10,
			reset			=> reset,
			tail 			=> tail_1,
			
			data_out		=> adc_data_out,
			head			=> head_1,
			write_en		=> write_en,
			clk_1			=> clock_1
		);
	
	-- tail control unit
	tail_control: control_tail
		generic map(
			buffer_size => 2**address_width
		)
		port map(
			clock_50	=> clock_50,
			reset		=> reset,
			head		=> head_50,
			
			tail		=> tail_50
		);
	
	-- 50 to 10 synchronizer
	cross50_10: synchronizer
		generic map(
			input_width => address_width
		)
		port map(
			bin_in 	=> std_logic_vector(to_unsigned(tail_50, address_width)),	
			clk_1 	=> clock_50,
			clk_2 	=> clock_1,
			reset  	=> reset,
			bin_out	=> tail_1_v		-- go back here later
		);
	tail_1 <= to_integer(unsigned(tail_1_v));
	
	-- 10 to 50 synchronizer
	cross10_50: synchronizer
		generic map(
			input_width => address_width
		)
		port map(
			bin_in 	=> std_logic_vector(to_unsigned(head_1, address_width)),
			clk_1 	=> clock_1,
			clk_2 	=> clock_50,
			reset  	=> reset,
			bin_out	=> head_50_v		-- go back here later
		);
	head_50 <= to_integer(unsigned(head_50_v));
	
	-- buffer for RAM
	buffer_ram: ram_buffer
		generic map(
			DATA_WIDTH => 12,
			ADDR_WIDTH => address_width
		)
		port map(
			clk_a		=> clock_50,
			clk_b		=> clock_1,
			addr_a	=> tail_50,
			addr_b	=> head_1,
			data_a	=> (others => '0'),
			data_b	=> std_logic_vector(to_unsigned(adc_data_out, 12)),
			we_a		=> '0',
			we_b		=> write_en,
			
			q_a		=> ram_data_out(11 downto 0),
			q_b		=> open
		);
		ram_data_out(23 downto 12) <= (others => '0');

end architecture top;