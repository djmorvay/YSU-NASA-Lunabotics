library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter is
    port (
           clk, btnL, reset : in std_logic;
	   data_in : in std_logic_vector(11 downto 0);
	   data_out : out std_logic_vector(7 downto 0)
    );
end shifter;

architecture arch of shifter is

signal counter : unsigned(1 downto 0) := (others => '0');
signal data : std_logic_vector(7 downto 0) := (others => '0');

begin
	
	process (clk)
        	begin
    		if rising_edge(clk) then
			if ((btnL = '1') AND (reset = '0')) then
				counter <= counter + 1;
			elsif (reset = '1') then
				counter <= "10";
			else 
				counter <= counter;
			end if;
		end if;
	end process;

	process (clk)
        	begin
    		if rising_edge(clk) then
			if (counter = "00") then
				data <= data_in(7 downto 0);
			elsif (counter = "01") then
				data <= "0100" & data_in(11 downto 8);
			elsif (counter = "10") then
				data <= "00001101";
			elsif (counter = "11") then
				data <= "00001010";
			else
				data <= data;
			end if;
		end if;
	end process;

	data_out <= data;
			
end arch;
