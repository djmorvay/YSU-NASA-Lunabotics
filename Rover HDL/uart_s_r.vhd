-----------------------------------------------------------------------------
-- Rover HDL
-- File: uart_s_r.vhd
-- Entity: uart_s_r
-- Description: UART shipping and receiving. Controller for receving and 
-- transmitting data through UART communication. 8-bytes will be 
-- received within one second and 8-bytes will be transmitted back
-- to the source. 
--
-- Written by: David J. Morvay
-- YSU Robotics Club - NASA Lunabotics Competition
-- ECEN 4899 - Senior Design
-- Date: April 2021	                                                    
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

entity uart_s_r is
	port(
		clk, reset_i : in std_logic;
		rx_done_tick, rx_empty, rx_full : in std_logic; 
		tx_done_tick, tx_fifo_not_empty : in std_logic;
		data_in : in std_logic_vector(7 downto 0);
		reset_o, transfer, transmit : out std_logic;
		led : out std_logic_vector(7 downto 0);
		tx_counter_o : out unsigned(4 downto 0)
	);
end uart_s_r;

architecture arch of uart_s_r is
	-- Signals
	signal reset_o_signal : std_logic := '0';
	signal rx_done_tick1, rx_done_tick2, rx_tick : std_logic := '0';
	signal rx_counter, rx_counter_follow : unsigned(3 downto 0) := (others => '0');

	signal SEC_DELAY : unsigned(27 downto 0) := x"5F5E100"; 
	signal sec_counter : unsigned(27 downto 0) := (others => '0');
	signal rx_payload_reset : std_logic := '0';

	signal start_tx, cycle_done : std_logic := '0';
	signal tx_counter : unsigned(4 downto 0) := (others => '0');

	
begin
	------------------ Reset Circuit ----------------
	-- Will reset the buffers and tx/rx circuits
	process (clk)
        	begin
		if rising_edge(clk) then 
			if (reset_i = '1') then
				reset_o_signal <= '1';
			elsif (rx_payload_reset = '1') then
				reset_o_signal <= '1';
			else
				reset_o_signal <= '0';
			end if;
		end if;
	end process;

	reset_o <= reset_o_signal;

	------------------- Input Check -----------------
	-- Determine if rx_done_tick is received 8 times

	-- Get rx_done_tick
	-- Just need one pulse
	process (clk)
        	begin
    		if rising_edge(clk) then 
			rx_done_tick1 <= rx_done_tick;
		end if;
	end process;
	
	process (clk)
        	begin
    		if rising_edge(clk) then 
			rx_done_tick2 <= rx_done_tick1;
		end if;
	end process;
	
	rx_tick <= rx_done_tick1 AND (NOT rx_done_tick2);

	-- Use rx_tick to count number of input bytes
	-- Counts to 8
	process (clk)
        	begin
    		if rising_edge(clk) then 
			if ((rx_tick = '1') AND (reset_o_signal = '0') AND (rx_counter_follow < x"8")) then
				rx_counter <= rx_counter + 1;
			elsif ((reset_o_signal = '1') OR (cycle_done = '1')) then
				rx_counter <= (others => '0');
			else
				rx_counter <= rx_counter;
			end if;
		end if;
	end process;

	-- Follower so rx_counter does not rely on itself
	-- Similar to what is seen above
	process (clk)
        	begin
    		if rising_edge(clk) then 
			if ((rx_tick = '1') AND (reset_o_signal = '0') AND (rx_counter < x"8")) then
				rx_counter_follow <= rx_counter_follow + 1;
			elsif ((reset_o_signal = '1') OR (cycle_done = '1')) then
				rx_counter_follow <= (others => '0');
			else
				rx_counter_follow <= rx_counter_follow;
			end if;
		end if;
	end process;

	-------------------------- rx input timer -------------------------------
	-- rx will reset signals after 1 sec if payload is stopped
	process (clk)
        	begin
    		if rising_edge(clk) then
			if ((rx_payload_reset = '1') OR (rx_counter = x"0") OR (rx_tick = '1') OR (rx_counter = x"8")) then
				sec_counter <= (others => '0');
			else
				sec_counter <= sec_counter + 1;
			end if;
		end if;
	end process;

	process (clk)
        	begin
    		if rising_edge(clk) then
			if (sec_counter = x"5F5E0FF") then
				rx_payload_reset <= '1';
			else
				rx_payload_reset <= '0';
			end if;
		end if;
	end process;

	process (clk)
		begin
		if rising_edge(clk) then
			case rx_counter is
				when x"0"  => led(7 downto 0) <= "00000000";
				when x"1"  => led(7 downto 0) <= "00000001";
				when x"2"  => led(7 downto 0) <= "00000011";
				when x"3"  => led(7 downto 0) <= "00000111";
				when x"4"  => led(7 downto 0) <= "00001111";
				when x"5"  => led(7 downto 0) <= "00011111";
				when x"6"  => led(7 downto 0) <= "00111111";
				when x"7"  => led(7 downto 0) <= "01111111";
				when x"8"  => led(7 downto 0) <= "11111111";
				when others => led(7 downto 0) <= "00000000";
			end case;
		end if;
	end process;

	----------------------- tx circuit ---------------------------
	-- Start tx
	-- Turns transmission on and off depending 
	-- on how many times tx_counter goes off.
	process (clk)
		begin
		if rising_edge(clk) then
			if (rx_full = '1') then
				start_tx <= '1';
			elsif (tx_counter = x"F") then
				start_tx <= '0';
			else 
				start_tx <= start_tx;
			end if;
		end if;
	end process;

	-- tx_counter = how many tx transmissions were sent
	process (clk)
		begin
		if rising_edge(clk) then
			if (start_tx = '1') then
				tx_counter <= tx_counter + 1;
			elsif (start_tx = '0') then
				tx_counter <= (others => '0');
			else
				tx_counter <= tx_counter;
			end if;
		end if;
	end process;
		
	tx_counter_o <= tx_counter;

	-- Initiate the transfer
	process (clk)
		begin
		if rising_edge(clk) then
			if ((tx_counter >= x"1") AND (tx_counter <= x"8")) then
				transfer <= '1';
			else
				transfer <= '0';
			end if;
		end if;
	end process;

	-- Initiate the transmit
	process (clk)
		begin
		if rising_edge(clk) then
			if ((tx_counter >= x"9") AND (tx_counter <= x"10")) then
				transmit <= '1';
			else
				transmit <= '0';
			end if;
		end if;
	end process;

	-- End the transfer
	process (clk)
		begin
		if rising_edge(clk) then
			if (tx_counter = x"10") then
				cycle_done <= '1';
			else
				cycle_done <= '0';
			end if;
		end if;
	end process;	
	-- Transfer of data complete to next fifo
		
end arch;
