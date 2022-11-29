library ieee;
use ieee.std_logic_1164.all;

library ads;
use ads.ads_fixed.all;
use ads.ads_complex_pkg.all;

use work.pipeline_pkg.all;

entity pipeline_stage is
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
		
end entity pipeline_stage;

architecture rtl of pipeline_stage is
	signal re_square, im_square, re_times_im: ads_sfixed;
begin
	-- save our multipliers
	re_square <= stage_input.z.re * stage_input.z.re;
	im_square <= stage_input.z.im * stage_input.z.im;
	re_times_im <= stage_input.z.re * stage_input.z.im;

	-- carry overflow from previous stage if needed, else send out our stage number
	stage_output.stage_data <= stage_input.stage_data when stage_input.stage_overflow
				else stage_number;
	
	-- c passes through
	stage_output.c <= stage_input.c;
	
	-- compute iteration on the stage using the multiplications
	stage_output.z.re <= re_square - im_square + stage_input.c.re;
	stage_output.z.im <= re_times_im + re_times_im + stage_input.c.im;
	
	-- send out the stage overflow based on the previous stage and our current stage data
	stage_output.stage_overflow <= stage_input.stage_overflow
				or ((re_square + im_square) >= threshold);
				
	-- stage valid signal propagation
	stage_output.stage_valid <= stage_input.stage_valid;
	
end architecture rtl;