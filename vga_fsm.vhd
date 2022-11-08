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
		hsync <= do_horizontal_sync(current_point, vga_res)
		vsync <= do_vertical_sync(current_point, vga_res)
		point_valid <= point_visible(current_point, vga_res)
		current_point <= next_coordinate(current_point,vga_res)
	end process


end architecture fsm;
