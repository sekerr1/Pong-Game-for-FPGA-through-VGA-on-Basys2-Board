library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Generate25MHz is
	port (
	   i_Clk : in std_logic;
	   o_Clk : out std_logic
	   );
end entity Generate25MHz;

architecture RTL of Generate25MHz is

signal temp_clk : std_logic := '0';

 begin


 -- convert 50Mhz input clock to a 25Mhz signal clock
p_Generate25MHz: process (i_Clk)
  begin
    if rising_edge(i_Clk) then
	   temp_clk <= not temp_clk;
	 end if;
 end process p_Generate25MHz;
  
  o_Clk <= temp_clk;
 
 end architecture RTL;