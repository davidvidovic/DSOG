library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.util_pkg.all;

entity fir_param is
    generic ( fir_ord : natural := 10;
            input_data_width : natural := 18;
            output_data_width : natural := 18;
            -- Intrducing param N = for N-modular redundancy
            n_param : natural := 4);
    Port ( clk_i : in STD_LOGIC;
           we_i : in STD_LOGIC;
           coef_addr_i : std_logic_vector(log2c(fir_ord+1)-1 downto 0);
           coef_i : in STD_LOGIC_VECTOR (input_data_width-1 downto 0);
           --data_i : in STD_LOGIC_VECTOR (input_data_width-1 downto 0);
           --data_o : out STD_LOGIC_VECTOR (output_data_width-1 downto 0)
           
           -- AXI Stream Slave (input interface)
           axi_data_in : in STD_LOGIC_VECTOR (input_data_width-1 downto 0);
           axi_valid_in : in STD_LOGIC;
           axi_last_in : in STD_LOGIC;
           axi_ready_in : out STD_LOGIC;
           
           -- AXI Stream Slave (input interface)
           axi_data_out : out STD_LOGIC_VECTOR (input_data_width-1 downto 0);
           axi_valid_out : out STD_LOGIC;
           axi_last_out : out STD_LOGIC;
           axi_ready_out : in STD_LOGIC
           
           );    
                
    attribute dont_touch : string;
    attribute dont_touch of fir_param : entity is "yes";
    
end fir_param;

architecture Behavioral of fir_param is
    
    type std_2d is array (fir_ord-1 downto 0) of std_logic_vector(2*input_data_width-1 downto 0);
    signal mac_inter : std_2d:=(others=>(others=>'0'));
    
    type coef_t is array (fir_ord-1 downto 0) of std_logic_vector(input_data_width-1 downto 0);
    signal b_s : coef_t := (others=>(others=>'0'));
    
    type fd_out_2d is array (n_param-1 downto 0) of std_logic;
    type fd_out_3d is array (fir_ord-1 downto 0) of fd_out_2d;
    signal fd_out : fd_out_3d := (others=>(others=>'0')); 
    
    type mac_out_2d is array (n_param-1 downto 0) of std_logic_vector(2*input_data_width-1 downto 0);
    type mac_out_3d is array (fir_ord-1 downto 0) of mac_out_2d;
    signal mac_out : mac_out_3d := (others=> (others=> (others=>'0'))); 
   
    type mux_in_2d is array (fir_ord-1 downto 0) of std_logic_vector(n_param*2*input_data_width-1 downto 0);
    signal mux_in : mux_in_2d := (others=>(others=>'0')); 
    
    type sel_in_2d is array (fir_ord-1 downto 0) of std_logic_vector(n_param-1 downto 0);
    signal sel_in : sel_in_2d := (others=>(others=>'0')); 
    
    -- niz za izlaze muxova
    type mux_out_2d is array (fir_ord-1 downto 0) of std_logic_vector(2*input_data_width-1 downto 0);
    signal mux_out_0, mux_out_1 : mux_out_2d := (others=>(others=>'0')); 
    
    type comp_error_2d is array (fir_ord-1 downto 0) of std_logic;
    signal comp_error : comp_error_2d := (others => '0');
    
    type u_type is array (fir_ord*2-1 downto 0) of std_logic_vector(input_data_width-1 downto 0);
    signal u_reg : u_type := (others=>(others=>'0')); 
    
    type valid_type is array (fir_ord*2-1+3 downto 0) of std_logic;
    signal valid_reg : valid_type := (others=>'0');
    
    type comp_type is array (fir_ord*3-1-3 downto 0) of std_logic;
    signal comp_reg : comp_type := (others=>'0');
    
    
    signal cnt_coef_reg : std_logic_vector(log2c(fir_ord)-1 downto 0) := (others => '0');
    signal cnt_init_clks : std_logic_vector(log2c(fir_ord*2+3)-1 downto 0) := (others => '0');

                                                               
begin
    
    process(clk_i)
    begin
        if(clk_i'event and clk_i = '1')then
            if we_i = '1' then
                b_s(to_integer(unsigned(coef_addr_i))) <= coef_i;
                
                if(cnt_coef_reg < std_logic_vector(to_unsigned(fir_ord, log2c(fir_ord)))) then   
                    cnt_coef_reg <= std_logic_vector(unsigned(cnt_coef_reg) + 1);
                else
                    cnt_coef_reg <= cnt_coef_reg;
                end if;
                
                -- count fir_ord clocks at the begging and only then say output data is valid
                if((axi_valid_in = '1') and (cnt_coef_reg = std_logic_vector(to_unsigned(fir_ord, log2c(fir_ord))))) then
                    if(cnt_init_clks < std_logic_vector(to_unsigned(fir_ord*2+3, log2c(fir_ord*2+3)))) then
                        cnt_init_clks <= std_logic_vector(unsigned(cnt_init_clks) + 1);
                    else
                        cnt_init_clks <= cnt_init_clks;
                    end if;
                else
                    cnt_init_clks <= cnt_init_clks;
                end if;
                
                
            end if;
        end if;
    end process;  

    process(cnt_coef_reg)
    begin
        if(unsigned(cnt_coef_reg) = fir_ord) then
            axi_ready_in <= '1';
        else
            axi_ready_in <= '0';
        end if;
    end process;
    
    -- Pipeline input data and valid signal
    -- Input data is propageted through 40 registers
    -- Valid signal is the same, but is propageted through 3 more stages because MAC is 3 pipeline stages deep
    -- (so it can propaget along with the signal thorugh last MAC)
    process(clk_i)
    begin
        if(clk_i'event and clk_i = '1')then
            u_reg(0) <= axi_data_in;
            valid_reg(0) <= axi_valid_in;
            u_regs: for i in 1 to 2*fir_ord-1 loop
                u_reg(i) <= u_reg(i-1);  
            end loop;
            
            v_regs: for i in 1 to 2*fir_ord-1+3 loop
                    valid_reg(i) <= valid_reg(i-1);
            end loop;
            
            comp_reg(0) <= '1';
            comp_regs: for i in 1 to 3*fir_ord-1-3 loop
                if(i mod 3 = 0) then
                    comp_reg(i) <= comp_reg(i-1) and comp_error(i/3);
                else
                    comp_reg(i) <= comp_reg(i-1);
                end if;
            end loop;
            
        end if;
    end process;

    axi_valid_out <= valid_reg(2*fir_ord-1+3) and comp_reg(fir_ord*3-1-3);
    
    -- ######################################################


    zero_mac_master: for n in 0 to n_param-1 generate
        zero_mac: entity work.mac(behavioral)
            generic map(input_data_width=>input_data_width)
            port map(clk_i=>clk_i,
                     u_i=>u_reg(0),
                     b_i=>b_s(fir_ord-1),
                     sec_i=>(others=>'0'),
                     sec_o=>mac_out(0)(n),
                     axi_valid_in=>valid_reg(0)
           );
                     
        FD: entity work.fault_detection
            generic map(input_data_width=>input_data_width)
            port map(clk_i=>clk_i,
                     in1=>mac_out(0)(n),
                     data_i=>u_reg(0),
                     b_i=>b_s(fir_ord-1),
                     sec_i=>(others=>'0'),
                     comp=>fd_out(0)(n),
                     axi_valid_in=>valid_reg(0)
            );
        mux_in(0)((n+1)*2*input_data_width - 1 downto n*2*input_data_width) <= mac_out(0)(n);
        sel_in(0)(n) <= fd_out(0)(n);
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
                        error_signal => comp_error(0),
                        clk=>clk_i);
                        
    
    mac_inter(0) <= mux_out_0(0);
    
    -- ######################################################

    other_sections:
    for i in 1 to fir_ord-1 generate
        other_macs_master: for n in 0 to n_param-1 generate
                other_macs: entity work.mac(behavioral)
                generic map(input_data_width=>input_data_width)
                port map(clk_i=>clk_i,
                         u_i=>u_reg(i*2),
                         b_i=>b_s(fir_ord-i-1),
                         sec_i=>mac_inter(i-1),
                         sec_o=>mac_out(i)(n),
                         axi_valid_in=>valid_reg(i*2)
                         );
                         
                 other_FD: entity work.fault_detection
                    generic map(input_data_width=>input_data_width)
                    port map(clk_i=>clk_i,
                             in1=>mac_out(i)(n),
                             data_i=>u_reg(i*2),
                             b_i=>b_s(fir_ord-i-1),
                             sec_i=>mac_inter(i-1),
                             comp=>fd_out(i)(n),
                             axi_valid_in=>valid_reg(i*2)
                    );
                    
                    mux_in(i)((n+1)*2*input_data_width-1 downto n*2*input_data_width) <= mac_out(i)(n);
                    sel_in(i)(n) <= fd_out(i)(n);
        end generate;
        
        switch_i: entity work.n_to_2_switch
            generic map (input_data_width=>input_data_width,
                        n_param => n_param)
            port map (  data_in => mux_in(i),
                        sel => sel_in(i),
                        error_signal => comp_error(i),
                        data_out_0 => mux_out_0(i),
                        data_out_1 => mux_out_1(i)
            );
     
         comp_i: entity work.comp_unit
                generic map(input_data_width=>input_data_width)
                port map (  in_0 => mux_out_0(i),
                            in_1 => mux_out_1(i),
                            error_signal => comp_error(i),
                            clk=>clk_i);
                            
        
        mac_inter(i) <= mux_out_0(i);
    end generate;
    
    
    -- ######################################################
    
    axi_last_out <= '0';
    
    process(clk_i)
    begin
        if(clk_i'event and clk_i='1')then
            if(axi_ready_out = '1') then
                axi_data_out <= mac_inter(fir_ord-1)(2*input_data_width-2 downto 2*input_data_width-output_data_width-1);
            else
                axi_data_out <= (others => '0');
            end if;
        end if;
    end process;
    
    
end Behavioral;