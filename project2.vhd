LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity vga_driver is
	GENERIC (
		Ha: INTEGER := 96;
		Hb: INTEGER := 144;
		Hc: INTEGER := 784;	
		Hd: INTEGER := 800;
		Va: INTEGER := 2;
		Vb: INTEGER := 35;
		Vc: INTEGER := 515;
		Vd: INTEGER := 525
	);
	PORT (
		vga_clock	: in std_logic;
		reset		: in std_logic;
		x		: out natural range 0 to Hd;
		y		: out natural range 0 to Vd; 
		hsync		: out std_logic;
		vsync		: out std_logic;
		x_valid		: out boolean;
		y_valid		: out boolean	
	);
end vga_driver;

architecture vga of vga_driver is
	SIGNAL Hactive, Vactive: std_logic;
	BEGIN
		PROCESS (vga_clock)
		BEGIN
			IF (vga_clock'EVENT AND vga_clock='1') THEN
				reset <= NOT reset;
			END IF;
		END PROCESS;
		
		PROCESS (reset)
		BEGIN
			IF (reset'EVENT AND reset='1') THEN
				x := x + 1;
				IF (x=Ha) THEN
					Hsync <= '1';
				ELSIF (x=Hb) THEN
					Hactive <= '1';
				ELSIF (x=Hc) THEN
					Hactive <= '0';
				ELSIF (x=Hd) THEN
					Hsync <= '0';
					Hcount := 0;
				END IF;
			END IF;
		END PROCESS;
		
		PROCESS (Hsync)
		BEGIN
			IF (Hsync'EVENT AND Hsync= '0') THEN
				y := y + 1;
				IF (y=Va) THEN
					Vsync <= '1';
				ELSIF (y=Vb) THEN
					Vactive <= '1';
				ELSIF (y=Vc) THEN
					Vactive <= '0';
				ELSIF (y=Vd) THEN
					Vsync <= '0';
					Vactive <= 0;
				END IF;
			END IF;
		END PROCESS;
END vga;
