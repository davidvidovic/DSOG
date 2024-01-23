library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.util_pkg.all;

entity fir_param is
    generic ( fir_ord : natural := 20;
            input_data_width : natural := 24;
            output_data_width : natural := 24;
            -- Intrducing param N = for N-modular redundancy
            n_param : natural := 8);
    Port ( clk_i : in STD_LOGIC;
           we_i : in STD_LOGIC;
           coef_addr_i : std_logic_vector(log2c(fir_ord+1)-1 downto 0);
           coef_i : in STD_LOGIC_VECTOR (input_data_width-1 downto 0);
           data_i : in STD_LOGIC_VECTOR (input_data_width-1 downto 0);
           data_o : out STD_LOGIC_VECTOR (output_data_width-1 downto 0));
end fir_param;

architecture Behavioral of fir_param is
    type std_2d is array (fir_ord downto 0) of std_logic_vector(2*input_data_width-1 downto 0);
    signal mac_inter : std_2d:=(others=>(others=>'0'));
    type coef_t is array (fir_ord downto 0) of std_logic_vector(input_data_width-1 downto 0);
    signal b_s : coef_t := (others=>(others=>'0')); 
    
    type fd_out_2d is array (n_param downto 0) of std_logic;
    type fd_out_3d is array (fir_ord downto 0) of fd_out_2d;
    signal fd_out : fd_out_3d := (others=>(others=>'0')); 
    
    type mac_out_2d is array (n_param downto 0) of std_logic_vector(2*input_data_width-1 downto 0);
    type mac_out_3d is array (fir_ord downto 0) of mac_out_2d;
    signal mac_out : mac_out_3d := (others=> (others=> (others=>'0'))); 
   
    type mux_in_2d is array (fir_ord downto 0) of std_logic_vector(n_param*2*input_data_width-1 downto 0);
    signal mux_in : mux_in_2d := (others=>(others=>'0')); 
    
    type sel_in_2d is array (fir_ord downto 0) of std_logic_vector(n_param-1 downto 0);
    signal sel_in : sel_in_2d := (others=>(others=>'0')); 
    
    -- niz za izlaze muxova
    type mux_out_2d is array (fir_ord downto 0) of std_logic_vector(2*input_data_width-1 downto 0);
    signal mux_out_0, mux_out_1 : mux_out_2d := (others=>(others=>'0')); 
    
   
    type comp_error_2d is array (fir_ord downto 0) of std_logic;
    signal comp_error : comp_error_2d := (others => '0');
                                                               
begin

    process(clk_i)
    begin
        if(clk_i'event and clk_i = '1')then
            if we_i = '1' then
                b_s(to_integer(unsigned(coef_addr_i))) <= coef_i;
            end if;
        end if;
    end process;
    
    zero_mac_master: for n in 0 to n_param generate
        zero_mac: entity work.mac(behavioral)
            generic map(input_data_width=>input_data_width)
            port map(clk_i=>clk_i,
                     u_i=>data_i,
                     b_i=>b_s(fir_ord),
                     sec_i=>(others=>'0'),
                     sec_o=>mac_out(0)(n)
           );
                     
        FD: entity work.fault_detection
            generic map(input_data_width=>input_data_width)
            port map(clk_i=>clk_i,
                     in1=>mac_out(0)(n),
                     data_i=>data_i,
                     b_i=>b_s(fir_ord),
                     sec_i=>(others=>'0'),
                     comp=>fd_out(0)(n)
            );
    end generate;      
    
    concatenate_mac_out: for j in 0 to n_param-1 generate
        mux_in(0)((j+1)*2*input_data_width - 1 downto j*2*input_data_width) <= mac_out(0)(j);
        sel_in(0)(j) <= fd_out(0)(j);
    end generate;
    
    switch_0: entity work.n_to_2_switch
            generic map (input_data_width=>input_data_width,
                        n_param => n_param)
            port map (  data_in => mux_in(0),
                        sel => sel_in(0),
                        error_signal => comp_error(0),
                        data_out_0 => mux_out_0(0),
                        data_out_1 => mux_out_1(0)
            );
     
     comp_0: entity work.comp_unit
            generic map(input_data_width=>input_data_width)
            port map (  in_0 => mux_out_0(0),
                        in_1 => mux_out_1(0),
                        error_signal => comp_error(0));
                        
    
    mac_inter(0) <= mux_out_0(0);
    
    -- ######################################################

    other_sections:
    for i in 1 to fir_ord generate
        --other_macs_master: for m in 1 to n_param generate
                other_macs: entity work.mac(behavioral)
                generic map(input_data_width=>input_data_width)
                port map(clk_i=>clk_i,
                         u_i=>data_i,
                         b_i=>b_s(fir_ord-i),
                         sec_i=>mac_inter(i-1),
                         sec_o=>mac_inter(i));
        --end generate;
    end generate;
    
    --switches:
    
    
    process(clk_i)
    begin
        if(clk_i'event and clk_i='1')then
            data_o <= mac_inter(fir_ord)(2*input_data_width-2 downto 2*input_data_width-output_data_width-1);
        end if;
    end process;
    
    
end Behavioral;