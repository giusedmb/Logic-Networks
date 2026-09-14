library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FSM is
    port(
        i_mem_data: in std_logic_vector (7 downto 0);
        i_k: in std_logic_vector(15 downto 0);
        i_out_elaborator: in std_logic_vector (7 downto 0);
        i_start: in std_logic;
        i_add: in std_logic_vector (15 downto 0);
        i_clk: in std_logic;
        i_rst: in std_logic;
        i_conteggio: in std_logic_vector(23 downto 0);
        
        o_rstcounter: out std_logic;
        o_count_enable: out std_logic;
        o_sr_enable: out std_logic;
        o_mem_addr: out std_logic_vector(15 downto 0); 
        o_mem_data: out std_logic_vector(7 downto 0);
        o_mem_we: out std_logic;
        o_mem_en: out std_logic;
        o_done: out std_logic;
        o_fd_enable: out std_logic;
        o_buf_enable: out std_logic
    );
end entity;

architecture fsm_arch of FSM is
    type S is (S0,S1,S2,S3,S4,S5,S6);
    signal curr_state: S;

begin
    delta_function: process (i_clk, i_rst)
    begin
        if(i_rst = '1') then
            curr_state <= S0;
        elsif(i_clk'event and i_clk = '1') then
            if(curr_state= S0 and i_start= '1' and i_rst = '0') then
                curr_state <= S1;
            elsif(curr_state =S0 and i_start='0') then
                curr_state <= S0;
            elsif(curr_state = S1 and to_integer(unsigned(i_conteggio)) = 17) then
                curr_state <= S2;
            elsif(curr_state = S2 and to_integer(unsigned(i_conteggio)) = 17 + to_integer(unsigned(i_k))) then
                curr_state <= S3;
            elsif(curr_state = S3) then
                curr_state <= S4;
            elsif(curr_state = S4) then
                curr_state <= S5;
            elsif(curr_state = S5 and to_integer(unsigned(i_conteggio)) < to_integer(unsigned(i_k)+3)) then
                curr_state <= S4;
            elsif(curr_state = S5 and to_integer(unsigned(i_conteggio)) = to_integer(unsigned(i_k)+3)) then
                curr_state <= S6;
            elsif(curr_state = S6 and i_start = '0') then
                curr_state <= S0;
            end if;
        end if;
    end process;

    with curr_state select
        o_mem_addr <= 
                (others => '0') when S0,
                std_logic_vector(to_unsigned(to_integer(unsigned(i_add)) + to_integer(unsigned(i_conteggio)), 16)) when S1,
                std_logic_vector(to_unsigned(to_integer(unsigned(i_add)) + to_integer(unsigned(i_conteggio)), 16)) when S2,
                (others => '0') when S3,
                (others => '0') when S4,
                std_logic_vector(to_unsigned(to_integer(unsigned(i_add)) + 13 + to_integer(unsigned(i_conteggio)) + to_integer(unsigned(i_k)), 16)) when S5,
                (others => '0') when S6;

    with curr_state select
        o_mem_en <=
                '0' when S0,
                '1' when S1,
                '1' when S2,
                '0' when S3,
                '0' when S4,
                '1' when S5,
                '0' when S6;

    o_mem_we <= '1' when (curr_state = S5 and to_integer(unsigned(i_conteggio)) >= 4) else '0';
                
    with curr_state select
        o_mem_data <=
                (others => '0') when S0,
                (others => '0') when S1,
                (others => '0') when S2,
                (others => '0') when S3,
                (others => '0') when S4,
                i_out_elaborator when S5,
                (others => '0') when S6;
                
    with curr_state select
        o_sr_enable <=
                '0' when S0,
                '1' when S1,
                '0' when S2,
                '0' when S3,
                '0' when S4,
                '0' when S5,
                '0' when S6;
                
    with curr_state select
        o_count_enable <=
                '0' when S0,
                '1' when S1,
                '1' when S2,
                '0' when S3,
                '0' when S4,
                '1' when S5,
                '0' when S6;
                
    with curr_state select
        o_done <=
                '0' when S0,
                '0' when S1,
                '0' when S2,
                '0' when S3,
                '0' when S4,
                '0' when S5,
                '1' when S6;
        
    with curr_state select
        o_rstcounter <=
                '1' when S0,
                '0' when S1,
                '0' when S2,
                '1' when S3,
                '0' when S4,
                '0' when S5,
                '0' when S6;

    with curr_state select
        o_fd_enable <=
                '0' when S0,
                '0' when S1,
                '0' when S2,
                '0' when S3,
                '1' when S4,
                '0' when S5,
                '0' when S6;

    with curr_state select
        o_buf_enable <=
                '0' when S0,
                '0' when S1,
                '1' when S2,
                '0' when S3,
                '0' when S4,
                '0' when S5,
                '0' when S6;

end architecture;