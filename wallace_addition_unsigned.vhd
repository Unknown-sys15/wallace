LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.Wallace_tree_functions.all;

ENTITY wallace_addition IS
	GENERIC (
		width : INTEGER := 4;	--sirina operanda
		nrargs : INTEGER := 4	--stevilo operandov
	);
	PORT (
		x	:	IN 	ArrayOfAddends(width - 1  DOWNTO 0, nrargs - 1  DOWNTO 0);		-- polje bitov operandov
		sum	:	OUT STD_LOGIC_VECTOR(sizeof( nrargs * ( 2**width - 1)) - 1 DOWNTO 0)	-- vsota
	);		
END wallace_addition;

ARCHITECTURE Wallace_unsigned_addition OF wallace_addition IS
	TYPE nr_stages_type IS ARRAY (32 DOWNTO 3) OF INTEGER;
	CONSTANT nr_stages : nr_stages_type := (
		3 => 1, 
		4 => 2, 
		5 TO 6 => 3,
		7 TO 9 => 4,
		10 TO 13 => 5,
		14 TO 19 => 6,
		20 TO 28 => 7,
		29 TO 32 => 8);
	CONSTANT stages: INTEGER := nr_stages( nrargs ); --tevilo stopenj redukcije Wallaceovega drevesa 
	CONSTANT max_sum_size: INTEGER := sizeof( nrargs * ( 2**width - 1));	--stevilo mest vsote s funk sizeof
	
	TYPE cell_type IS ARRAY(max_sum_size-1 DOWNTO 0, nrargs-1 DOWNTO 0) OF STD_LOGIC;--2D POLJE BITOV
	TYPE w_type IS ARRAY (stages DOWNTO 0) OF cell_type; -- 1D polje polja (cell_type)
	SIGNAL W : W_type := (others => (others =>(others =>'0'))); -- Wallaceovo drevo
	------------------------CLA COMPONENT------------------------
	COMPONENT cla_add_n_bit IS
		GENERIC(n:NATURAL := 8);
		PORT( Cin : in std_logic ;
				X, Y : in std_logic_vector(n-1 downto 0); 
				S : out std_logic_vector(n-1 downto 0); 
				Gout, 
				Pout, 
				Cout : out std_logic);
	END COMPONENT;
	--------------------------------------------------------------
	SIGNAL add_a, add_b, add_sum: STD_LOGIC_VECTOR(max_sum_size-1 DOWNTO 0);

BEGIN
	wallace_proc: PROCESS(X,W) IS--VHODI
	VARIABLE this_carry_bits,this_stage_bits,num_full_adds,num_half_adds,num_wires : NATURAL;
	BEGIN 
		FOR I IN 0 TO WIDTH-1 LOOP
			FOR J IN 0 TO NARGS-1 LOOP
				W(0)( i, j) <= x(i,j);
			END LOOP;
		END LOOP;
		
		FOR K IN 0 TO SATGES-1 LOOP
			FOR I IN 0 TO max_sum_size - 1 LOOP --"WEIGHT"
				this_carry_bits := prev_lvl_carry_rect( nrargs, width, i, k + 1); 
				num_full_adds := num_full_adders_rect( nrargs, width, i, k);
				
				--IZRACUN VSOTE IN CARRIJA ZA NASLEDNJI STAGE ZA FA
				FOR J IN 0 TO num_full_adds-1 LOOP
					 W( k+1 )( i, this_carry_bits + j) <= W(K)(I,3*J) XOR W(K)(I,3*J+1) XOR W(K)(I,3*J+2);--VSOTA 
					 W( k+1 )( i + 1, j)<= (W(k)(i, 3*j) AND W(k)(i, 3*j+1)) OR (W(k)(i, 3*j) AND W(k)(i, 3*j+2)) OR (W(k)(i, 3*j+1) AND W(k)(i, 3*j+2));--CARRY
				END LOOP;
				
				--IZRACUN VSOTE IN CARRIJA ZA NASLEDNJI STAGE ZA HA
				num_half_adds := num_half_adders_rect( nrargs, width, i, k);
				FOR J IN 0 TO num_half_adds-1 LOOP
					 W( k+1 )( i, this_carry_bits + num_full_adds + j) <= W(k)( i, num_full_adds*3 + 2*j) XOR W(k)( i,num_full_adds*3+(2*j+1));--VSOTA HA
					 W( k+1 )( i + 1, num_full_adds + j) <= W(k)( i, num_full_adds*3 + 2*j) AND W(k)( i, num_full_adds*3 + 2*j+1);--CARRY
				END LOOP;
				
				this_stage_bits <= this_lvl_bits_rect(nrargs, widthL, I, K);
				num_wires <=  this_stage_bits - 3*num_full_adds - 2*num_half_adds;
				FOR J IN 0 TO num_wires-1 LOOP
					W( k+1 )( i, this_carry_bits + num_full_adds + num_half_adds + j) <= W(k)(i, num_full_adds * 3 + num_half_adds * 2 + j);
				END LOOP;
				
			END LOOP;
			
			report "Bit#/Total " & integer'image(i) & "/" & 
			integer'image(this_stage_bits) & HT & 
			"FA: " & integer'image(num_full_adds) & HT & 
			"HA: " & integer'image(num_half_adds) & HT & 
			"C: " & integer'image(this_carry_bits) & HT & 
			"W: " & integer'image(num_wires); 
			
		END LOOP;
		
	END PROCESS wallace_proc;
	
	final_stage_sum__proc: PROCESS(w) IS
	BEGIN 
		FOR I IN 0 TO max_num_size-1 LOOP
			add_a(I) <= W( stages )( i, 0);
			add_b(I) <= W( stages )( i, 1);
		END LOOP;
	END PROCESS final_stage_sum__proc;
	
	cla:cla_add_n_bit
	GENERIC MAP(N => max_num_size)
	PORT MAP(
		X=>add_a,
		Y=>add_b,
		S=>add_sum,
		Cin=>'0'
		);
	
	sum <= add_sum;

END Wallace_unsigned_addition;