library ieee;
use ieee.std_logic_1164.all;

library vga;
use vga.vga_data.all;

entity vga_fsm is
	generic (
		vga_res:	vga_timing := vga_res_default
	);
	port (
		vga_clock:		in	std_logic;
		reset:			in	std_logic;

		point:			out	coordinate;
		point_valid:	out	boolean;

		h_sync:			out	std_logic;
		v_sync:			out std_logic
	);
end entity vga_fsm;

architecture fsm of vga_fsm is
	-- any internal signals you may need
	signal current_point: coordinate;
begin
	-- implement methodology to drive outputs here
	-- use vga_data functions and types to make your life easier
	process(vga_clock)
	begin
		if rising_edge(vga_clock) then
			if reset = '0' then
				current_point <= make_coordinate(0,0);
			else
				current_point <= make_coordinate(current_point, vga_res);
			end if;
		end if;

		hsync <= do_horizontal_sync(current_point, vga_res);
		vsync <= do_vertical_sync(current_point, vga_res);
		point <= current_point;
		point_valid <= next_coordinate(current_point,vga_res);

	end process


end architecture fsm;
