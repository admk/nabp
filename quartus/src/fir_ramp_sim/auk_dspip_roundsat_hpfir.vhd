-- (C) 2001-2011 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions and other 
-- software and tools, and its AMPP partner logic functions, and any output 
-- files any of the foregoing (including device programming or simulation 
-- files), and any associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License Subscription 
-- Agreement, Altera MegaCore Function License Agreement, or other applicable 
-- license agreement, including, without limitation, that your use is for the 
-- sole purpose of programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the applicable 
-- agreement for further details.


-------------------------------------------------------------------------
-------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: auk_dspip_roundsat_hpfir.vhd,v $
--
-- $Revision: #1 $
-- $Date: 2010/08/19 $
-- Check in by     : $Author: max $
--
-- Description : 
-- Implement output options for HP-FIR
-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2006 (c) Altera Corporation
-- All rights reserved
--
-------------------------------------------------------------------------
-------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity auk_dspip_roundsat_hpfir is
  generic (
    IN_WIDTH_g      : natural := 8;               -- i/p data width
    REM_LSB_BIT_g   : natural := 2;               -- no. of lsb to be removed
    REM_LSB_TYPE_g  : string  := "Truncation";    -- Truncation/Rounding
    REM_MSB_BIT_g   : natural := 2;               -- no. of msb to be removed
    REM_MSB_TYPE_g  : string  := "Truncation"     -- Truncation/Saturating
    );
  port (
    clk             : in  std_logic;
    reset_n         : in  std_logic;
    enable          : in  std_logic;
    datain          : in  std_logic_vector(IN_WIDTH_g-1 downto 0);
    valid           : out std_logic;
    dataout         : out std_logic_vector(IN_WIDTH_g-REM_LSB_BIT_g-REM_MSB_BIT_g-1 downto 0)
  );
end entity auk_dspip_roundsat_hpfir;

architecture beh of auk_dspip_roundsat_hpfir is

  signal    data_lsb  : std_logic_vector(IN_WIDTH_g-REM_LSB_BIT_g-1 downto 0);
  signal    valid_lsb : std_logic;

  signal    data_msb  : std_logic_vector(IN_WIDTH_g-REM_LSB_BIT_g-REM_MSB_BIT_g-1 downto 0);

  constant  zero_vec  : std_logic_vector := std_logic_vector(to_signed(0, REM_LSB_BIT_g));

begin  -- architecture beh

  -----------------------------------------------------------------------------
  -- lsb : truncation/round-up (symmetric)
  -----------------------------------------------------------------------------
  remove_lsb: if REM_LSB_BIT_g > 0 generate
  begin
    trunc_lsb: if REM_LSB_TYPE_g = "Truncation" generate
    begin
      data_lsb  <= datain(IN_WIDTH_g-1 downto REM_LSB_BIT_g);
      valid_lsb <= enable;
    end generate trunc_lsb;
    rndup_lsb: if REM_LSB_TYPE_g = "Rounding" generate
      round_up_sym_p : process (clk, reset_n)
        variable OR_accu : std_logic := '0';
      begin
        if reset_n = '0' then
          data_lsb  <= (others => '0');
          valid_lsb <= '0';
        elsif rising_edge(clk) then
          if enable = '1' then
            OR_accu := '0';
            for i in 0 to REM_LSB_BIT_g-2 loop
              OR_accu := OR_accu or datain(i);
            end loop;
            -- negative value
            if (datain(IN_WIDTH_g-1) = '1') then
              -- larger than -x.5 : rounded to -x
              if (datain(REM_LSB_BIT_g-1)='1' and OR_accu='1') then
                data_lsb <= std_logic_vector(signed(datain(IN_WIDTH_g-1 downto REM_LSB_BIT_g))+1);
              -- less than or equal -x.5 : rounded to -x + 1
              else
                data_lsb <= datain(IN_WIDTH_g-1 downto REM_LSB_BIT_g);
              end if;
            -- positive value
            else
              -- maximum positive value
              if datain(IN_WIDTH_g-1 downto REM_LSB_BIT_g-1) = std_logic_vector(to_signed(2**(IN_WIDTH_g-REM_LSB_BIT_g)-1, IN_WIDTH_g-REM_LSB_BIT_g+1)) then
                data_lsb <= std_logic_vector(to_signed( 2**(IN_WIDTH_g-REM_LSB_BIT_g-1)-1, IN_WIDTH_g-REM_LSB_BIT_g));
              -- larger than or equal x.5 : rounded to x + 1
              elsif datain(REM_LSB_BIT_g-1) = '1' then
                data_lsb <= std_logic_vector(signed(datain(IN_WIDTH_g-1 downto REM_LSB_BIT_g))+1);
              -- less than x.5 : rounded to x
              else
                data_lsb <= datain(IN_WIDTH_g-1 downto REM_LSB_BIT_g);
              end if;
            end if;
          end if;
          valid_lsb <= enable;
        end if;
      end process round_up_sym_p;
    end generate rndup_lsb;
  end generate remove_lsb;
  
  -----------------------------------------------------------------------------
  -- keep lsb
  -----------------------------------------------------------------------------
  keep_lsb: if REM_LSB_BIT_g = 0 generate
  begin
    data_lsb <= datain;
    valid_lsb <= enable;
  end generate keep_lsb;
  
  -----------------------------------------------------------------------------
  -- msb : truncation/saturation
  -----------------------------------------------------------------------------
  remove_msb: if REM_MSB_BIT_g > 0 generate
  begin
    trunc_msb: if REM_MSB_TYPE_g = "Truncation" generate
    begin
      data_msb <= data_lsb(IN_WIDTH_g-REM_LSB_BIT_g-REM_MSB_BIT_g-1 downto 0);
      dataout  <= data_msb;
      valid    <= valid_lsb;
    end generate trunc_msb;
    sat_msb: if REM_MSB_TYPE_g = "Saturating" generate
      data_msb <= std_logic_vector(to_signed( 2**(IN_WIDTH_g-REM_LSB_BIT_g-REM_MSB_BIT_g-1)-1, IN_WIDTH_g-REM_LSB_BIT_g-REM_MSB_BIT_g)) when signed(data_lsb) >  2**(IN_WIDTH_g-REM_LSB_BIT_g-REM_MSB_BIT_g-1)-1 else
                  std_logic_vector(to_signed(-2**(IN_WIDTH_g-REM_LSB_BIT_g-REM_MSB_BIT_g-1)  , IN_WIDTH_g-REM_LSB_BIT_g-REM_MSB_BIT_g)) when signed(data_lsb) < -2**(IN_WIDTH_g-REM_LSB_BIT_g-REM_MSB_BIT_g-1)   else
                  data_lsb(IN_WIDTH_g-REM_LSB_BIT_g-REM_MSB_BIT_g-1 downto 0);
      msb_p : process (clk, reset_n)
      begin
        if reset_n = '0' then
          dataout <= (others => '0');
          valid   <= '0';
        elsif rising_edge(clk) then
          if valid_lsb = '1' then
            dataout <= data_msb;
          end if;
          valid <= valid_lsb;
        end if;
      end process msb_p;
    end generate sat_msb; 
  end generate remove_msb;
  
  -----------------------------------------------------------------------------
  -- keep msb
  -----------------------------------------------------------------------------
  keep_msb: if REM_MSB_BIT_g = 0 generate
  begin
    data_msb <= data_lsb;
    dataout  <= data_msb;
    valid    <= valid_lsb;
  end generate keep_msb;
  
  -----------------------------------------------------------------------------
  -- error checking:
  --   Have we got a valid rounding mode?
  --   Is the input greater than the output?
  -----------------------------------------------------------------------------
  assert    (REM_LSB_TYPE_g = "Truncation" or
             REM_LSB_TYPE_g = "Rounding" or
             REM_MSB_TYPE_g = "Truncation" or
             REM_MSB_TYPE_g = "Saturating"
             ) report "Please check your rounding type and its spelling.  Currently, we only support Truncation, and Rounding for LSB, Truncation and Saturating for MSB" severity error;


end architecture beh;
