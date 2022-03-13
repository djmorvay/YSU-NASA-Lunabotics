library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
    port (
           clk : in std_logic;
	   btn : in std_logic;
	   click : out std_logic
    );
end debounce;

architecture behavior of debounce is
	-- Signals
	signal btn1, btn2 : std_logic := '0';
	signal fire, click_sig : boolean := FALSE;
	signal button_count : unsigned(19 downto 0) := (others => '0'); 
	signal DEBOUNCE_DELAY : unsigned(19 downto 0) := x"F4240"; 

	-- component debounce is 
	-- port (
		-- clk : in std_logic;
		-- btn : in std_logic;
		-- click : out std_logic
	-- );
	-- end component;

	-- Instantiate Debounce
	-- button_debounce : debounce port map(clk => clk, btn => btn?, click => btnOut?);

begin

	process (clk)
        	begin
    		if rising_edge(clk) then
			btn1 <= btn;
                end if;
         end process;

	process (clk)
        	begin
    		if rising_edge(clk) then
			btn2 <= btn1;
                end if;
         end process;

	fire <= (button_count = DEBOUNCE_DELAY); 
	click_sig <= (button_count = DEBOUNCE_DELAY - 1); 

	process (clk)
        	begin
		if rising_edge(clk) then
         		 if (btn2 = '0')  then                   
				button_count <= (others => '0');
          		elsif (fire) then    
				button_count <= button_count;
          		else                          
				button_count <= button_count + 1;
			end if;
		end if;
	end process;

	process (clk)
        	begin
		if rising_edge(clk) then
         		 if (click_sig = TRUE)  then                   
				click <= '1';
			else 
				click <= '0';
			end if;
		end if;
	end process;


end behavior;
