library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.util_pkg.all;


entity n_to_2_switch is
    Generic ( input_data_width : natural := 24;
              n_param : natural := 8 );
    Port ( data_in : in std_logic_vector(n_param * 2 * input_data_width - 1 downto 0);
           sel : in std_logic_vector(n_param - 1 downto 0);
           error_signal: in std_logic;
           data_out_0 : out std_logic_vector(2*input_data_width-1 downto 0);
           data_out_1 : out std_logic_vector(2*input_data_width-1 downto 0)
    );
end n_to_2_switch;

architecture Behavioral of n_to_2_switch is

signal sel_0 : std_logic_vector(log2c(n_param)-1 downto 0);
signal sel_1 : std_logic_vector(log2c(n_param)-1 downto 0);

begin

encoder_0: entity work.priority_encoder
        generic map (   n_param => n_param)
        port map (      data_in => sel,
                        data_out => sel_0);

mux_0: entity work.mux
        generic map (   input_data_width => input_data_width,
                        n_param => n_param)
        port map (      data_in => data_in,
                        sel => sel_0,
                        data_out => data_out_0);
--encoder_1:                        
           
mux_1: entity work.mux
        generic map (   input_data_width => input_data_width,
                        n_param => n_param)
        port map (      data_in => data_in,
                        sel => sel_1,
                        data_out => data_out_1);                

sel_1 <= std_logic_vector((unsigned(sel_0) - 2) + (error_signal & ""));

end Behavioral;