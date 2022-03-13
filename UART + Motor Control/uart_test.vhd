library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 
entity uart_test is
	port(
		clk, btnC : in std_logic;
		btnR, btnL : in std_logic;
		RsRx : in std_logic;
		sw : in std_logic_vector(11 downto 0);
		RsTx : out std_logic;
		led : out std_logic_vector(7 downto 0);
		JA : out std_logic_vector(0 downto 0)
	);
end uart_test;

architecture arch of uart_test is
	-- Signals
	signal tx_full, rx_empty : std_logic;
	signal rec_data, rec_data1 : std_logic_vector(7 downto 0);
	signal btn_tick_R, btn_tick_L, tenth_tick : std_logic;

	-- Components
	component uart is
	port (
		clk, reset, reset_tx : in std_logic; 
		rd_uart, wr_uart : in std_logic;
		rx: in std_logic;
		w_data: in std_logic_vector(7 downto 0); 
		tx_full, rx_empty : out std_logic;
 		r_data: out std_logic_vector(7 downto 0);
		tx: out std_logic
	);
	end component;

	component debounce is 
	port (
		clk, reset : in std_logic;
		sw : in std_logic;
		db_level, db_tick : out std_logic
	);
	end component;

	component motor_control is
    	port (
           clk : in std_logic;
	   rec_data : in std_logic_vector(7 downto 0);
	   JA : out std_logic_vector(0 downto 0)
    	);
	end component;

	component tenth_timer is
    	port (
           clk : in std_logic;
	   tenth_tick : out std_logic
    	);
	end component;

	component shifter is
    	port (
           clk, btnL, reset : in std_logic;
	   data_in : in std_logic_vector(11 downto 0);
	   data_out : out std_logic_vector(7 downto 0)
    	);
	end component;

begin
	-- instantiate uart
	uart_unit : uart port map(clk => clk, reset => tenth_tick, reset_tx => btnC, rd_uart => tenth_tick, 
					wr_uart => btn_tick_L, rx => RsRx, w_data => rec_data1, 
					tx_full => tx_full, rx_empty => rx_empty, r_data => rec_data, tx => RsTx);
	-- instantiate debounce circuit
	-- btn_db_unit_R : debounce port map(clk => clk, reset => btnC, sw => btnR, 
					-- db_level => open, db_tick => btn_tick_R);

	btn_db_unit_L : debounce port map(clk => clk, reset => btnC, sw => btnL, 
					db_level => open, db_tick => btn_tick_L);

	-- Instantiate shifter
	shift_reg : shifter port map(clk => clk, btnL => btn_tick_L, reset => btnC, data_in => sw, data_out => rec_data1);

	-- Instantiate tenth tick
	tenth : tenth_timer port map(clk => clk, tenth_tick => tenth_tick);

	-- instantiate motor control
	motor1 : motor_control port map(clk => clk, rec_data => rec_data, JA => JA);

	-- LED display
	led <= rec_data;
	
end arch;
