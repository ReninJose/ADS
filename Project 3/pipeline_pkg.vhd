library ieee;
use ieee.std_logic_1164.all;

library ads;
use ads.ads_fixed.all;
use ads.ads_complex_pkg.all;

package pipeline_pkg is

	type pipeline_signals is
	record
		z:	ads_complex;
		c:	ads_complex;
		stage_data:	natural;
		stage_overflow: boolean;
		stage_valid: boolean;
	end record pipeline_signals;
	
	component pipeline_stage is
		generic (
			threshold:		ads_sfixed := to_ads_sfixed(4);
			stage_number:	natural := 0
		);
		port (
			clock:	in		std_logic;
			reset:	in		std_logic;
			
			stage_input:	in		pipeline_signals;
			stage_output:	out	pipeline_signals
		);
	end component pipeline_stage;

	component pipeline is
		generic (
			threshold:	ads_sfixed := to_ads_sfixed(4);
			total_stages:	positive	:= 16
		);
		port (
			clock:	in	std_logic;
			reset:	in	std_logic;
			
			z_input:	in	ads_complex;
			c_input:	in	ads_complex;
			
			output_valid:	out	boolean;
			iterations:		out	natural range 0 to total_stages - 1
		);
	end component pipeline;

end package pipeline_pkg;