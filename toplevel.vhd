library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library vga;
use vga.vga_data.all;

library ads;
use ads.ads_fixed.all;
use ads.ads_complex_pkg.all;

use work.pipeline_pkg.pipeline;

entity toplevel is
	generic (
		vga_res: vga_timing := vga_res_default;
		threshold: ads_sfixed := to_ads_sfixed(4);
		pipeline_stages: positive := 16
	);
	port (
		clock:	in		std_logic;
		reset:	in		std_logic;
		
		red:		out	std_logic_vector(3 downto 0);
		green:	out	std_logic_vector(3 downto 0);
		blue:		out	std_logic_vector(3 downto 0);
		
		h_sync:	out	std_logic;
		v_sync:	out	std_logic
	);
end entity toplevel;

architecture top of toplevel is

	component pll
		port (
			inclk0:	in STD_LOGIC  := '0';
			c0: 		out STD_LOGIC 
		);
	end component;

	component vga_fsm is
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
	end component vga_fsm;
	
	signal point_valid: boolean;
	signal system_clock: std_logic;
	
	signal seed_value: ads_complex := complex_zero;
	signal point: coordinate;
	
	signal iterations: natural;

	signal h_sync_sreg: std_logic_vector(pipeline_stages - 1 downto 0);
	signal v_sync_sreg: std_logic_vector(pipeline_stages - 1 downto 0);
	
	signal h_sync_out, v_sync_out: std_logic;
	
	type point_valid_array is array(pipeline_stages - 1 downto 0)
				of boolean;
				
	signal point_valid_sreg: point_valid_array;
	
	function gen_seed_value (
			pt: 	in coordinate;
			res:	vga_timing := vga_res_default
		) return ads_complex
	is
		constant x_min:	real := -2.2;
		constant x_max:	real :=  1.0;
		constant y_min:	real := -1.1;
		constant y_max:	real :=  1.1;
		constant h_res:	real := real(res.horizontal.active);
		constant v_res:	real := real(res.vertical.active);
		constant dx: ads_sfixed := to_ads_sfixed((x_max - x_min)/h_res);
		constant dy: ads_sfixed := to_ads_sfixed((y_max - y_min)/v_res);
		
		variable ret: ads_complex;
	begin
		ret.im := to_ads_sfixed(y_max) - dy * to_ads_sfixed(pt.y);
		ret.re := dx * to_ads_sfixed(pt.x) + to_ads_sfixed(x_min);
		return ret;
	end function gen_seed_value;
	
begin

	-- save seed value
	seed: process(clock) is
	begin
		if rising_edge(clock) then
			if reset = '0' then
				seed_value <= complex_zero;
			else
				seed_value <= gen_seed_value(point, vga_res);
			end if;
		end if;
	end process seed;

	pll0: pll
		port map (
			inclk0	=> clock,
			c0			=> system_clock
		);

	p0: pipeline
		generic map (
			threshold		=> threshold,
			total_stages	=> pipeline_stages
		)
		port map (
			clock		=> system_clock,
			reset		=> reset,
			z_input	=> seed_value,
			c_input	=> seed_value,
			output_valid	=> open,
			iterations		=> iterations
		);
		
	video_out: vga_fsm
		generic map (
			vga_res	=> vga_res
		)
		port map (
			vga_clock	=> system_clock,
			reset			=> reset,
			point			=> point,
			point_valid	=> point_valid,
			h_sync		=> h_sync_out,
			v_sync		=> v_sync_out
		);

	-- synchronize sync signals
	sync: process(clock) is
	begin
		if rising_edge(clock) then
			if reset = '0' then
				h_sync_sreg <= (others => '0');
				v_sync_sreg <= (others => '0');
				point_valid_sreg <= (others => false);
			else
				h_sync_sreg <= h_sync_sreg(pipeline_stages - 2 downto 0) & h_sync_out;
				v_sync_sreg <= v_sync_sreg(pipeline_stages - 2 downto 0) & v_sync_out;
				point_valid_sreg <= point_valid_sreg(pipeline_stages - 2 downto 0) & point_valid;
			end if;
		end if;
	end process sync;
		
	-- color outputs
	red   <= std_logic_vector(to_unsigned(pipeline_stages - iterations, 4)) when point_valid_sreg(pipeline_stages-1) else "0000";
	green <= std_logic_vector(to_unsigned(pipeline_stages - iterations, 4)) when point_valid_sreg(pipeline_stages-1) else "0000";
	blue  <= std_logic_vector(to_unsigned(pipeline_stages - iterations, 4)) when point_valid_sreg(pipeline_stages-1) else "0000";
	
	-- sync outputs
	h_sync <= h_sync_sreg(pipeline_stages - 1);
	v_sync <= v_sync_sreg(pipeline_stages - 1);
end architecture top;