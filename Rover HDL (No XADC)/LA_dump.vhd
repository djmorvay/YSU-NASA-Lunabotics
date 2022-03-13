-----------------------------------------------------------------
-- Rover HDL
-- File: LA_dump.vhd
-- Entity: linearA
-- Description: Linear actuator control for dump system.
--
-- Written by: David J. Morvay
-- YSU Robotics Club - NASA Lunabotics Competition
-- ECEN 4899 - Senior Design
-- Date: April 2021	                                                
-----------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity LA_dump is
	port (
    		clk : in std_logic;
            	up, down : in std_logic;
            	angle_90 : in std_logic;
            	dump_limit : in std_logic;
            	ENA, IN1, IN2 : out std_logic
     );
end LA_dump;

architecture behavior of LA_dump is
	-- Signals
    
    	-- Components

begin

	process(clk)
    	begin
    		if rising_edge(clk) then
        		if (((up = '1') OR (down = '1')) AND (angle_90 = '1')) then
            			ENA <= '1';
             		else 
             			ENA <= '0';
             		end if;
         	end if;
    	end process;
    
    
    
   	 process(clk)
   	 begin
    		if rising_edge(clk) then
        		if ((up = '1') AND (dump_limit = '1')) then
            			IN1 <= '1';
             		else 
             			IN1 <= '0';
             		end if;
         	end if;
    	end process;
    
    
    
    	process(clk)
    	begin
    		if rising_edge(clk) then
        		if (down = '1') then
            			IN2 <= '1';
             		else 
             			IN2 <= '0';
             		end if;
         	end if;
    	end process;
    
    
end behavior;
