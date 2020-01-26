----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/05/2020 05:03:35 PM
-- Design Name: 
-- Module Name: slow_clock - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity slow_clock is
    Port ( clock_25 : in STD_LOGIC;
           slow_clock : out STD_LOGIC);
end slow_clock;

architecture Behavioral of slow_clock is
signal count : unsigned(25 downto 0) := (others => '0');
signal clock_out : std_logic := '0';
begin

  count_reg : process(clock_25) is
  begin
    if rising_edge(clock_25) then
      if (count = 12500000) then
        clock_out <= not(clock_out);
        count <= (others => '0');
      else
        count <= count + 1;
      end if;
    end if;
  end process;
  
  slow_clock <= clock_out;

end Behavioral;
