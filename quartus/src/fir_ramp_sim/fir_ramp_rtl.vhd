----------------------------------------------------------------------------- 
-- Altera DSP Builder Advanced Flow Tools Release Version 0.0.0 (Built: TIMESTAMP_ADDED_DURING_BUILD)
-- Quartus II development tool and MATLAB/Simulink Interface
-- 
-- Legal Notice: � 2011 Altera Corporation.  All rights reserved. Your use of 
-- Altera  Corporation's design tools, logic functions and other software and 
-- tools, and its AMPP  partner logic functions, and  any output files any of 
-- the  foregoing device programming or simulation files), and any associated 
-- documentation  or  information  are  expressly  subject  to  the terms and 
-- conditions of the  Altera  Program License  Subscription Agreement, Altera 
-- MegaCore Function License Agreement, or other applicable license agreement,
-- including, without  limitation, that  your use  is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by Altera or its 
-- authorized  distributors.  Please refer to  the  applicable  agreement for 
-- further details.
----------------------------------------------------------------------------- 

-- VHDL created from fir_ramp_rtl
-- VHDL created on Fri Jun  8 19:31:24 2012


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;
use std.TextIO.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
LIBRARY lpm;
USE lpm.lpm_components.all;

-- Text written from /build/swbuild/SJ/nightly/11.1/173/l32/p4/ip/aion/src/mip_common/hw_model.cpp:1213
entity fir_ramp_rtl is
    port (
        xIn_v : in std_logic_vector(0 downto 0);
        xIn_c : in std_logic_vector(7 downto 0);
        xIn_0 : in std_logic_vector(7 downto 0);
        xOut_v : out std_logic_vector(0 downto 0);
        xOut_c : out std_logic_vector(7 downto 0);
        xOut_0 : out std_logic_vector(25 downto 0);
        clk : in std_logic;
        areset : in std_logic;
        bus_clk : in std_logic;
        h_areset : in std_logic
        );
end;

architecture normal of fir_ramp_rtl is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name NOT_GATE_PUSH_BACK OFF; -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410";

    signal GND_q : std_logic_vector (0 downto 0);
    signal VCC_q : std_logic_vector (0 downto 0);
    signal d_in0_m0_wi0_wo0_assign_sel_q_11_q : std_logic_vector (0 downto 0);
    signal d_in0_m0_wi0_wo0_assign_sel_q_12_q : std_logic_vector (0 downto 0);
    signal d_in0_m0_wi0_wo0_assign_sel_q_17_q : std_logic_vector (0 downto 0);
    signal d_in0_m0_wi0_wo0_assign_sel_q_17_v_0 : std_logic_vector (0 downto 0);
    signal d_in0_m0_wi0_wo0_assign_sel_q_17_v_1 : std_logic_vector (0 downto 0);
    signal d_in0_m0_wi0_wo0_assign_sel_q_17_v_2 : std_logic_vector (0 downto 0);
    signal d_in0_m0_wi0_wo0_assign_sel_q_17_v_3 : std_logic_vector (0 downto 0);
    signal d_u0_m0_wo0_wi0_phasedelay0_q_12_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_phasedelay0_q_12_v_0 : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr1_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr2_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr2_q_12_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr2_q_12_v_0 : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr3_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr4_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr4_q_12_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr4_q_12_v_0 : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr5_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr6_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr6_q_12_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr6_q_12_v_0 : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr7_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr8_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr8_q_12_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr8_q_12_v_0 : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr9_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr10_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr10_q_12_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr10_q_12_v_0 : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr11_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr12_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr12_q_12_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr12_q_12_v_0 : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr13_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr14_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr14_q_12_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr14_q_12_v_0 : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr15_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr16_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr16_q_12_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr16_q_12_v_0 : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr17_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr18_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr18_q_11_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr19_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr20_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr20_q_12_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr20_q_12_v_0 : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr21_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr22_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr22_q_11_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr23_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr24_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr24_q_11_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr25_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr26_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr26_q_11_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr27_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr28_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr29_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr30_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr31_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr31_q_12_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr31_q_12_v_0 : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr33_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr34_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr35_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr35_q_11_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr36_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr37_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr38_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr39_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr40_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr41_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr42_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr43_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr43_q_12_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr44_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr45_q : std_logic_vector (7 downto 0);
    signal d_u0_m0_wo0_wi0_delayr45_q_12_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr46_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr47_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr48_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr49_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr50_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr51_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr52_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr53_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr54_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr55_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr56_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr57_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr58_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr59_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr60_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr61_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr62_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_wi0_delayr63_q : std_logic_vector (7 downto 0);
    signal u0_m0_wo0_sym_add0_a : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add0_b : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add0_o : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add0_q : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add2_a : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add2_b : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add2_o : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add2_q : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add4_a : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add4_b : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add4_o : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add4_q : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add6_a : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add6_b : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add6_o : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add6_q : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add8_a : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add8_b : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add8_o : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add8_q : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add10_a : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add10_b : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add10_o : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add10_q : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add12_a : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add12_b : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add12_o : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add12_q : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add14_a : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add14_b : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add14_o : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add14_q : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add16_a : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add16_b : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add16_o : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add16_q : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add18_a : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add18_b : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add18_o : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add18_q : std_logic_vector (8 downto 0);
    signal d_u0_m0_wo0_sym_add18_q_13_q : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add20_a : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add20_b : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add20_o : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add20_q : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add22_a : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add22_b : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add22_o : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add22_q : std_logic_vector (8 downto 0);
    signal d_u0_m0_wo0_sym_add22_q_13_q : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add24_a : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add24_b : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add24_o : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add24_q : std_logic_vector (8 downto 0);
    signal d_u0_m0_wo0_sym_add24_q_13_q : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add26_a : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add26_b : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add26_o : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add26_q : std_logic_vector (8 downto 0);
    signal d_u0_m0_wo0_sym_add26_q_13_q : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add28_a : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add28_b : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add28_o : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add28_q : std_logic_vector (8 downto 0);
    signal d_u0_m0_wo0_sym_add28_q_12_q : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add30_a : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add30_b : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add30_o : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add30_q : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add31_a : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add31_b : std_logic_vector(8 downto 0);
    signal u0_m0_wo0_sym_add31_i : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add31_o : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add31_q : std_logic_vector (8 downto 0);
    signal u0_m0_wo0_sym_add31_reset : std_logic;
    COMPONENT fir_ramp_rtl_AddWithSload IS
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
    END COMPONENT;
    signal u0_m0_wo0_mtree_add0_0_a : std_logic_vector(13 downto 0);
    signal u0_m0_wo0_mtree_add0_0_b : std_logic_vector(13 downto 0);
    signal u0_m0_wo0_mtree_add0_0_o : std_logic_vector (13 downto 0);
    signal u0_m0_wo0_mtree_add0_0_q : std_logic_vector (13 downto 0);
    signal u0_m0_wo0_mtree_add0_1_a : std_logic_vector(14 downto 0);
    signal u0_m0_wo0_mtree_add0_1_b : std_logic_vector(14 downto 0);
    signal u0_m0_wo0_mtree_add0_1_o : std_logic_vector (14 downto 0);
    signal u0_m0_wo0_mtree_add0_1_q : std_logic_vector (14 downto 0);
    signal u0_m0_wo0_mtree_add0_2_a : std_logic_vector(16 downto 0);
    signal u0_m0_wo0_mtree_add0_2_b : std_logic_vector(16 downto 0);
    signal u0_m0_wo0_mtree_add0_2_o : std_logic_vector (16 downto 0);
    signal u0_m0_wo0_mtree_add0_2_q : std_logic_vector (16 downto 0);
    signal u0_m0_wo0_mtree_add0_3_a : std_logic_vector(23 downto 0);
    signal u0_m0_wo0_mtree_add0_3_b : std_logic_vector(23 downto 0);
    signal u0_m0_wo0_mtree_add0_3_o : std_logic_vector (23 downto 0);
    signal u0_m0_wo0_mtree_add0_3_q : std_logic_vector (23 downto 0);
    signal u0_m0_wo0_mtree_add1_0_a : std_logic_vector(15 downto 0);
    signal u0_m0_wo0_mtree_add1_0_b : std_logic_vector(15 downto 0);
    signal u0_m0_wo0_mtree_add1_0_o : std_logic_vector (15 downto 0);
    signal u0_m0_wo0_mtree_add1_0_q : std_logic_vector (15 downto 0);
    signal u0_m0_wo0_mtree_add1_1_a : std_logic_vector(24 downto 0);
    signal u0_m0_wo0_mtree_add1_1_b : std_logic_vector(24 downto 0);
    signal u0_m0_wo0_mtree_add1_1_o : std_logic_vector (24 downto 0);
    signal u0_m0_wo0_mtree_add1_1_q : std_logic_vector (24 downto 0);
    signal u0_m0_wo0_mtree_add2_0_a : std_logic_vector(25 downto 0);
    signal u0_m0_wo0_mtree_add2_0_b : std_logic_vector(25 downto 0);
    signal u0_m0_wo0_mtree_add2_0_o : std_logic_vector (25 downto 0);
    signal u0_m0_wo0_mtree_add2_0_q : std_logic_vector (25 downto 0);
    signal u0_m0_wo0_oseq_gated_reg_q : std_logic_vector (0 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult0_add_1_a : std_logic_vector(12 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult0_add_1_b : std_logic_vector(12 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult0_add_1_o : std_logic_vector (12 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult0_add_1_q : std_logic_vector (12 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult0_sub_3_a : std_logic_vector(14 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult0_sub_3_b : std_logic_vector(14 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult0_sub_3_o : std_logic_vector (14 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult0_sub_3_q : std_logic_vector (14 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult2_sub_1_a : std_logic_vector(14 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult2_sub_1_b : std_logic_vector(14 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult2_sub_1_o : std_logic_vector (14 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult2_sub_1_q : std_logic_vector (14 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult2_sub_3_a : std_logic_vector(11 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult2_sub_3_b : std_logic_vector(11 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult2_sub_3_o : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult2_sub_3_q : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult2_add_5_a : std_logic_vector(19 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult2_add_5_b : std_logic_vector(19 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult2_add_5_o : std_logic_vector (19 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult2_add_5_q : std_logic_vector (19 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult3_sub_1_a : std_logic_vector(20 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult3_sub_1_b : std_logic_vector(20 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult3_sub_1_o : std_logic_vector (20 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult3_sub_1_q : std_logic_vector (20 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_sum2_a : std_logic_vector(21 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_sum2_b : std_logic_vector(21 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_sum2_o : std_logic_vector (21 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_sum2_q : std_logic_vector (21 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_sum_final_a : std_logic_vector(22 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_sum_final_b : std_logic_vector(22 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_sum_final_o : std_logic_vector (22 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_sum_final_q : std_logic_vector (22 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_constmult0_sub_0_a : std_logic_vector(9 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_constmult0_sub_0_b : std_logic_vector(9 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_constmult0_sub_0_o : std_logic_vector (9 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_constmult0_sub_0_q : std_logic_vector (9 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_constmult0_sub_2_a : std_logic_vector(13 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_constmult0_sub_2_b : std_logic_vector(13 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_constmult0_sub_2_o : std_logic_vector (13 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_constmult0_sub_2_q : std_logic_vector (13 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_constmult2_sub_0_a : std_logic_vector(9 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_constmult2_sub_0_b : std_logic_vector(9 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_constmult2_sub_0_o : std_logic_vector (9 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_constmult2_sub_0_q : std_logic_vector (9 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_constmult2_sub_2_a : std_logic_vector(14 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_constmult2_sub_2_b : std_logic_vector(14 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_constmult2_sub_2_o : std_logic_vector (14 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_constmult2_sub_2_q : std_logic_vector (14 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_sum2_a : std_logic_vector(15 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_sum2_b : std_logic_vector(15 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_sum2_o : std_logic_vector (15 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_sum2_q : std_logic_vector (15 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_constmult0_sub_1_a : std_logic_vector(12 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_constmult0_sub_1_b : std_logic_vector(12 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_constmult0_sub_1_o : std_logic_vector (12 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_constmult0_sub_1_q : std_logic_vector (12 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_constmult2_sub_1_a : std_logic_vector(10 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_constmult2_sub_1_b : std_logic_vector(10 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_constmult2_sub_1_o : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_constmult2_sub_1_q : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_constmult2_sub_3_a : std_logic_vector(12 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_constmult2_sub_3_b : std_logic_vector(12 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_constmult2_sub_3_o : std_logic_vector (12 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_constmult2_sub_3_q : std_logic_vector (12 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_sum2_a : std_logic_vector(13 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_sum2_b : std_logic_vector(13 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_sum2_o : std_logic_vector (13 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_sum2_q : std_logic_vector (13 downto 0);
    signal u0_m0_wo0_mtree_madd4_4_constmult0_sub_1_a : std_logic_vector(11 downto 0);
    signal u0_m0_wo0_mtree_madd4_4_constmult0_sub_1_b : std_logic_vector(11 downto 0);
    signal u0_m0_wo0_mtree_madd4_4_constmult0_sub_1_o : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_4_constmult0_sub_1_q : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_4_constmult2_sub_0_a : std_logic_vector(9 downto 0);
    signal u0_m0_wo0_mtree_madd4_4_constmult2_sub_0_b : std_logic_vector(9 downto 0);
    signal u0_m0_wo0_mtree_madd4_4_constmult2_sub_0_o : std_logic_vector (9 downto 0);
    signal u0_m0_wo0_mtree_madd4_4_constmult2_sub_0_q : std_logic_vector (9 downto 0);
    signal u0_m0_wo0_mtree_madd4_4_constmult2_sub_2_a : std_logic_vector(11 downto 0);
    signal u0_m0_wo0_mtree_madd4_4_constmult2_sub_2_b : std_logic_vector(11 downto 0);
    signal u0_m0_wo0_mtree_madd4_4_constmult2_sub_2_o : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_4_constmult2_sub_2_q : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_4_sum2_a : std_logic_vector(12 downto 0);
    signal u0_m0_wo0_mtree_madd4_4_sum2_b : std_logic_vector(12 downto 0);
    signal u0_m0_wo0_mtree_madd4_4_sum2_o : std_logic_vector (12 downto 0);
    signal u0_m0_wo0_mtree_madd4_4_sum2_q : std_logic_vector (12 downto 0);
    signal u0_m0_wo0_mtree_madd4_3_constmult0_sub_1_a : std_logic_vector(11 downto 0);
    signal u0_m0_wo0_mtree_madd4_3_constmult0_sub_1_b : std_logic_vector(11 downto 0);
    signal u0_m0_wo0_mtree_madd4_3_constmult0_sub_1_o : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_3_constmult0_sub_1_q : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_3_constmult2_sub_1_a : std_logic_vector(11 downto 0);
    signal u0_m0_wo0_mtree_madd4_3_constmult2_sub_1_b : std_logic_vector(11 downto 0);
    signal u0_m0_wo0_mtree_madd4_3_constmult2_sub_1_o : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_3_constmult2_sub_1_q : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_3_sum2_a : std_logic_vector(12 downto 0);
    signal u0_m0_wo0_mtree_madd4_3_sum2_b : std_logic_vector(12 downto 0);
    signal u0_m0_wo0_mtree_madd4_3_sum2_o : std_logic_vector (12 downto 0);
    signal u0_m0_wo0_mtree_madd4_3_sum2_q : std_logic_vector (12 downto 0);
    signal u0_m0_wo0_mtree_madd4_2_constmult0_sub_1_a : std_logic_vector(10 downto 0);
    signal u0_m0_wo0_mtree_madd4_2_constmult0_sub_1_b : std_logic_vector(10 downto 0);
    signal u0_m0_wo0_mtree_madd4_2_constmult0_sub_1_o : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_2_constmult0_sub_1_q : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_2_constmult2_sub_1_a : std_logic_vector(10 downto 0);
    signal u0_m0_wo0_mtree_madd4_2_constmult2_sub_1_b : std_logic_vector(10 downto 0);
    signal u0_m0_wo0_mtree_madd4_2_constmult2_sub_1_o : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_2_constmult2_sub_1_q : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_2_sum2_a : std_logic_vector(11 downto 0);
    signal u0_m0_wo0_mtree_madd4_2_sum2_b : std_logic_vector(11 downto 0);
    signal u0_m0_wo0_mtree_madd4_2_sum2_o : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_2_sum2_q : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_1_constmult0_sub_1_a : std_logic_vector(10 downto 0);
    signal u0_m0_wo0_mtree_madd4_1_constmult0_sub_1_b : std_logic_vector(10 downto 0);
    signal u0_m0_wo0_mtree_madd4_1_constmult0_sub_1_o : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_1_constmult0_sub_1_q : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_1_constmult2_sub_1_a : std_logic_vector(10 downto 0);
    signal u0_m0_wo0_mtree_madd4_1_constmult2_sub_1_b : std_logic_vector(10 downto 0);
    signal u0_m0_wo0_mtree_madd4_1_constmult2_sub_1_o : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_1_constmult2_sub_1_q : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_1_sum2_a : std_logic_vector(11 downto 0);
    signal u0_m0_wo0_mtree_madd4_1_sum2_b : std_logic_vector(11 downto 0);
    signal u0_m0_wo0_mtree_madd4_1_sum2_o : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_1_sum2_q : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_constmult0_sub_1_a : std_logic_vector(10 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_constmult0_sub_1_b : std_logic_vector(10 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_constmult0_sub_1_o : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_constmult0_sub_1_q : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_constmult2_sub_1_a : std_logic_vector(10 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_constmult2_sub_1_b : std_logic_vector(10 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_constmult2_sub_1_o : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_constmult2_sub_1_q : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_sum2_a : std_logic_vector(11 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_sum2_b : std_logic_vector(11 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_sum2_o : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_sum2_q : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_constmult0_shift0_q_int : std_logic_vector (9 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_constmult0_shift0_q : std_logic_vector (9 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_constmult2_shift0_q_int : std_logic_vector (9 downto 0);
    signal u0_m0_wo0_mtree_madd4_0_constmult2_shift0_q : std_logic_vector (9 downto 0);
    signal u0_m0_wo0_mtree_madd4_1_constmult0_shift0_q_int : std_logic_vector (9 downto 0);
    signal u0_m0_wo0_mtree_madd4_1_constmult0_shift0_q : std_logic_vector (9 downto 0);
    signal u0_m0_wo0_mtree_madd4_1_constmult2_shift0_q_int : std_logic_vector (9 downto 0);
    signal u0_m0_wo0_mtree_madd4_1_constmult2_shift0_q : std_logic_vector (9 downto 0);
    signal u0_m0_wo0_mtree_madd4_2_constmult0_shift0_q_int : std_logic_vector (9 downto 0);
    signal u0_m0_wo0_mtree_madd4_2_constmult0_shift0_q : std_logic_vector (9 downto 0);
    signal u0_m0_wo0_mtree_madd4_2_constmult2_shift0_q_int : std_logic_vector (9 downto 0);
    signal u0_m0_wo0_mtree_madd4_2_constmult2_shift0_q : std_logic_vector (9 downto 0);
    signal u0_m0_wo0_mtree_madd4_3_constmult0_shift0_q_int : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_3_constmult0_shift0_q : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_3_constmult2_shift0_q_int : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_3_constmult2_shift0_q : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_4_constmult0_shift0_q_int : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_4_constmult0_shift0_q : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_4_constmult2_shift1_q_int : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_4_constmult2_shift1_q : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_constmult0_shift0_q_int : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_constmult0_shift0_q : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_constmult2_shift0_q_int : std_logic_vector (9 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_constmult2_shift0_q : std_logic_vector (9 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_constmult2_shift2_q_int : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_5_constmult2_shift2_q : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_constmult0_shift1_q_int : std_logic_vector (12 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_constmult0_shift1_q : std_logic_vector (12 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_constmult2_shift1_q_int : std_logic_vector (13 downto 0);
    signal u0_m0_wo0_mtree_madd4_6_constmult2_shift1_q : std_logic_vector (13 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult0_shift0_q_int : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult0_shift0_q : std_logic_vector (11 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult0_shift2_q_int : std_logic_vector (13 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult0_shift2_q : std_logic_vector (13 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult2_shift0_q_int : std_logic_vector (13 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult2_shift0_q : std_logic_vector (13 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult2_shift2_q_int : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult2_shift2_q : std_logic_vector (10 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult3_shift0_q_int : std_logic_vector (19 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult3_shift0_q : std_logic_vector (19 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult0_shift4_q_int : std_logic_vector (16 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult0_shift4_q : std_logic_vector (16 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult2_shift4_q_int : std_logic_vector (18 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult2_shift4_q : std_logic_vector (18 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult2_shift6_q_int : std_logic_vector (20 downto 0);
    signal u0_m0_wo0_mtree_madd4_7_constmult2_shift6_q : std_logic_vector (20 downto 0);
begin


	--GND(CONSTANT,1)@12
    GND_q <= "0";

	--VCC(CONSTANT,2)@0
    VCC_q <= "1";

	--xIn(PORTIN,3)@10

	--d_in0_m0_wi0_wo0_assign_sel_q_11(DELAY,225)@10
    d_in0_m0_wi0_wo0_assign_sel_q_11: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_in0_m0_wi0_wo0_assign_sel_q_11_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_in0_m0_wi0_wo0_assign_sel_q_11_q <= xIn_v;
        END IF;
    END PROCESS;


	--d_in0_m0_wi0_wo0_assign_sel_q_12(DELAY,226)@11
    d_in0_m0_wi0_wo0_assign_sel_q_12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_in0_m0_wi0_wo0_assign_sel_q_12_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_in0_m0_wi0_wo0_assign_sel_q_12_q <= d_in0_m0_wi0_wo0_assign_sel_q_11_q;
        END IF;
    END PROCESS;


	--d_in0_m0_wi0_wo0_assign_sel_q_17(DELAY,227)@12
    d_in0_m0_wi0_wo0_assign_sel_q_17: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_in0_m0_wi0_wo0_assign_sel_q_17_v_0 <= (others => '0');
            d_in0_m0_wi0_wo0_assign_sel_q_17_v_1 <= (others => '0');
            d_in0_m0_wi0_wo0_assign_sel_q_17_v_2 <= (others => '0');
            d_in0_m0_wi0_wo0_assign_sel_q_17_v_3 <= (others => '0');
            d_in0_m0_wi0_wo0_assign_sel_q_17_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_in0_m0_wi0_wo0_assign_sel_q_17_v_0 <= d_in0_m0_wi0_wo0_assign_sel_q_12_q;
            d_in0_m0_wi0_wo0_assign_sel_q_17_v_1 <= d_in0_m0_wi0_wo0_assign_sel_q_17_v_0;
            d_in0_m0_wi0_wo0_assign_sel_q_17_v_2 <= d_in0_m0_wi0_wo0_assign_sel_q_17_v_1;
            d_in0_m0_wi0_wo0_assign_sel_q_17_v_3 <= d_in0_m0_wi0_wo0_assign_sel_q_17_v_2;
            d_in0_m0_wi0_wo0_assign_sel_q_17_q <= d_in0_m0_wi0_wo0_assign_sel_q_17_v_3;
        END IF;
    END PROCESS;


	--d_u0_m0_wo0_wi0_phasedelay0_q_12(DELAY,228)@10
    d_u0_m0_wo0_wi0_phasedelay0_q_12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_wi0_phasedelay0_q_12_v_0 <= (others => '0');
            d_u0_m0_wo0_wi0_phasedelay0_q_12_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_wi0_phasedelay0_q_12_v_0 <= xIn_0;
            d_u0_m0_wo0_wi0_phasedelay0_q_12_q <= d_u0_m0_wo0_wi0_phasedelay0_q_12_v_0;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr1(DELAY,8)@10
    u0_m0_wo0_wi0_delayr1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr1_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr1_q <= xIn_0;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr2(DELAY,9)@10
    u0_m0_wo0_wi0_delayr2: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr2_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr2_q <= u0_m0_wo0_wi0_delayr1_q;
            END IF;
        END IF;
    END PROCESS;


	--d_u0_m0_wo0_wi0_delayr2_q_12(DELAY,229)@10
    d_u0_m0_wo0_wi0_delayr2_q_12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_wi0_delayr2_q_12_v_0 <= (others => '0');
            d_u0_m0_wo0_wi0_delayr2_q_12_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_wi0_delayr2_q_12_v_0 <= u0_m0_wo0_wi0_delayr2_q;
            d_u0_m0_wo0_wi0_delayr2_q_12_q <= d_u0_m0_wo0_wi0_delayr2_q_12_v_0;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr3(DELAY,10)@10
    u0_m0_wo0_wi0_delayr3: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr3_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr3_q <= u0_m0_wo0_wi0_delayr2_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr4(DELAY,11)@10
    u0_m0_wo0_wi0_delayr4: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr4_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr4_q <= u0_m0_wo0_wi0_delayr3_q;
            END IF;
        END IF;
    END PROCESS;


	--d_u0_m0_wo0_wi0_delayr4_q_12(DELAY,230)@10
    d_u0_m0_wo0_wi0_delayr4_q_12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_wi0_delayr4_q_12_v_0 <= (others => '0');
            d_u0_m0_wo0_wi0_delayr4_q_12_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_wi0_delayr4_q_12_v_0 <= u0_m0_wo0_wi0_delayr4_q;
            d_u0_m0_wo0_wi0_delayr4_q_12_q <= d_u0_m0_wo0_wi0_delayr4_q_12_v_0;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr5(DELAY,12)@10
    u0_m0_wo0_wi0_delayr5: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr5_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr5_q <= u0_m0_wo0_wi0_delayr4_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr6(DELAY,13)@10
    u0_m0_wo0_wi0_delayr6: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr6_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr6_q <= u0_m0_wo0_wi0_delayr5_q;
            END IF;
        END IF;
    END PROCESS;


	--d_u0_m0_wo0_wi0_delayr6_q_12(DELAY,231)@10
    d_u0_m0_wo0_wi0_delayr6_q_12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_wi0_delayr6_q_12_v_0 <= (others => '0');
            d_u0_m0_wo0_wi0_delayr6_q_12_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_wi0_delayr6_q_12_v_0 <= u0_m0_wo0_wi0_delayr6_q;
            d_u0_m0_wo0_wi0_delayr6_q_12_q <= d_u0_m0_wo0_wi0_delayr6_q_12_v_0;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr7(DELAY,14)@10
    u0_m0_wo0_wi0_delayr7: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr7_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr7_q <= u0_m0_wo0_wi0_delayr6_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr8(DELAY,15)@10
    u0_m0_wo0_wi0_delayr8: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr8_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr8_q <= u0_m0_wo0_wi0_delayr7_q;
            END IF;
        END IF;
    END PROCESS;


	--d_u0_m0_wo0_wi0_delayr8_q_12(DELAY,232)@10
    d_u0_m0_wo0_wi0_delayr8_q_12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_wi0_delayr8_q_12_v_0 <= (others => '0');
            d_u0_m0_wo0_wi0_delayr8_q_12_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_wi0_delayr8_q_12_v_0 <= u0_m0_wo0_wi0_delayr8_q;
            d_u0_m0_wo0_wi0_delayr8_q_12_q <= d_u0_m0_wo0_wi0_delayr8_q_12_v_0;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr9(DELAY,16)@10
    u0_m0_wo0_wi0_delayr9: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr9_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr9_q <= u0_m0_wo0_wi0_delayr8_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr10(DELAY,17)@10
    u0_m0_wo0_wi0_delayr10: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr10_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr10_q <= u0_m0_wo0_wi0_delayr9_q;
            END IF;
        END IF;
    END PROCESS;


	--d_u0_m0_wo0_wi0_delayr10_q_12(DELAY,233)@10
    d_u0_m0_wo0_wi0_delayr10_q_12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_wi0_delayr10_q_12_v_0 <= (others => '0');
            d_u0_m0_wo0_wi0_delayr10_q_12_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_wi0_delayr10_q_12_v_0 <= u0_m0_wo0_wi0_delayr10_q;
            d_u0_m0_wo0_wi0_delayr10_q_12_q <= d_u0_m0_wo0_wi0_delayr10_q_12_v_0;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr11(DELAY,18)@10
    u0_m0_wo0_wi0_delayr11: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr11_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr11_q <= u0_m0_wo0_wi0_delayr10_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr12(DELAY,19)@10
    u0_m0_wo0_wi0_delayr12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr12_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr12_q <= u0_m0_wo0_wi0_delayr11_q;
            END IF;
        END IF;
    END PROCESS;


	--d_u0_m0_wo0_wi0_delayr12_q_12(DELAY,234)@10
    d_u0_m0_wo0_wi0_delayr12_q_12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_wi0_delayr12_q_12_v_0 <= (others => '0');
            d_u0_m0_wo0_wi0_delayr12_q_12_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_wi0_delayr12_q_12_v_0 <= u0_m0_wo0_wi0_delayr12_q;
            d_u0_m0_wo0_wi0_delayr12_q_12_q <= d_u0_m0_wo0_wi0_delayr12_q_12_v_0;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr13(DELAY,20)@10
    u0_m0_wo0_wi0_delayr13: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr13_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr13_q <= u0_m0_wo0_wi0_delayr12_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr14(DELAY,21)@10
    u0_m0_wo0_wi0_delayr14: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr14_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr14_q <= u0_m0_wo0_wi0_delayr13_q;
            END IF;
        END IF;
    END PROCESS;


	--d_u0_m0_wo0_wi0_delayr14_q_12(DELAY,235)@10
    d_u0_m0_wo0_wi0_delayr14_q_12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_wi0_delayr14_q_12_v_0 <= (others => '0');
            d_u0_m0_wo0_wi0_delayr14_q_12_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_wi0_delayr14_q_12_v_0 <= u0_m0_wo0_wi0_delayr14_q;
            d_u0_m0_wo0_wi0_delayr14_q_12_q <= d_u0_m0_wo0_wi0_delayr14_q_12_v_0;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr15(DELAY,22)@10
    u0_m0_wo0_wi0_delayr15: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr15_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr15_q <= u0_m0_wo0_wi0_delayr14_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr16(DELAY,23)@10
    u0_m0_wo0_wi0_delayr16: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr16_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr16_q <= u0_m0_wo0_wi0_delayr15_q;
            END IF;
        END IF;
    END PROCESS;


	--d_u0_m0_wo0_wi0_delayr16_q_12(DELAY,236)@10
    d_u0_m0_wo0_wi0_delayr16_q_12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_wi0_delayr16_q_12_v_0 <= (others => '0');
            d_u0_m0_wo0_wi0_delayr16_q_12_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_wi0_delayr16_q_12_v_0 <= u0_m0_wo0_wi0_delayr16_q;
            d_u0_m0_wo0_wi0_delayr16_q_12_q <= d_u0_m0_wo0_wi0_delayr16_q_12_v_0;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr17(DELAY,24)@10
    u0_m0_wo0_wi0_delayr17: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr17_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr17_q <= u0_m0_wo0_wi0_delayr16_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr18(DELAY,25)@10
    u0_m0_wo0_wi0_delayr18: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr18_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr18_q <= u0_m0_wo0_wi0_delayr17_q;
            END IF;
        END IF;
    END PROCESS;


	--d_u0_m0_wo0_wi0_delayr18_q_11(DELAY,237)@10
    d_u0_m0_wo0_wi0_delayr18_q_11: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_wi0_delayr18_q_11_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_wi0_delayr18_q_11_q <= u0_m0_wo0_wi0_delayr18_q;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr19(DELAY,26)@10
    u0_m0_wo0_wi0_delayr19: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr19_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr19_q <= u0_m0_wo0_wi0_delayr18_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr20(DELAY,27)@10
    u0_m0_wo0_wi0_delayr20: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr20_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr20_q <= u0_m0_wo0_wi0_delayr19_q;
            END IF;
        END IF;
    END PROCESS;


	--d_u0_m0_wo0_wi0_delayr20_q_12(DELAY,238)@10
    d_u0_m0_wo0_wi0_delayr20_q_12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_wi0_delayr20_q_12_v_0 <= (others => '0');
            d_u0_m0_wo0_wi0_delayr20_q_12_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_wi0_delayr20_q_12_v_0 <= u0_m0_wo0_wi0_delayr20_q;
            d_u0_m0_wo0_wi0_delayr20_q_12_q <= d_u0_m0_wo0_wi0_delayr20_q_12_v_0;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr21(DELAY,28)@10
    u0_m0_wo0_wi0_delayr21: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr21_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr21_q <= u0_m0_wo0_wi0_delayr20_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr22(DELAY,29)@10
    u0_m0_wo0_wi0_delayr22: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr22_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr22_q <= u0_m0_wo0_wi0_delayr21_q;
            END IF;
        END IF;
    END PROCESS;


	--d_u0_m0_wo0_wi0_delayr22_q_11(DELAY,239)@10
    d_u0_m0_wo0_wi0_delayr22_q_11: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_wi0_delayr22_q_11_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_wi0_delayr22_q_11_q <= u0_m0_wo0_wi0_delayr22_q;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr23(DELAY,30)@10
    u0_m0_wo0_wi0_delayr23: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr23_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr23_q <= u0_m0_wo0_wi0_delayr22_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr24(DELAY,31)@10
    u0_m0_wo0_wi0_delayr24: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr24_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr24_q <= u0_m0_wo0_wi0_delayr23_q;
            END IF;
        END IF;
    END PROCESS;


	--d_u0_m0_wo0_wi0_delayr24_q_11(DELAY,240)@10
    d_u0_m0_wo0_wi0_delayr24_q_11: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_wi0_delayr24_q_11_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_wi0_delayr24_q_11_q <= u0_m0_wo0_wi0_delayr24_q;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr25(DELAY,32)@10
    u0_m0_wo0_wi0_delayr25: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr25_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr25_q <= u0_m0_wo0_wi0_delayr24_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr26(DELAY,33)@10
    u0_m0_wo0_wi0_delayr26: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr26_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr26_q <= u0_m0_wo0_wi0_delayr25_q;
            END IF;
        END IF;
    END PROCESS;


	--d_u0_m0_wo0_wi0_delayr26_q_11(DELAY,241)@10
    d_u0_m0_wo0_wi0_delayr26_q_11: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_wi0_delayr26_q_11_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_wi0_delayr26_q_11_q <= u0_m0_wo0_wi0_delayr26_q;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr27(DELAY,34)@10
    u0_m0_wo0_wi0_delayr27: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr27_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr27_q <= u0_m0_wo0_wi0_delayr26_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr28(DELAY,35)@10
    u0_m0_wo0_wi0_delayr28: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr28_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr28_q <= u0_m0_wo0_wi0_delayr27_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr29(DELAY,36)@10
    u0_m0_wo0_wi0_delayr29: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr29_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr29_q <= u0_m0_wo0_wi0_delayr28_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr30(DELAY,37)@10
    u0_m0_wo0_wi0_delayr30: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr30_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr30_q <= u0_m0_wo0_wi0_delayr29_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr31(DELAY,38)@10
    u0_m0_wo0_wi0_delayr31: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr31_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr31_q <= u0_m0_wo0_wi0_delayr30_q;
            END IF;
        END IF;
    END PROCESS;


	--d_u0_m0_wo0_wi0_delayr31_q_12(DELAY,242)@10
    d_u0_m0_wo0_wi0_delayr31_q_12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_wi0_delayr31_q_12_v_0 <= (others => '0');
            d_u0_m0_wo0_wi0_delayr31_q_12_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_wi0_delayr31_q_12_v_0 <= u0_m0_wo0_wi0_delayr31_q;
            d_u0_m0_wo0_wi0_delayr31_q_12_q <= d_u0_m0_wo0_wi0_delayr31_q_12_v_0;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr33(DELAY,40)@10
    u0_m0_wo0_wi0_delayr33: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr33_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr33_q <= u0_m0_wo0_wi0_delayr31_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr34(DELAY,41)@10
    u0_m0_wo0_wi0_delayr34: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr34_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr34_q <= u0_m0_wo0_wi0_delayr33_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr35(DELAY,42)@10
    u0_m0_wo0_wi0_delayr35: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr35_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (xIn_v = "1") THEN
                u0_m0_wo0_wi0_delayr35_q <= u0_m0_wo0_wi0_delayr34_q;
            END IF;
        END IF;
    END PROCESS;


	--d_u0_m0_wo0_wi0_delayr35_q_11(DELAY,243)@10
    d_u0_m0_wo0_wi0_delayr35_q_11: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_wi0_delayr35_q_11_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_wi0_delayr35_q_11_q <= u0_m0_wo0_wi0_delayr35_q;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr36(DELAY,43)@11
    u0_m0_wo0_wi0_delayr36: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr36_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_11_q = "1") THEN
                u0_m0_wo0_wi0_delayr36_q <= d_u0_m0_wo0_wi0_delayr35_q_11_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr37(DELAY,44)@11
    u0_m0_wo0_wi0_delayr37: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr37_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_11_q = "1") THEN
                u0_m0_wo0_wi0_delayr37_q <= u0_m0_wo0_wi0_delayr36_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr38(DELAY,45)@11
    u0_m0_wo0_wi0_delayr38: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr38_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_11_q = "1") THEN
                u0_m0_wo0_wi0_delayr38_q <= u0_m0_wo0_wi0_delayr37_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr39(DELAY,46)@11
    u0_m0_wo0_wi0_delayr39: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr39_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_11_q = "1") THEN
                u0_m0_wo0_wi0_delayr39_q <= u0_m0_wo0_wi0_delayr38_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr40(DELAY,47)@11
    u0_m0_wo0_wi0_delayr40: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr40_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_11_q = "1") THEN
                u0_m0_wo0_wi0_delayr40_q <= u0_m0_wo0_wi0_delayr39_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr41(DELAY,48)@11
    u0_m0_wo0_wi0_delayr41: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr41_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_11_q = "1") THEN
                u0_m0_wo0_wi0_delayr41_q <= u0_m0_wo0_wi0_delayr40_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr42(DELAY,49)@11
    u0_m0_wo0_wi0_delayr42: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr42_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_11_q = "1") THEN
                u0_m0_wo0_wi0_delayr42_q <= u0_m0_wo0_wi0_delayr41_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr43(DELAY,50)@11
    u0_m0_wo0_wi0_delayr43: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr43_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_11_q = "1") THEN
                u0_m0_wo0_wi0_delayr43_q <= u0_m0_wo0_wi0_delayr42_q;
            END IF;
        END IF;
    END PROCESS;


	--d_u0_m0_wo0_wi0_delayr43_q_12(DELAY,244)@11
    d_u0_m0_wo0_wi0_delayr43_q_12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_wi0_delayr43_q_12_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_wi0_delayr43_q_12_q <= u0_m0_wo0_wi0_delayr43_q;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr44(DELAY,51)@11
    u0_m0_wo0_wi0_delayr44: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr44_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_11_q = "1") THEN
                u0_m0_wo0_wi0_delayr44_q <= u0_m0_wo0_wi0_delayr43_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr45(DELAY,52)@11
    u0_m0_wo0_wi0_delayr45: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr45_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_11_q = "1") THEN
                u0_m0_wo0_wi0_delayr45_q <= u0_m0_wo0_wi0_delayr44_q;
            END IF;
        END IF;
    END PROCESS;


	--d_u0_m0_wo0_wi0_delayr45_q_12(DELAY,245)@11
    d_u0_m0_wo0_wi0_delayr45_q_12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_wi0_delayr45_q_12_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_wi0_delayr45_q_12_q <= u0_m0_wo0_wi0_delayr45_q;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr46(DELAY,53)@12
    u0_m0_wo0_wi0_delayr46: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr46_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_12_q = "1") THEN
                u0_m0_wo0_wi0_delayr46_q <= d_u0_m0_wo0_wi0_delayr45_q_12_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr47(DELAY,54)@12
    u0_m0_wo0_wi0_delayr47: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr47_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_12_q = "1") THEN
                u0_m0_wo0_wi0_delayr47_q <= u0_m0_wo0_wi0_delayr46_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr48(DELAY,55)@12
    u0_m0_wo0_wi0_delayr48: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr48_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_12_q = "1") THEN
                u0_m0_wo0_wi0_delayr48_q <= u0_m0_wo0_wi0_delayr47_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr49(DELAY,56)@12
    u0_m0_wo0_wi0_delayr49: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr49_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_12_q = "1") THEN
                u0_m0_wo0_wi0_delayr49_q <= u0_m0_wo0_wi0_delayr48_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr50(DELAY,57)@12
    u0_m0_wo0_wi0_delayr50: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr50_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_12_q = "1") THEN
                u0_m0_wo0_wi0_delayr50_q <= u0_m0_wo0_wi0_delayr49_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr51(DELAY,58)@12
    u0_m0_wo0_wi0_delayr51: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr51_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_12_q = "1") THEN
                u0_m0_wo0_wi0_delayr51_q <= u0_m0_wo0_wi0_delayr50_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr52(DELAY,59)@12
    u0_m0_wo0_wi0_delayr52: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr52_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_12_q = "1") THEN
                u0_m0_wo0_wi0_delayr52_q <= u0_m0_wo0_wi0_delayr51_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr53(DELAY,60)@12
    u0_m0_wo0_wi0_delayr53: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr53_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_12_q = "1") THEN
                u0_m0_wo0_wi0_delayr53_q <= u0_m0_wo0_wi0_delayr52_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr54(DELAY,61)@12
    u0_m0_wo0_wi0_delayr54: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr54_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_12_q = "1") THEN
                u0_m0_wo0_wi0_delayr54_q <= u0_m0_wo0_wi0_delayr53_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr55(DELAY,62)@12
    u0_m0_wo0_wi0_delayr55: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr55_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_12_q = "1") THEN
                u0_m0_wo0_wi0_delayr55_q <= u0_m0_wo0_wi0_delayr54_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr56(DELAY,63)@12
    u0_m0_wo0_wi0_delayr56: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr56_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_12_q = "1") THEN
                u0_m0_wo0_wi0_delayr56_q <= u0_m0_wo0_wi0_delayr55_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr57(DELAY,64)@12
    u0_m0_wo0_wi0_delayr57: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr57_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_12_q = "1") THEN
                u0_m0_wo0_wi0_delayr57_q <= u0_m0_wo0_wi0_delayr56_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr58(DELAY,65)@12
    u0_m0_wo0_wi0_delayr58: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr58_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_12_q = "1") THEN
                u0_m0_wo0_wi0_delayr58_q <= u0_m0_wo0_wi0_delayr57_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr59(DELAY,66)@12
    u0_m0_wo0_wi0_delayr59: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr59_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_12_q = "1") THEN
                u0_m0_wo0_wi0_delayr59_q <= u0_m0_wo0_wi0_delayr58_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr60(DELAY,67)@12
    u0_m0_wo0_wi0_delayr60: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr60_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_12_q = "1") THEN
                u0_m0_wo0_wi0_delayr60_q <= u0_m0_wo0_wi0_delayr59_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr61(DELAY,68)@12
    u0_m0_wo0_wi0_delayr61: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr61_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_12_q = "1") THEN
                u0_m0_wo0_wi0_delayr61_q <= u0_m0_wo0_wi0_delayr60_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr62(DELAY,69)@12
    u0_m0_wo0_wi0_delayr62: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr62_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_12_q = "1") THEN
                u0_m0_wo0_wi0_delayr62_q <= u0_m0_wo0_wi0_delayr61_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_wi0_delayr63(DELAY,70)@12
    u0_m0_wo0_wi0_delayr63: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_wi0_delayr63_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            IF (d_in0_m0_wi0_wo0_assign_sel_q_12_q = "1") THEN
                u0_m0_wo0_wi0_delayr63_q <= u0_m0_wo0_wi0_delayr62_q;
            END IF;
        END IF;
    END PROCESS;


	--u0_m0_wo0_sym_add0(ADD,103)@12
    u0_m0_wo0_sym_add0_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(d_u0_m0_wo0_wi0_phasedelay0_q_12_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add0_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_wi0_delayr63_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add0: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add0_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add0_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add0_a) + SIGNED(u0_m0_wo0_sym_add0_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add0_q <= u0_m0_wo0_sym_add0_o(8 downto 0);


	--u0_m0_wo0_sym_add2(ADD,105)@12
    u0_m0_wo0_sym_add2_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(d_u0_m0_wo0_wi0_delayr2_q_12_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add2_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_wi0_delayr61_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add2: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add2_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add2_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add2_a) + SIGNED(u0_m0_wo0_sym_add2_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add2_q <= u0_m0_wo0_sym_add2_o(8 downto 0);


	--u0_m0_wo0_sym_add4(ADD,107)@12
    u0_m0_wo0_sym_add4_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(d_u0_m0_wo0_wi0_delayr4_q_12_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add4_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_wi0_delayr59_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add4: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add4_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add4_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add4_a) + SIGNED(u0_m0_wo0_sym_add4_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add4_q <= u0_m0_wo0_sym_add4_o(8 downto 0);


	--u0_m0_wo0_sym_add6(ADD,109)@12
    u0_m0_wo0_sym_add6_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(d_u0_m0_wo0_wi0_delayr6_q_12_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add6_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_wi0_delayr57_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add6: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add6_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add6_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add6_a) + SIGNED(u0_m0_wo0_sym_add6_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add6_q <= u0_m0_wo0_sym_add6_o(8 downto 0);


	--u0_m0_wo0_sym_add8(ADD,111)@12
    u0_m0_wo0_sym_add8_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(d_u0_m0_wo0_wi0_delayr8_q_12_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add8_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_wi0_delayr55_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add8: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add8_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add8_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add8_a) + SIGNED(u0_m0_wo0_sym_add8_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add8_q <= u0_m0_wo0_sym_add8_o(8 downto 0);


	--u0_m0_wo0_sym_add10(ADD,113)@12
    u0_m0_wo0_sym_add10_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(d_u0_m0_wo0_wi0_delayr10_q_12_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add10_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_wi0_delayr53_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add10: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add10_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add10_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add10_a) + SIGNED(u0_m0_wo0_sym_add10_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add10_q <= u0_m0_wo0_sym_add10_o(8 downto 0);


	--u0_m0_wo0_sym_add12(ADD,115)@12
    u0_m0_wo0_sym_add12_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(d_u0_m0_wo0_wi0_delayr12_q_12_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add12_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_wi0_delayr51_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add12_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add12_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add12_a) + SIGNED(u0_m0_wo0_sym_add12_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add12_q <= u0_m0_wo0_sym_add12_o(8 downto 0);


	--u0_m0_wo0_sym_add14(ADD,117)@12
    u0_m0_wo0_sym_add14_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(d_u0_m0_wo0_wi0_delayr14_q_12_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add14_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_wi0_delayr49_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add14: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add14_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add14_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add14_a) + SIGNED(u0_m0_wo0_sym_add14_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add14_q <= u0_m0_wo0_sym_add14_o(8 downto 0);


	--u0_m0_wo0_sym_add16(ADD,119)@12
    u0_m0_wo0_sym_add16_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(d_u0_m0_wo0_wi0_delayr16_q_12_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add16_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_wi0_delayr47_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add16: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add16_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add16_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add16_a) + SIGNED(u0_m0_wo0_sym_add16_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add16_q <= u0_m0_wo0_sym_add16_o(8 downto 0);


	--u0_m0_wo0_sym_add18(ADD,121)@11
    u0_m0_wo0_sym_add18_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(d_u0_m0_wo0_wi0_delayr18_q_11_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add18_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_wi0_delayr45_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add18: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add18_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add18_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add18_a) + SIGNED(u0_m0_wo0_sym_add18_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add18_q <= u0_m0_wo0_sym_add18_o(8 downto 0);


	--d_u0_m0_wo0_sym_add18_q_13(DELAY,246)@12
    d_u0_m0_wo0_sym_add18_q_13: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_sym_add18_q_13_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_sym_add18_q_13_q <= u0_m0_wo0_sym_add18_q;
        END IF;
    END PROCESS;


	--u0_m0_wo0_sym_add20(ADD,123)@12
    u0_m0_wo0_sym_add20_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(d_u0_m0_wo0_wi0_delayr20_q_12_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add20_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(d_u0_m0_wo0_wi0_delayr43_q_12_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add20: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add20_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add20_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add20_a) + SIGNED(u0_m0_wo0_sym_add20_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add20_q <= u0_m0_wo0_sym_add20_o(8 downto 0);


	--u0_m0_wo0_sym_add22(ADD,125)@11
    u0_m0_wo0_sym_add22_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(d_u0_m0_wo0_wi0_delayr22_q_11_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add22_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_wi0_delayr41_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add22: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add22_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add22_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add22_a) + SIGNED(u0_m0_wo0_sym_add22_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add22_q <= u0_m0_wo0_sym_add22_o(8 downto 0);


	--d_u0_m0_wo0_sym_add22_q_13(DELAY,247)@12
    d_u0_m0_wo0_sym_add22_q_13: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_sym_add22_q_13_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_sym_add22_q_13_q <= u0_m0_wo0_sym_add22_q;
        END IF;
    END PROCESS;


	--u0_m0_wo0_sym_add24(ADD,127)@11
    u0_m0_wo0_sym_add24_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(d_u0_m0_wo0_wi0_delayr24_q_11_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add24_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_wi0_delayr39_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add24: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add24_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add24_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add24_a) + SIGNED(u0_m0_wo0_sym_add24_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add24_q <= u0_m0_wo0_sym_add24_o(8 downto 0);


	--d_u0_m0_wo0_sym_add24_q_13(DELAY,248)@12
    d_u0_m0_wo0_sym_add24_q_13: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_sym_add24_q_13_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_sym_add24_q_13_q <= u0_m0_wo0_sym_add24_q;
        END IF;
    END PROCESS;


	--u0_m0_wo0_sym_add26(ADD,129)@11
    u0_m0_wo0_sym_add26_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(d_u0_m0_wo0_wi0_delayr26_q_11_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add26_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_wi0_delayr37_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add26: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add26_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add26_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add26_a) + SIGNED(u0_m0_wo0_sym_add26_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add26_q <= u0_m0_wo0_sym_add26_o(8 downto 0);


	--d_u0_m0_wo0_sym_add26_q_13(DELAY,249)@12
    d_u0_m0_wo0_sym_add26_q_13: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_sym_add26_q_13_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_sym_add26_q_13_q <= u0_m0_wo0_sym_add26_q;
        END IF;
    END PROCESS;


	--u0_m0_wo0_sym_add28(ADD,131)@10
    u0_m0_wo0_sym_add28_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_wi0_delayr28_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add28_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_wi0_delayr35_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add28: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add28_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add28_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add28_a) + SIGNED(u0_m0_wo0_sym_add28_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add28_q <= u0_m0_wo0_sym_add28_o(8 downto 0);


	--d_u0_m0_wo0_sym_add28_q_12(DELAY,250)@11
    d_u0_m0_wo0_sym_add28_q_12: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            d_u0_m0_wo0_sym_add28_q_12_q <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            d_u0_m0_wo0_sym_add28_q_12_q <= u0_m0_wo0_sym_add28_q;
        END IF;
    END PROCESS;


	--u0_m0_wo0_sym_add30(ADD,133)@10
    u0_m0_wo0_sym_add30_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_wi0_delayr30_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add30_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_wi0_delayr33_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add30: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_sym_add30_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_sym_add30_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_sym_add30_a) + SIGNED(u0_m0_wo0_sym_add30_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_sym_add30_q <= u0_m0_wo0_sym_add30_o(8 downto 0);


	--u0_m0_wo0_sym_add31(ADD,134)@12
    u0_m0_wo0_sym_add31_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(d_u0_m0_wo0_wi0_delayr31_q_12_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add31_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(d_u0_m0_wo0_wi0_delayr31_q_12_q(7 downto 0)), 9));
    u0_m0_wo0_sym_add31_i <= u0_m0_wo0_sym_add31_a;
    u0_m0_wo0_sym_add31_reset <= areset;
    u0_m0_wo0_sym_add31_au : fir_ramp_rtl_AddWithSload 
        generic map (L => 9, OPTIMIZED => "TRUE") 
        port map (clk => clk,
            reset => u0_m0_wo0_sym_add31_reset,
            ena => VCC_q(0),
            sreset => '0',
            sload => d_in0_m0_wi0_wo0_assign_sel_q_12_q(0),
            loadval_in => u0_m0_wo0_sym_add31_i,
            doAddnSub => '1',
            addL_in => u0_m0_wo0_sym_add31_a,
            addR_in => u0_m0_wo0_sym_add31_b,
            sum_out => u0_m0_wo0_sym_add31_o);
    u0_m0_wo0_sym_add31_q <= u0_m0_wo0_sym_add31_o(8 downto 0);


	--u0_m0_wo0_mtree_add0_0(ADD,143)@15
    u0_m0_wo0_mtree_add0_0_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_0_sum2_q(11 downto 0)), 14));
    u0_m0_wo0_mtree_add0_0_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_1_sum2_q(11 downto 0)), 14));
    u0_m0_wo0_mtree_add0_0: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add0_0_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add0_0_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add0_0_a) + SIGNED(u0_m0_wo0_mtree_add0_0_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add0_0_q <= u0_m0_wo0_mtree_add0_0_o(13 downto 0);


	--u0_m0_wo0_mtree_add0_1(ADD,144)@15
    u0_m0_wo0_mtree_add0_1_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_2_sum2_q(11 downto 0)), 15));
    u0_m0_wo0_mtree_add0_1_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_3_sum2_q(12 downto 0)), 15));
    u0_m0_wo0_mtree_add0_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add0_1_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add0_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add0_1_a) + SIGNED(u0_m0_wo0_mtree_add0_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add0_1_q <= u0_m0_wo0_mtree_add0_1_o(14 downto 0);


	--u0_m0_wo0_mtree_add0_2(ADD,145)@15
    u0_m0_wo0_mtree_add0_2_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_4_sum2_q(12 downto 0)), 17));
    u0_m0_wo0_mtree_add0_2_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_5_sum2_q(13 downto 0)), 17));
    u0_m0_wo0_mtree_add0_2: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add0_2_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add0_2_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add0_2_a) + SIGNED(u0_m0_wo0_mtree_add0_2_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add0_2_q <= u0_m0_wo0_mtree_add0_2_o(16 downto 0);


	--u0_m0_wo0_mtree_add0_3(ADD,146)@15
    u0_m0_wo0_mtree_add0_3_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_6_sum2_q(15 downto 0)), 24));
    u0_m0_wo0_mtree_add0_3_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_7_sum_final_q(22 downto 0)), 24));
    u0_m0_wo0_mtree_add0_3: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add0_3_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add0_3_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add0_3_a) + SIGNED(u0_m0_wo0_mtree_add0_3_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add0_3_q <= u0_m0_wo0_mtree_add0_3_o(23 downto 0);


	--u0_m0_wo0_mtree_add1_0(ADD,147)@16
    u0_m0_wo0_mtree_add1_0_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_add0_0_q(13 downto 0)), 16));
    u0_m0_wo0_mtree_add1_0_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_add0_1_q(14 downto 0)), 16));
    u0_m0_wo0_mtree_add1_0: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add1_0_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add1_0_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add1_0_a) + SIGNED(u0_m0_wo0_mtree_add1_0_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add1_0_q <= u0_m0_wo0_mtree_add1_0_o(15 downto 0);


	--u0_m0_wo0_mtree_add1_1(ADD,148)@16
    u0_m0_wo0_mtree_add1_1_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_add0_2_q(16 downto 0)), 25));
    u0_m0_wo0_mtree_add1_1_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_add0_3_q(23 downto 0)), 25));
    u0_m0_wo0_mtree_add1_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add1_1_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add1_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add1_1_a) + SIGNED(u0_m0_wo0_mtree_add1_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add1_1_q <= u0_m0_wo0_mtree_add1_1_o(24 downto 0);


	--u0_m0_wo0_mtree_add2_0(ADD,149)@17
    u0_m0_wo0_mtree_add2_0_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_add1_0_q(15 downto 0)), 26));
    u0_m0_wo0_mtree_add2_0_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_add1_1_q(24 downto 0)), 26));
    u0_m0_wo0_mtree_add2_0: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_add2_0_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_add2_0_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_add2_0_a) + SIGNED(u0_m0_wo0_mtree_add2_0_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_add2_0_q <= u0_m0_wo0_mtree_add2_0_o(25 downto 0);


	--u0_m0_wo0_oseq_gated_reg(REG,150)@17
    u0_m0_wo0_oseq_gated_reg: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_oseq_gated_reg_q <= "0";
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_oseq_gated_reg_q <= d_in0_m0_wi0_wo0_assign_sel_q_17_q;
        END IF;
    END PROCESS;


	--u0_m0_wo0_mtree_madd4_7_constmult0_add_1(ADD,155)@11
    u0_m0_wo0_mtree_madd4_7_constmult0_add_1_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_sym_add28_q(8 downto 0)), 13));
    u0_m0_wo0_mtree_madd4_7_constmult0_add_1_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_7_constmult0_shift0_q(11 downto 0)), 13));
    u0_m0_wo0_mtree_madd4_7_constmult0_add_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_7_constmult0_add_1_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_7_constmult0_add_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_7_constmult0_add_1_a) + SIGNED(u0_m0_wo0_mtree_madd4_7_constmult0_add_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_7_constmult0_add_1_q <= u0_m0_wo0_mtree_madd4_7_constmult0_add_1_o(12 downto 0);


	--u0_m0_wo0_mtree_madd4_7_constmult0_sub_3(SUB,157)@12
    u0_m0_wo0_mtree_madd4_7_constmult0_sub_3_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_7_constmult0_add_1_q(12 downto 0)), 15));
    u0_m0_wo0_mtree_madd4_7_constmult0_sub_3_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_7_constmult0_shift2_q(13 downto 0)), 15));
    u0_m0_wo0_mtree_madd4_7_constmult0_sub_3: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_7_constmult0_sub_3_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_7_constmult0_sub_3_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_7_constmult0_sub_3_a) - SIGNED(u0_m0_wo0_mtree_madd4_7_constmult0_sub_3_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_7_constmult0_sub_3_q <= u0_m0_wo0_mtree_madd4_7_constmult0_sub_3_o(14 downto 0);


	--u0_m0_wo0_mtree_madd4_7_constmult2_sub_1(SUB,160)@11
    u0_m0_wo0_mtree_madd4_7_constmult2_sub_1_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_sym_add30_q(8 downto 0)), 15));
    u0_m0_wo0_mtree_madd4_7_constmult2_sub_1_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_7_constmult2_shift0_q(13 downto 0)), 15));
    u0_m0_wo0_mtree_madd4_7_constmult2_sub_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_7_constmult2_sub_1_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_7_constmult2_sub_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_7_constmult2_sub_1_a) - SIGNED(u0_m0_wo0_mtree_madd4_7_constmult2_sub_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_7_constmult2_sub_1_q <= u0_m0_wo0_mtree_madd4_7_constmult2_sub_1_o(14 downto 0);


	--u0_m0_wo0_mtree_madd4_7_constmult2_sub_3(SUB,162)@11
    u0_m0_wo0_mtree_madd4_7_constmult2_sub_3_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_sym_add30_q(8 downto 0)), 12));
    u0_m0_wo0_mtree_madd4_7_constmult2_sub_3_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_7_constmult2_shift2_q(10 downto 0)), 12));
    u0_m0_wo0_mtree_madd4_7_constmult2_sub_3: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_7_constmult2_sub_3_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_7_constmult2_sub_3_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_7_constmult2_sub_3_a) - SIGNED(u0_m0_wo0_mtree_madd4_7_constmult2_sub_3_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_7_constmult2_sub_3_q <= u0_m0_wo0_mtree_madd4_7_constmult2_sub_3_o(11 downto 0);


	--u0_m0_wo0_mtree_madd4_7_constmult2_add_5(ADD,164)@12
    u0_m0_wo0_mtree_madd4_7_constmult2_add_5_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_7_constmult2_sub_1_q(14 downto 0)), 20));
    u0_m0_wo0_mtree_madd4_7_constmult2_add_5_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_7_constmult2_shift4_q(18 downto 0)), 20));
    u0_m0_wo0_mtree_madd4_7_constmult2_add_5: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_7_constmult2_add_5_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_7_constmult2_add_5_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_7_constmult2_add_5_a) + SIGNED(u0_m0_wo0_mtree_madd4_7_constmult2_add_5_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_7_constmult2_add_5_q <= u0_m0_wo0_mtree_madd4_7_constmult2_add_5_o(19 downto 0);


	--u0_m0_wo0_mtree_madd4_7_constmult3_sub_1(SUB,167)@13
    u0_m0_wo0_mtree_madd4_7_constmult3_sub_1_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_7_constmult3_shift0_q(19 downto 0)), 21));
    u0_m0_wo0_mtree_madd4_7_constmult3_sub_1_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_sym_add31_q(8 downto 0)), 21));
    u0_m0_wo0_mtree_madd4_7_constmult3_sub_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_7_constmult3_sub_1_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_7_constmult3_sub_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_7_constmult3_sub_1_a) - SIGNED(u0_m0_wo0_mtree_madd4_7_constmult3_sub_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_7_constmult3_sub_1_q <= u0_m0_wo0_mtree_madd4_7_constmult3_sub_1_o(20 downto 0);


	--u0_m0_wo0_mtree_madd4_7_sum2(ADD,169)@13
    u0_m0_wo0_mtree_madd4_7_sum2_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_7_constmult0_shift4_q(16 downto 0)), 22));
    u0_m0_wo0_mtree_madd4_7_sum2_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_7_constmult2_shift6_q(20 downto 0)), 22));
    u0_m0_wo0_mtree_madd4_7_sum2: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_7_sum2_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_7_sum2_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_7_sum2_a) + SIGNED(u0_m0_wo0_mtree_madd4_7_sum2_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_7_sum2_q <= u0_m0_wo0_mtree_madd4_7_sum2_o(21 downto 0);


	--u0_m0_wo0_mtree_madd4_7_sum_final(ADD,170)@14
    u0_m0_wo0_mtree_madd4_7_sum_final_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_7_constmult3_sub_1_q(20 downto 0)), 23));
    u0_m0_wo0_mtree_madd4_7_sum_final_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_7_sum2_q(21 downto 0)), 23));
    u0_m0_wo0_mtree_madd4_7_sum_final: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_7_sum_final_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_7_sum_final_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_7_sum_final_a) + SIGNED(u0_m0_wo0_mtree_madd4_7_sum_final_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_7_sum_final_q <= u0_m0_wo0_mtree_madd4_7_sum_final_o(22 downto 0);


	--u0_m0_wo0_mtree_madd4_6_constmult0_sub_0(SUB,171)@12
    u0_m0_wo0_mtree_madd4_6_constmult0_sub_0_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(GND_q(0 downto 0)), 10));
    u0_m0_wo0_mtree_madd4_6_constmult0_sub_0_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_sym_add24_q(8 downto 0)), 10));
    u0_m0_wo0_mtree_madd4_6_constmult0_sub_0: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_6_constmult0_sub_0_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_6_constmult0_sub_0_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_6_constmult0_sub_0_a) - SIGNED(u0_m0_wo0_mtree_madd4_6_constmult0_sub_0_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_6_constmult0_sub_0_q <= u0_m0_wo0_mtree_madd4_6_constmult0_sub_0_o(9 downto 0);


	--u0_m0_wo0_mtree_madd4_6_constmult0_sub_2(SUB,173)@13
    u0_m0_wo0_mtree_madd4_6_constmult0_sub_2_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_6_constmult0_sub_0_q(9 downto 0)), 14));
    u0_m0_wo0_mtree_madd4_6_constmult0_sub_2_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_6_constmult0_shift1_q(12 downto 0)), 14));
    u0_m0_wo0_mtree_madd4_6_constmult0_sub_2: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_6_constmult0_sub_2_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_6_constmult0_sub_2_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_6_constmult0_sub_2_a) - SIGNED(u0_m0_wo0_mtree_madd4_6_constmult0_sub_2_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_6_constmult0_sub_2_q <= u0_m0_wo0_mtree_madd4_6_constmult0_sub_2_o(13 downto 0);


	--u0_m0_wo0_mtree_madd4_6_constmult2_sub_0(SUB,174)@12
    u0_m0_wo0_mtree_madd4_6_constmult2_sub_0_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(GND_q(0 downto 0)), 10));
    u0_m0_wo0_mtree_madd4_6_constmult2_sub_0_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_sym_add26_q(8 downto 0)), 10));
    u0_m0_wo0_mtree_madd4_6_constmult2_sub_0: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_6_constmult2_sub_0_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_6_constmult2_sub_0_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_6_constmult2_sub_0_a) - SIGNED(u0_m0_wo0_mtree_madd4_6_constmult2_sub_0_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_6_constmult2_sub_0_q <= u0_m0_wo0_mtree_madd4_6_constmult2_sub_0_o(9 downto 0);


	--u0_m0_wo0_mtree_madd4_6_constmult2_sub_2(SUB,176)@13
    u0_m0_wo0_mtree_madd4_6_constmult2_sub_2_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_6_constmult2_sub_0_q(9 downto 0)), 15));
    u0_m0_wo0_mtree_madd4_6_constmult2_sub_2_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_6_constmult2_shift1_q(13 downto 0)), 15));
    u0_m0_wo0_mtree_madd4_6_constmult2_sub_2: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_6_constmult2_sub_2_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_6_constmult2_sub_2_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_6_constmult2_sub_2_a) - SIGNED(u0_m0_wo0_mtree_madd4_6_constmult2_sub_2_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_6_constmult2_sub_2_q <= u0_m0_wo0_mtree_madd4_6_constmult2_sub_2_o(14 downto 0);


	--u0_m0_wo0_mtree_madd4_6_sum2(ADD,178)@14
    u0_m0_wo0_mtree_madd4_6_sum2_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_6_constmult0_sub_2_q(13 downto 0)), 16));
    u0_m0_wo0_mtree_madd4_6_sum2_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_6_constmult2_sub_2_q(14 downto 0)), 16));
    u0_m0_wo0_mtree_madd4_6_sum2: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_6_sum2_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_6_sum2_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_6_sum2_a) + SIGNED(u0_m0_wo0_mtree_madd4_6_sum2_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_6_sum2_q <= u0_m0_wo0_mtree_madd4_6_sum2_o(15 downto 0);


	--u0_m0_wo0_mtree_madd4_5_constmult0_sub_1(SUB,181)@13
    u0_m0_wo0_mtree_madd4_5_constmult0_sub_1_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_sym_add20_q(8 downto 0)), 13));
    u0_m0_wo0_mtree_madd4_5_constmult0_sub_1_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_5_constmult0_shift0_q(11 downto 0)), 13));
    u0_m0_wo0_mtree_madd4_5_constmult0_sub_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_5_constmult0_sub_1_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_5_constmult0_sub_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_5_constmult0_sub_1_a) - SIGNED(u0_m0_wo0_mtree_madd4_5_constmult0_sub_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_5_constmult0_sub_1_q <= u0_m0_wo0_mtree_madd4_5_constmult0_sub_1_o(12 downto 0);


	--u0_m0_wo0_mtree_madd4_5_constmult2_sub_1(SUB,183)@12
    u0_m0_wo0_mtree_madd4_5_constmult2_sub_1_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(GND_q(0 downto 0)), 11));
    u0_m0_wo0_mtree_madd4_5_constmult2_sub_1_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_5_constmult2_shift0_q(9 downto 0)), 11));
    u0_m0_wo0_mtree_madd4_5_constmult2_sub_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_5_constmult2_sub_1_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_5_constmult2_sub_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_5_constmult2_sub_1_a) - SIGNED(u0_m0_wo0_mtree_madd4_5_constmult2_sub_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_5_constmult2_sub_1_q <= u0_m0_wo0_mtree_madd4_5_constmult2_sub_1_o(10 downto 0);


	--u0_m0_wo0_mtree_madd4_5_constmult2_sub_3(SUB,185)@13
    u0_m0_wo0_mtree_madd4_5_constmult2_sub_3_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_5_constmult2_sub_1_q(10 downto 0)), 13));
    u0_m0_wo0_mtree_madd4_5_constmult2_sub_3_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_5_constmult2_shift2_q(11 downto 0)), 13));
    u0_m0_wo0_mtree_madd4_5_constmult2_sub_3: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_5_constmult2_sub_3_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_5_constmult2_sub_3_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_5_constmult2_sub_3_a) - SIGNED(u0_m0_wo0_mtree_madd4_5_constmult2_sub_3_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_5_constmult2_sub_3_q <= u0_m0_wo0_mtree_madd4_5_constmult2_sub_3_o(12 downto 0);


	--u0_m0_wo0_mtree_madd4_5_sum2(ADD,187)@14
    u0_m0_wo0_mtree_madd4_5_sum2_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_5_constmult0_sub_1_q(12 downto 0)), 14));
    u0_m0_wo0_mtree_madd4_5_sum2_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_5_constmult2_sub_3_q(12 downto 0)), 14));
    u0_m0_wo0_mtree_madd4_5_sum2: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_5_sum2_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_5_sum2_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_5_sum2_a) + SIGNED(u0_m0_wo0_mtree_madd4_5_sum2_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_5_sum2_q <= u0_m0_wo0_mtree_madd4_5_sum2_o(13 downto 0);


	--u0_m0_wo0_mtree_madd4_4_constmult0_sub_1(SUB,190)@13
    u0_m0_wo0_mtree_madd4_4_constmult0_sub_1_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(GND_q(0 downto 0)), 12));
    u0_m0_wo0_mtree_madd4_4_constmult0_sub_1_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_4_constmult0_shift0_q(10 downto 0)), 12));
    u0_m0_wo0_mtree_madd4_4_constmult0_sub_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_4_constmult0_sub_1_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_4_constmult0_sub_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_4_constmult0_sub_1_a) - SIGNED(u0_m0_wo0_mtree_madd4_4_constmult0_sub_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_4_constmult0_sub_1_q <= u0_m0_wo0_mtree_madd4_4_constmult0_sub_1_o(11 downto 0);


	--u0_m0_wo0_mtree_madd4_4_constmult2_sub_0(SUB,191)@12
    u0_m0_wo0_mtree_madd4_4_constmult2_sub_0_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(GND_q(0 downto 0)), 10));
    u0_m0_wo0_mtree_madd4_4_constmult2_sub_0_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_sym_add18_q(8 downto 0)), 10));
    u0_m0_wo0_mtree_madd4_4_constmult2_sub_0: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_4_constmult2_sub_0_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_4_constmult2_sub_0_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_4_constmult2_sub_0_a) - SIGNED(u0_m0_wo0_mtree_madd4_4_constmult2_sub_0_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_4_constmult2_sub_0_q <= u0_m0_wo0_mtree_madd4_4_constmult2_sub_0_o(9 downto 0);


	--u0_m0_wo0_mtree_madd4_4_constmult2_sub_2(SUB,193)@13
    u0_m0_wo0_mtree_madd4_4_constmult2_sub_2_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_4_constmult2_sub_0_q(9 downto 0)), 12));
    u0_m0_wo0_mtree_madd4_4_constmult2_sub_2_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_4_constmult2_shift1_q(10 downto 0)), 12));
    u0_m0_wo0_mtree_madd4_4_constmult2_sub_2: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_4_constmult2_sub_2_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_4_constmult2_sub_2_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_4_constmult2_sub_2_a) - SIGNED(u0_m0_wo0_mtree_madd4_4_constmult2_sub_2_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_4_constmult2_sub_2_q <= u0_m0_wo0_mtree_madd4_4_constmult2_sub_2_o(11 downto 0);


	--u0_m0_wo0_mtree_madd4_4_sum2(ADD,195)@14
    u0_m0_wo0_mtree_madd4_4_sum2_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_4_constmult0_sub_1_q(11 downto 0)), 13));
    u0_m0_wo0_mtree_madd4_4_sum2_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_4_constmult2_sub_2_q(11 downto 0)), 13));
    u0_m0_wo0_mtree_madd4_4_sum2: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_4_sum2_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_4_sum2_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_4_sum2_a) + SIGNED(u0_m0_wo0_mtree_madd4_4_sum2_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_4_sum2_q <= u0_m0_wo0_mtree_madd4_4_sum2_o(12 downto 0);


	--u0_m0_wo0_mtree_madd4_3_constmult0_sub_1(SUB,198)@13
    u0_m0_wo0_mtree_madd4_3_constmult0_sub_1_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_sym_add12_q(8 downto 0)), 12));
    u0_m0_wo0_mtree_madd4_3_constmult0_sub_1_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_3_constmult0_shift0_q(10 downto 0)), 12));
    u0_m0_wo0_mtree_madd4_3_constmult0_sub_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_3_constmult0_sub_1_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_3_constmult0_sub_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_3_constmult0_sub_1_a) - SIGNED(u0_m0_wo0_mtree_madd4_3_constmult0_sub_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_3_constmult0_sub_1_q <= u0_m0_wo0_mtree_madd4_3_constmult0_sub_1_o(11 downto 0);


	--u0_m0_wo0_mtree_madd4_3_constmult2_sub_1(SUB,200)@13
    u0_m0_wo0_mtree_madd4_3_constmult2_sub_1_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_sym_add14_q(8 downto 0)), 12));
    u0_m0_wo0_mtree_madd4_3_constmult2_sub_1_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_3_constmult2_shift0_q(10 downto 0)), 12));
    u0_m0_wo0_mtree_madd4_3_constmult2_sub_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_3_constmult2_sub_1_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_3_constmult2_sub_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_3_constmult2_sub_1_a) - SIGNED(u0_m0_wo0_mtree_madd4_3_constmult2_sub_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_3_constmult2_sub_1_q <= u0_m0_wo0_mtree_madd4_3_constmult2_sub_1_o(11 downto 0);


	--u0_m0_wo0_mtree_madd4_3_sum2(ADD,202)@14
    u0_m0_wo0_mtree_madd4_3_sum2_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_3_constmult2_sub_1_q(11 downto 0)), 13));
    u0_m0_wo0_mtree_madd4_3_sum2_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_3_constmult0_sub_1_q(11 downto 0)), 13));
    u0_m0_wo0_mtree_madd4_3_sum2: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_3_sum2_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_3_sum2_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_3_sum2_a) + SIGNED(u0_m0_wo0_mtree_madd4_3_sum2_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_3_sum2_q <= u0_m0_wo0_mtree_madd4_3_sum2_o(12 downto 0);


	--u0_m0_wo0_mtree_madd4_2_constmult0_sub_1(SUB,205)@13
    u0_m0_wo0_mtree_madd4_2_constmult0_sub_1_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(GND_q(0 downto 0)), 11));
    u0_m0_wo0_mtree_madd4_2_constmult0_sub_1_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_2_constmult0_shift0_q(9 downto 0)), 11));
    u0_m0_wo0_mtree_madd4_2_constmult0_sub_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_2_constmult0_sub_1_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_2_constmult0_sub_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_2_constmult0_sub_1_a) - SIGNED(u0_m0_wo0_mtree_madd4_2_constmult0_sub_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_2_constmult0_sub_1_q <= u0_m0_wo0_mtree_madd4_2_constmult0_sub_1_o(10 downto 0);


	--u0_m0_wo0_mtree_madd4_2_constmult2_sub_1(SUB,207)@13
    u0_m0_wo0_mtree_madd4_2_constmult2_sub_1_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(GND_q(0 downto 0)), 11));
    u0_m0_wo0_mtree_madd4_2_constmult2_sub_1_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_2_constmult2_shift0_q(9 downto 0)), 11));
    u0_m0_wo0_mtree_madd4_2_constmult2_sub_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_2_constmult2_sub_1_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_2_constmult2_sub_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_2_constmult2_sub_1_a) - SIGNED(u0_m0_wo0_mtree_madd4_2_constmult2_sub_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_2_constmult2_sub_1_q <= u0_m0_wo0_mtree_madd4_2_constmult2_sub_1_o(10 downto 0);


	--u0_m0_wo0_mtree_madd4_2_sum2(ADD,209)@14
    u0_m0_wo0_mtree_madd4_2_sum2_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_2_constmult2_sub_1_q(10 downto 0)), 12));
    u0_m0_wo0_mtree_madd4_2_sum2_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_2_constmult0_sub_1_q(10 downto 0)), 12));
    u0_m0_wo0_mtree_madd4_2_sum2: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_2_sum2_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_2_sum2_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_2_sum2_a) + SIGNED(u0_m0_wo0_mtree_madd4_2_sum2_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_2_sum2_q <= u0_m0_wo0_mtree_madd4_2_sum2_o(11 downto 0);


	--u0_m0_wo0_mtree_madd4_1_constmult0_sub_1(SUB,212)@13
    u0_m0_wo0_mtree_madd4_1_constmult0_sub_1_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(GND_q(0 downto 0)), 11));
    u0_m0_wo0_mtree_madd4_1_constmult0_sub_1_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_1_constmult0_shift0_q(9 downto 0)), 11));
    u0_m0_wo0_mtree_madd4_1_constmult0_sub_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_1_constmult0_sub_1_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_1_constmult0_sub_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_1_constmult0_sub_1_a) - SIGNED(u0_m0_wo0_mtree_madd4_1_constmult0_sub_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_1_constmult0_sub_1_q <= u0_m0_wo0_mtree_madd4_1_constmult0_sub_1_o(10 downto 0);


	--u0_m0_wo0_mtree_madd4_1_constmult2_sub_1(SUB,214)@13
    u0_m0_wo0_mtree_madd4_1_constmult2_sub_1_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(GND_q(0 downto 0)), 11));
    u0_m0_wo0_mtree_madd4_1_constmult2_sub_1_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_1_constmult2_shift0_q(9 downto 0)), 11));
    u0_m0_wo0_mtree_madd4_1_constmult2_sub_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_1_constmult2_sub_1_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_1_constmult2_sub_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_1_constmult2_sub_1_a) - SIGNED(u0_m0_wo0_mtree_madd4_1_constmult2_sub_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_1_constmult2_sub_1_q <= u0_m0_wo0_mtree_madd4_1_constmult2_sub_1_o(10 downto 0);


	--u0_m0_wo0_mtree_madd4_1_sum2(ADD,216)@14
    u0_m0_wo0_mtree_madd4_1_sum2_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_1_constmult2_sub_1_q(10 downto 0)), 12));
    u0_m0_wo0_mtree_madd4_1_sum2_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_1_constmult0_sub_1_q(10 downto 0)), 12));
    u0_m0_wo0_mtree_madd4_1_sum2: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_1_sum2_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_1_sum2_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_1_sum2_a) + SIGNED(u0_m0_wo0_mtree_madd4_1_sum2_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_1_sum2_q <= u0_m0_wo0_mtree_madd4_1_sum2_o(11 downto 0);


	--u0_m0_wo0_mtree_madd4_0_constmult0_sub_1(SUB,219)@13
    u0_m0_wo0_mtree_madd4_0_constmult0_sub_1_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(GND_q(0 downto 0)), 11));
    u0_m0_wo0_mtree_madd4_0_constmult0_sub_1_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_0_constmult0_shift0_q(9 downto 0)), 11));
    u0_m0_wo0_mtree_madd4_0_constmult0_sub_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_0_constmult0_sub_1_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_0_constmult0_sub_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_0_constmult0_sub_1_a) - SIGNED(u0_m0_wo0_mtree_madd4_0_constmult0_sub_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_0_constmult0_sub_1_q <= u0_m0_wo0_mtree_madd4_0_constmult0_sub_1_o(10 downto 0);


	--u0_m0_wo0_mtree_madd4_0_constmult2_sub_1(SUB,221)@13
    u0_m0_wo0_mtree_madd4_0_constmult2_sub_1_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(GND_q(0 downto 0)), 11));
    u0_m0_wo0_mtree_madd4_0_constmult2_sub_1_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_0_constmult2_shift0_q(9 downto 0)), 11));
    u0_m0_wo0_mtree_madd4_0_constmult2_sub_1: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_0_constmult2_sub_1_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_0_constmult2_sub_1_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_0_constmult2_sub_1_a) - SIGNED(u0_m0_wo0_mtree_madd4_0_constmult2_sub_1_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_0_constmult2_sub_1_q <= u0_m0_wo0_mtree_madd4_0_constmult2_sub_1_o(10 downto 0);


	--u0_m0_wo0_mtree_madd4_0_sum2(ADD,223)@14
    u0_m0_wo0_mtree_madd4_0_sum2_a <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_0_constmult2_sub_1_q(10 downto 0)), 12));
    u0_m0_wo0_mtree_madd4_0_sum2_b <= STD_LOGIC_VECTOR(RESIZE(SIGNED(u0_m0_wo0_mtree_madd4_0_constmult0_sub_1_q(10 downto 0)), 12));
    u0_m0_wo0_mtree_madd4_0_sum2: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            u0_m0_wo0_mtree_madd4_0_sum2_o <= (others => '0');
        ELSIF(clk'EVENT AND clk = '1') THEN
            u0_m0_wo0_mtree_madd4_0_sum2_o <= STD_LOGIC_VECTOR(SIGNED(u0_m0_wo0_mtree_madd4_0_sum2_a) + SIGNED(u0_m0_wo0_mtree_madd4_0_sum2_b));
        END IF;
    END PROCESS;
    u0_m0_wo0_mtree_madd4_0_sum2_q <= u0_m0_wo0_mtree_madd4_0_sum2_o(11 downto 0);


	--xOut(PORTOUT,153)@18
    xOut_v <= u0_m0_wo0_oseq_gated_reg_q;
    xOut_c <= "0000000" & GND_q;
    xOut_0 <= u0_m0_wo0_mtree_add2_0_q;


	--u0_m0_wo0_mtree_madd4_0_constmult0_shift0(BITSHIFT,218)@13
    u0_m0_wo0_mtree_madd4_0_constmult0_shift0_q_int <= u0_m0_wo0_sym_add0_q & "0";
    u0_m0_wo0_mtree_madd4_0_constmult0_shift0_q <= u0_m0_wo0_mtree_madd4_0_constmult0_shift0_q_int(9 downto 0);

	--u0_m0_wo0_mtree_madd4_0_constmult2_shift0(BITSHIFT,220)@13
    u0_m0_wo0_mtree_madd4_0_constmult2_shift0_q_int <= u0_m0_wo0_sym_add2_q & "0";
    u0_m0_wo0_mtree_madd4_0_constmult2_shift0_q <= u0_m0_wo0_mtree_madd4_0_constmult2_shift0_q_int(9 downto 0);

	--u0_m0_wo0_mtree_madd4_1_constmult0_shift0(BITSHIFT,211)@13
    u0_m0_wo0_mtree_madd4_1_constmult0_shift0_q_int <= u0_m0_wo0_sym_add4_q & "0";
    u0_m0_wo0_mtree_madd4_1_constmult0_shift0_q <= u0_m0_wo0_mtree_madd4_1_constmult0_shift0_q_int(9 downto 0);

	--u0_m0_wo0_mtree_madd4_1_constmult2_shift0(BITSHIFT,213)@13
    u0_m0_wo0_mtree_madd4_1_constmult2_shift0_q_int <= u0_m0_wo0_sym_add6_q & "0";
    u0_m0_wo0_mtree_madd4_1_constmult2_shift0_q <= u0_m0_wo0_mtree_madd4_1_constmult2_shift0_q_int(9 downto 0);

	--u0_m0_wo0_mtree_madd4_2_constmult0_shift0(BITSHIFT,204)@13
    u0_m0_wo0_mtree_madd4_2_constmult0_shift0_q_int <= u0_m0_wo0_sym_add8_q & "0";
    u0_m0_wo0_mtree_madd4_2_constmult0_shift0_q <= u0_m0_wo0_mtree_madd4_2_constmult0_shift0_q_int(9 downto 0);

	--u0_m0_wo0_mtree_madd4_2_constmult2_shift0(BITSHIFT,206)@13
    u0_m0_wo0_mtree_madd4_2_constmult2_shift0_q_int <= u0_m0_wo0_sym_add10_q & "0";
    u0_m0_wo0_mtree_madd4_2_constmult2_shift0_q <= u0_m0_wo0_mtree_madd4_2_constmult2_shift0_q_int(9 downto 0);

	--u0_m0_wo0_mtree_madd4_3_constmult0_shift0(BITSHIFT,197)@13
    u0_m0_wo0_mtree_madd4_3_constmult0_shift0_q_int <= u0_m0_wo0_sym_add12_q & "00";
    u0_m0_wo0_mtree_madd4_3_constmult0_shift0_q <= u0_m0_wo0_mtree_madd4_3_constmult0_shift0_q_int(10 downto 0);

	--u0_m0_wo0_mtree_madd4_3_constmult2_shift0(BITSHIFT,199)@13
    u0_m0_wo0_mtree_madd4_3_constmult2_shift0_q_int <= u0_m0_wo0_sym_add14_q & "00";
    u0_m0_wo0_mtree_madd4_3_constmult2_shift0_q <= u0_m0_wo0_mtree_madd4_3_constmult2_shift0_q_int(10 downto 0);

	--u0_m0_wo0_mtree_madd4_4_constmult0_shift0(BITSHIFT,189)@13
    u0_m0_wo0_mtree_madd4_4_constmult0_shift0_q_int <= u0_m0_wo0_sym_add16_q & "00";
    u0_m0_wo0_mtree_madd4_4_constmult0_shift0_q <= u0_m0_wo0_mtree_madd4_4_constmult0_shift0_q_int(10 downto 0);

	--u0_m0_wo0_mtree_madd4_4_constmult2_shift1(BITSHIFT,192)@13
    u0_m0_wo0_mtree_madd4_4_constmult2_shift1_q_int <= d_u0_m0_wo0_sym_add18_q_13_q & "00";
    u0_m0_wo0_mtree_madd4_4_constmult2_shift1_q <= u0_m0_wo0_mtree_madd4_4_constmult2_shift1_q_int(10 downto 0);

	--u0_m0_wo0_mtree_madd4_5_constmult0_shift0(BITSHIFT,180)@13
    u0_m0_wo0_mtree_madd4_5_constmult0_shift0_q_int <= u0_m0_wo0_sym_add20_q & "000";
    u0_m0_wo0_mtree_madd4_5_constmult0_shift0_q <= u0_m0_wo0_mtree_madd4_5_constmult0_shift0_q_int(11 downto 0);

	--u0_m0_wo0_mtree_madd4_5_constmult2_shift0(BITSHIFT,182)@12
    u0_m0_wo0_mtree_madd4_5_constmult2_shift0_q_int <= u0_m0_wo0_sym_add22_q & "0";
    u0_m0_wo0_mtree_madd4_5_constmult2_shift0_q <= u0_m0_wo0_mtree_madd4_5_constmult2_shift0_q_int(9 downto 0);

	--u0_m0_wo0_mtree_madd4_5_constmult2_shift2(BITSHIFT,184)@13
    u0_m0_wo0_mtree_madd4_5_constmult2_shift2_q_int <= d_u0_m0_wo0_sym_add22_q_13_q & "000";
    u0_m0_wo0_mtree_madd4_5_constmult2_shift2_q <= u0_m0_wo0_mtree_madd4_5_constmult2_shift2_q_int(11 downto 0);

	--u0_m0_wo0_mtree_madd4_6_constmult0_shift1(BITSHIFT,172)@13
    u0_m0_wo0_mtree_madd4_6_constmult0_shift1_q_int <= d_u0_m0_wo0_sym_add24_q_13_q & "0000";
    u0_m0_wo0_mtree_madd4_6_constmult0_shift1_q <= u0_m0_wo0_mtree_madd4_6_constmult0_shift1_q_int(12 downto 0);

	--u0_m0_wo0_mtree_madd4_6_constmult2_shift1(BITSHIFT,175)@13
    u0_m0_wo0_mtree_madd4_6_constmult2_shift1_q_int <= d_u0_m0_wo0_sym_add26_q_13_q & "00000";
    u0_m0_wo0_mtree_madd4_6_constmult2_shift1_q <= u0_m0_wo0_mtree_madd4_6_constmult2_shift1_q_int(13 downto 0);

	--u0_m0_wo0_mtree_madd4_7_constmult0_shift0(BITSHIFT,154)@11
    u0_m0_wo0_mtree_madd4_7_constmult0_shift0_q_int <= u0_m0_wo0_sym_add28_q & "000";
    u0_m0_wo0_mtree_madd4_7_constmult0_shift0_q <= u0_m0_wo0_mtree_madd4_7_constmult0_shift0_q_int(11 downto 0);

	--u0_m0_wo0_mtree_madd4_7_constmult0_shift2(BITSHIFT,156)@12
    u0_m0_wo0_mtree_madd4_7_constmult0_shift2_q_int <= d_u0_m0_wo0_sym_add28_q_12_q & "00000";
    u0_m0_wo0_mtree_madd4_7_constmult0_shift2_q <= u0_m0_wo0_mtree_madd4_7_constmult0_shift2_q_int(13 downto 0);

	--u0_m0_wo0_mtree_madd4_7_constmult2_shift0(BITSHIFT,159)@11
    u0_m0_wo0_mtree_madd4_7_constmult2_shift0_q_int <= u0_m0_wo0_sym_add30_q & "00000";
    u0_m0_wo0_mtree_madd4_7_constmult2_shift0_q <= u0_m0_wo0_mtree_madd4_7_constmult2_shift0_q_int(13 downto 0);

	--u0_m0_wo0_mtree_madd4_7_constmult2_shift2(BITSHIFT,161)@11
    u0_m0_wo0_mtree_madd4_7_constmult2_shift2_q_int <= u0_m0_wo0_sym_add30_q & "00";
    u0_m0_wo0_mtree_madd4_7_constmult2_shift2_q <= u0_m0_wo0_mtree_madd4_7_constmult2_shift2_q_int(10 downto 0);

	--u0_m0_wo0_mtree_madd4_7_constmult3_shift0(BITSHIFT,166)@13
    u0_m0_wo0_mtree_madd4_7_constmult3_shift0_q_int <= u0_m0_wo0_sym_add31_q & "00000000000";
    u0_m0_wo0_mtree_madd4_7_constmult3_shift0_q <= u0_m0_wo0_mtree_madd4_7_constmult3_shift0_q_int(19 downto 0);

	--u0_m0_wo0_mtree_madd4_7_constmult0_shift4(BITSHIFT,158)@13
    u0_m0_wo0_mtree_madd4_7_constmult0_shift4_q_int <= u0_m0_wo0_mtree_madd4_7_constmult0_sub_3_q & "00";
    u0_m0_wo0_mtree_madd4_7_constmult0_shift4_q <= u0_m0_wo0_mtree_madd4_7_constmult0_shift4_q_int(16 downto 0);

	--u0_m0_wo0_mtree_madd4_7_constmult2_shift4(BITSHIFT,163)@12
    u0_m0_wo0_mtree_madd4_7_constmult2_shift4_q_int <= u0_m0_wo0_mtree_madd4_7_constmult2_sub_3_q & "0000000";
    u0_m0_wo0_mtree_madd4_7_constmult2_shift4_q <= u0_m0_wo0_mtree_madd4_7_constmult2_shift4_q_int(18 downto 0);

	--u0_m0_wo0_mtree_madd4_7_constmult2_shift6(BITSHIFT,165)@13
    u0_m0_wo0_mtree_madd4_7_constmult2_shift6_q_int <= u0_m0_wo0_mtree_madd4_7_constmult2_add_5_q & "0";
    u0_m0_wo0_mtree_madd4_7_constmult2_shift6_q <= u0_m0_wo0_mtree_madd4_7_constmult2_shift6_q_int(20 downto 0);

end normal;
