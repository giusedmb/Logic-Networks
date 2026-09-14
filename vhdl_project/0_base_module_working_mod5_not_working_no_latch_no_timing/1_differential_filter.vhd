library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DIFFERENTIAL_FILTER is
    port(
        i_conteggio: in std_logic_vector(23 downto 0);
        i_data0: in std_logic_vector(7 downto 0);
        i_data1: in std_logic_vector(7 downto 0);
        i_data2: in std_logic_vector(7 downto 0);
        i_data3: in std_logic_vector(7 downto 0);
        i_data4: in std_logic_vector(7 downto 0);
        i_data5: in std_logic_vector(7 downto 0);
        i_data6: in std_logic_vector(7 downto 0);
        i_fdenable: in std_logic;
        i_opmode: in std_logic_vector(7 downto 0);
        i_coeff: in std_logic_vector(111 downto 0);
        i_k: in std_logic_vector(15 downto 0);
        i_clk, i_rst: in std_logic;

        o_fd_out: out std_logic_vector(7 downto 0);
        o_fd_end: out std_logic
    );
end entity;

architecture df_arch of DIFFERENTIAL_FILTER is
    type result_array is array (0 to 6) of signed(15 downto 0);
    signal provv_results : result_array;
    signal sum : signed(15 downto 0);
    signal normalized : signed(7 downto 0);

    function shift_and_correct(value: signed(15 downto 0); shift_val: integer) return signed is
        variable shifted_value : signed(15 downto 0);
    begin
        shifted_value := shift_right(value, shift_val);  -- Esegui lo shift
        if value < 0 then
            shifted_value := shifted_value + 1;  -- Correzione per numeri negativi
        end if;
        return shifted_value(7 downto 0);  -- Restituisci solo i primi 8 bit
    end function;

begin
        process(i_clk, i_rst)
        variable data_byte : signed(7 downto 0);
        variable coeff_byte : signed(7 downto 0);
    begin
        if (i_rst = '1') then
            sum <= (others => '0');
            normalized <= (others => '0');
            o_fd_end <= '0';
        elsif (i_clk'event and i_clk = '1') then
            if (i_fdenable = '1') then
                for i in 0 to 6 loop
                    case i is
                        when 0 => data_byte := signed(i_data0);
                        when 1 => data_byte := signed(i_data1);
                        when 2 => data_byte := signed(i_data2);
                        when 3 => data_byte := signed(i_data3);
                        when 4 => data_byte := signed(i_data4);
                        when 5 => data_byte := signed(i_data5);
                        when 6 => data_byte := signed(i_data6);
                        when others => data_byte := (others => '0');
                    end case;
                    
                    if (i_opmode(0) = '0') then
                        coeff_byte := signed(i_coeff(111 - (i*8) downto 104 - (i*8)));
                    else
                        coeff_byte := signed(i_coeff(55 - (i*8) downto 48 - (i*8)));
                    end if;
                    
                    provv_results(i) <= data_byte * coeff_byte;
                end loop;

                sum <= provv_results(0) + provv_results(1) + provv_results(2) +
                       provv_results(3) + provv_results(4) + provv_results(5) +
                       provv_results(6);
                
                -- Normalizzazione con shifting e correzione
                if (i_opmode(0) = '1') then
                    normalized <= shift_and_correct(sum, 4) + shift_and_correct(sum, 6) +
                                  shift_and_correct(sum, 8) + shift_and_correct(sum, 10) +
                                  shift_and_correct(sum, 12);
                else
                    normalized <= shift_and_correct(sum, 4) + shift_and_correct(sum, 6) +
                                  shift_and_correct(sum, 8) + shift_and_correct(sum, 10);
                end if;
                
                o_fd_out <= std_logic_vector(normalized);
                
                -- Controllo della condizione per il segnale di fine elaborazione
                if (unsigned(i_conteggio) = unsigned(i_k)+3) then
                    o_fd_end <= '1';
                end if;
                
            end if;  -- Chiusura dell'if (i_fdenable = '1')
        end if;  -- Chiusura dell'if (i_clk'event and i_clk = '1')
    end process;
end architecture;