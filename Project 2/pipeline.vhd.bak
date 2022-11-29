library ieee;
use ieee.std_logic_1164.all;

library ads;
use ads.ads_fixed.all;
use ads.ads_complex_pkg.all;

use work.pipeline_pkg.all;

entity pipeline is
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
end entity pipeline;

architecture pip of pipeline is
	type stage_signal_array is array(0 to total_stages - 1)
			of pipeline_signals;
	
	signal stage_input: stage_signal_array;
	signal stage_output: stage_signal_array;
begin

	-- drive outputs of entity
	output_valid <= stage_output(total_stages - 1).stage_valid;
	iterations <= stage_output(total_stages - 1).stage_data;

	stages: for stage in 0 to total_stages - 1 generate
		s: pipeline_stage
			generic map (
				threshold		=> threshold,
				stage_number	=> stage
			)
			port map (
				clock			=>	clock,
				reset			=> reset,
				
				stage_input		=> stage_input(stage),
				stage_output	=> stage_output(stage)
			);
	end generate stages;
	
	gen_registers: for stage in 1 to total_stages - 1 generate
		registers: process(clock) is
		begin
			if rising_edge(clock) then
				if reset = '0' then
					stage_input(stage).z <= complex_zero;
					stage_input(stage).c <= complex_zero;
					stage_input(stage).stage_data <= 0;
					stage_input(stage).stage_overflow <= false;
					stage_input(stage).stage_valid <= false;
				else
					stage_input(stage) <= stage_output(stage-1);
				end if;
			end if;
		end process registers;
	end generate gen_registers;

	-- pipeline stage 0 input
	stage_input(0).z <= z_input;
	stage_input(0).c <= c_input;
	stage_input(0).stage_data <= 0;
	stage_input(0).stage_overflow <= false;
	stage_input(0).stage_valid <= true;
	
end architecture pip;