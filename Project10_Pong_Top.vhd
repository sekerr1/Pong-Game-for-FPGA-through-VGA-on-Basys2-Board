library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
 
entity Project10_Pong_Top is
  port (
    -- Main Clock (50 MHz)
    i_Clk         : in std_logic;
	 
	-- Starts the round of the game
	 i_Rst		: in std_logic;
	 
    -- Push Buttons
    i_Switch_1 : in std_logic;
    i_Switch_2 : in std_logic;
    i_Switch_3 : in std_logic;
    i_Switch_4 : in std_logic;
       
    -- VGA Sync and RGB
    o_VGA_HSync : out std_logic;
    o_VGA_VSync : out std_logic;
    o_VGA_Red_0 : out std_logic;
    o_VGA_Red_1 : out std_logic;
    o_VGA_Red_2 : out std_logic;
    o_VGA_Grn_0 : out std_logic;
    o_VGA_Grn_1 : out std_logic;
    o_VGA_Grn_2 : out std_logic;
    o_VGA_Blu_0 : out std_logic;
    o_VGA_Blu_1 : out std_logic

   );
end entity Project10_Pong_Top;
 
architecture RTL of Project10_Pong_Top is
  
  -- VGA Constants to set Frame Size
  constant c_VIDEO_WIDTH : integer := 12; 
  constant c_TOTAL_COLS  : integer := 800;
  constant c_TOTAL_ROWS  : integer := 525;
  constant c_ACTIVE_COLS : integer := 640;
  constant c_ACTIVE_ROWS : integer := 480;
   
  -- VGA Signals
  signal w_HSync_VGA       : std_logic;
  signal w_VSync_VGA       : std_logic;
  signal w_Red_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Grn_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Blu_Video_Porch : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
 
  -- Player 1 and  2 inputs
  signal w_Switch_1 : std_logic;
  signal w_Switch_2 : std_logic;
  signal w_Switch_3 : std_logic;
  signal w_Switch_4 : std_logic;
   
  -- Pong Signals
  signal w_HSync_Pong     : std_logic;
  signal w_VSync_Pong     : std_logic;
  signal w_Red_Video_Pong : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Grn_Video_Pong : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);
  signal w_Blu_Video_Pong : std_logic_vector(c_VIDEO_WIDTH-1 downto 0);  
  
  -- 25Mhz clock for VGA Sync (required)
  signal clk_25MHz : std_logic; 
  
begin
  -- Port mapping for componets
  
  VGA_Sync_Pulses_inst : entity work.VGA_Sync_Pulses
    generic map (
      g_TOTAL_COLS  => c_TOTAL_COLS,
      g_TOTAL_ROWS  => c_TOTAL_ROWS,
      g_ACTIVE_COLS => c_ACTIVE_COLS,
      g_ACTIVE_ROWS => c_ACTIVE_ROWS
      )
    port map (
      i_Clk       => clk_25MHz,
      o_HSync     => w_HSync_VGA,
      o_VSync     => w_VSync_VGA,
      o_Col_Count => open,
      o_Row_Count => open
      );
 
   Generate25MHz_1: entity work.Generate25MHz
     port map (
		i_Clk => i_Clk,
		o_Clk  => clk_25MHz
		);
 
  Debounce_Switch_1: entity work.Debounce_Switch
    port map (
      i_Clk    => clk_25MHz,
      i_Switch => i_Switch_1,
      o_Switch => w_Switch_1);
   
  Debounce_Switch_2: entity work.Debounce_Switch
    port map (
      i_Clk    => clk_25MHz,
      i_Switch => i_Switch_2,
      o_Switch => w_Switch_2);
   
  Debounce_Switch_3: entity work.Debounce_Switch
    port map (
      i_Clk    => clk_25MHz,
      i_Switch => i_Switch_3,
      o_Switch => w_Switch_3);
   
  Debounce_Switch_4: entity work.Debounce_Switch
    port map (
      i_Clk    => clk_25MHz,
      i_Switch => i_Switch_4,
      o_Switch => w_Switch_4);
   
   
  Pong_Top_1: entity work.Pong_Top
    generic map (
      g_Video_Width => c_VIDEO_WIDTH,
      g_Total_Cols  => c_TOTAL_COLS, 
      g_Total_Rows  => c_TOTAL_ROWS, 
      g_Active_Cols => c_ACTIVE_COLS,
      g_Active_Rows => c_ACTIVE_ROWS) 
    port map (
      i_Clk          => clk_25MHz,
      i_HSync        => w_HSync_VGA,
      i_VSync        => w_VSync_VGA,
	  i_Game_Start   => i_Rst,
      i_Paddle_Up_P1 => w_Switch_1,
      i_Paddle_Dn_P1 => w_Switch_2,
      i_Paddle_Up_P2 => w_Switch_3,
      i_Paddle_Dn_P2 => w_Switch_4,
      o_HSync        => w_HSync_Pong,
      o_VSync        => w_VSync_Pong,
      o_Red_Video    => w_Red_Video_Pong,
      o_Blu_Video    => w_Blu_Video_Pong,
      o_Grn_Video    => w_Grn_Video_Pong);
 
       
  VGA_Sync_Porch_Inst : entity work.VGA_Sync_Porch
    generic map (
      g_Video_Width => c_VIDEO_WIDTH,
      g_TOTAL_COLS  => c_TOTAL_COLS,
      g_TOTAL_ROWS  => c_TOTAL_ROWS,
      g_ACTIVE_COLS => c_ACTIVE_COLS,
      g_ACTIVE_ROWS => c_ACTIVE_ROWS 
      )
    port map (
      i_Clk       => clk_25MHz,
      i_HSync     => w_HSync_Pong,
      i_VSync     => w_VSync_Pong,
      i_Red_Video => w_Red_Video_Pong,
      i_Grn_Video => w_Blu_Video_Pong,
      i_Blu_Video => w_Grn_Video_Pong,
      --
      o_HSync     => o_VGA_HSync,
      o_VSync     => o_VGA_VSync,
      o_Red_Video => w_Red_Video_Porch,
      o_Grn_Video => w_Blu_Video_Porch,
      o_Blu_Video => w_Grn_Video_Porch
      );
       
  o_VGA_Red_0 <= w_Red_Video_Porch(0);
  o_VGA_Red_1 <= w_Red_Video_Porch(1);
  o_VGA_Red_2 <= w_Red_Video_Porch(2);
   
  o_VGA_Grn_0 <= w_Grn_Video_Porch(0);
  o_VGA_Grn_1 <= w_Grn_Video_Porch(1);
  o_VGA_Grn_2 <= w_Grn_Video_Porch(2);
 
  o_VGA_Blu_0 <= w_Blu_Video_Porch(0);
  o_VGA_Blu_1 <= w_Blu_Video_Porch(1);
   
end architecture RTL;