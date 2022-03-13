------------------------------------------------------------------
-- Rover HDL
-- File: angle_read.vhd
-- Entity: angle_read
-- Description: Determine the angle of the auger position.
--
-- Written by: David J. Morvay
-- YSU Robotics Club - NASA Lunabotics Competition
-- ECEN 4899 - Senior Design
-- Date: April 2021	                                                    
------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

entity angle_read is
	port(
		clk : in std_logic;
		do_out : in std_logic_vector(11 downto 0);
		angle_0, angle_90, dump_ready : out std_logic
	);
end angle_read;

architecture behavior of angle_read is
	-- Signals
	
	-- Components

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if (do_out <= "011100111111") then 
				angle_0 <= '1';
			else
				angle_0 <= '0';
			end if;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			if (do_out >= "101010100000") then 
				angle_90 <= '1';
			else
				angle_90 <= '0';
			end if;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			if ((do_out <= "101000000000") AND (do_out >= "100101011111")) then
				dump_ready <= '1';
			else
				dump_ready <= '0';
			end if;
		end if;
	end process;

end behavior;
