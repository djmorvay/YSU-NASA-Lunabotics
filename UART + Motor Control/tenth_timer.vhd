library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tenth_timer is
    port (
           clk : in std_logic;
	   tenth_tick : out std_logic
    );
end tenth_timer;

architecture behavior of tenth_timer is

signal TENTH_DELAY : unsigned(23 downto 0) := x"989680"; 
signal tenth_counter : unsigned(23 downto 0) := (others => '0');
signal reset : std_logic := '0';
signal tick1, tick2 : std_logic := '0';

begin

	process (clk)
        	begin
    		if rising_edge(clk) then
			if (reset = '1') then
				tenth_counter <= (others => '0');
			else
				tenth_counter <= tenth_counter + 1;
			end if;
		end if;
	end process;

	process (clk)
        	begin
    		if rising_edge(clk) then
			if (tenth_counter = x"98967F") then
				reset <= '1';
			else
				reset <= '0';
			end if;
		end if;
	end process;	
	
	process (clk)
        	begin
    		if rising_edge(clk) then 
			tick1 <= reset;
		end if;
	end process;

	process (clk)
        	begin
    		if rising_edge(clk) then 
			tick2 <= tick1;
		end if;
	end process;

	tenth_tick <= tick1 AND (NOT tick2);					

end behavior;
