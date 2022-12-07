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
		write_en:	out	std_logic;
		clk_1:		out	std_logic
	);
end entity control_head;

architecture rtl of control_head is

	function can_advance_head (
			head_pointer:	in	natural range 0 to buffer_size - 1;
			tail_pointer:	in	natural range 0 to buffer_size - 1
		) return boolean
	is
	begin
		if head > tail and not (head = buffer_size - 1 and tail = 0) then
			return true;
		elsif tail > head and (tail - head) > 1 then
			return true;
		end if;
		return false;
	end function can_advance_head;

	type state_type is (start, wait_eoc, wait_buffer, store);
	signal state, nexT_state: state_type:= start;
	
	component pll
		PORT
		(
			inclk0		: IN STD_LOGIC  := '0';
			c0		: OUT STD_LOGIC 
		);
	end component;

	signal soc, eoc: std_logic;
	signal pll_clk, clk_dft: std_logic;
	
	signal head_ptr: natural range 0 to buffer_size - 1;
begin

	-- drive head pointer output
	head <= head_ptr;

	transition_function: process(state, eoc, head_ptr, tail) is
	begin
		case state is
		
			when start => 
						next_state <= wait_eoc;
						
			when wait_eoc =>
						if eoc = '1' then
							next_state <= wait_buffer;
						else
							next_state <= wait_eoc;
						end if;
						
			when wait_buffer => 
						if can_advance_head(head_ptr, tail) then
							next_state <= store;
						else
							next_state <= wait_buffer;
						end if;
						
			when store => 
						next_state <= start;
						
		end case;
	end process transition_function;
	
	output_function: process(clk_dft, reset) is
	begin
		if reset = '0' then
			soc <= '0';
			write_en <= '0';
			head_ptr <= 0;
		elsif rising_edge(clk_dft) then
			if state = start or state = wait_eoc then
				soc <= '1';
			else
				soc <= '0';
			end if;
			
			if state = store then
				write_en <= '1';
				if head_ptr = buffer_size - 1 then
					head_ptr <= 0;
				else
					head_ptr <= head_ptr + 1;
				end if;
			else
				write_en <= '0';
			end if;
		end if;
	end process output_function;
	
	save_state: process(clk_dft, reset) is
	begin
		if reset = '0' then
			state <= start;
		elsif rising_edge(clk_dft) then
			state <= next_state;
		end if;
	end process save_state;

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
