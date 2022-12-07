library ieee;
use ieee.std_logic_1164.all;

entity control_tail is
	generic(
		buffer_size:  positive:= 20
	);
	port(
		clock_50: 	in	std_logic;
		reset: 	in	std_logic;
		head:		in	natural range 0 to buffer_size-1;
		
		tail: 	out	natural range 0 to buffer_size-1
	);
end entity control_tail;

architecture rtl of control_tail is

	function can_advance_tail (
		head_pointer:	in natural range 0 to buffer_size - 1;
		tail_pointer: 	in natural range 0 to buffer_size - 1
	) return boolean
	is
	begin
		if head_pointer > tail_pointer and (head_pointer - tail_pointer > 1) then
			return true;
		elsif (tail_pointer > head_pointer) and not (tail_pointer = buffer_size - 1 and head_pointer = 0) then
			return true;
		end if;
		return false;
	end function can_advance_tail;
	
	type state_type is (wait_state, read_state);
	signal state, next_state: state_type := wait_state;
	signal tail_ptr:	natural range 0 to buffer_size - 1;
	
begin
	
		tail <= tail_ptr;
		
		transition_process: process(state, tail_ptr, head) is
		begin
			case state is
		
				when read_state =>
						next_state <= wait_state;
						
				when wait_state =>
						if can_advance_tail(head, tail_ptr) then
							next_state <= read_state;
						else
							next_state <= wait_state;
						end if;
			end case;
		end process transition_process;
		
	save_state: process(clock_50, reset) is
	begin
		if reset = '0' then
			state <= wait_state;
		elsif rising_edge(clock_50) then
			state <= next_state;
		end if;
	end process save_state;	

	output_function: process(clock_50, reset) is
	begin
		if reset = '0' then
			tail_ptr <= buffer_size - 1;
		elsif rising_edge(clock_50) then
			if state = read_state then
				if tail_ptr = buffer_size - 1 then
					tail_ptr <= 0;
				else
					tail_ptr <= tail_ptr + 1;
				end if;
			end if;
		end if;
	end process output_function;
	
end architecture rtl;


