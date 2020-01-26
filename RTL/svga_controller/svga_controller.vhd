----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  Peter Saffold 
-- 
-- Create Date: 01/05/2020 11:16:00 AM
-- Design Name: 
-- Module Name: svga_controller - Behavioral
-- Project Name: 
-- Target Devices: Zedboard
-- Tool Versions: Vivado 2018.3
-- Description: SVGA display controller for 800 x 600 @ 60 Hz
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

entity svga_controller is
    Port ( clock_40 : in STD_LOGIC;
           red : in STD_LOGIC_VECTOR (3 downto 0);
           green : in STD_LOGIC_VECTOR (3 downto 0);
           blue : in STD_LOGIC_VECTOR (3 downto 0);
           red_out : out STD_LOGIC_VECTOR (3 downto 0);
           green_out : out STD_LOGIC_VECTOR (3 downto 0);
           blue_out : out STD_LOGIC_VECTOR (3 downto 0);
           horz_sync_out : out STD_LOGIC;
           vert_sync_out : out STD_LOGIC;
           address : out STD_LOGIC_VECTOR(18 downto 0)
           );
end svga_controller;

architecture Behavioral of svga_controller is
  SIGNAL horiz_sync, vert_sync : STD_LOGIC;
  SIGNAL video_on, video_on_v, video_on_h : STD_LOGIC;
  SIGNAL h_count : UNSIGNED (10 downto 0) := "00000000000"; 
  SIGNAL v_count : UNSIGNED (10 downto 0) := "00000000000";
  SIGNAL address_out : STD_LOGIC_VECTOR(18 downto 0);
  
  constant H_VISIBLE : natural := 800;
  constant H_FP : natural := 40;
  constant H_SYNC : natural := 128;  
  constant H_BP : natural := 88;
  constant H_WHOLE : natural := H_VISIBLE + H_FP + H_SYNC + H_BP;
  
  constant V_VISIBLE : natural := 600;
  constant V_FP : natural := 1;
  constant V_SYNC : natural := 4;  
  constant V_BP : natural := 23;
  constant V_WHOLE : natural := V_VISIBLE + V_FP + V_SYNC + V_BP;
  
begin

  video_on <= video_on_h AND video_on_v;
  
  process(clock_40)
  begin
    if rising_edge(clock_40) then
    
      if (h_count < H_WHOLE) then
        h_count <= h_count + 1;
      else
        h_count <= "00000000000";
      end if;
      
      -- generate horizontal sync signal
      if (h_count < H_VISIBLE + H_FP) OR (h_count >= H_WHOLE - H_BP) then
        horiz_sync <= '1';
      else      
        horiz_sync <= '0';
      end if;

      -- generate video on signal      
      if (h_count < H_VISIBLE) then
        video_on_h <= '1';
      else
        video_on_h <= '0';
      end if;
      
      if (v_count = V_WHOLE - 1) and (h_count = H_WHOLE - 1) then
        v_count <= "00000000000";
      elsif (h_count = H_WHOLE - 1) then
        v_count <= v_count + 1;
      end if;
           
      -- generate vertical sync signal using v_count
      if (v_count < V_VISIBLE + V_FP) or (v_count >= V_WHOLE - V_BP) then
        vert_sync <= '1';
      else
        vert_sync <= '0';
      end if;
   
      if (v_count < V_VISIBLE) then
        video_on_v <= '1';
      else
        video_on_v <= '0';
      end if;
      
      if (h_count < H_VISIBLE) AND (v_count < V_VISIBLE) then
        address_out <= std_logic_vector(resize(h_count + (v_count * H_VISIBLE), address'length));
      else
        address_out <= (others=>'0');
      end if;
      
      if (video_on = '1') then
        red_out <= red;
        green_out <= green;
        blue_out <= blue;
      else
        red_out <= "0000";
        green_out <= "0000";
        blue_out <= "0000";
      end if;
      
      horz_sync_out <= horiz_sync;
      vert_sync_out <= vert_sync;  
    end if;
  end process;
  
  address <= address_out;

end Behavioral;