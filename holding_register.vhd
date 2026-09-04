library ieee;
use ieee.std_logic_1164.all;

entity holding_register is
    port (
        clk           : in std_logic;
        reset         : in std_logic;
        register_clr  : in std_logic;
        din           : in std_logic;
        dout          : out std_logic
    );
end holding_register;

architecture circuit of holding_register is

    signal sreg : std_logic;

begin

    process(clk)
    begin
        if (clk'event and clk = '1') then
            if (reset = '1') then
                sreg <= '0';
            else
                if (register_clr = '1') then
                    sreg <= '0';
                else
                    sreg <= sreg or din;
                end if;
            end if;
        end if;
    end process;

    dout <= sreg;

end circuit;