--------------------------------------------------------
-- Rover HDL
-- File: top.vhd
-- Entity: top
-- Description: Top file for rover HDL.
--
-- Written by: David J. Morvay
-- YSU Robotics Club - NASA Lunabotics Competition
-- ECEN 4899 - Senior Design
-- Date: April 2021	                                                    
--------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

entity top is
	port(
		clk : in std_logic;
		btnC : in std_logic;
		RsRx : in std_logic;
		limit : in std_logic;
		dump_limit : in std_logic;
		RsTx : out std_logic;
		led : out std_logic_vector(7 downto 0);
		right_motors, left_motors : out std_logic;
		step, dir : out std_logic;
		dig_l, dig_r : out std_logic;
		ENA, IN1, IN2 : out std_logic;
		ENA_D, IN1_D, IN2_D : out std_logic
	);
end top;

architecture arch of top is
	-- Signals
	signal tx_full, rx_empty, rx_done_tick, rx_full : std_logic;
	signal rec_data, rec_data1 : std_logic_vector(7 downto 0);
	signal btn_tick_R, btn_tick_L : std_logic;
	signal reset, transfer, transmit, tx_done_tick, tx_fifo_not_empty : std_logic;
	signal tx_counter : unsigned(4 downto 0);
	signal motor_r, motor_l : std_logic_vector(7 downto 0);
	signal auger_rail_r, auger_rail_l : std_logic;
	signal auger_LA_up, auger_LA_down : std_logic;
        signal auger_drill_r_fw, auger_drill_r_rev : std_logic;
	signal auger_drill_l_fw, auger_drill_l_rev : std_logic;
	signal boost : std_logic;
	signal angle_90, angle_0, dump_ready : std_logic;
	signal dump_up, dump_down : std_logic;
	
	-- Components
	component uart is
	port (
		clk, reset : in std_logic; 
		rd_uart, wr_uart : in std_logic;
		rx : in std_logic;
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
		led : out std_logic_vector(7 downto 0);
		tx_counter_o : out unsigned(4 downto 0)
	);
	end component;

	component move is
	port (
		clk : in std_logic;
		tx_counter : in unsigned(4 downto 0);
		data_in : in std_logic_vector(7 downto 0);	
		data_out : out std_logic_vector(7 downto 0);
		motor_r, motor_l : out std_logic_vector(7 downto 0);
		auger_rail_r, auger_rail_l : out std_logic;
		auger_LA_up, auger_LA_down : out std_logic;
		auger_drill_r_fw, auger_drill_r_rev : out std_logic;
		auger_drill_l_fw, auger_drill_l_rev : out std_logic;
		boost : out std_logic;
		dump_down, dump_up : out std_logic
	);
	end component;

	component motor_control_right is
    	port (
           clk : in std_logic;
	   rec_data : in std_logic_vector(7 downto 0);
	   boost : in std_logic;
	   JA : out std_logic
    	);
	end component;

	component motor_control_left is
    	port (
           clk : in std_logic;
	   rec_data : in std_logic_vector(7 downto 0);
	   boost : in std_logic;
	   JA : out std_logic
    	);
	end component;

	component stepper_motor_control is
    	port (
           clk : in std_logic;
	   btnR, btnL, boost : in std_logic;
	   limit, angle_0, angle_90 : in std_logic;
	   step, dir : out std_logic
    	);
	end component;

	component AD_motor_control is
	port (
           clk : in std_logic;
	   cw, ccw, boost : in std_logic;
	   dig : out std_logic
    	);
	end component;

	component LA_drill is
    	port (
               clk : in std_logic;
	       btnR, btnL : in std_logic;
	       angle_0, angle_90 : in std_logic;
	       ENA, IN1, IN2 : out std_logic
    	);
	end component;

	component angle_read is
	port(
		clk : in std_logic;
		do_out : in std_logic_vector(11 downto 0);
		angle_0, angle_90, dump_ready : out std_logic
	);
	end component;

	component LA_dump is
	port(   
		clk : in std_logic;
            	up, down : in std_logic;
            	angle_90 : in std_logic;
            	dump_limit : in std_logic;
            	ENA, IN1, IN2 : out std_logic
	);
	end component;


begin
	-- Instantiate uart
	uart_unit : uart port map(clk => clk, reset => reset, rd_uart => transfer, 
					wr_uart => transmit, rx => RsRx, w_data => rec_data1, 
					tx_full => tx_full, rx_empty => rx_empty, rx_done_tick => rx_done_tick,
					rx_full => rx_full, r_data => rec_data, tx => RsTx, 
					tx_done_tick => tx_done_tick, tx_fifo_not_empty => tx_fifo_not_empty);
	
	-- Instantiate debounce circuit
	-- btn_db_unit_R : debounce port map(clk => clk, reset => btnC, sw => btnR, 
					-- db_level => open, db_tick => btn_tick_R);

	-- btn_db_unit_L : debounce port map(clk => clk, reset => btnC, sw => btnL, 
					-- db_level => open, db_tick => btn_tick_L);

	-- Instantiate shipping and receiving circuit
	uart_s_r_test : uart_s_r port map(clk => clk, reset_i => btnC, rx_done_tick => rx_done_tick, rx_empty => rx_empty, 
					  rx_full => rx_full, tx_done_tick => tx_done_tick, tx_fifo_not_empty => tx_fifo_not_empty,
					  data_in => rec_data, reset_o => reset, transfer => transfer, 
					  transmit => transmit, led => led, tx_counter_o => tx_counter);

	-- Instantiate data movement
	move1 : move port map(clk => clk, tx_counter => tx_counter, data_in => rec_data, 
				data_out => rec_data1, motor_r => motor_r, motor_l => motor_l,
				auger_rail_r => auger_rail_r, auger_rail_l => auger_rail_l,
				auger_LA_up => auger_LA_up, auger_LA_down => auger_LA_down,
				auger_drill_r_fw => auger_drill_r_fw, auger_drill_r_rev => auger_drill_r_rev,
				auger_drill_l_fw => auger_drill_l_fw, auger_drill_l_rev => auger_drill_l_rev,
				boost => boost, dump_down => dump_down, dump_up => dump_up);

	-- Instantiate drive motor control
	left_motors_DUT : motor_control_left port map(clk => clk, rec_data => motor_l, boost => boost, JA => left_motors);
	right_motors_DUT  : motor_control_right port map(clk => clk, rec_data => motor_r, boost => boost, JA => right_motors);

	-- Instantiate Stepper Motor control
	auger_rail : stepper_motor_control port map(clk => clk, btnR => auger_rail_r, btnL => auger_rail_l, boost => boost, 
						    limit => limit, angle_0 => '1', angle_90 => '0',
						    step => step, dir => dir);

	-- Instantiate Auger Drill Left
	   auger_drill_left : AD_motor_control port map(clk => clk, cw => auger_drill_l_fw, ccw => auger_drill_l_rev, boost => boost, dig => dig_l);

	-- Instantiate Auger Drill Right
	   auger_drill_right : AD_motor_control port map(clk => clk, cw => auger_drill_r_rev, ccw => auger_drill_r_fw, boost => boost, dig => dig_r);

	-- Instantiate Linear Actuator Control for Auger
	   auger_LA : LA_drill port map(clk => clk, btnR => auger_LA_down, btnL => auger_LA_up, angle_0 => '0', angle_90 => '0', 
					ENA => ENA, IN1 => IN1, IN2 => IN2);

	-- Instantiate Angle Read
	read_angle : angle_read port map(clk => clk, do_out => "000000000000", angle_0 => angle_0, angle_90 => angle_90, dump_ready => dump_ready);

	-- Instantiate Auger Linear Actuator Control
	dump : LA_dump port map(clk => clk, up => dump_up, down => dump_down, angle_90 => angle_90,
        			dump_limit => dump_limit, ENA => ENA_D, IN1 => IN1_D, IN2 => IN2_D);

end arch;
