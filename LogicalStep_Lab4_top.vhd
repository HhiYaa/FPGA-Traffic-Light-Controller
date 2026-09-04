LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
    PORT (
        clkin_50    : IN std_logic;                       -- The 50 MHz FPGA Clock input
        rst_n       : IN std_logic;                       -- The RESET input (ACTIVE LOW)
        pb_n        : IN std_logic_vector(3 DOWNTO 0);    -- The push-button inputs (ACTIVE LOW)
        sw          : IN std_logic_vector(7 DOWNTO 0);    -- The switch inputs
        leds        : OUT std_logic_vector(7 DOWNTO 0);   -- For displaying the lab4 project details
        
        -- You can add temporary output ports here if you need to debug your design
        -- or to add internal signals for your simulations

        seg7_data   : OUT std_logic_vector(6 DOWNTO 0);   -- 7-bit outputs to a 7-segment
        seg7_char1  : OUT std_logic;                      -- seg7 digit selectors
        seg7_char2  : OUT std_logic                       -- seg7 digit selectors
    );
END LogicalStep_Lab4_top;

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS

    COMPONENT segment7_mux
        PORT (
            clk     : IN  std_logic := '0';
            DIN2    : IN  std_logic_vector(6 DOWNTO 0);  -- Bits 6 to 0 represent segments G,F,E,D,C,B,A
            DIN1    : IN  std_logic_vector(6 DOWNTO 0);  -- Bits 6 to 0 represent segments G,F,E,D,C,B,A
            DOUT    : OUT std_logic_vector(6 DOWNTO 0);
            DIG2    : OUT std_logic;
            DIG1    : OUT std_logic
        );
    END COMPONENT;

    COMPONENT clock_generator
        PORT (
            sim_mode    : IN boolean;
            reset       : IN std_logic;
            clkin       : IN std_logic;
            sm_clken    : OUT std_logic;
            blink       : OUT std_logic
        );
    END COMPONENT;

    COMPONENT pb_inverters
        PORT (
            rst_n       : IN std_logic;
            rst         : OUT std_logic;
            pb_n        : IN std_logic_vector(3 DOWNTO 0);
            pb          : OUT std_logic_vector(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT synchronizer
        PORT (
            clk         : IN std_logic;
            reset       : IN std_logic;
            din         : IN std_logic;
            dout        : OUT std_logic
        );
    END COMPONENT;

    COMPONENT holding_register
        PORT (
            clk         : IN std_logic;
            reset       : IN std_logic;
            register_clr: IN std_logic;
            din         : IN std_logic;
            dout        : OUT std_logic
        );
    END COMPONENT;

    COMPONENT PB_filters
        PORT (
            clkin           : IN std_logic;
            rst_n           : IN std_logic;
            rst_n_filtered  : OUT std_logic;
            pb_n            : IN std_logic_vector(3 DOWNTO 0);
            pb_n_filtered   : OUT std_logic_vector(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT State_Machine_moore
        PORT (
            clk_input       : IN std_logic;
            reset           : IN std_logic;
            enable          : IN std_logic;
            NSrequest       : IN std_logic;
            EWrequest       : IN std_logic;
            blink_sig       : IN std_logic;
            green           : OUT std_logic;
            yellow          : OUT std_logic;
            red             : OUT std_logic;
            greenEW         : OUT std_logic;
            yellowEW        : OUT std_logic;
            redEW           : OUT std_logic;
            NS_CROSSINGS    : OUT std_logic;
            NSREGISTER_CLEAR: OUT std_logic;
            EWREGISTER_CLEAR: OUT std_logic;
            EW_CROSSINGS    : OUT std_logic;
            stateout        : OUT std_logic_vector(3 DOWNTO 0)
        );
    END COMPONENT;

    CONSTANT sim_mode : boolean := FALSE; -- Set to FALSE for LogicalStep board downloads.
                                          -- Set to TRUE for simulations

    SIGNAL sm_clken, blink_sig, NS_CROSSING, EW_CROSSING: std_logic;
    SIGNAL pb                              : std_logic_vector(3 DOWNTO 0); -- pb(3) is used as an active-high reset for all registers
    SIGNAL sync_out                        : std_logic_vector(1 DOWNTO 0);
    SIGNAL rst_in, rst_n_fil, synch_rst    : std_logic;
    SIGNAL pb_filt                         : std_logic_vector(3 DOWNTO 0);

    -- NS
    SIGNAL gsolid, asolid, rsolid          : std_logic;
    SIGNAL gsolidEW, asolidEW, rsolidEW    : std_logic;

    SIGNAL light                           : std_logic_vector(6 DOWNTO 0);
    SIGNAL lightEW                         : std_logic_vector(6 DOWNTO 0);
    SIGNAL rst                             : std_logic;
    SIGNAL requestNS, requestEW            : std_logic;
    SIGNAL REGISTER_CLEARNS, REGISTER_CLEAREW: std_logic;

BEGIN

    -- Connects output values to LEDs
    leds(0) <= NS_CROSSING;
    leds(2) <= EW_CROSSING;
    leds(1) <= requestNS;
    leds(3) <= requestEW;

    light <= asolid & "00" & gsolid & "00" & rsolid;
    lightEW <= asolidEW & "00" & gsolidEW & "00" & rsolidEW;

    INST1: pb_inverters
        PORT MAP (
            rst_n => rst_n_fil,
            rst => rst,
            pb_n => pb_filt,
            pb => pb
        );

    INST2: clock_generator
        PORT MAP (
            sim_mode => sim_mode,
            reset => pb(3),
            clkin => clkin_50,
            sm_clken => sm_clken,
            blink => blink_sig
        );

    INST3: PB_filters
        PORT MAP (
            clkin => clkin_50,
            rst_n => rst_n,
            rst_n_filtered => rst_n_fil,
            pb_n => pb_n,
            pb_n_filtered => pb_filt
        );

    INST4: synchronizer
        PORT MAP (
            clk => clkin_50,
            reset => synch_rst,
            din => rst,
            dout => synch_rst
        );

    INST5: synchronizer
        PORT MAP (
            clk => clkin_50,
            reset => synch_rst,
            din => pb(1),
            dout => sync_out(1)
        );

    INST6: holding_register
        PORT MAP (
            clk => clkin_50,
            reset => synch_rst,
            register_clr => REGISTER_CLEAREW,
            din => sync_out(1),
            dout => requestEW
        );

    INST7: synchronizer
        PORT MAP (
            clk => clkin_50,
            reset => synch_rst,
            din => pb(0),
            dout => sync_out(0)
        );

    INST8: holding_register
        PORT MAP (
            clk => clkin_50,
            reset => synch_rst,
            register_clr => REGISTER_CLEARNS,
            din => sync_out(0),
            dout => requestNS
        );

    INST9: State_Machine_moore
        PORT MAP (
            clk_input => clkin_50,
            reset => synch_rst,
            enable => sm_clken,
            NSrequest => requestNS,
            EWrequest => requestEW,
            blink_sig => blink_sig,
            green => gsolid,
            yellow => asolid,
            red => rsolid,
            greenEW => gsolidEW,
            yellowEW => asolidEW,
            redEW => rsolidEW,
            NS_CROSSINGS => NS_CROSSING,
            NSREGISTER_CLEAR => REGISTER_CLEARNS,
            EWREGISTER_CLEAR => REGISTER_CLEAREW,
            EW_CROSSINGS => EW_CROSSING,
            stateout => leds(7 DOWNTO 4)
        );

    INST10: segment7_mux
        PORT MAP (
            clk => clkin_50,
            DIN2 => lightEW,
            DIN1 => light,
            DOUT => seg7_data(6 DOWNTO 0),
            DIG2 => seg7_char1,
            DIG1 => seg7_char2
        );

END SimpleCircuit;

