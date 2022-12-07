	library ieee;
	use ieee.std_logic_1164.all;



	package seven_segment_pkg is
		
		type seven_segment_config is record
			a	:	std_logic;
			b	:	std_logic;
			c	:	std_logic;
			d	:	std_logic;
			e	:	std_logic;
			f	:	std_logic;
			g	:	std_logic;
		
		end record seven_segment_config;
		
		type seven_segment_output is array (0 to 5) of seven_segment_config;
		
		type seven_segment_array is array (natural range <>) of seven_segment_config;
		
		type lamp_configuration is (common_anode, common_cathode);
		
		constant default_lamp_config :	lamp_configuration := common_anode; 
		
		constant seven_segment_table: seven_segment_array := (
		
				( a => '1', b => '1', c => '1', d => '1', e => '1', f => '1', g => '0' ),
				( a => '0', b => '1', c => '1', d => '0', e => '0', f => '0', g => '0' ),
				( a => '1', b => '1', c => '0', d => '1', e => '1', f => '0', g => '1' ),
				( a => '1', b => '1', c => '1', d => '1', e => '0', f => '0', g => '1' ),
				( a => '0', b => '1', c => '1', d => '0', e => '0', f => '1', g => '1' ),
				( a => '1', b => '0', c => '1', d => '1', e => '0', f => '1', g => '1' ),
				( a => '1', b => '0', c => '1', d => '1', e => '1', f => '1', g => '1' ),
				( a => '1', b => '1', c => '1', d => '0', e => '0', f => '0', g => '0' ),
				( a => '1', b => '1', c => '1', d => '1', e => '1', f => '1', g => '1' ),
				( a => '1', b => '1', c => '1', d => '1', e => '0', f => '1', g => '1' ),
				( a => '1', b => '1', c => '1', d => '0', e => '1', f => '1', g => '1' ),
				( a => '0', b => '0', c => '1', d => '1', e => '1', f => '1', g => '1' ),
				( a => '1', b => '0', c => '0', d => '1', e => '1', f => '1', g => '0' ),
				( a => '0', b => '1', c => '1', d => '1', e => '1', f => '0', g => '1' ),
				( a => '1', b => '0', c => '0', d => '1', e => '1', f => '1', g => '1' ),
				( a => '1', b => '0', c => '0', d => '0', e => '1', f => '1', g => '1' )
		);
		
		
		
		constant seven_segment_table_off: seven_segment_config := 
		( a => '0', b => '0', c => '0', d => '0', e => '0', f => '0', g => '0' );
		
		
		subtype hex_digit is natural range 0 to 15;
		
		function get_hex_digit (
			digit: in hex_digit;
			lamp_mode: in lamp_configuration := default_lamp_config
			) return seven_segment_config;
			
			
			
		function lamps_off (
			lamp_mode: in lamp_configuration := default_lamp_config
			) return seven_segment_config;
	
	
	end package seven_segment_pkg;
	
	
	package body seven_segment_pkg is
			
			function get_hex_digit (
				digit: in hex_digit;
				lamp_mode: in lamp_configuration := default_lamp_config
				) 
				return seven_segment_config
			is
				variable ret: seven_segment_config;
			begin
				ret := seven_segment_table(digit);
				if lamp_mode = common_cathode then
					return ret;
				end if;
				
				return ( a => not ret.a, b => not ret.b, c => not ret.c, d => not ret.d, e => not ret.e, f => not ret.f, g => not ret.g );
				
			end;
					
			function lamps_off (
				lamp_mode: in lamp_configuration := default_lamp_config
				) 
			return seven_segment_config is
		begin 
			return(seven_segment_table_off);
		end;
		
		
		end package body seven_segment_pkg;
			