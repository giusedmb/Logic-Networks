library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity buf is
    port(
        i_conteggio: in std_logic_vector(23 downto 0); 
        i_mem_data: in std_logic_vector(7 downto 0);   
        i_buf_enable: in std_logic; 
        i_k: in std_logic_vector(15 downto 0);
        i_clk, i_rst: in std_logic;
        
        o_data0: out std_logic_vector(7 downto 0);
        o_data1: out std_logic_vector(7 downto 0);
        o_data2: out std_logic_vector(7 downto 0);
        o_data3: out std_logic_vector(7 downto 0);
        o_data4: out std_logic_vector(7 downto 0);
        o_data5: out std_logic_vector(7 downto 0);
        o_data6: out std_logic_vector(7 downto 0)
    );
end entity;

architecture buf_arch of buf is
    type buffer_array is array (0 to 65535) of std_logic_vector(7 downto 0);
    signal buffer_mem : buffer_array; -- buffer di dimensione massima, ovvero la massima lunghezza esprimibile con due byte 

begin
    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            o_data0 <= (others => '0');
            o_data1 <= (others => '0'); 
            o_data2 <= (others => '0'); 
            o_data3 <= (others => '0'); 
            o_data4 <= (others => '0'); 
            o_data5 <= (others => '0'); 
            o_data6 <= (others => '0');   
        elsif rising_edge(i_clk) then
            if i_buf_enable = '1' then 
                buffer_mem(to_integer(unsigned(i_conteggio)) - 18) <= i_mem_data;
            end if;
             if to_integer(unsigned(i_conteggio)) >= 3 then
                    o_data0   <= buffer_mem(to_integer(unsigned(i_conteggio)) - 3);
                else
                    o_data0   <= (others => '0');
                end if;
                
                if to_integer(unsigned(i_conteggio)) >= 2 then
                    o_data1  <= buffer_mem(to_integer(unsigned(i_conteggio)) - 2);
                else
                    o_data1  <= (others => '0');
                end if;

                if to_integer(unsigned(i_conteggio)) >= 1 then
                    o_data2 <= buffer_mem(to_integer(unsigned(i_conteggio)) - 1);
                else
                   o_data2 <= (others => '0');
                end if;
                
                o_data3 <= std_logic_vector(unsigned(buffer_mem(to_integer(unsigned(i_conteggio))))); -- centro della finestra

                if (to_integer(unsigned(i_conteggio)) + 1) < to_integer(unsigned(i_k)) then
                o_data4 <= buffer_mem(to_integer(unsigned(i_conteggio)) + 1);
                else
                    o_data4 <= (others => '0');
                end if;

                if (to_integer(unsigned(i_conteggio)) + 2) < to_integer(unsigned(i_k)) then
                    o_data5 <= buffer_mem(to_integer(unsigned(i_conteggio)) + 2);
                else
                   o_data5 <= (others => '0');
                end if;

                if (to_integer(unsigned(i_conteggio)) + 3) < to_integer(unsigned(i_k)) then
                    o_data6 <= buffer_mem(to_integer(unsigned(i_conteggio)) + 3);
                else
                    o_data6 <= (others => '0');
                end if;
            end if;

        
               
    end process;
end architecture;