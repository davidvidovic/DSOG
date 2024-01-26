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
           sec_o : out STD_LOGIC_VECTOR (2*input_data_width-1 downto 0));
           
    attribute dont_touch : string;
    attribute dont_touch of mac : entity is "yes";
    
end mac;

architecture Behavioral of mac is

    attribute use_dsp : string;
    attribute use_dsp of Behavioral : architecture is "yes";

    signal reg_s : STD_LOGIC_VECTOR (2*input_data_width-1 downto 0):=(others=>'0');
--    signal a_reg, b_reg, a_next, b_next : STD_LOGIC_VECTOR (input_data_width-1 downto 0):=(others=>'0');
--    signal m_reg, m_next : STD_LOGIC_VECTOR (input_data_width-1 downto 0):=(others=>'0');
--    signal c_reg, c_next : STD_LOGIC_VECTOR (2*input_data_width-1 downto 0):=(others=>'0');
--    signal p_reg, p_next : STD_LOGIC_VECTOR (2*input_data_width-1 downto 0):=(others=>'0');
    
begin
    process(clk_i)
    begin
        if (clk_i'event and clk_i = '1')then
--            a_reg <= a_next;
--            b_reg <= b_next;
--            m_reg <= m_next;
--            c_reg <= c_next;
--            p_reg <= p_next;
              reg_s <= sec_i;
        end if;
    end process;
    
--    a_next <= u_i;
--    b_next <= b_i;
--    m_next <= std_logic_vector(signed(a_reg) + signed(b_reg));
--    --m_next <= a_reg + b_reg;
--    c_next <= sec_i;
--    p_next <= std_logic_vector(signed(m_reg) * signed(c_reg(2*input_data_width-2 downto input_data_width-1)));
--    sec_o <= p_reg;
    sec_o <= std_logic_vector(signed(reg_s) + (signed(u_i) * signed(b_i)));
    
end Behavioral;