----------------------------------------------------------------
-- Rover HDL
-- File: move_data.vhd
-- Entity: move
-- Description: Distribution of data from UART communication.
-- Data is sent to the respective circuit and "packed" to 
-- be sent back to the source and control room.
--
-- Written by: David J. Morvay
-- YSU Robotics Club - NASA Lunabotics Competition
-- ECEN 4899 - Senior Design
-- Date: April 2021	                                                    
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

entity move is
	port(
		clk : in std_logic;
		tx_counter : in unsigned(4 downto 0);
		data_in : in std_logic_vector(7 downto 0);	
		data_out : out std_logic_vector(7 downto 0);
		motor_r, motor_l : out std_logic_vector(7 downto 0);
		auger_rail_r, auger_rail_l : out std_logic;
		auger_LA_up, auger_LA_down : out std_logic;
		auger_drill_r_fw, auger_drill_r_rev : out std_logic;
		auger_drill_l_fw, auger_drill_l_rev : out std_logic;
		boost : out std_logic;
		dump_down, dump_up : out std_logic;
		auger_lock : out std_logic
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

	signal check : std_logic_vector(7 downto 0);

begin

	-- MOVE IN --
	-- Byte 0
	process (clk)
        	begin
		if rising_edge(clk) then 
			if (tx_counter = x"2") then
				byte0 <= data_in;
			else
				byte0 <= byte0;
			end if;
		end if;
	end process;
	
	motor_l <= byte0;

	-- Byte 1
	process (clk)
        	begin
		if rising_edge(clk) then 
			if (tx_counter = x"3") then
				byte1 <= data_in;
			else
				byte1 <= byte1;
			end if;
		end if;
	end process;

	motor_r <= byte1;

	-- Byte 2
	process (clk)
        	begin
		if rising_edge(clk) then 
			if (tx_counter = x"4") then
				byte2 <= data_in;
			else
				byte2 <= byte2;
			end if;
		end if;
	end process;

	auger_rail_r <= byte2(0);
	auger_rail_l <= byte2(1);
	auger_LA_up <=  byte2(2);
	auger_LA_down <=  byte2(3);
	auger_lock <= byte2(4);

	-- Byte 3
	process (clk)
        	begin
		if rising_edge(clk) then 
			if (tx_counter = x"5") then
				byte3 <= data_in;
			else
				byte3 <= byte3;
			end if;
		end if;
	end process;
	
	auger_drill_r_fw <= byte3(0);
	auger_drill_r_rev <= byte3(1);
	auger_drill_l_fw <= byte3(2);
	auger_drill_l_rev <= byte3(3);
	boost <= byte3(4);

	-- Byte 4
	process (clk)
        	begin
		if rising_edge(clk) then 
			if (tx_counter = x"6") then
				byte4 <= data_in;
			else
				byte4 <= byte4;
			end if;
		end if;
	end process;

	dump_down <= byte4(0);
	dump_up <= byte4(1);

	-- Byte 5
	process (clk)
        	begin
		if rising_edge(clk) then 
			if (tx_counter = x"7") then
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
			if (tx_counter = x"8") then
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
			if (tx_counter = x"9") then
				byte7 <= data_in;
			else
				byte7 <= byte7;
			end if;
		end if;
	end process;
	

	-- MOVE OUT -- 
	process (clk)
        	begin
		if rising_edge(clk) then 
			case tx_counter is
				when "01001"  => data_out <=  byte0;
				when "01010"  => data_out <=  byte1;
				when "01011"  => data_out <=  byte2;
				when "01100"  => data_out <=  byte3;
				when "01101"  => data_out <=  byte4;
				when "01110"  => data_out <=  byte5;
				when "01111"  => data_out <=  byte6;
				when "10000"  => data_out <=  byte7;
				when others => data_out <= "00000000";
			end case;
		end if;
	end process;

end behavior;
