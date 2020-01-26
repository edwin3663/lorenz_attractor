library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity attractor is
  port(clock_25      : in  std_logic;
       slow_clock    : in  std_logic;
       reset         : in  std_logic;
       red_out       : out std_logic_vector(2 downto 0);
       green_out     : out std_logic_vector(2 downto 0);
       blue_out      : out std_logic_vector(2 downto 0);       
       address       : out std_logic_vector(18 downto 0);
       plot          : out std_logic       
       );
end attractor;

architecture rtl of attractor is
  -- signals for the fsm
  type colorState is (G_INC, R_DEC, B_INC, G_DEC, R_INC, B_DEC);
  type myStates is (RUN, DELAY, INIT_CLEAR, CLEAR);   
  signal cur_state, next_state : myStates := RUN;
  signal cur_color, next_color : colorState := G_INC;
	
	-- color data
	signal r_count : unsigned(2 downto 0) := "111";
	signal g_count : unsigned(2 downto 0) := "000";
	signal b_count : unsigned(2 downto 0) := "000";
  
  -- constants
  constant FRAC_BITS  : natural := 20;
  constant INT_BITS   : natural := 10;
  constant SIGN_BIT   : natural := 1;
  constant TOTAL_BITS : natural := FRAC_BITS + INT_BITS + SIGN_BIT;
  constant MAX_COUNT  : natural := 25000;
  constant ONE          : signed(TOTAL_BITS - 1 downto 0)  := "0000000000100000000000000000000"; -- 1
  constant TEN          : signed(TOTAL_BITS - 1 downto 0)  := "0000000101000000000000000000000"; -- 10
  constant TWENTY_EIGHT : signed(TOTAL_BITS - 1 downto 0)  := "0000001111000000000000000000000"; -- 28
  constant SIXY_FOUR    : signed(TOTAL_BITS - 1 downto 0)  := "0000010000000000000000000000000"; -- 64
  constant EIGHT_THIRDS : signed(TOTAL_BITS - 1 downto 0)  := "0000000001010101010100000000000"; -- 8/3
  constant THOUSANDTH   : signed(TOTAL_BITS - 1 downto 0)  := "0000000000000000000010000011000";  -- 0.001
  
  constant INIT_DX : signed(TOTAL_BITS - 1 downto 0)       := (others => '0');
  constant INIT_DY : signed(TOTAL_BITS - 1 downto 0)       := shift_left(to_signed(62, TOTAL_BITS), FRAC_BITS); -- shift_left(to_signed(26, TOTAL_BITS), FRAC_BITS);
  constant INIT_DZ : signed(TOTAL_BITS - 1 downto 0)       := "1111111111001010101100000000000"; -- -1.667
  
  -- lorenz attractor	registers                              _________.______________________________
  signal x     : signed(TOTAL_BITS - 1 downto 0)       := ONE; 
  signal y     : signed(TOTAL_BITS - 1 downto 0)       := ONE;
  signal z     : signed(TOTAL_BITS - 1 downto 0)       := ONE;

  signal dx     : signed(TOTAL_BITS - 1 downto 0)       := INIT_DX; 
  signal dy     : signed(TOTAL_BITS - 1 downto 0)       := INIT_DY;
  signal dz     : signed(TOTAL_BITS - 1 downto 0)       := INIT_DZ;
  
  signal sig       : signed(TOTAL_BITS - 1 downto 0)       := TEN;
  signal rho       : signed(TOTAL_BITS - 1 downto 0)       := SIXY_FOUR;-- TWENTY_EIGHT;
  signal beta      : signed(TOTAL_BITS - 1 downto 0)       := EIGHT_THIRDS;
    
  signal time_step : signed(TOTAL_BITS - 1 downto 0)       := THOUSANDTH;
  signal count     : signed(24 downto 0)       := (others => '0');
  
  signal address_reg : signed(19 downto 0) := (others => '0');
  signal plot_reg : std_logic := '0';
  
  signal mode : unsigned(1 downto 0) := (others => '0');
begin

   output_reg : process(clock_25, reset, plot_reg, address_reg, cur_state, reset, x, y)
   begin
     if rising_edge(clock_25) then
       if (reset = '1') then
         plot_reg <= '0';
         address_reg <= (others => '0');
       else
         if (cur_state = DELAY) then
            plot_reg <= '0';
            address_reg <= address_reg;
         elsif (cur_state = INIT_CLEAR) then
           if (mode = "10") then
             mode <= "00";
           else
             mode <= mode + 1;
           end if;
         elsif (cur_state = CLEAR) then
           plot_reg <= '1';
           address_reg <= resize(x + (y * 800), address_reg'length);
         else
            plot_reg <= '1';
            case (mode) is
            when "00" =>
              address_reg <= resize(shift_right(x * 11, FRAC_BITS), 20) + to_signed(400, 20)  + resize((resize(shift_right(z * 8, FRAC_BITS), 20) + to_signed(100, 20)) * to_signed(800, 20), 20);
            when "01" =>
              address_reg <= resize(shift_right(y * 11, FRAC_BITS), 20) + to_signed(400, 20)  + resize((resize(shift_right(z * 8, FRAC_BITS), 20) + to_signed(100, 20)) * to_signed(800, 20), 20);
            when "10" =>
              address_reg <= resize(shift_right(x * 11, FRAC_BITS), 20) + to_signed(400, 20)  + resize((resize(shift_right(y * 8, FRAC_BITS), 20) + to_signed(250, 20)) * to_signed(800, 20), 20);
            when "11" =>
              address_reg <= resize(shift_right(y * 8, FRAC_BITS), 20) + to_signed(400, 20)  + resize((resize(shift_right(x * 8, FRAC_BITS), 20) + to_signed(250, 20)) * to_signed(800, 20), 20);
            end case;                        
         end if;
       end if;
     end if;
     
     plot <= plot_reg;
     address <= std_logic_vector(resize(unsigned(address_reg), address'length));
   end process output_reg;
   
  state_reg : process(clock_25, reset, next_state) is
  begin
    if rising_edge(clock_25) then
      if (reset = '1') then
        cur_state <= INIT_CLEAR;
      else
        cur_state <= next_state;
      end if;
    end if;
  end process state_reg;
  
  count_reg : process(clock_25, reset, cur_state, count) is
  begin
    if rising_edge(clock_25) then
      if (reset = '1') or (count = MAX_COUNT) then
        count <= (others => '0');
      else
        count <= count + 1;
      end if;
    end if;
  end process count_reg;  
  
  next_state_logic : process(cur_state, count, x, y) is
	begin
		case cur_state is
			when RUN =>
	      next_state <= DELAY; 
			when DELAY =>
				if count = MAX_COUNT then
					next_state <= RUN;
				else
					next_state <= DELAY;
				end if;
			when INIT_CLEAR =>
			  next_state <= CLEAR;
		  when CLEAR =>
		    if (x = 798) and (y = 598) then
		      next_state <= RUN;
		    else
		      next_state <= CLEAR;
		    end if;
		end case;
	end process next_state_logic;
  
	compute_ode : process(clock_25, reset, dx, dy, dz) is
	begin
	  if rising_edge(clock_25) then
	    if (reset = '1') then
	      x <= ONE;
        y <= ONE;
        z <= ONE;
        
        dx <= INIT_DX;
        dy <= INIT_DY;
        dz <= INIT_DZ;
	    else
        -- dx_dt = sig * (y - x)
        -- dy_dt = x * (rho - z) - y
        -- dz_dt = (x * y) - (beta * z)        
        
        if (cur_state = RUN) then
          dx <= resize(shift_right(sig * (y - x), FRAC_BITS), TOTAL_BITS);
          dy <= resize(shift_right(x * (rho - z), FRAC_BITS) - y, TOTAL_BITS);
          dz <= resize(shift_right(x * y, FRAC_BITS), TOTAL_BITS) - 
            resize(shift_right(beta * z, FRAC_BITS), TOTAL_BITS);       
        
          x <= x + resize(shift_right(dx * time_step, FRAC_BITS), TOTAL_BITS);
          y	<= y + resize(shift_right(dy * time_step, FRAC_BITS), TOTAL_BITS);
          z	<= z + resize(shift_right(dz * time_step, FRAC_BITS), TOTAL_BITS);
        elsif (cur_state = INIT_CLEAR) then
          x <= (others => '0');
          y <= (others => '0');
          z <= (others => '0');
          
          dx <= dx;
          dy <= dy;
          dz <= dz;          
        elsif (cur_state = CLEAR) then
          if (x < 799) then
            x <= x + 1;
          else
            x <= (others => '0');
          end if;
          
          if (x = 799) and (y < 600) then
            y <= y + 1;
          else
            y <= y;
          end if;
          
          z <= z;
          
          dx <= dx;
          dy <= dy;
          dz <= dz;          
        else
          dx <= dx;
          dy <= dy;
          dz <= dz;       
        
          x <= x;
          y	<= y;
          z	<= z;
        end if;        
      end if;
    end if;
  end process compute_ode;
  
  color_state_reg : process(slow_clock) is
  begin
    if rising_edge(slow_clock) then
      if (reset = '1') then
        r_count <= "111";
        g_count <= "000";
        b_count <= "000";
        cur_color <= G_INC;
      else
        cur_color <= next_color;
        case cur_color is
        when G_INC =>
          r_count <= r_count;
          g_count <= g_count + 1;
          b_count <= b_count;
        when R_DEC =>
          r_count <= r_count - 1;
          g_count <= g_count;
          b_count <= b_count;
        when B_INC =>
          r_count <= r_count;
          g_count <= g_count;
          b_count <= b_count + 1;
        when G_DEC =>
          r_count <= r_count;
          g_count <= g_count - 1;
          b_count <= b_count;
        when R_INC =>
          r_count <= r_count + 1;
          g_count <= g_count;
          b_count <= b_count;
        when B_DEC =>
          r_count <= r_count; 
          g_count <= g_count;
          b_count <= b_count - 1;
        end case;
      end if;
    end if;
  end process color_state_reg;
  
  next_color_logic : process(r_count, g_count, b_count, cur_color) is
  begin
    case (cur_color) is
    when G_INC =>
      if g_count < "110" then
        next_color <= G_INC;
      else
        next_color <= R_DEC;
      end if;
    when R_DEC =>
      if r_count > "001" then
        next_color <= R_DEC;
      else
        next_color <= B_INC;
      end if;   
    when B_INC =>
      if b_count < "110" then
        next_color <= B_INC;
      else
        next_color <= G_DEC;
      end if;    
    when G_DEC =>
      if g_count > "001" then
        next_color <= G_DEC;
      else
        next_color <= R_INC;
      end if;    
    when R_INC =>
      if r_count < "110" then
        next_color <= R_INC;
      else
        next_color <= B_DEC;
      end if;    
    when B_DEC =>
      if b_count > "001" then
        next_color <= B_DEC;
      else
        next_color <= G_INC;
      end if;    
    end case;
  end process next_color_logic;
  
  	-- output color
  red_out <= "000" when (cur_state = CLEAR) else std_logic_vector(r_count);
  green_out <= "000" when (cur_state = CLEAR) else std_logic_vector(g_count);
  blue_out <= "000" when (cur_state = CLEAR) else std_logic_vector(b_count);
   
end architecture RTL;

