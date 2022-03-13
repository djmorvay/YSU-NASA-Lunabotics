------------------------------------------------------------
-- Rover HDL
-- File: stepper_motor_control.vhd
-- Entity: stepper_motor_control
-- Description: Stepper motor control for auger rail. 
--
-- Written by: David J. Morvay
-- YSU Robotics Club - NASA Lunabotics Competition
-- ECEN 4899 - Senior Design
-- Date: April 2021	                                                    
-------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stepper_motor_control is
    port (
           clk : in std_logic;
	   btnR, btnL, boost : in std_logic;
	   limit, angle_0, angle_90 : in std_logic;
	   step, dir : out std_logic
    );
end stepper_motor_control;

architecture behavior of stepper_motor_control is

-- Motor Signals
signal period_counter : unsigned(15 downto 0) := (others => '0');
signal duty_cycle : unsigned(15 downto 0) := (others => '0');
signal period : unsigned(15 downto 0) := (others => '0');
signal period_res : std_logic := '0';
signal motor_dc : std_logic := '0';
signal microstep, microstep1, microstep2, microstep_tick : std_logic := '0';
signal microstep_counter : unsigned(15 downto 0) := (others => '0');
signal revolutions : unsigned(15 downto 0) := (others => '0');
signal end_of_rail : std_logic := '0';
signal allow_step : std_logic := '0';

begin

-- Is auger in 0 or 90 degree position?
	process(clk)
	begin
		if rising_edge(clk) then
			if ((angle_0 = '1') OR (angle_90 = '1')) then
				allow_step <= '1';
			else
				allow_step <= '0';
			end if;
		end if;
	end process;



-- Boost Control 
-- Duty_cycle
	process(clk)
	begin
		if rising_edge(clk) then
			if (boost = '1') then
				duty_cycle <= x"4E20";
			else
				duty_cycle <= x"61A8";
			end if;
		end if;
	end process;

-- Period
	process(clk)
	begin
		if rising_edge(clk) then
			if (boost = '1') then
				period <= x"9C40";
			else
				period <= x"C350";
			end if;
		end if;
	end process;

-- Motor control --
 	-- Button LEFT is stepper forward!
	process (clk)
	begin
		if rising_edge(clk) then
			if (btnL = '1') then ----------------------> CHECK!
				dir <= '1';
			else
				dir <= '0';
			end if;		
		end if;
	end process;
			

-- period Counter --
	process (clk)
        	begin
    		if rising_edge(clk) then 
			if (period_res = '1') then
				period_counter <= (others => '0');
			elsif ((btnR = '1') AND (btnL = '0') AND (period_res = '0') AND (limit = '1') AND (allow_step = '1')) then
				period_counter <= period_counter + 1;
			elsif ((btnL = '1') AND (btnR = '0') AND (period_res = '0') AND (end_of_rail = '0') AND (allow_step = '1')) then
				period_counter <= period_counter + 1;
			else
				period_counter <= period_counter;
			end if;
                end if;
         end process;

	process (clk)
		begin
			if rising_edge(clk) then
				if (period_counter = period) then 
					period_res <= '1';
				else
					period_res <= '0';
				end if;
			end if;
	end process;

-- Duty-Cylce --
	process (clk)
        	begin
    		if rising_edge(clk) then
			if (period_counter = x"0") then
				motor_dc <= '1';
			elsif (period_counter = duty_cycle) then
				motor_dc <= '0';
			else
				motor_dc <= motor_dc;
			end if;
                end if;
         end process;

--------------------------------------------------------
	process (clk)
        	begin
    		if rising_edge(clk) then
			step <= motor_dc;
                end if;
         end process;

	microstep <= motor_dc;

-- Revolution Counter

-- Get one tick per microstep
	process (clk)
        begin
    		if rising_edge(clk) then
			microstep1 <= microstep;
                end if;
         end process;

	process (clk)
        begin
    		if rising_edge(clk) then
			microstep2 <= microstep1;
                end if;
         end process;

	microstep_tick <= (NOT microstep1) AND microstep2;

-- Microstep counter
	process (clk)
	begin
		if rising_edge(clk) then
			if ((btnR = '1') AND (btnL = '0') AND (microstep_tick = '1') AND (limit = '1')) then
				microstep_counter <= microstep_counter - 1;
			elsif ((btnL = '1') AND (btnR = '0') AND (microstep_tick = '1') AND (limit = '1')) then
				microstep_counter <= microstep_counter + 1;
			elsif (limit = '0') then
				microstep_counter <= (others => '0');
			else
				microstep_counter <= microstep_counter;
			end if;
		end if;
	end process;

	revolutions <= microstep_counter / x"C8";

-- End of rail estimation.

-- If auger is in the 0 degree angle,
-- the maximum distance it can travel is 115 revolutions
-- due to the dump bucket.

-- If the auger if in the 90 degree angle, 
-- the maximum distance it can travel is 210 revolutions 
-- to the end of the rail.
	process (clk)
	begin
		if rising_edge(clk) then
			if ((angle_0 = '1') AND (microstep_counter >= x"4E20")) then
				end_of_rail <= '1';
			elsif ((angle_90 = '1') AND (microstep_counter >= x"9C40")) then
				end_of_rail <= '1';
			else
				end_of_rail <= '0';
			end if;
		end if;
	end process;

end behavior;
