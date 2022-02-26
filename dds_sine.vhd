
-- ******************************************************************** 
-- ******************************************************************** 
-- 
-- Coding style summary:
--
--	i_   Input signal 
--	o_   Output signal 
--	b_   Bi-directional signal 
--	r_   Register signal 
--	w_   Wire signal (no registered logic) 
--	t_   User-Defined Type 
--	p_   pipe
--  pad_ PAD used in the top level
--	G_   Generic (UPPER CASE)
--	C_   Constant (UPPER CASE)
--  ST_  FSM state definition (UPPER CASE)
--
-- ******************************************************************** 
--
-- Copyright ©2015 SURF-VHDL
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- ******************************************************************** 
--
-- Fle Name: dds_sine.vhd
-- 
-- scope: programmable DDS sine generator
--
-- rev 1.00
-- 
-- ******************************************************************** 
-- ******************************************************************** 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;

entity dds_sine is
port(
	i_clk          : in  std_logic;
	i_rstb         : in  std_logic;
	i_sync_reset   : in  std_logic;
	i_fcw          : in  std_logic_vector(31 downto 0);
	i_start_phase  : in  std_logic_vector(31 downto 0);
	o_sine         : out std_logic_vector(13 downto 0));
end dds_sine;

architecture rtl of dds_sine is

constant C_LUT_DEPTH    : integer := 2**13;  -- 8Kword
constant C_LUT_BIT      : integer := 14;     -- 14 bit LUT
type t_lut_sin is array(0 to C_LUT_DEPTH-1) of std_logic_vector(C_LUT_BIT-1 downto 0);

-- quantize a real value as signed 
function quantization_sgn(nbit : integer; max_abs : real; dval : real) return std_logic_vector is
variable temp    : std_logic_vector(nbit-1 downto 0):=(others=>'0');
constant scale   : real :=(2.0**(real(nbit-1)))/max_abs;
constant minq    : integer := -(2**(nbit-1));
constant maxq    : integer := +(2**(nbit-1))-1;
variable itemp   : integer := 0;
begin
  if(nbit>0) then
    if (dval>=0.0) then 
      itemp := +(integer(+dval*scale+0.49));
    else 
      itemp := -(integer(-dval*scale+0.49));
    end if;
    if(itemp<minq) then itemp := minq; end if;
    if(itemp>maxq) then itemp := maxq; end if;
  end if;
  temp := std_logic_vector(to_signed(itemp,nbit));
  return temp;
end quantization_sgn;

-- generate the sine values for a LUT of depth "LUT_DEPTH" and quantization of "LUT_BIT"
function init_lut_sin return t_lut_sin is
variable ret           : t_lut_sin:=(others=>(others=>'0'));  -- LUT generated
variable v_tstep       : real:=0.0;
variable v_qsine_sgn   : std_logic_vector(C_LUT_BIT-1 downto 0):=(others=>'0');
constant step          : real := 1.00/real(C_LUT_DEPTH);
begin
	for count in 0 to C_LUT_DEPTH-1 loop
		v_qsine_sgn := quantization_sgn(C_LUT_BIT, 1.0,sin(MATH_2_PI*v_tstep));
		ret(count)  := v_qsine_sgn;
		v_tstep := v_tstep + step;
     end loop;
     return ret;
end function init_lut_sin;

-- initialize LUT with sine samples
constant C_LUT_SIN                 : t_lut_sin := init_lut_sin;
signal r_sync_reset                : std_logic;
signal r_start_phase               : unsigned(31 downto 0);
signal r_fcw                       : unsigned(31 downto 0);
signal r_nco                       : unsigned(31 downto 0);
signal lut_addr                    : std_logic_vector(12 downto 0);
signal lut_value                   : std_logic_vector(13 downto 0);

begin

p_nco : process(i_clk,i_rstb)
begin
	if(i_rstb='0') then
		r_sync_reset      <= '1';
		r_start_phase     <= (others=>'0');
		r_fcw             <= (others=>'0');
		r_nco             <= (others=>'0');
	elsif(rising_edge(i_clk)) then
		r_sync_reset      <= i_sync_reset   ;
		r_start_phase     <= unsigned(i_start_phase);
		r_fcw             <= unsigned(i_fcw);
		if(r_sync_reset='1') then
			r_nco             <= r_start_phase;
		else
			r_nco             <= r_nco + r_fcw;
		end if;
	end if;
end process p_nco;

p_rom : process(i_clk)
begin
	if(rising_edge(i_clk)) then
		lut_addr   <= std_logic_vector(r_nco(31 downto 19));
		lut_value  <= C_LUT_SIN(to_integer(unsigned(lut_addr)));
	end if;
end process p_rom;

p_sine : process(i_clk,i_rstb)
begin
	if(i_rstb='0') then
		o_sine     <= (others=>'0');
	elsif(rising_edge(i_clk)) then
		o_sine     <= lut_value;
	end if;
end process p_sine;

end rtl;

