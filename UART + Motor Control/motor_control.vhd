library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity motor_control is
    port (
           clk : in std_logic;
	   rec_data : in std_logic_vector(7 downto 0);
	   JA : out std_logic_vector(0 downto 0)
    );
end motor_control;

architecture behavior of motor_control is

-- Motor Signals
signal counter : unsigned(31 downto 0) := (others => '0');
signal res : std_logic := '0';
signal switch : unsigned(0 downto 0) := "0";

signal period_counter : unsigned(21 downto 0) := (others => '0');
signal period_res : std_logic := '0';

signal duty_cycle : unsigned(19 downto 0) := (others => '0');
signal motor_dc : std_logic_vector(0 downto 0) := "0";

signal duty_cycle_follow : unsigned(19 downto 0) := (others => '0');

begin

-- Motor control --

	process (clk)
		begin
		if rising_edge(clk) then
			case rec_data is
				when x"71"  => duty_cycle <= x"25D78";
				when x"77"  => duty_cycle <= x"27100";
				when x"65"  => duty_cycle <= x"28488";
				when x"72"  => duty_cycle <= x"29810";
				when x"74"  => duty_cycle <= x"2AB98";
				when x"79"  => duty_cycle <= x"2BF20";
				when x"75"  => duty_cycle <= x"2D2A8";
				when x"69"  => duty_cycle <= x"2E630";
				when x"6F"  => duty_cycle <= x"2F9B8";
				when x"70"  => duty_cycle <= x"30D40";
				when x"61"  => duty_cycle <= x"23668";
				when x"73"  => duty_cycle <= x"222E0";
				when x"64"  => duty_cycle <= x"20F58";
				when x"66"  => duty_cycle <= x"1FBD0";
				when x"67"  => duty_cycle <= x"1E848";
				when x"68"  => duty_cycle <= x"1D4C0";
				when x"6A"  => duty_cycle <= x"1C138";
				when x"6B"  => duty_cycle <= x"1ADB0";
				when x"6C"  => duty_cycle <= x"19A28";
				when x"3B"  => duty_cycle <= x"186A0";
				when x"7F"  => duty_cycle <= x"249F0";
				when others => duty_cycle <= duty_cycle_follow;
			end case;
		end if;
	end process;

	duty_cycle_follow <= duty_cycle;
			

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
				motor_dc <= "1";
			elsif (period_counter = duty_cycle) then
				motor_dc <= "0";
			else
				motor_dc <= motor_dc;
			end if;
                end if;
         end process;

--------------------------------------------------------
	process (clk)
        	begin
    		if rising_edge(clk) then
			JA(0 downto 0) <= motor_dc;
                end if;
         end process;

end behavior;
