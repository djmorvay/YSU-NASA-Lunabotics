library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity tenth_timer_tb is
end tenth_timer_tb;

architecture testbench of tenth_timer_tb is
    constant num_cycles : integer := 50000;
    signal clk : std_logic := '1';
    signal tenth_tick : std_logic;
    component tenth_timer is
        port (
            	clk : in std_logic;
		tenth_tick : out std_logic
	     );
    end component;

begin
	dut : tenth_timer port map(clk, tenth_tick);
    process
    begin
    
    report "* START OF TESTBENCH *";

    for i in 1 to num_cycles loop
      clk <= not clk;
      wait for 5 ns;
      clk <= not clk;
      wait for 5 ns;
      -- clock period = 10 ns
    end loop;

    report "* END OF TESTBENCH *";
    wait;
    end process;

end testbench;
