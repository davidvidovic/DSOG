library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use work.util_pkg.all;

entity FIR is
    Generic ( WIDTH_IN        : natural := 16;
              WIDTH_OUT       : natural := 48;
              FILTER_ORDER    : natural := 5;
              N_MODULE        : natural := 11   
             );
    Port (  clk : in std_logic;
            rst : in std_logic;
            coef_addr : in STD_LOGIC_VECTOR(log2c(FILTER_ORDER)-1 downto 0);
            coef : in STD_LOGIC_VECTOR (WIDTH_IN-1 downto 0);
            we: in std_logic;
            
            -- AXI Slave
            --ain_data    : in std_logic_vector(WIDTH_IN-1 downto 0);
            --ain_ready   : out std_logic;
            --ain_valid   : in std_logic;
            --ain_last    : in std_logic;
            
            -- AXI Master
            --aout_data   : out std_logic_vector(WIDTH_OUT-1 downto 0);
            --aout_ready  : in std_logic;
            --aout_valid  : out std_logic;
            --aout_last   :out std_logic
            u_i : in STD_LOGIC_VECTOR (WIDTH_IN-1 downto 0);
            y_o : out STD_LOGIC_VECTOR (WIDTH_OUT-1 downto 0)
    );
end FIR;

architecture Behavioral of FIR is

type std_2d is array (FILTER_ORDER-1 downto 0) of std_logic_vector(WIDTH_OUT-1 downto 0);
signal mac_intern : std_2d := (others=>(others=>'0'));

type coef_t is array (FILTER_ORDER-1 downto 0) of std_logic_vector(WIDTH_IN-1 downto 0);
signal b : coef_t := (others=>(others=>'0'));

begin
    process(clk) 
    begin
        if(clk'event and clk = '1') then 
            if(we = '1') then
                b(to_integer(unsigned(coef_addr))) <= coef;
            end if;
        end if;
    end process;

    -- Instanciranje MAC-ova
    
    first_mac: 
    for n in 0 to N_MODULE-1 generate
        first_mac_n: entity work.MAC
        generic map (
                WIDTH_IN => WIDTH_IN,
                WIDTH_OUT => WIDTH_OUT
                )
        port map (
                clk     => clk,
                rst     => rst,
                a_i     => u_i,
                b_i     => b(FILTER_ORDER-1),
                c_i     => (others => '0'),
                y_o     => mac_intern(0)
                );                
    end generate;
    
    other_macs:
    for i in 1 to FILTER_ORDER generate
        other_n: for n in 0 to N_MODULE-1 generate
            other_macs_n: entity work.MAC
            generic map (
                    WIDTH_IN => WIDTH_IN,
                    WIDTH_OUT => WIDTH_OUT
                    )
            port map (
                    clk     => clk,
                    rst     => rst,
                    a_i     => u_i,
                    b_i     => b(FILTER_ORDER-i),
                    c_i     => mac_intern(i-1),
                    y_o     => mac_intern(i)
                    );
        end generate;
    end generate;
    
    y_o <= mac_intern(FILTER_ORDER);

end Behavioral;
