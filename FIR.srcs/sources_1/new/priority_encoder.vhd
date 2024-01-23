library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.util_pkg.all;

entity priority_encoder is
    -- Input is FD vector, which means input width is N from FIR
    Generic ( n_param : natural := 8);
    Port ( --clk, rst : in std_logic;
           data_in : in STD_LOGIC_VECTOR (n_param-1 downto 0);
           data_out : out STD_LOGIC_VECTOR (log2c(n_param)-1 downto 0)
           -- data_valid : out STD_LOGIC
           );
end priority_encoder;

architecture Behavioral of priority_encoder is
--signal res_reg, res_next : std_logic_vector(log2c(n_param)-1 downto 0);

begin

--process(clk) begin
--    if(rst = '1') then
--        res_reg <= (others => '0');
--    else
--        res_reg <= res_next;
--    end if;
--end process;

process(data_in) 
    variable temp : integer range 0 to n_param;
    -- Possible latch when working with variable
    
    begin
    for i in 0 to n_param-1 loop
        if(data_in(i) = '1') then
            --res_next <= std_logic_vector(to_unsigned(i, log2c(n_param)));
            temp := i;
        end if; 
    end loop;
    
    data_out <= std_logic_vector(to_unsigned(temp, log2c(n_param)));
end process;

end Behavioral;