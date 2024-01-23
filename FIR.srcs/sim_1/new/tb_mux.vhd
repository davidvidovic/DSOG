library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.util_pkg.all;

entity tb_mux is
    Generic ( input_data_width : natural := 2;
              n_param : natural := 16 );
--  Port ( );
end tb_mux;

architecture Behavioral of tb_mux is

signal data_in_s : STD_LOGIC_VECTOR (n_param * 2 * input_data_width-1 downto 0);
signal data_out_s : STD_LOGIC_VECTOR (2*input_data_width-1 downto 0);
signal sel_s : STD_LOGIC_VECTOR (log2c(n_param)-1 downto 0);

begin

dut: entity work.mux
        generic map (   input_data_width => input_data_width,
                        n_param => n_param)
        port map (      data_in => data_in_s,
                        sel => sel_s,
                        data_out => data_out_s);
                        
stim: process begin
    data_in_s <= "0000000100100011010001010110011110001001101010111100110111101111";
    sel_s <= "0000";
    wait for 10ns;
    for i in 1 to n_param loop
        sel_s <= std_logic_vector(unsigned(sel_s) + 1);
        wait for 10ns;
    end loop;
    wait;
end process;

end Behavioral;