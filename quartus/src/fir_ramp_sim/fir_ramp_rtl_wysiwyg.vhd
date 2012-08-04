

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
LIBRARY wysiwyg;
USE wysiwyg.stratix_components.ALL;

ENTITY fir_ramp_rtl_CarryPropagator IS
PORT (
	cin  	  : IN  STD_LOGIC;
	cout 	  : OUT STD_LOGIC;
	inverta : IN STD_LOGIC
);
END ENTITY fir_ramp_rtl_CarryPropagator;

ARCHITECTURE WYSI OF fir_ramp_rtl_CarryPropagator IS
BEGIN
	carry_propagating_lcell : stratix_lcell
	----------------------------------
	-- Function is: cout = cin, sum = 0
	----------------------------------
	-- D C B A  Z
	----------------------------------
	-- 0 0 0 0  0 THIS HALF USED FOR CARRY
	-- 0 0 0 1  0
	-- 0 0 1 0  0
	-- 0 0 1 1  0
	-- 0 1 0 0  1
	-- 0 1 0 1  1
	-- 0 1 1 0  1
	-- 0 1 1 1  1 => F0 (LOW BYTE)
	----------
	-- 1 0 0 0  0 THIS HALF USED FOR SUM
	-- 1 0 0 1  0
	-- 1 0 1 0  0
	-- 1 0 1 1  0
	-- 1 1 0 0  0
	-- 1 1 0 1  0
	-- 1 1 1 0  0
	-- 1 1 1 1  0 => 00 (HIGH BYTE)
	----------------------------------
	GENERIC MAP (
		operation_mode => "arithmetic",
		synch_mode => "off",
		register_cascade_mode => "off",
		sum_lutc_input => "cin",
		lut_mask => "00F0",
		cin_used => "true",
		output_mode => "comb_only"
	)
	PORT MAP (
		cin => cin,
		cout => cout,
		inverta => inverta
	);	
END ARCHITECTURE WYSI;


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
LIBRARY wysiwyg;
USE wysiwyg.stratix_components.ALL;


ENTITY fir_ramp_rtl_AddWithSload IS
GENERIC (
	L : INTEGER;
	SIMULATION : STRING := "FALSE";
	OPTIMIZED : STRING := "FALSE"
);
PORT (
	clk, reset : IN STD_LOGIC;
	ena : IN STD_LOGIC := '1';
	sreset : IN STD_LOGIC := '0';
	sload : IN STD_LOGIC;
	loadval_in : IN STD_LOGIC_VECTOR(L-1 DOWNTO 0);
	doAddnSub : IN STD_LOGIC := '1';
	addL_in : IN STD_LOGIC_VECTOR(L-1 DOWNTO 0);
	addR_in : IN STD_LOGIC_VECTOR(L-1 DOWNTO 0);
	sum_out : OUT STD_LOGIC_VECTOR(L-1 DOWNTO 0)
);
END fir_ramp_rtl_AddWithSload;


ARCHITECTURE RTL OF fir_ramp_rtl_AddWithSload IS

	SIGNAL InvertedAddnSub : STD_LOGIC;
	SIGNAL CarryChain : STD_LOGIC_VECTOR(L-1 DOWNTO 0);
	SIGNAL Padding : STD_LOGIC_VECTOR(99 DOWNTO 0);
	
	COMPONENT fir_ramp_rtl_CarryPropagator IS
		PORT (cin     : IN  STD_LOGIC;
			  cout    : OUT STD_LOGIC;
			  inverta : IN STD_LOGIC);
	END COMPONENT fir_ramp_rtl_CarryPropagator;

BEGIN

	noopt_gen :
	IF (OPTIMIZED = "FALSE") GENERATE
		PROCESS (clk, reset)
		BEGIN
			IF (reset = '1') THEN
				sum_out <= (others => '0');
			ELSIF (clk'EVENT AND clk = '1') THEN
				IF (ena = '1') THEN
					IF (sreset = '1') THEN
						sum_out <= (others => '0');
					ELSIF (sload = '1') THEN
						sum_out <= loadval_in;
					ELSE				
                  IF (doAddnSub = '1') THEN
                     sum_out <= STD_LOGIC_VECTOR(UNSIGNED(addL_in) + UNSIGNED(addR_in));
                  ELSE
                     sum_out <= STD_LOGIC_VECTOR(UNSIGNED(addL_in) - UNSIGNED(addR_in));
                  END IF;
					END IF;
				END IF;
			END IF;
		END PROCESS;
	END GENERATE;

	opt_gen :
	IF (OPTIMIZED = "TRUE") GENERATE
		InvertedAddnSub <= not doAddnSub;
		----------------------------------
		-- Ordinary adding lcell
		----------------------------------
		-- D C B A  Z
		----------------------------------
		-- 0 0 0 0  0 THIS HALF USED FOR CARRY
		-- 0 0 0 1  0
		-- 0 0 1 0  0
		-- 0 0 1 1  1
		-- 0 1 0 0  0
		-- 0 1 0 1  1
		-- 0 1 1 0  1
		-- 0 1 1 1  1 => E8 (LOW BYTE)
		----------
		-- 1 0 0 0  0 THIS HALF USED FOR SUM
		-- 1 0 0 1  1
		-- 1 0 1 0  1
		-- 1 0 1 1  0
		-- 1 1 0 0  1
		-- 1 1 0 1  0
		-- 1 1 1 0  0
		-- 1 1 1 1  1 => 96 (HIGH BYTE)
		----------------------------------
		first_lcell_in_carry_chain : stratix_lcell	-- special because it has no carry_in port, but the mask is the same as the rest
		GENERIC MAP (
			operation_mode => "arithmetic",
			synch_mode => "on",
			register_cascade_mode => "off",
			sum_lutc_input => "cin",
			lut_mask => "96E8",
			cin_used => "false",
			output_mode => "reg_only"
		)
		PORT MAP (
			clk => clk,
			aclr => reset,
			ena => ena,
			sclr => sreset,
			sload => sload,
			dataa => addR_in(0), 
			datab => addL_in(0),
			datac => loadval_in(0),
			regout => sum_out(0),
			inverta => InvertedAddnSub,
			cout => CarryChain(0)
		);
		addwithsload_per_bit_generate :
		FOR i IN 1 TO L-2 GENERATE
			unpadded_bit :
			IF (i < 1000) GENERATE
				main_wysi : stratix_lcell
				GENERIC MAP (
					operation_mode => "arithmetic",
					synch_mode => "on",
					register_cascade_mode => "off",
					sum_lutc_input => "cin",
					lut_mask => "96E8",
					cin_used => "true",
					output_mode => "reg_only"
				)
				PORT MAP (
					clk => clk,
					aclr => reset,
					ena => ena,
					sclr => sreset,
					sload => sload,
					dataa => addR_in(i), 
					datab => addL_in(i),
					datac => loadval_in(i),
					cin => CarryChain(i-1),
					cout => CarryChain(i),
					inverta => InvertedAddnSub,
					regout => sum_out(i)
				);
			END GENERATE;
			padded_bit :
			IF (i > 1000) GENERATE
				cp1 : fir_ramp_rtl_CarryPropagator PORT MAP (cin => CarryChain(i-1), cout => Padding(i/4-1), inverta => InvertedAddnSub);
				cp2 : fir_ramp_rtl_CarryPropagator PORT MAP (cin => Padding(i/4-1), cout => Padding(i/4), inverta => InvertedAddnSub);
				main_wysi : stratix_lcell
				GENERIC MAP (
					operation_mode => "arithmetic",
					synch_mode => "on",
					register_cascade_mode => "off",
					sum_lutc_input => "cin",
					lut_mask => "96E8",
					cin_used => "true",
					output_mode => "reg_only"
				)
				PORT MAP (
					clk => clk,
					aclr => reset,
					ena => ena,
					sclr => sreset,
					sload => sload,
					dataa => addR_in(i), 
					datab => addL_in(i),
					datac => loadval_in(i),
					cin => Padding(i/4),
					cout => CarryChain(i),
					inverta => InvertedAddnSub,
					regout => sum_out(i)
				);
			END GENERATE;
		END GENERATE;
		addwithsload_topbit : stratix_lcell
		----------------------------------
		-- Calculate sum irrespective of D input
		----------------------------------
		-- D C B A  Z
		----------------------------------
		-- 0 0 0 0  0
		-- 0 0 0 1  1
		-- 0 0 1 0  1
		-- 0 0 1 1  0
		-- 0 1 0 0  1
		-- 0 1 0 1  0
		-- 0 1 1 0  0
		-- 0 1 1 1  1
		----------
		-- 1 0 0 0  0
		-- 1 0 0 1  1
		-- 1 0 1 0  1
		-- 1 0 1 1  0
		-- 1 1 0 0  1
		-- 1 1 0 1  0
		-- 1 1 1 0  0
		-- 1 1 1 1  1 => 9696
		----------------------------------
		GENERIC MAP (
			operation_mode => "normal",
			synch_mode => "on",
			register_cascade_mode => "off",
			sum_lutc_input => "cin",
			lut_mask => "9696",
			cin_used => "true",
			output_mode => "reg_only"
		)
		PORT MAP (
			clk => clk,
			aclr => reset,
			ena => ena,
			sclr => sreset,
			sload => sload,
			dataa => addR_in(L-1), 
			datab => addL_in(L-1),
			datac => loadval_in(L-1),
			cin => CarryChain(L-2),
			inverta => InvertedAddnSub,
			regout => sum_out(L-1)
		);
	END GENERATE;
			
END RTL;
