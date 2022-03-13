library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stepper_motor_control is
    port (
           clk : in std_logic;
	   btnR, btnL, boost : in std_logic;
	   limit, angle_0, angle_90 : in std_logic;
	   JA : out std_logic_vector(1 downto 0)
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
signal microstep_counter : unsigned(7 downto 0) := (others => '0');
signal revolution_counter : unsigned(15 downto 0) := (others => '0');
signal too_large, too_small : std_logic := '0';
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
 	-- Button right is stepper reverse!
	process (clk)
	begin
		if rising_edge(clk) then
			if (btnR = '1') then ----------------------> CHECK!
				JA(1) <= '1';
			else
				JA(1) <= '0';
			end if;		
		end if;
	end process;
			

-- period Counter --
	process (clk)
        	begin
    		if rising_edge(clk) then 
			if (period_res = '1') then
				period_counter <= (others => '0');
			elsif ((btnR = '1') AND (btnL = '0') AND (period_res = '0') AND (limit = '0') AND (allow_step = '1')) then
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
			JA(0) <= motor_dc;
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
			if ((btnR = '1') AND (btnL = '0') AND (microstep_tick = '1') AND (limit = '0') AND (too_small = '0') AND (too_large = '0')) then
				microstep_counter <= microstep_counter - 1;
			elsif ((btnL = '1') AND (btnR = '0') AND (microstep_tick = '1') AND (limit = '0') AND (too_small = '0') AND (too_large = '0')) then
				microstep_counter <= microstep_counter + 1;
			elsif ((too_large = '1') AND (microstep_tick = '1') AND (limit = '0')) then
				microstep_counter <= "00000101";
			elsif ((too_small = '1') AND (microstep_tick = '1') AND (limit = '0')) then
				microstep_counter <= "11001100";
			elsif (limit = '1') then
				microstep_counter <= "00000101";
			else
				microstep_counter <= microstep_counter;
			end if;
		end if;
	end process;

-- btnL microstep maximum
	process (clk)
	begin
		if rising_edge(clk) then
			if ((btnL = '1') AND (microstep_counter >= x"CC")) then
				too_large <= '1';
			else 
				too_large <= '0';
			end if;
		end if;
	end process;

-- btnR microstep minimum
	process (clk)
	begin
		if rising_edge(clk) then
			if ((btnR = '1') AND (microstep_counter <= x"5")) then
				too_small <= '1';
			else 
				too_small <= '0';
			end if;
		end if;
	end process;

-- Revolutions
	process (clk)
	begin
		if rising_edge(clk) then
			if ((microstep_counter = x"CC") AND (btnR = '1') AND (btnL = '0') AND (limit = '0')) then
				revolution_counter <= revolution_counter - 1;
			elsif ((microstep_counter = x"CC") AND (btnL = '1') AND (btnR = '0') AND (limit = '0')) then
				revolution_counter <= revolution_counter + 1;	
			elsif (limit = '1') then
				revolution_counter <= (others => '0');
			else
				revolution_counter <= revolution_counter;	
			end if;
		end if;
	end process;

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
			if ((angle_0 = '1') AND (revolution_counter >= 115) AND (revolution_counter <= 125)) then
				end_of_rail <= '1';
			elsif ((angle_90 = '1') AND (revolution_counter >= 210) AND (revolution_counter <= 220)) then
				end_of_rail <= '1';
			else
				end_of_rail <= '0';
			end if;
		end if;
	end process;

end behavior;
