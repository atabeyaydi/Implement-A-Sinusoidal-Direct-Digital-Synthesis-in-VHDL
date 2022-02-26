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
-- Fle Name: dds_sine_tb.vhd
-- 
-- scope: test bench for dds_sine.vhd
--
-- rev 1.00
-- 
-- ******************************************************************** 
-- ******************************************************************** 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dds_sine_tb is
end dds_sine_tb;

architecture rtl of dds_sine_tb is

component dds_sine
port (
	i_clk          : in  std_logic;
	i_rstb         : in  std_logic;
	i_sync_reset   : in  std_logic;
	i_fcw          : in  std_logic_vector(31 downto 0);
	i_start_phase  : in  std_logic_vector(31 downto 0);
	o_sine         : out std_logic_vector(13 downto 0));
end component;

signal i_clk                       : std_logic:='0';
signal i_rstb                      : std_logic;
signal i_sync_reset                : std_logic;
signal i_start_phase1              : std_logic_vector(31 downto 0):=X"00000000";
signal i_start_phase2              : std_logic_vector(31 downto 0):=X"80000000";  -- 180°
signal i_fcw                       : std_logic_vector(31 downto 0):=X"028F5C28";  -- 1 MHz
signal o_sine1                     : std_logic_vector(13 downto 0);
signal o_sine2                     : std_logic_vector(13 downto 0);

begin

i_clk  <= not i_clk  after 5 ns;
i_rstb <= '0', '1' after 163 ns;
i_sync_reset <= '1', '0' after 200 ns;

u1_dds_sine : dds_sine
port map(
	i_clk                       => i_clk                      ,
	i_rstb                      => i_rstb                     ,
	i_sync_reset                => i_sync_reset               ,
	i_start_phase               => i_start_phase1             ,
	i_fcw                       => i_fcw                      ,
	o_sine                      => o_sine1                    );
	
u2_dds_sine : dds_sine
port map(
	i_clk                       => i_clk                      ,
	i_rstb                      => i_rstb                     ,
	i_sync_reset                => i_sync_reset               ,
	i_start_phase               => i_start_phase2             ,
	i_fcw                       => i_fcw                      ,
	o_sine                      => o_sine2                    );
end rtl;
