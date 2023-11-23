LIBRARY ieee;
USE ieee.std_logic_1164.all;

PACKAGE Wallace_tree_functions IS

	--	@Type name: sizeof
	-- @Parameters:
	--	argument 1: x dimenzija polja
	--	argument 2: y dimenzija polja 
	--	@Description:
	--	definicija tipa splonega dvodimenzionalnega polja (x, y) bitov tipa STD_LOGIC
	Type ArrayOfAddends is array (natural range <>, natural range <>) of STD_LOGIC;

	--	@Function name: sizeof
	-- @Parameters:
	--	a: vhodno tevilo
	--	@Return:
	--	Vrne tevilo bitov, potrebnih za zapis tevila a
	FUNCTION sizeof (a: NATURAL) RETURN NATURAL;
	
	--	@Function name: prev_lvl_carry_rect
	-- @Parameters:
	--	height: viina Wallaceove drevesne strukture na danem nivoju redukcije
	--	arg_width: velikost operanda Wallaceove drevesne strukture na danem nivoju redukcije
	--	this_weight: Ute (stolpec) Wallaceove drevesne strukture na danem nivoju redukcije
	--	this_lvl: nivo redukcije Wallaceove drevesne strukture
	--	@Return:
	--	tevilo bitov prenosa za dani stolpec podanega nivoja redukcije Wallaceove drevesne strukture (this_lvl)
	FUNCTION prev_lvl_carry_rect (height: NATURAL; arg_width: NATURAL; this_weight: NATURAL; this_lvl: NATURAL) RETURN NATURAL;
	
	--	@Function name: this_lvl_bits_rect
	-- @Parameters:
	--	height: viina Wallaceove drevesne strukture na danem nivoju redukcije
	--	arg_width: velikost operanda Wallaceove drevesne strukture na danem nivoju redukcije
	--	this_weight: Ute (stolpec) Wallaceove drevesne strukture na danem nivoju redukcije
	--	this_lvl: nivo redukcije Wallaceove drevesne strukture
	--	@Return:
	--	tevilo bitov v danem stolpcu podanega nivoja redukcije Wallaceove drevesne strukture (this_lvl)
	FUNCTION this_lvl_bits_rect (height: NATURAL; arg_width: NATURAL; this_weight: NATURAL; this_lvl: NATURAL) RETURN NATURAL;
	
	--	@Function name: num_full_adders_rect
	-- @Parameters:
	--	height: viina Wallaceove drevesne strukture na danem nivoju redukcije
	--	arg_width: velikost operanda Wallaceove drevesne strukture na danem nivoju redukcije
	--	this_weight: Ute (stolpec) Wallaceove drevesne strukture na danem nivoju redukcije
	--	this_lvl: nivo redukcije Wallaceove drevesne strukture
	--	@Return:
	--	tevilo polnih setevalnikov v danem stolpcu podanega nivoja redukcije Wallaceove drevesne strukture (this_lvl)
	FUNCTION num_full_adders_rect (height: NATURAL; arg_width: NATURAL; this_weight: NATURAL; this_lvl: NATURAL) RETURN NATURAL;
	
	--	@Function name: num_half_adders_rect
	-- @Parameters:
	--	height: viina Wallaceove drevesne strukture na danem nivoju redukcije
	--	arg_width: velikost operanda Wallaceove drevesne strukture na danem nivoju redukcije
	--	this_weight: Ute (stolpec) Wallaceove drevesne strukture na danem nivoju redukcije
	--	this_lvl: nivo redukcije Wallaceove drevesne strukture
	--	@Return:
	--	tevilo polnih setevalnikov v danem stolpcu podanega nivoja redukcije Wallaceove drevesne strukture (this_lvl)
	FUNCTION num_half_adders_rect (height: NATURAL; arg_width: NATURAL; this_weight: NATURAL; this_lvl: NATURAL) RETURN NATURAL;
	
END Wallace_tree_functions;

PACKAGE BODY Wallace_tree_functions IS
   ---------------------------------------------------------------------------------------------------------------------------------
	FUNCTION sizeof (a: NATURAL) RETURN NATURAL IS
		VARIABLE nr	: NATURAL := a;
		VARIABLE DIVS: NATURAL := 0;
	BEGIN
		DIVISION: WHILE NR /=0 LOOP 
			NR := NR/2;
			DIVS := DIVS+1;
		END LOOP DIVISION;
		RETURN DIVS;
	END FUNCTION;
	---------------------------------------------------------------------------------------------------------------------------------
	FUNCTION this_lvl_bits_rect (height: NATURAL; arg_width: NATURAL; this_weight: NATURAL; this_lvl: NATURAL) RETURN NATURAL IS
	--VARIABLI
	VARIABLE prev_lvl_bits,full_adder_sum_bits,half_adder_sum_bits,this_num_bits : NATURAL;
	BEGIN
		-------PREVERI TLE POGOJE 
		IF this_lvl = 0 THEN
			IF this_weight < arg_width THEN
				RETURN height;
			ELSE 
				RETURN 0;
			END IF;
		END IF;
		prev_lvl_bits:= this_lvl_bits_rect(height, arg_width, this_weight, this_lvl - 1);
		full_adder_sum_bits := prev_lvl_bits/3;--KOLKO FA
		half_adder_sum_bits := (prev_lvl_bits - (3*full_adder_sum_bits))/2--KOLKO HA
		prev_lvl_bits-(2*full_adder_sum_bits)-(half_adder_sum_bits)+prev_lvl_carry_rect(height, arg_width, this_weight,this_lvl);
		RETURN this_num_bits;
	END FUNCTION;
	---------------------------------------------------------------------------------------------------------------------------------
	--STEVILO PRENOSOV VSEH SEST
	FUNCTION prev_lvl_carry_rect (height: NATURAL; arg_width: NATURAL; this_weight: NATURAL; this_lvl: NATURAL) RETURN NATURAL IS
	VARIABLE num_carry, prev_lvl_bits,num_carry_FA,num_carry_HA : NATURAL;
	BEGIN
		IF this_weight =0 THEN
			num_carry:=0;
		END IF;
		prev_lvl_bits := this_lvl_bits_rect(height, arg_width,this_weight-1, this_lvl-1);
		num_carry_FA := prev_lvl_bits/3;
		num_carry_HA := (prev_lvl_bits-3*num_carry_FA)/2;
		num_carry := num_carry_FA+num_carry_HA;
		RETURN num_carry;
	END FUNCTION;
	---------------------------------------------------------------------------------------------------------------------------------
	FUNCTION num_full_adders_rect (height: NATURAL; arg_width: NATURAL; this_weight: NATURAL; this_lvl: NATURAL) RETURN NATURAL IS
	VARIABLE this_num_bits : NATURAL;
	BEGIN 
		this_num_bits := this_lvl_bits_rect(height, arg_width, this_weight, this_lvl);
		RETURN this_num_bits/3;
	END FUNCTION;
	---------------------------------------------------------------------------------------------------------------------------------
	FUNCTION num_half_adders_rect (height: NATURAL; arg_width: NATURAL; this_weight: NATURAL; this_lvl: NATURAL) RETURN NATURAL IS
	VARIABLE this_num_bits,num_full_adds: NATURAL;
	BEGIN
		this_num_bits:= this_lvl_bits_rect(height, arg_width, this_weight, this_lvl);
		num_full_adds := num_full_adders_rect(height, arg_width, this_weight, this_lvl);
		RETURN (this_num_bits-(3*num_full_adds))/2;
	END FUNCTION;
	
END Wallace_tree_functions;
