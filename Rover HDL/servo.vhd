-- D.J. Morvay
-- Servo Example
-- February 14, 2021
-- djmorvay@me.com

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity servo is
	port(
		clk : in std_logic;
		btnC : in std_logic;
		JA : out std_logic
        );
end servo;

architecture behavior of servo is

	-- Signals 
	signal counter : unsigned(23 downto 0) := (others => '0');
	signal end_period : std_logic := '0';
	signal duty_cycle : unsigned(19 downto 0) := (others => '0');
	signal output : std_logic := '0';

	-- Components


begin

	-- Counter
	-- Will continue to count until 
	-- 2 million clock ticks. 
	process(clk)
   	begin
    		if rising_edge(clk) then
			if (end_period = '0') then
				counter <= counter + 1;
			elsif (end_period = '1') then
				counter <= (others => '0');
			else
				counter <= counter;
			end if;
		end if;
	end process; 

	-- End period signal
	process(clk)
   	begin
    		if rising_edge(clk) then
			if (counter = x"1E847F") then
				end_period <= '1';
			else
				end_period <= '0';
			end if;
		end if;
	end process;

	-- Duty cycle determination
	-- Button press and hold will turn the motor to the right
	-- Button low will keep the motor to the left.
	process(clk)
   	begin
    		if rising_edge(clk) then
			if (btnC = '1') then
				duty_cycle <= x"36EE8";
			else
				duty_cycle <= x"124F8";
			end if;
		end if;
	end process;

	-- Now we will set the output based on the duty cycle and period
	process(clk)
   	begin
    		if rising_edge(clk) then
			if (counter = x"0") then 
				output <= '1';
			elsif (counter = duty_cycle) then
				output <= '0';
			else
				output <= output;
			end if;
		end if;
	end process;

	JA <= output;

end behavior;
