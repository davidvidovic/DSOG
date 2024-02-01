library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity comp_unit is
    Generic ( input_data_width : natural := 24);
    Port ( in_0 : in STD_LOGIC_VECTOR (2*input_data_width-1 downto 0);
           in_1 : in STD_LOGIC_VECTOR (2*input_data_width-1 downto 0);
           error_signal : out STD_LOGIC;
           clk : in std_logic);
           
    attribute dont_touch : string;
    attribute dont_touch of comp_unit : entity is "yes";
end comp_unit;


architecture Behavioral of comp_unit is

begin

process(clk) begin
    if rising_edge(clk) then
        if(in_0 = in_1) then
            error_signal <= '1';
        else
            error_signal <= '0';
        end if;
    end if;
end process;

end Behavioral;