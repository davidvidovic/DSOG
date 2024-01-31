library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity mac is
    Generic (input_data_width : natural := 24);
    Port ( clk_i : in std_logic;
           u_i : in STD_LOGIC_VECTOR (input_data_width-1 downto 0);
           b_i : in STD_LOGIC_VECTOR (input_data_width-1 downto 0);
           sec_i : in STD_LOGIC_VECTOR (2*input_data_width-1 downto 0);
           sec_o : out STD_LOGIC_VECTOR (2*input_data_width-1 downto 0);
           axi_valid_in : in std_logic
           );
           
    attribute dont_touch : string;
    attribute dont_touch of mac : entity is "yes";
    
end mac;

architecture Behavioral of mac is

    attribute use_dsp : string;
    attribute use_dsp of Behavioral : architecture is "yes";

    signal a_reg, b_reg, a_next, b_next : STD_LOGIC_VECTOR (input_data_width-1 downto 0):=(others=>'0');
    signal c0_reg, c1_reg, c0_next, c1_next : STD_LOGIC_VECTOR (2*input_data_width-1 downto 0):=(others=>'0');
    signal m_reg, p_reg, m_next, p_next : STD_LOGIC_VECTOR (2*input_data_width-1 downto 0):=(others=>'0');
    --signal v0, v1, v2 : std_logic := '0';
    
begin
    process(clk_i)
    begin
        if (clk_i'event and clk_i = '1')then           
            a_reg <= a_next;
            b_reg <= b_next;
            c0_reg <= c0_next;
            c1_reg <= c1_next;
            m_reg <= m_next;
            p_reg <= p_next;    
  
        end if;
    end process;
    
    process(axi_valid_in, u_i, b_i, sec_i) begin   
        if axi_valid_in = '0' then
            a_next <= a_reg;
            b_next <= b_reg;
            c0_next <= c0_reg;
            c1_next <= c1_reg;
            m_next <= m_reg;
            p_next <= p_reg;
        else
            a_next <= u_i;
            b_next <= b_i;
            m_next <= std_logic_vector(signed(a_reg) * signed(b_reg));
            c0_next <= sec_i;
            c1_next <= c0_reg;
            p_next <= std_logic_vector(signed(m_reg) + signed(c1_reg));
        end if;
        
    end process;
    
    sec_o <= p_reg;


end Behavioral;