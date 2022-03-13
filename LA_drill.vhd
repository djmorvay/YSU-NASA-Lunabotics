----------------------------------------------------------------
-- Rover HDL
-- File: LA_drill.vhd
-- Entity: LA_drill
-- Description: Control circuit for auger lineatr actuator. 
--
-- Written by: David J. Morvay
-- YSU Robotics Club - NASA Lunabotics Competition
-- ECEN 4899 - Senior Design
-- Date: April 2021	                                                    
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LA_drill is
    port (
               clk : in std_logic;
	       btnR, btnL : in std_logic;
	       angle_0, angle_90, auger_lock : in std_logic;
	       ENA, IN1, IN2 : out std_logic
    );
end LA_drill;

architecture behavior of LA_drill is
    -- Signals

    -- Components
    


begin
 
 -- Linear Actuator Circuit
 	process(clk)
 	begin
    		if rising_edge(clk) then
        		if (((btnR = '1') OR (btnL = '1')) AND (auger_lock = '0')) then 
            			ENA <= '1';
        		else
            			ENA <= '0';
        		end if;
    		end if;
	end process;
 
 	process(clk)
 	begin
    		if rising_edge(clk) then
        		if ((btnR = '1') AND (angle_90 = '0')) then 
            			IN1 <= '1';
        		else
            			IN1 <= '0';
        		end if;
    		end if;
	end process;

	process(clk)
 	begin
    		if rising_edge(clk) then
        		if ((btnL = '1') AND (angle_0 = '0')) then 
            			IN2 <= '1';
       			else
            			IN2 <= '0';
        		end if;
    		end if;
	end process;

end behavior;
