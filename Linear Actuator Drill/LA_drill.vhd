library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LA_drill is
    port (
           clk : in std_logic;
	       btnR, btnL : in std_logic;
	       sw : in std_logic_vector(0 downto 0);
	       angle_p, angle_n : in std_logic;
	       ENA, IN1, IN2 : out std_logic;
	       led : out std_logic_vector(11 downto 0)
    );
end LA_drill;

architecture behavior of LA_drill is
    -- Signals
    signal channel_out : std_logic_vector(6 downto 0);
    signal eoc_out : std_logic;
    signal do_out, di_in : std_logic_vector(15 downto 0);
    signal zero : std_logic := '0';
    signal angle_read : std_logic_vector(11 downto 0);

    -- Components
    component xadc_wiz_0 is
    port(
            daddr_in        : in  STD_LOGIC_VECTOR (6 downto 0);     -- Address bus for the dynamic reconfiguration port
            den_in          : in  STD_LOGIC;                         -- Enable Signal for the dynamic reconfiguration port
            di_in           : in  STD_LOGIC_VECTOR (15 downto 0);    -- Input data bus for the dynamic reconfiguration port
            dwe_in          : in  STD_LOGIC;                         -- Write Enable for the dynamic reconfiguration port
            do_out          : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
            drdy_out        : out  STD_LOGIC;                        -- Data ready signal for the dynamic reconfiguration port
            dclk_in         : in  STD_LOGIC;                         -- Clock input for the dynamic reconfiguration port
            reset_in        : in  STD_LOGIC;                         -- Reset signal for the System Monitor control logic
            vauxp6          : in  STD_LOGIC;                         -- Auxiliary Channel 5
            vauxn6          : in  STD_LOGIC;
            busy_out        : out  STD_LOGIC;                        -- ADC Busy signal
            channel_out     : out  STD_LOGIC_VECTOR (4 downto 0);    -- Channel Selection Outputs
            eoc_out         : out  STD_LOGIC;                        -- End of Conversion Signal
            eos_out         : out  STD_LOGIC;                        -- End of Sequence Signal
            ot_out          : out  STD_LOGIC;                        -- Over-Temperature alarm output
            vccaux_alarm_out : out  STD_LOGIC;                        -- VCCAUX-sensor alarm output
            vccint_alarm_out : out  STD_LOGIC;                        -- VCCINT-sensor alarm output
            user_temp_alarm_out : out  STD_LOGIC;                        -- Temperature-sensor alarm output
            alarm_out       : out STD_LOGIC;                         -- OR'ed output of all the Alarms
            vp_in           : in  STD_LOGIC;                         -- Dedicated Analog Input Pair
            vn_in           : in  STD_LOGIC
	);
	end component;


begin

led <= do_out(15 downto 4);
channel_out(6 downto 5) <= (others => '0');

angle_read <= do_out(15 downto 4);

-- Instantiate XADC
angle_XADC : xadc_wiz_0 port map(
        daddr_in => channel_out(6 downto 0),       -- input wire [6 : 0] daddr_in
        den_in => eoc_out,             -- input wire den_in
        di_in => (others => '0'),              -- input wire [15:0] di_in
        dwe_in => '0',                 -- input wire dwe_in
        do_out => do_out,              -- output wire [15 : 0] do_out
        drdy_out => open,              -- output wire drdy_out
        dclk_in => clk,                -- input wire dclk_in
        reset_in => sw(0),             -- input wire reset_in

        vauxp6 => angle_p,                 -- note since vauxn5, channel 5, is used  .daddr_in(ADC_ADDRESS), ADC_ADRESS = 15h, i.e., 010101 
        vauxn6 => angle_n,                 -- note since vauxn5, channel 5, is used  .daddr_in(ADC_ADDRESS), ADC_ADRESS = 15h, i.e., 010101     
 
        busy_out => open,                           -- output wire busy_out
        channel_out => channel_out(4 downto 0),     -- output wire [4 : 0] channel_out
        eoc_out => eoc_out,                         -- output wire eoc_out
        eos_out => open,
        ot_out => open,
        vccaux_alarm_out => open,                -- VCCAUX-sensor alarm output
        vccint_alarm_out => open,                -- VCCINT-sensor alarm output
        user_temp_alarm_out => open,             -- Temperature-sensor alarm output
        alarm_out => open,                       -- OR'ed output of all the Alarms
        vp_in => '0',                           -- Dedicated Analog Input Pair
        vn_in => '0'
);
 ------ End INSTANTIATION ---------
 
 
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
        -- if ((btnR = '1') AND (angle_read <= "101001111000")) then
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
        -- if ((btnL = '1') AND (angle_read >= "011101111000")) then 
        if (btnL = '1') then
            IN2 <= '1';
        else
            IN2 <= '0';
        end if;
    end if;
end process;

end behavior;

-- Big angle for dump system
-- "101000000000" 
-- "100101011111"
