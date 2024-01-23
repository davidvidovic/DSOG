library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.util_pkg.all;

entity tb_priority_encoder is
    Generic (N : natural := 8);
--  Port ( );
end tb_priority_encoder;

architecture Behavioral of tb_priority_encoder is

signal data_in_s : std_logic_vector(N-1 downto 0);
signal data_out_s : std_logic_vector(log2c(N)-1 downto 0);

begin

dut: entity work.priority_encoder
    generic map (n_param => N)
    port map (
        data_in => data_in_s,
        data_out => data_out_s);

stim_process: process begin
    data_in_s <= "00000001";
    wait for 10ns;
    data_in_s <= "00000010";
    wait for 10ns;
    data_in_s <= "00000100";
    wait for 10ns;
    data_in_s <= "00001000";
    wait for 10ns;
    data_in_s <= "00010000";
    wait for 10ns;
    data_in_s <= "00100000";
    wait for 10ns;
    data_in_s <= "01000000";
    wait for 10ns;
    data_in_s <= "10000000";
    wait for 10ns;
    
    data_in_s <= "00001101";
    wait for 10ns;
    data_in_s <= "01100010";
    wait for 10ns;
    data_in_s <= "11111111";
    wait for 10ns;
    data_in_s <= "01001001";
    wait for 10ns;
    data_in_s <= "00000000";
    wait for 10ns;
    data_in_s <= "01000110";
    wait for 10ns;
    
    wait;
end process;

end Behavioral;