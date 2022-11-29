---- this file is part of the ADS library

library ads;
use ads.ads_fixed.all;

package ads_complex_pkg is
	-- complex number in rectangular form
	type ads_complex is
	record
		re: ads_sfixed;
		im: ads_sfixed;
	end record ads_complex;

	---- functions

	-- make a complex number
--	function ads_cmplx (
--			re, im: in ads_sfixed
--		) return ads_complex;

	-- returns l + r
	function "+" (
			l, r: in ads_complex
		) return ads_complex;

	-- returns l - r
	function "-" (
			l, r: in ads_complex
		) return ads_complex;

	-- returns l * r
	function "*" (
			l, r: in ads_complex
		) return ads_complex;

	-- returns the complex conjugate of arg
	function conj (
			arg: in ads_complex
		) return ads_complex;

	-- returns || arg || ** 2
	function abs2 (
			arg: in ads_complex
		) return ads_sfixed;

	-- constants
	constant complex_zero: ads_complex :=
					( re => to_ads_sfixed(0), im => to_ads_sfixed(0) );

end package ads_complex_pkg;

package body ads_complex_pkg is

	-- function implementations
	function "+" (
			l, r: in ads_complex
		) return ads_complex
	is
		variable ret: ads_complex;
	begin
		ret.re := l.re + r.re;
		ret.im := l.im + r.im;
		return ret;
	end function "+";

	-- implement all other functions here
	function "-" (
			l, r: in ads_complex
		) return ads_complex
	is
		variable ret: ads_complex;
	begin
		ret.re := l.re - r.re;
		ret.im := l.im - r.im;
		return ret;
	end function "-";

	function "*" (
			l, r: in ads_complex
		) return ads_complex
	is
		variable ret: ads_complex;
	begin
		ret.re := l.re * r.re;
		ret.im := l.im * r.im;
		return ret;
	end function "*";

	function conj (
			arg: in ads_complex
		) return ads_complex
	is
		variable ret: ads_complex;
	begin
		ret.im := -arg.im;
		ret.re := arg.re;
		return ret;
	end function conj;

	function abs2 (
			arg: in ads_complex
		) return ads_sfixed
	is
	begin
		return arg.re * arg.re + arg.im * arg.im;
	end function abs2;

end package body ads_complex_pkg;
