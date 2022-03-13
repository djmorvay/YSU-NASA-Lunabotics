library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 
entity uart_test is
	port(
		clk, btnC : in std_logic;
		btnR, btnL : in std_logic;
		RsRx : in std_logic;
		sw : in std_logic_vector(7 downto 0);
		RsTx : out std_logic;
		led : out std_logic_vector(7 downto 0)
	);
end uart_test;

architecture arch of uart_test is
	-- Signals
	signal tx_full, rx_empty : std_logic;
	signal rec_data, rec_data1 : std_logic_vector(7 downto 0);
	signal btn_tick_R, btn_tick_L : std_logic;

	-- Components
	component uart is
	port (
		clk, reset : in std_logic; 
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

begin
	-- instantiate uart
	uart_unit : uart port map(clk => clk, reset => btnC, rd_uart => btn_tick_R, 
					wr_uart => btn_tick_L, rx => RsRx, w_data => rec_data1, 
					tx_full => tx_full, rx_empty => rx_empty, r_data => rec_data, tx => RsTx);
	-- instantiate debounce circuit
	btn_db_unit_R : debounce port map(clk => clk, reset => btnC, sw => btnR, 
					db_level => open, db_tick => btn_tick_R);

	btn_db_unit_L : debounce port map(clk => clk, reset => btnC, sw => btnL, 
					db_level => open, db_tick => btn_tick_L);

	-- LED display
	led <= rec_data;

	-- Send switch string
	rec_data1 <= sw;
	
end arch;
