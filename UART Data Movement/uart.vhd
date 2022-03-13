library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
entity uart is
	generic(
	-- Default setting:
	-- 19200 baud, 8 data bits, 1 stop bit, 2^2 FIFO
	DBIT : integer := 8;		-- # data bits
	SB_TICK : integer := 16;	-- # ticks for stop bits, 16/24/32
					-- for 1/1.5/2 stop bits
	DVSR : integer := 326;		-- baud rate divisor
					-- DVSR = 100MHz / (16*baud rate)
	DVSR_BIT : integer := 9;	-- # bits of DVSR
	FIFO_W : integer := 2		-- # addr bits of FIFO
					-- # words in FIFO = 2^FIFO_W
	);
	port(
		clk, reset : in std_logic; 
		rd_uart, wr_uart : in std_logic;
		rx, send : in std_logic;
		w_data: in std_logic_vector(7 downto 0); 
		tx_full, rx_empty, rx_done_tick, rx_full : out std_logic;
 		r_data: out std_logic_vector(7 downto 0);
		tx, tx_done_tick, tx_fifo_not_empty : out std_logic
	);
end uart;

architecture str_arch of uart is 

-- Signals
	signal tick : std_logic;
	signal tx_fifo_out : std_logic_vector(7 downto 0); 
	signal rx_data_out : std_logic_vector(7 downto 0); 
	signal tx_empty : std_logic; 
	signal rx_done_tick_sig1, rx_done_tick_sig2 : std_logic;
	signal tx_done_tick_sig, rx_full_sig, tx_fifo_not_empty_sig : std_logic;

-- Components
	component mod_m_counter is
    	port (
        	clk, reset: in std_logic; 
		max_tick: out std_logic; 
		q : out std_logic_vector(DVSR_BIT-1 downto 0)
        );
    	end component;

	component uart_rx is
    	port (
        	clk, reset: in std_logic;
		rx: in std_logic;
		s_tick: in std_logic;
		rx_done_tick: out std_logic;
		dout: out std_logic_vector(7 downto 0)
        );
    	end component;
	
	component fifo is
    	port (
        	clk, reset : in std_logic;
		rd, wr : in std_logic;
		w_data : in std_logic_vector(DBIT-1 downto 0);
		empty, full : out std_logic;
		r_data : out std_logic_vector(DBIT-1 downto 0)
        );
    	end component;
	
	component uart_tx is
	port (
		clk, reset: in std_logic;
		tx_start : in std_logic;
		s_tick: in std_logic;
		din: in std_logic_vector(7 downto 0); 
		tx_done_tick: out std_logic;
		tx: out std_logic
	);
	end component;

begin
	baud_gen_unit : mod_m_counter port map(clk => clk, reset => reset, q => open, max_tick => tick);
	
	uart_rx_unit : uart_rx port map(clk => clk, reset => reset, rx => rx, 
					s_tick => tick, rx_done_tick => rx_done_tick_sig1, 
					dout => rx_data_out);

	rx_done_tick_sig2 <= rx_done_tick_sig1 AND (NOT rx_full_sig);
	
			
	fifo_rx_unit : fifo port map(clk => clk, reset => reset, rd => rd_uart,
					wr => rx_done_tick_sig2, w_data => rx_data_out,
					empty => rx_empty, full => rx_full_sig, r_data => r_data);

	fifo_tx_unit : fifo port map(clk => clk, reset => reset, rd => tx_done_tick_sig,
					wr => wr_uart, w_data => w_data, empty => tx_empty,
					full => tx_full, r_data => tx_fifo_out);
	
	uart_tx_unit : uart_tx port map(clk => clk, reset => reset,
					tx_start => tx_fifo_not_empty_sig,
					s_tick => tick, din => tx_fifo_out,
					tx_done_tick => tx_done_tick_sig, tx => tx);

tx_done_tick <= tx_done_tick_sig;
rx_full <= rx_full_sig;
rx_done_tick <= rx_done_tick_sig2;
tx_fifo_not_empty_sig <= not tx_empty;
tx_fifo_not_empty <= not tx_empty;

end str_arch;
