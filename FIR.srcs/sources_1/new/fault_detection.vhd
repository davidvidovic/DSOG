library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fault_detection is
    Generic (input_data_width : natural := 24);
    Port ( in1 : in STD_LOGIC_VECTOR (2*input_data_width-1 downto 0);
           clk_i : in STD_LOGIC;
           data_i : in STD_LOGIC_VECTOR (input_data_width-1 downto 0);
           b_i : in STD_LOGIC_VECTOR (input_data_width-1 downto 0);
           sec_i : in STD_LOGIC_VECTOR (2*input_data_width-1 downto 0);
           comp : out STD_LOGIC;
           axi_valid_in : in std_logic);
           
    --attribute dont_touch : string;
    --attribute dont_touch of fault_detection : entity is "yes";
    
end fault_detection;

architecture Behavioral of fault_detection is

signal sec_o : STD_LOGIC_VECTOR (2*input_data_width-1 downto 0);

begin

FD_MAC: entity work.mac
    generic map(input_data_width=>input_data_width)
    port map(clk_i=>clk_i,
             u_i=>data_i,
             b_i=>b_i,
             sec_i=>sec_i,
             sec_o=>sec_o,
             axi_valid_in=>axi_valid_in);

process(in1, sec_o) begin
    if(in1 = sec_o) then
        comp <= '1';
    else
        comp <= '0';
    end if;
end process;

end Behavioral;