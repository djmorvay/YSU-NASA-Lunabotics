library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

entity move is
	port(
		clk : in std_logic;
		tx_counter : in unsigned(3 downto 0);
		data_in : in std_logic_vector(7 downto 0);	
		data_out : out std_logic_vector(7 downto 0)
	);
end move;

architecture behavior of move is
	-- Signals
	signal byte0, byte1, byte2 : std_logic_vector(7 downto 0);
	signal byte3, byte4, byte5 : std_logic_vector(7 downto 0);
	signal byte6, byte7 : std_logic_vector(7 downto 0);

	signal send0, send1, send2 : std_logic_vector(7 downto 0);
	signal send3, send4, send5 : std_logic_vector(7 downto 0);
	signal send6, send7 : std_logic_vector(7 downto 0);

	signal tx_counter_sig : unsigned(3 downto 0);

begin

	-- MOVE IN --
	-- Byte 0
	process (clk)
        	begin
		if rising_edge(clk) then 
			if (tx_counter = x"1") then
				byte0 <= data_in;
			else
				byte0 <= byte0;
			end if;
		end if;
	end process;

	-- Byte 1
	process (clk)
        	begin
		if rising_edge(clk) then 
			if (tx_counter = x"2") then
				byte1 <= data_in;
			else
				byte1 <= byte1;
			end if;
		end if;
	end process;

	-- Byte 2
	process (clk)
        	begin
		if rising_edge(clk) then 
			if (tx_counter = x"3") then
				byte2 <= data_in;
			else
				byte2 <= byte2;
			end if;
		end if;
	end process;

	-- Byte 3
	process (clk)
        	begin
		if rising_edge(clk) then 
			if (tx_counter = x"4") then
				byte3 <= data_in;
			else
				byte3 <= byte3;
			end if;
		end if;
	end process;

	-- Byte 4
	process (clk)
        	begin
		if rising_edge(clk) then 
			if (tx_counter = x"5") then
				byte4 <= data_in;
			else
				byte4 <= byte4;
			end if;
		end if;
	end process;

	-- Byte 5
	process (clk)
        	begin
		if rising_edge(clk) then 
			if (tx_counter = x"6") then
				byte5 <= data_in;
			else
				byte5 <= byte5;
			end if;
		end if;
	end process;

	-- Byte 6
	process (clk)
        	begin
		if rising_edge(clk) then 
			if (tx_counter = x"7") then
				byte6 <= data_in;
			else
				byte6 <= byte6;
			end if;
		end if;
	end process;

	-- Byte 7
	process (clk)
        	begin
		if rising_edge(clk) then 
			if (tx_counter = x"8") then
				byte7 <= data_in;
			else
				byte7 <= byte7;
			end if;
		end if;
	end process;


	process (clk)
        	begin
		if rising_edge(clk) then 
			tx_counter_sig <= tx_counter;
		end if;
	end process;
	

	-- MOVE OUT -- 
	process (clk)
        	begin
		if rising_edge(clk) then 
			case tx_counter_sig is
				when x"1"  => data_out <=  "00000001";
				when x"2"  => data_out <=  "00000011";
				when x"3"  => data_out <=  "00000111";
				when x"4"  => data_out <=  "00001111";
				when x"5"  => data_out <=  "00011111";
				when x"6"  => data_out <=  "00111111";
				when x"7"  => data_out <=  "01111111";
				when x"8"  => data_out <=  data_in;
				when others => data_out <= "00000000";
			end case;
		end if;
	end process;

end behavior;
