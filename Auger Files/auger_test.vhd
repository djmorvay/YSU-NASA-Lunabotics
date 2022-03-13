library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity auger_test is
    port (
           clk : in std_logic;
	   sw : in std_logic_vector(6 downto 0);
	   limit : in std_logic;
	   btnU, btnD, btnR, btnL :  in std_logic;
	   step, dir : out std_logic;
	   drill_r, drill_l : out std_logic;
	   ENA, IN1, IN2 : out std_logic
    );
end auger_test;

architecture behavior of auger_test is
	-- Signals
	signal step_dir : std_logic_vector(1 downto 0);

	-- Components
	component LA is
	port (
	       clk : in std_logic;
	       btnR, btnL : in std_logic;
	       angle_0, angle_45, angle_90 : in std_logic;
	       ENA, IN1, IN2 : out std_logic
        );
	end component;

	component AD_motor_control is
    	port (
           clk : in std_logic;
	   cw, ccw, boost : in std_logic;
	   JA : out std_logic
    	);
	end component;

	component stepper_motor_control is
        port (
           clk : in std_logic;
	   btnR, btnL, boost : in std_logic;
	   limit, angle_0, angle_90 : in std_logic;
	   JA : out std_logic_vector(1 downto 0)
        );
        end component;
	

begin 
	-- Instantiate LA
	drill_LA : LA port map(clk => clk, btnR => btnU, btnL => btnD, 
			       angle_0 => '0', angle_45 => '0', angle_90 => '0',
			       ENA => ENA, IN1 => IN1, IN2 => IN2);

	-- Instantiate Auger Motor Control
	-- Right Auger
	right_auger : AD_motor_control port map (clk => clk, cw => sw(0), ccw => sw(1), 
						 boost => sw(2), JA => drill_r);
	-- Left Auger
	left_auger : AD_motor_control port map (clk => clk, cw => sw(4), ccw => sw(3), 
						 boost => sw(5), JA => drill_l);

	-- Instantiate stepper motor
	auger_stepper : stepper_motor_control port map(clk => clk, btnR => btnR, btnL => btnL, 
						       boost => sw(6), limit => limit, angle_0 => '0',
						       angle_90 => '0', JA => step_dir);

	step <= step_dir(0);
	dir <= step_dir(1);
						       
end behavior;
