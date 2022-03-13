library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LA is
    port (
               clk : in std_logic;
	       btnR, btnL : in std_logic;
	       angle_0, angle_45, angle_90 : in std_logic;
	       ENA, IN1, IN2 : out std_logic
    );
end LA;

architecture behavior of LA is
    -- Signals

    -- Components
    


begin
 
 -- Linear Actuator Circuit
 	process(clk)
 	begin
    		if rising_edge(clk) then
        		if ((btnR = '1') OR (btnL = '1')) then 
            			ENA <= '1';
        		else
            			ENA <= '0';
        		end if;
    		end if;
	end process;
 
 	process(clk)
 	begin
    		if rising_edge(clk) then
        		if (btnR = '1') then 
            			IN1 <= '1';
        		else
            			IN1 <= '0';
        		end if;
    		end if;
	end process;

	process(clk)
 	begin
    		if rising_edge(clk) then
        		if (btnL = '1') then 
            			IN2 <= '1';
       			else
            			IN2 <= '0';
        		end if;
    		end if;
	end process;

end behavior;
