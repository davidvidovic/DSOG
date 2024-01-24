library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.util_pkg.all;


entity mux is
    Generic ( input_data_width : natural := 24;
              n_param : natural := 8 );
    Port ( data_in : in STD_LOGIC_VECTOR (n_param * 2 *input_data_width-1 downto 0);
           data_out : out STD_LOGIC_VECTOR (2*input_data_width-1 downto 0);
           sel : in STD_LOGIC_VECTOR (log2c(n_param)-1 downto 0)
           );
end mux;

architecture Behavioral of mux is

type temp_arr is array (n_param-1 downto 0) of std_logic_vector(2*input_data_width-1 downto 0);
signal mux_in : temp_arr := (others=>(others=>'0'));

begin

inputs: for i in 0 to n_param-1 generate
    mux_in(i) <= data_in(((i+1)*2*input_data_width)-1 downto (i*2*input_data_width));
end generate;

data_out <= mux_in(to_integer(unsigned(sel(log2c(n_param)-1 downto 0))));

end Behavioral;