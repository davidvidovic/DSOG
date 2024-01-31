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
    
    attribute dont_touch : string;
    attribute dont_touch of n_to_2_switch : entity is "yes";
    
end n_to_2_switch;

architecture Behavioral of n_to_2_switch is

signal sel_0 : std_logic_vector(log2c(n_param)-1 downto 0) := (others=>'0');
signal sel_1 : std_logic_vector(log2c(n_param)-1 downto 0) := std_logic_vector(TO_UNSIGNED(1, log2c(n_param)));

signal next_sel : std_logic_vector(log2c(n_param)-1 downto 0) := std_logic_vector(TO_UNSIGNED(2, log2c(n_param)));

-- At the start, SEL0 is 0 and SEL1 is 1
-- As error signal is produced 

begin

--encoder_0: entity work.priority_encoder
--        generic map (   n_param => n_param)
--        port map (      data_in => sel,
--                        data_out => sel_0);

mux_0: entity work.mux
        generic map (   input_data_width => input_data_width,
                        n_param => n_param)
        port map (      data_in => data_in,
                        sel => sel_0,
                        data_out => data_out_0);
           
mux_1: entity work.mux
        generic map (   input_data_width => input_data_width,
                        n_param => n_param)
        port map (      data_in => data_in,
                        sel => sel_1,
                        data_out => data_out_1);                

--sel_1 <= std_logic_vector((unsigned(sel_0) - 2) + (error_signal & ""));

process(error_signal)
begin
    if error_signal = '0' then
    
       -- if non valid input is on MUX0
        if sel(TO_INTEGER(unsigned(sel_0))) = '0' then 
            sel_0 <= next_sel;
        end if;
        
        -- if non valid input is on MUX1
        if sel(TO_INTEGER(unsigned(sel_1))) = '0' then 
            sel_1 <= next_sel;
        end if;
        
        
         -- if there is error signal and next signal has already counted and went through all inputs
        -- reset it to 2, but there is no valid input anyway
        if next_sel = std_logic_vector(to_unsigned(n_param-1, log2c(n_param))) then
            next_sel <= std_logic_vector(TO_UNSIGNED(2, log2c(n_param)));
        else
            next_sel <= std_logic_vector(unsigned(next_sel) + 1);
        end if;
    
    end if;
end process;

end Behavioral;