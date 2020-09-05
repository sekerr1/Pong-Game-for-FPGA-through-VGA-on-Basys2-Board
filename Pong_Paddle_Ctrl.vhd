library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;
 
library work;
use work.Pong_Pkg.all;
 
entity Pong_Paddle_Ctrl is
  generic (
    g_Player_Paddle_X : integer  -- Changes for P1 vs P2
    );
  port (
    i_Clk : in std_logic;
	 r_P1_Score : in integer;
	 
    i_Col_Count_Div : in std_logic_vector(7 downto 0);
    i_Row_Count_Div : in std_logic_vector(7 downto 0);
	  
    -- Player Paddle Control
    i_Paddle_Up : in std_logic;
    i_Paddle_Dn : in std_logic;
 
    o_Draw_Paddle : out std_logic;
    o_Paddle_Y    : out std_logic_vector(7 downto 0)
    );
end entity Pong_Paddle_Ctrl;
 
architecture rtl of Pong_Paddle_Ctrl is
 
  signal w_Col_Index : integer range  0 to 2**i_Col_Count_Div'length := 0;
  signal w_Row_Index : integer range 0 to 2**i_Row_Count_Div'length := 0;
 
  signal w_Paddle_Count_En : std_logic;
 
  signal r_Paddle_Count : integer range 0 to c_Paddle_Speed := 0;
   
  -- Start Location of Paddles and the range they can travel 
  signal r_Paddle_Y : integer range 0 to c_Game_Height-c_Paddle_Height-1 := c_Game_Height/2; -- change the height at start

  signal r_Draw_Paddle : std_logic := '0';
   
begin

  w_Col_Index <= to_integer(unsigned(i_Col_Count_Div));
  w_Row_Index <= to_integer(unsigned(i_Row_Count_Div));  
 
  -- Only allow paddles to move if only one button is pushed.
  w_Paddle_Count_En <= i_Paddle_Up xor i_Paddle_Dn;
 
  -- Controls how the paddles are moved.  Sets r_Paddle_Y.
  -- Can change the movement speed by changing the constant in Package file.
  p_Move_Paddles : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
 
      -- Update the paddle counter when either switch is pushed and held.
      if w_Paddle_Count_En = '1' then
        if r_Paddle_Count = c_Paddle_Speed then
          r_Paddle_Count <= 0;
        else
          r_Paddle_Count <= r_Paddle_Count + 1;
        end if;
      else
        r_Paddle_Count <= 0;
      end if;
 
      -- Update the Paddle Location Slowly, only allowed when the Paddle Count
      -- reaches its limit
      if (i_Paddle_Up = '1' and r_Paddle_Count = c_Paddle_Speed) then
 
        -- If Paddle is already at the top, do not update it
        if r_Paddle_Y /= 0 then
          r_Paddle_Y <= r_Paddle_Y - 1;
        end if;
 
      elsif (i_Paddle_Dn = '1' and r_Paddle_Count = c_Paddle_Speed) then
 
        -- If Paddle is already at the bottom, do not update it
        if r_Paddle_Y /= c_Game_Height-c_Paddle_Height+(r_P1_Score*2) then
          r_Paddle_Y <= r_Paddle_Y  + 1;
        end if;
         
      end if;
    end if;
  end process p_Move_Paddles;
 
   
  -- Draws the Paddles as deteremined by input Generic g_Player_Paddle_X
  -- as well as r_Paddle_Y.
  p_Draw_Paddles : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      -- Draws in a single column and in a range of rows.
      -- Range of rows is determined by c_Paddle_Height
      if (w_Col_Index = g_Player_Paddle_X and
          w_Row_Index >= r_Paddle_Y and
          w_Row_Index <= r_Paddle_Y + c_Paddle_Height - (r_P1_Score*2)) then
          r_Draw_Paddle <= '1';
			 
		elsif(w_Col_Index = c_Game_Width/2 and 
				((w_Row_Index >= 0 and w_Row_Index <= 2) or 
				(w_Row_Index >= c_Game_Height - 2 and  w_Row_Index <= c_Game_Height))) then
				r_Draw_Paddle <= '1';
																														-- PRINT SCORE 0
		elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and 
				w_Row_Index = 0 and
			    r_P1_Score = 0) then
			r_Draw_Paddle <= '1';
		elsif ((w_Col_Index = g_Player_Paddle_X + 12 or w_Col_Index = g_Player_Paddle_X -14 ) and 
				w_Row_Index >= 0 and
            w_Row_Index <= 4 and 
			    r_P1_Score = 0) then
			r_Draw_Paddle <= '1';	
		elsif ((w_Col_Index = g_Player_Paddle_X + 14 or w_Col_Index = g_Player_Paddle_X - 12 ) and 
				w_Row_Index >= 0 and
            w_Row_Index <= 4 and 
			    r_P1_Score = 0) then
			r_Draw_Paddle <= '1';
			elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and
				w_Row_Index = 4  and
			    r_P1_Score = 0) then
				r_Draw_Paddle <= '1';
				
			 
																			--PRINT SCORE 1
		elsif ((w_Col_Index = g_Player_Paddle_X + 12 or w_Col_Index = g_Player_Paddle_X -18) and 
				w_Row_Index >= 0 and
				w_Row_Index <= 4 and
			    r_P1_Score = 1 ) then
			r_Draw_Paddle <= '1';
			
																			--PRINT  SCORE 2	
		elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and
				w_Row_Index = 0 and
			    r_P1_Score = 2) then
			r_Draw_Paddle <= '1';
			
		elsif ((w_Col_Index = g_Player_Paddle_X + 14 or w_Col_Index = g_Player_Paddle_X - 12 ) and 
				w_Row_Index >= 0 and
				w_Row_Index <= 1 and 
			    r_P1_Score = 2) then
			r_Draw_Paddle <= '1';	
			
		elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and
				w_Row_Index = 2 and
			    r_P1_Score = 2) then
			r_Draw_Paddle <= '1';
			
		elsif ((w_Col_Index = g_Player_Paddle_X + 12 or w_Col_Index = g_Player_Paddle_X - 14 ) and 
				w_Row_Index >= 2 and
                w_Row_Index <= 4 and 
			    r_P1_Score = 2) then
			r_Draw_Paddle <= '1';
			
		elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and
				w_Row_Index = 4  and
			    r_P1_Score = 2) then
			r_Draw_Paddle <= '1';		
			
			
																			--PRINT SCORE 3	
		elsif ((w_Col_Index = g_Player_Paddle_X + 14 or w_Col_Index = g_Player_Paddle_X - 12) and 
				w_Row_Index >= 0 and
				w_Row_Index <= 4 and
				r_P1_Score = 3 ) then
			r_Draw_Paddle <= '1';
								
		elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and
				w_Row_Index = 0 and
				r_P1_Score = 3) then
			r_Draw_Paddle <= '1';
		
		elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and
				w_Row_Index = 2  and
				r_P1_Score = 3) then
			r_Draw_Paddle <= '1';				
				
		elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and
				w_Row_Index = 4  and
				r_P1_Score = 3) then
			r_Draw_Paddle <= '1';		
				
			
																			--PRINT SCORE 4	
		elsif ((w_Col_Index = g_Player_Paddle_X + 14 or w_Col_Index = g_Player_Paddle_X - 12 ) and 
				w_Row_Index >= 0 and
				w_Row_Index <= 4 and
				r_P1_Score = 4 ) then
			r_Draw_Paddle <= '1';
								
		elsif ((w_Col_Index = g_Player_Paddle_X + 12 or w_Col_Index = g_Player_Paddle_X - 14) and 
				w_Row_Index >= 0 and
				w_Row_Index <= 2 and
				r_P1_Score = 4 ) then
			r_Draw_Paddle <= '1';
			
		elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and
				w_Row_Index = 2  and
				r_P1_Score = 4) then
			r_Draw_Paddle <= '1';	
			
			
			
			
																			-- PRINT SCORE 5
		elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and 
				w_Row_Index = 0 and
			    r_P1_Score = 5) then
			r_Draw_Paddle <= '1';
		elsif ((w_Col_Index = g_Player_Paddle_X + 12 or w_Col_Index = g_Player_Paddle_X -14 ) and 
				w_Row_Index >= 0 and
            w_Row_Index <= 1 and 
			    r_P1_Score = 5) then
			r_Draw_Paddle <= '1';	
		elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and
				w_Row_Index = 2 and
			    r_P1_Score = 5) then
			r_Draw_Paddle <= '1';
		elsif ((w_Col_Index = g_Player_Paddle_X + 14 or w_Col_Index = g_Player_Paddle_X - 12 ) and 
				w_Row_Index >= 2 and
            w_Row_Index <= 4 and 
			    r_P1_Score = 5) then
			r_Draw_Paddle <= '1';
			elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and
				w_Row_Index = 4  and
			    r_P1_Score = 5) then
			r_Draw_Paddle <= '1';
					
			
																						-- PRINT SCORE 6
		elsif ((w_Col_Index = g_Player_Paddle_X + 12 or w_Col_Index = g_Player_Paddle_X -14 ) and 
				w_Row_Index >= 0 and
            w_Row_Index <= 4 and 
			    r_P1_Score = 6) then
			r_Draw_Paddle <= '1';	
		elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and
				w_Row_Index = 2 and
			    r_P1_Score = 6) then
			r_Draw_Paddle <= '1';
		elsif ((w_Col_Index = g_Player_Paddle_X + 14 or w_Col_Index = g_Player_Paddle_X - 12 ) and 
				w_Row_Index >= 2 and
            w_Row_Index <= 4 and 
			    r_P1_Score = 6) then
			r_Draw_Paddle <= '1';
			elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and
				w_Row_Index = 4  and
			    r_P1_Score = 6) then
			r_Draw_Paddle <= '1';
			
			
																				-- PRINT SCORE 7
		elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and 
				w_Row_Index = 0 and
			    r_P1_Score = 7) then
			r_Draw_Paddle <= '1';
		elsif ((w_Col_Index = g_Player_Paddle_X + 14 or w_Col_Index = g_Player_Paddle_X -12) and 
				w_Row_Index >= 0 and
            w_Row_Index <= 4 and 
			    r_P1_Score = 7) then
				 r_Draw_Paddle <= '1';
				 
				 
																			-- PRINT SCORE 8
		elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and 
				w_Row_Index = 0 and
			    r_P1_Score = 8) then
			r_Draw_Paddle <= '1';
		elsif ((w_Col_Index = g_Player_Paddle_X + 12 or w_Col_Index = g_Player_Paddle_X -14 ) and 
				w_Row_Index >= 0 and
            w_Row_Index <= 4 and 
			    r_P1_Score = 8) then
			r_Draw_Paddle <= '1';	
		elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and
				w_Row_Index = 2 and
			    r_P1_Score = 8) then
			r_Draw_Paddle <= '1';
		elsif ((w_Col_Index = g_Player_Paddle_X + 14 or w_Col_Index = g_Player_Paddle_X - 12 ) and 
				w_Row_Index >= 0 and
            w_Row_Index <= 4 and 
			    r_P1_Score = 8) then
			r_Draw_Paddle <= '1';
			elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and
				w_Row_Index = 4  and
			    r_P1_Score = 8) then
			r_Draw_Paddle <= '1';	


																											-- PRINT SCORE 9
		elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and 
				w_Row_Index = 0 and
			    r_P1_Score = 9) then
			r_Draw_Paddle <= '1';
		elsif ((w_Col_Index = g_Player_Paddle_X + 12 or w_Col_Index = g_Player_Paddle_X -14 ) and 
				w_Row_Index >= 0 and
            w_Row_Index <= 2 and 
			    r_P1_Score = 9) then
			r_Draw_Paddle <= '1';	
		elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and
				w_Row_Index = 2 and
			    r_P1_Score = 9) then
			r_Draw_Paddle <= '1';
		elsif ((w_Col_Index = g_Player_Paddle_X + 14 or w_Col_Index = g_Player_Paddle_X - 12 ) and 
				w_Row_Index >= 0 and
            w_Row_Index <= 4 and 
			    r_P1_Score = 9) then
			r_Draw_Paddle <= '1';	
		
			
		
																											-- PRINT P1 SCORE 10
		elsif ((w_Col_Index = g_Player_Paddle_X + 10 or w_Col_Index = g_Player_Paddle_X -16) and 
				w_Row_Index >= 0 and
				w_Row_Index <= 4 and
			    r_P1_Score = 10 ) then
			r_Draw_Paddle <= '1';																																																		
		elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and 
				w_Row_Index = 0 and
			    r_P1_Score = 10) then
			r_Draw_Paddle <= '1';
		elsif ((w_Col_Index = g_Player_Paddle_X + 12 or w_Col_Index = g_Player_Paddle_X -14 ) and 
				w_Row_Index >= 0 and
            w_Row_Index <= 4 and 
			    r_P1_Score = 10) then
			r_Draw_Paddle <= '1';	
		elsif ((w_Col_Index = g_Player_Paddle_X + 14 or w_Col_Index = g_Player_Paddle_X - 12 ) and 
				w_Row_Index >= 0 and
            w_Row_Index <= 4 and 
			    r_P1_Score = 10) then
			r_Draw_Paddle <= '1';
			elsif (((w_Col_Index >= g_Player_Paddle_X + 12 and w_Col_Index <= g_Player_Paddle_X + 14) or
				(w_Col_Index >= g_Player_Paddle_X - 14 and w_Col_Index <= g_Player_Paddle_X - 12)) and
				w_Row_Index = 4  and
			    r_P1_Score = 10) then
				r_Draw_Paddle <= '1';
					
		
      else
        r_Draw_Paddle <= '0';
      end if;
    end if;
  end process p_Draw_Paddles;
 
  -- Assign output for next higher module to use
  o_Draw_Paddle <= r_Draw_Paddle;
  o_Paddle_Y    <= std_logic_vector(to_unsigned(r_Paddle_Y, o_Paddle_Y'length));
   
end architecture rtl;