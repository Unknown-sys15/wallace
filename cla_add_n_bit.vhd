LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY cla_add_n_bit IS
	generic(n: natural := 8);
	PORT (	Cin	:	in 	std_logic;
				X, Y	:	in 	std_logic_vector(n-1 downto 0);
				S		:	out	std_logic_vector(n-1 downto 0);
				Gout, 
				Pout, 
				Cout	:	out	std_logic);
END cla_add_n_bit;

ARCHITECTURE for_loop_arch OF cla_add_n_bit IS
BEGIN
PROCESS(Cin, X, Y)
	TYPE cla_carry_array_type IS ARRAY(n DOWNTO 0) OF STD_LOGIC;
	VARIABLE cla_carry_array: cla_carry_array_type;
	VARIABLE g_sig, p_sig : STD_LOGIC;
	BEGIN
		cla_carry_array(0) := Cin;
		FOR i IN 0 TO n-1 LOOP
			g_sig := x(i) and y(i);	-- funkcija tvorjenja
			p_sig := x(i) xor y(i);	-- funkcija sirjenja
			cla_carry_array(i+1) := g_sig or ( p_sig and cla_carry_array(i)); -- prenos			
			S(i) <= x(i) xor y(i) xor cla_carry_array(i); -- vsota
		END LOOP;
		Cout <= cla_carry_array(n);	--izhodni prenos
		Gout <= g_sig;	--izhodna funkcija tvorjenja (generate)
		Pout <= p_sig;	--izhodna funkcija širjenja (propagate)		
END PROCESS;
END for_loop_arch;

ARCHITECTURE for_generate_arch2 OF cla_add_n_bit IS

COMPONENT cla_gp IS
	PORT (	Cin, x, y : IN STD_LOGIC;
				S, Cout, g, p : OUT STD_LOGIC );
END COMPONENT;

--vektor vmesnih prenosov in funkcij tvorjenja in širjenja
SIGNAL C : STD_LOGIC_VECTOR(n DOWNTO 0);
SIGNAL G, P	: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
BEGIN
	C(0) <= Cin;
	
	cla_stages:	FOR i IN 0 TO n-1 GENERATE
			g(i) <= x(i) and y(i);	-- funkcija tvorjenja
			p(i) <= x(i) xor y(i);	-- funkcija sirjenja
			s(i) <= x(i) xor y(i) xor c(i);	-- vsota
			C(i+1) <= g(i) or ( p(i) and C(i) ); -- izhodni prenos
	END GENERATE;
	
	Cout <= C(n);	--izhodni prenos
	Gout <= x(n-1) and y(n-1);	--izhodna funkcija tvorjenja (generate)
	Pout <= x(n-1) xor y(n-1);	--izhodna funkcija širjenja (propagate)
	
END for_generate_arch2; 