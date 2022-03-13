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
		led : out std_logic_vector(10 downto 0)
	);
end uart_test;

architecture arch of uart_test is
	-- Signals
	signal tx_full, rx_empty, rx_done_tick, rx_full : std_logic;
	signal rec_data, rec_data1 : std_logic_vector(7 downto 0);
	signal btn_tick_R, btn_tick_L : std_logic;
	signal reset, transfer, transmit, tx_done_tick, tx_fifo_not_empty : std_logic;
	signal tx_counter : unsigned(3 downto 0);

	-- Components
	component uart is
	port (
		clk, reset : in std_logic; 
		rd_uart, wr_uart : in std_logic;
		rx, send : in std_logic;
		w_data: in std_logic_vector(7 downto 0); 
		tx_full, rx_empty, rx_done_tick, rx_full : out std_logic;
 		r_data: out std_logic_vector(7 downto 0);
		tx, tx_done_tick, tx_fifo_not_empty : out std_logic
	);
	end component;

	component debounce is 
	port (
		clk, reset : in std_logic;
		sw : in std_logic;
		db_level, db_tick : out std_logic
	);
	end component;
	
	component uart_s_r is
	port (
		clk, reset_i : in std_logic;
		rx_done_tick, rx_empty, rx_full : in std_logic;
		tx_done_tick, tx_fifo_not_empty : in std_logic;
		data_in : in std_logic_vector(7 downto 0);
		reset_o, transfer, transmit : out std_logic;
		led : out std_logic_vector(10 downto 0);
		tx_counter_o : out unsigned(3 downto 0)
	);
	end component;

	component move is
	port (
		clk : in std_logic;
		tx_counter : in unsigned(3 downto 0);
		data_in : in std_logic_vector(7 downto 0);	
		data_out : out std_logic_vector(7 downto 0)
	);
	end component;

begin
	-- instantiate uart
	uart_unit : uart port map(clk => clk, reset => reset, rd_uart => transfer, 
					wr_uart => transfer, rx => RsRx, send => transmit, w_data => rec_data1, 
					tx_full => tx_full, rx_empty => rx_empty, rx_done_tick => rx_done_tick,
					rx_full => rx_full, r_data => rec_data, tx => RsTx, 
					tx_done_tick => tx_done_tick, tx_fifo_not_empty => tx_fifo_not_empty);
	
	-- instantiate debounce circuit
	btn_db_unit_R : debounce port map(clk => clk, reset => btnC, sw => btnR, 
					db_level => open, db_tick => btn_tick_R);

	btn_db_unit_L : debounce port map(clk => clk, reset => btnC, sw => btnL, 
					db_level => open, db_tick => btn_tick_L);

	-- instantiate shipping and receiving circuit
	uart_s_r_test : uart_s_r port map(clk => clk, reset_i => btnC, rx_done_tick => rx_done_tick, rx_empty => rx_empty, 
					  rx_full => rx_full, tx_done_tick => tx_done_tick, tx_fifo_not_empty => tx_fifo_not_empty,
					  data_in => rec_data, reset_o => reset, transfer => transfer, 
					  transmit => transmit, led => led, tx_counter_o => tx_counter);

	-- instantiate data movement
	move1 : move port map(clk => clk, tx_counter => tx_counter, data_in => rec_data, data_out => rec_data1);

	
end arch;
