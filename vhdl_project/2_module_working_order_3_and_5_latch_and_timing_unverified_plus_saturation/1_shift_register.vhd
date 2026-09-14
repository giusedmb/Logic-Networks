library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SHIFT_REG is
    port( 
        i_clk, i_rst, i_sr_enable: in std_logic;
        i_mem_data: in std_logic_vector(7 downto 0);
        o_k: out std_logic_vector(15 downto 0);
        o_coeff: out std_logic_vector(111 downto 0); 
        o_opmode: out std_logic_vector(7 downto 0)
    );
end entity SHIFT_REG;

architecture SR_arch of SHIFT_REG is
    signal internal_vector: std_logic_vector(135 downto 0); 
begin

    process (i_clk, i_rst)
    begin
        if (i_rst = '1') then
            internal_vector <= (others => '0');
        elsif (rising_edge(i_clk)) then
            if (i_sr_enable = '1') then
                internal_vector <= internal_vector(127 downto 0) & i_mem_data;
            end if;
        end if;
    end process;

    -- posso collegare direttamente così gli ingressi perchè sono sicuro che vengono utilizzati solo dopo la fase di riempimento,
    -- in quanto il tutto è gestito dalla fsm
    o_k <= internal_vector(135 downto 120);
    o_opmode <= internal_vector(119 downto 112);
    o_coeff <= internal_vector(111 downto 0);  

end architecture SR_arch;