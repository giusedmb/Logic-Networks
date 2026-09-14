library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
entity COUNTER is
    port( 
        i_clk, i_rst, i_count_enable: in std_logic;
        o_conteggio: out std_logic_vector(23 downto 0)
    );
end entity COUNTER;

architecture COUNT_arch of COUNTER is
    signal provvcount: unsigned(23 downto 0); 
begin
    counting_function: process(i_clk,i_rst)
    begin
        if(i_rst='1') then
             provvcount <= (others => '0');
        elsif (i_clk'event and i_clk='1' and i_count_enable='1') then
            provvcount <= provvcount + 1;
        end if;
    end process;
    o_conteggio <= std_logic_vector(provvcount);
end architecture COUNT_arch;