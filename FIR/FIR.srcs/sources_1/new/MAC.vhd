library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity MAC is
    Generic ( WIDTH_IN        : natural := 16;
              WIDTH_OUT       : natural := 48
              );
    Port ( clk : in std_logic;
           rst : in std_logic;
           a_i : in std_logic_vector(WIDTH_IN-1 downto 0); 
           b_i : in std_logic_vector(WIDTH_IN-1 downto 0);
           c_i : in std_logic_vector(WIDTH_OUT-1 downto 0);
           y_o : out std_logic_vector(WIDTH_OUT-1 downto 0)
          );
end MAC;

architecture Behavioral of MAC is

-- Ulazni registri, prva faza pipelinea
signal a_reg, a_next, b_reg, b_next : std_logic_vector(WIDTH_IN-1 downto 0) := (others=>'0'); 

-- Izlaz mnozaca, druga faza pipelinea
signal m_reg, m_next : std_logic_vector(2*WIDTH_IN-1 downto 0) := (others=>'0');

-- Izlaz ALU, treca faza pipelinea (ulazi ALU su 48bitni, izlaz 49bitan) ??????
signal p_reg, p_next : std_logic_vector(WIDTH_OUT-1 downto 0) := (others=>'0');


begin
process(clk) begin
    if(rising_edge(clk)) then
        if(rst = '1') then
            a_reg <= (others=>'0');
            b_reg <= (others=>'0');
            m_reg <= (others=>'0');
            p_reg <= (others=>'0');
        else
            a_reg <= a_next;
            b_reg <= b_next;
            m_reg <= m_next;
            p_reg <= p_next;
        end if;
    end if;
end process;

a_next <= a_i;
b_next <= b_i;

-- Mnozac, izlaz je WIDTH_IN*2
m_next <= std_logic_vector(signed(a_reg) * signed(b_reg));

-- ALU, oba ulaza su WIDTH_OUT, izlaz je WIDTH_OUT+1 ???????
p_next <= std_logic_vector(RESIZE(signed(m_reg), WIDTH_OUT) + signed(c_i));

-- Izlaz MACa je WIDTH_OUT
y_o <= p_reg;

end Behavioral;
