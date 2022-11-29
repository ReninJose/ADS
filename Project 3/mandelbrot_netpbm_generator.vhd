library ieee;
use ieee.std_logic_1164.all;

use std.textio.all;

library ads;
use ads.ads_complex_pkg.all;
use ads.ads_fixed.all;

use work.netpbm_config.all;

entity mandelbrot_netpbm_generator is
end entity mandelbrot_netpbm_generator;

architecture test_fixture of mandelbrot_netpbm_generator is

	-- your mandelbrot computational engine here
	component pipeline is
		generic (
			total_stages:		positive := 16;
			threshold	:		ads_sfixed	:= to_ads_sfixed(4)
		);
		port (
			clock:				in	std_logic;
			reset:				in	std_logic;
			z_input:				in	ads_complex;
			c_input:				in ads_complex;
	
			iterations	:		out	natural range 0 to total_stages - 1;
			output_valid:		out	boolean
		);
	end component pipeline;


	--signal iteration_test: natural range 0 to q + 1;
	--alias total_stages: natural is iterations;
	--alias threshold: ads_sfixed is escape;
	constant total_stages: natural := 16;
	signal seed: ads_complex;
	signal clock: std_logic		:= '0';
	signal reset: std_logic		:= '0';

	signal iteration_count: natural range 0 to 15;
	signal output_valid: boolean;

	signal finished: boolean	:= false;

begin

	clock <= not clock after 1 ps when not finished else '0';

	generator: pipeline
		generic map (
			total_stages => 16,
			threshold => to_ads_sfixed(4)
		)
		port map (
			clock => clock,
			reset => reset,
			z_input => seed,
			c_input => ( re => to_ads_sfixed(-0.4), im => to_ads_sfixed(0.6) ),

			iterations => iteration_count,
			output_valid => output_valid
		);
	
	make_pgm: process
		variable x_coord: ads_sfixed;
		variable y_coord: ads_sfixed;
		variable output_line: line;
	begin
		-- header information
		---- P2
		write(output_line, string'("P2"));
		writeline(output, output_line);
		---- resolution
		write(output_line, integer'image(x_steps) & string'(" ")
				& integer'image(y_steps));
		writeline(output, output_line);
		---- maximum value
		write(output_line, integer'image(total_stages - 1));
		writeline(output, output_line);

		-- from here onwards, stimulus depends on your implementation

		-- reset generator
		wait until rising_edge(clock);
		reset <= '0';
		wait until rising_edge(clock);
		reset <= '1';

		-- iterate Y coordinates (rows)
		for y_pt in 0 to y_steps-1 loop
			-- imaginary portion computation
			y_coord := to_ads_sfixed(y_range.min) + to_ads_sfixed(y_pt) * dy;

			-- iterate X coordinates (columns)
			for x_pt in 0 to x_steps-1 loop

				-- real portion computation
				x_coord := to_ads_sfixed(x_range.min) + to_ads_sfixed(x_pt) * dx;

				-- set seed
			
				seed <= (re=>x_coord, im=>y_coord);

				-- TODO: modify stimulus here depending on your core!
				wait until rising_edge(clock);

				-- in my pipeline, i have to wait until data goes through it
				-- from the initial reset to get data out, after that, all
				-- outputs are valid
				if output_valid then
					write(output_line, integer'image(total_stages - 1 - iteration_count));
					writeline(output, output_line);
					--flush(output);
				end if;
				-- if you are doing the control unit method then you need to
				-- clock until the done signal is asserted
				-- while done = '0' loop
				-- 	wait until rising_edge(clock);
				-- end loop;
				-- write(output_line, integer'image(iterations - 1 -
				-- 				iteration_count));
				-- writeline(output, output_line);
			end loop;
		end loop;

		for i in 0 to total_stages - 1 loop
			wait until rising_edge(clock);
			write(output_line, integer'image(total_stages - 1 - iteration_count));
			writeline(output, output_line);
			--flush(output);
		end loop;

		-- all done
		finished <= true;
		wait;
	end process make_pgm;

end architecture test_fixture;
