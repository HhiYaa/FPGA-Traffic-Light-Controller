library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity State_Machine_moore is
    port (
        clk_input, reset, enable, blink_sig  : in std_logic;
        NSrequest, EWrequest                 : in std_logic;
        green, yellow, red                   : out std_logic;
        greenEW, yellowEW, redEW             : out std_logic;
        NS_CROSSINGS, EW_CROSSINGS           : out std_logic;
        NSREGISTER_CLEAR, EWREGISTER_CLEAR   : out std_logic;
        stateout                             : out std_logic_vector(3 downto 0)
    );
end entity;

architecture SM of State_Machine_moore is

    type STATE_NAMES is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15);
    signal current_state, next_state : STATE_NAMES;

begin

    -- Register Logic Process
    process (clk_input)
    begin
        if rising_edge(clk_input) then
            if reset = '1' then
                current_state <= S0;
            elsif enable = '1' then
                current_state <= next_state;
            end if;
        end if;
    end process;

    -- Transition Logic Process
    process (EWrequest, NSrequest, current_state)
    begin
        case current_state is
            when S0 =>
                if EWrequest = '1' and NSrequest = '0' then
                    next_state <= S6;
                else
                    next_state <= S1;
                end if;

            when S1 =>
                if EWrequest = '1' and NSrequest = '0' then
                    next_state <= S6;
                else
                    next_state <= S2;
                end if;

            when S2 =>
                next_state <= S3;

            when S3 =>
                next_state <= S4;

            when S4 =>
                next_state <= S5;

            when S5 =>
                next_state <= S6;

            when S6 =>
                next_state <= S7;

            when S7 =>
                next_state <= S8;

            when S8 =>
                if NSrequest = '1' and EWrequest = '0' then
                    next_state <= S14;
                else
                    next_state <= S9;
                end if;

            when S9 =>
                if NSrequest = '1' and EWrequest = '0' then
                    next_state <= S14;
                else
                    next_state <= S10;
                end if;

            when S10 =>
                next_state <= S11;

            when S11 =>
                next_state <= S12;

            when S12 =>
                next_state <= S13;

            when S13 =>
                next_state <= S14;

            when S14 =>
                next_state <= S15;

            when S15 =>
                next_state <= S0;

            when others =>
                next_state <= S0;
        end case;
    end process;

    -- Decoder Section Process (Moore FSM)
    process (blink_sig, current_state)
    begin
        -- Default output values
        green <= '0'; yellow <= '0'; red <= '0';
        greenEW <= '0'; yellowEW <= '0'; redEW <= '0';
        NS_CROSSINGS <= '0'; EW_CROSSINGS <= '0';
        NSREGISTER_CLEAR <= '0'; EWREGISTER_CLEAR <= '0';

        case current_state is
            when S0 =>
                green <= blink_sig;
                redEW <= '1';
                stateout <= "0000";

            when S1 =>
                green <= blink_sig;
                redEW <= '1';
                stateout <= "0001";

            when S2 =>
                green <= '1';
                redEW <= '1';
                NS_CROSSINGS <= '1';
                stateout <= "0010";

            when S3 =>
                green <= '1';
                redEW <= '1';
                NS_CROSSINGS <= '1';
                stateout <= "0011";

            when S4 =>
                green <= '1';
                redEW <= '1';
                NS_CROSSINGS <= '1';
                stateout <= "0100";

            when S5 =>
                green <= '1';
                redEW <= '1';
                NS_CROSSINGS <= '1';
                stateout <= "0101";

            when S6 =>
                yellow <= '1';
                redEW <= '1';
                NSREGISTER_CLEAR <= '1';
                stateout <= "0110";

            when S7 =>
                yellow <= '1';
                redEW <= '1';
                stateout <= "0111";

            when S8 =>
                red <= '1';
                greenEW <= blink_sig;
                stateout <= "1000";

            when S9 =>
                red <= '1';
                greenEW <= blink_sig;
                stateout <= "1001";

            when S10 =>
                red <= '1';
                greenEW <= '1';
                EW_CROSSINGS <= '1';
                stateout <= "1010";

            when S11 =>
                red <= '1';
                greenEW <= '1';
                EW_CROSSINGS <= '1';
                stateout <= "1011";

            when S12 =>
                red <= '1';
                greenEW <= '1';
                EW_CROSSINGS <= '1';
                stateout <= "1100";

            when S13 =>
                red <= '1';
                greenEW <= '1';
                EW_CROSSINGS <= '1';
                stateout <= "1101";

            when S14 =>
                red <= '1';
                yellowEW <= '1';
                EWREGISTER_CLEAR <= '1';
                stateout <= "1110";

            when S15 =>
                red <= '1';
                yellowEW <= '1';
                stateout <= "1111";

            when others =>
                -- This case is redundant due to default values but is here for completeness
                stateout <= "0000";
        end case;
    end process;

end architecture SM;