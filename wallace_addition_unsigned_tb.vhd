LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE std.textio.all;
USE work.Wallace_tree_functions.all;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE STD.TEXTIO.ALL;

ENTITY wallace_adder_tb IS
	GENERIC (
		width: INTEGER := 7;
		nrargs : INTEGER := 4
	);
END wallace_adder_tb;

ARCHITECTURE tb OF wallace_adder_tb IS

	FILE RESULTS: TEXT OPEN APPEND_MODE IS "wallace_addition_unsigned.csv";

	SIGNAL t_x		:	ArrayOfAddends( width - 1  DOWNTO 0, nrargs - 1  DOWNTO 0)  := (others =>(others =>'0'));
	SIGNAL t_sum	:	STD_LOGIC_VECTOR(sizeof( nrargs * ( 2**width - 1)) - 1 DOWNTO 0) := (others =>'0');
	
	COMPONENT wallace_addition IS
		GENERIC (
			width : INTEGER := 4;
			nrargs : INTEGER := 4
		);
		PORT (
			x		:	IN ArrayOfAddends( width - 1  DOWNTO 0, nrargs - 1  DOWNTO 0);
			sum	:	OUT STD_LOGIC_VECTOR(sizeof( nrargs * ( 2**width - 1)) - 1 DOWNTO 0)
		);		
	END COMPONENT;

BEGIN
	UUT: wallace_addition 
	GENERIC MAP( width => width,	nrargs => nrargs)
		PORT MAP( x => t_x, sum	=> t_sum );

	-- Input Processes
	inp_prc: PROCESS
	type INT_ARRAY is array (integer range <>) of integer;
	variable v_x: INT_ARRAY(nrargs - 1 DOWNTO 0) := (0, 0, 0, 0); -- array of addition arguments

	function to_unsigned_int_string(sv: Std_Logic_Vector) return string is
	use Std.TextIO.all;
		variable iv: integer := to_integer(unsigned(sv));
		variable lp: line;
	begin
		write(lp, iv);
		return lp.all;
	end;

	PROCEDURE Log_header IS
	VARIABLE RES_LINE : LINE;
	BEGIN
		FOR j IN nrargs - 1 DOWNTO 0 LOOP
			write(RES_LINE, string'(" ARG("));
			write(RES_LINE, (nrargs - 1) - j);
			write(RES_LINE, string'("),"));
		END LOOP;	
		write(RES_LINE, string'(" S"));
		writeline(RESULTS, RES_LINE);		
	END;
			  
	PROCEDURE Log_variables(
		t_sum	:	STD_LOGIC_VECTOR(sizeof( nrargs * ( 2**width - 1)) - 1 DOWNTO 0)
	) IS
	VARIABLE RES_LINE : LINE;
	BEGIN
		FOR j IN nrargs - 1 DOWNTO 0 LOOP
			  write(RES_LINE, v_x(j));
			  write(RES_LINE, string'(","));
		END LOOP;
		write(RES_LINE, to_unsigned_int_string(t_sum));
		writeline(RESULTS, RES_LINE);		
	END;
	--convert input array to bit array t_bitx and transpose the bit matrix into t_x
	PROCEDURE Transpose_addition_args IS
	VARIABLE t_bitx	:	STD_LOGIC_VECTOR(width - 1 downto 0);
	BEGIN
		FOR j IN nrargs - 1 DOWNTO 0 LOOP
			-- loop through addition arguments			
			t_bitx := std_logic_vector(to_unsigned(v_x(j), t_bitx'length));	--convert addition argument
			FOR i IN width - 1 DOWNTO 0 LOOP	
				t_x( i, j ) <= std_logic(t_bitx( i ));	--transpose addition argument
			END LOOP;
		END LOOP;		
	END;
	BEGIN
		WAIT FOR 100 ns;
		Log_header;
		WAIT FOR 100 ns;
		v_x := (12, 23, 45, 67);
		WAIT FOR 100 ns;
		Transpose_addition_args;
		WAIT FOR 100 ns;
		Log_variables(t_sum);
		WAIT FOR 100 ns;
		
		v_x := (34, 45, 56, 67);
		WAIT FOR 100 ns;
		Transpose_addition_args;
		WAIT FOR 100 ns;
		Log_variables(t_sum);
		WAIT FOR 100 ns;

		v_x := (67, 78, 89, 90);
		WAIT FOR 100 ns;
		Transpose_addition_args;
		WAIT FOR 100 ns;
		Log_variables(t_sum);
		WAIT FOR 100 ns;
		
	END PROCESS;
	
END tb;