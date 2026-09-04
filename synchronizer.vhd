library ieee;
use ieee.std_logic_1164.all;

entity synchronizer is
    port (
        clk    : in std_logic;
        reset  : in std_logic;
        din    : in std_logic;
        dout   : out std_logic
    );
end synchronizer;

architecture circuit of synchronizer is

    signal sreg : std_logic_vector(1 downto 0);

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                sreg <= (others => '0');
            else
                sreg(0) <= din;
                sreg(1) <= sreg(0);
            end if;
        end if;
    end process;

    dout <= sreg(1);

end architecture circuit;