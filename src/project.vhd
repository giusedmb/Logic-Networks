--10856752_10848505

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 


-- PROGETTO
--interfaccia da specifica
entity project_reti_logiche is
    port(
        i_clk: in std_logic;
        i_rst: in std_logic;
        i_start: in std_logic;
        i_add: in std_logic_vector(15 downto 0);

        o_done: out std_logic;

        o_mem_addr: out std_logic_vector(15 downto 0);
        i_mem_data: in std_logic_vector(7 downto 0);
        o_mem_data: out std_logic_vector(7 downto 0);
        o_mem_we: out std_logic;
        o_mem_en: out std_logic
    );
end project_reti_logiche;

architecture project_arch of project_reti_logiche is
    -- definizione delle componenti
    component FSM is
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
    end component FSM;

    component COUNTER is
        port( 
        i_clk, i_rst, i_count_enable: in std_logic;
        o_conteggio: out std_logic_vector(23 downto 0)
        );
    end component COUNTER;

    component DIFFERENTIAL_FILTER is
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

        o_fd_out: out std_logic_vector(7 downto 0)
        );
    end component;

    component buf is
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
    end component;

    component SHIFT_REG is
        port( 
            i_clk, i_rst, i_sr_enable: in std_logic;
            i_mem_data: in std_logic_vector(7 downto 0);
            o_k: out std_logic_vector(15 downto 0);
            o_coeff: out std_logic_vector(111 downto 0); 
            o_opmode: out std_logic_vector(7 downto 0)
        );
    end component SHIFT_REG;
    
    -- segnali interni tra componenti dell'architettura
    signal sr_enable: std_logic;
    signal k:std_logic_vector(15 downto 0);
    signal coeff: std_logic_vector(111 downto 0);
    signal opmode: std_logic_vector(7 downto 0); 
    signal fd_out: std_logic_vector(7 downto 0);
    signal fdenable: std_logic; 
    signal buf_enable: std_logic;
    signal rstcounter: std_logic;
    signal conteggio: std_logic_vector(23 downto 0); 
    signal count_enable: std_logic;
    signal data0: std_logic_vector(7 downto 0);
    signal data1: std_logic_vector(7 downto 0);
    signal data2: std_logic_vector(7 downto 0);
    signal data3: std_logic_vector(7 downto 0);
    signal data4: std_logic_vector(7 downto 0);
    signal data5: std_logic_vector(7 downto 0);
    signal data6: std_logic_vector(7 downto 0);

    begin 
    -- mappatura dei segnali ai componenti
    FP_COUNTER: COUNTER port map(
        i_clk => i_clk,
        i_rst => rstcounter,
        i_count_enable => count_enable,
        o_conteggio => conteggio
    );
    
    FP_FSM: FSM port map(
        i_mem_data =>  i_mem_data,
        i_k => k,
        i_out_elaborator =>  fd_out,
        i_start => i_start,
        i_add =>  i_add,
        i_clk => i_clk,
        i_rst => i_rst,
        i_conteggio => conteggio,
        
        o_rstcounter =>  rstcounter,
        o_count_enable =>  count_enable,
        o_sr_enable => sr_enable,
        o_mem_addr =>  o_mem_addr,
        o_mem_data =>  o_mem_data,
        o_mem_we => o_mem_we,
        o_mem_en => o_mem_en,
        o_done => o_done,
        o_fd_enable => fdenable,
        o_buf_enable =>  buf_enable
    );

    FP_FD: DIFFERENTIAL_FILTER port map(
        i_conteggio => conteggio,
        i_data0 => data0,
        i_data1 => data1,
        i_data2 => data2,
        i_data3 => data3,
        i_data4 => data4,
        i_data5 => data5,
        i_data6 => data6,
        i_fdenable => fdenable,
        i_opmode => opmode,
        i_coeff => coeff,
        i_k => k,
        i_clk => i_clk,
        i_rst => i_rst,
        o_fd_out => fd_out
    );

    FP_BUF: buf port map(
        i_conteggio => conteggio,
        i_mem_data => i_mem_data, 
        i_buf_enable => buf_enable,
        i_k => k,
        i_clk => i_clk,
        i_rst => i_rst,
        o_data0 => data0,
        o_data1 => data1,
        o_data2 => data2,
        o_data3 => data3,
        o_data4 => data4,
        o_data5 => data5,
        o_data6 => data6
    );

    FP_SR: SHIFT_REG port map( 
        i_clk => i_clk,
        i_rst => i_rst,
        i_sr_enable => sr_enable,
        i_mem_data => i_mem_data,
        o_k => k,
        o_coeff => coeff,
        o_opmode => opmode
    );


end architecture;


-- SHIFT REGISTER
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

-- FSM
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

    -- FUNZIONE DELLA VARIAZIONE DEGLI STATI
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

    -- GESTIONE DELLE USCITE
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

    o_mem_we <= '1' when (curr_state = S5 and to_integer(unsigned(i_conteggio)) >= 4) else '0'; -- la condizione sul conteggio è imposta per evitare una sovrascrittura della memoria dato che lo stato di scrittura parte in anticipo (vedi tabella degli stati)
                
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

-- DIFFERENTIAL FILTER
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
    type result_array is array (0 to 6) of signed(23 downto 0);
    signal provv_results : result_array;
    signal sum : signed(23 downto 0);
    signal normalized : signed(7 downto 0);

    function shift_and_correct(value: signed(23 downto 0); shift_val: integer) return signed is
    variable shifted_value : signed(23 downto 0);
    begin
        shifted_value := shift_right(value, shift_val);  --esegui lo shift
        if value < 0 then
        shifted_value := shifted_value + 1;  --correzione per i numeri negativi
        end if;
        return resize(shifted_value, 16);  --ridimensionamento a 16 bit prima di restituire
    end function;

begin
    process(i_clk, i_rst)
        variable data_byte : signed(7 downto 0);
        variable coeff_byte : signed(7 downto 0);
        variable temp_result : signed(15 downto 0);
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
                    
                    --discriminazione del filtro da applicare
                    if (i_opmode(0) = '0') then
                        coeff_byte := signed(i_coeff(111 - (i*8) downto 104 - (i*8)));
                    else
                        coeff_byte := signed(i_coeff(55 - (i*8) downto 48 - (i*8)));
                    end if;
                    
                    provv_results(i) <= resize(data_byte * coeff_byte, 24);
                end loop;

                --somma dei risultati ottenuti moltiplicando per i coefficienti
                sum <= provv_results(0) + provv_results(1) + provv_results(2) +
                       provv_results(3) + provv_results(4) + provv_results(5) +
                       provv_results(6);
                
                -- normalizzazione con shifting e correzione
                if (i_opmode(0) = '1') then
                    -- filtro di ordine 5: normalizzazione con 1/64 + 1/1024
                    temp_result := shift_and_correct(sum, 6) + shift_and_correct(sum, 10);
                else
                    -- filtro di ordine 3: normalizzazione con 1/16 + 1/64 + 1/256 + 1/1024
                    temp_result := shift_and_correct(sum, 4) + shift_and_correct(sum, 6) +
                                   shift_and_correct(sum, 8) + shift_and_correct(sum, 10);
                end if;
                
                --saturazione ai limiti di -128 e 127
                if temp_result > 127 then
                    normalized <= to_signed(127, 8);
                elsif temp_result < -128 then
                    normalized <= to_signed(-128, 8);
                else
                    normalized <= temp_result(7 downto 0);
                end if;
                
                o_fd_out <= std_logic_vector(normalized);
                
                if (unsigned(i_conteggio) = unsigned(i_k)+3) then
                    o_fd_end <= '1';
                end if;
            end if;  
        end if;  
    end process;
end architecture;

-- COUNTER
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


-- BUFFER
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
            -- gestione riempimento finestra di 7 byte in uscita con gli 0 opportuni
             if to_integer(unsigned(i_conteggio)) >= 3 then
                    o_data0<= buffer_mem(to_integer(unsigned(i_conteggio)) - 3);
                else
                    o_data0<= (others => '0');
                end if;
                
                if to_integer(unsigned(i_conteggio)) >= 2 then
                    o_data1<= buffer_mem(to_integer(unsigned(i_conteggio)) - 2);
                else
                    o_data1<= (others => '0');
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