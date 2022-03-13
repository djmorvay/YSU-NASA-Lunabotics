library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AD_motor_control is
    port (
           clk : in std_logic;
	   cw, ccw, boost : in std_logic;
	   JA : out std_logic
    );
end AD_motor_control;

architecture behavior of AD_motor_control is

-- Motor Signals
signal counter : unsigned(31 downto 0) := (others => '0');
signal res : std_logic := '0';
signal switch : unsigned(0 downto 0) := "0";

signal period_counter : unsigned(21 downto 0) := (others => '0');
signal period_res : std_logic := '0';

signal duty_cycle : unsigned(19 downto 0) := (others => '0');
signal motor_dc : std_logic := '0';

begin

-- Motor control --

	process (clk)
		begin
		if rising_edge(clk) then
			-- Half speed reverse
			if ((ccw = '1') AND (boost = '0') AND (cw = '0')) then
				duty_cycle <= x"2191C";
			-- Full speed reverse
			elsif ((ccw = '1') AND (boost = '1') AND (cw = '0')) then
				duty_cycle <= x"1E848";
			-- Half speed drill
			elsif ((cw = '1') AND (boost = '0') AND (ccw = '0')) then
				duty_cycle <= x"27AC4";
			-- Full speed drill
			elsif ((cw = '1') AND (boost = '1') AND (ccw = '0')) then
				duty_cycle <= x"2AB98";
			-- Else: go to standby
			else
				duty_cycle <= x"249F0";
			end if;
		end if;
	end process;			

-- period Counter --
	process (clk)
        	begin
    		if rising_edge(clk) then 
			if (period_res = '1') then
				period_counter <= (others => '0');
			else
				period_counter <= period_counter + 1;
			end if;
                end if;
         end process;

	process (clk)
		begin
			if rising_edge(clk) then
				if (period_counter = x"F4240") then 
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
			JA <= motor_dc;
                end if;
         end process;

end behavior;
