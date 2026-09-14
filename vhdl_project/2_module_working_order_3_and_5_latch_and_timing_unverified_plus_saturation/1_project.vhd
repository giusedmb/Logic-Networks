library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

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
end entity;

architecture project_arch of project_reti_logiche is
    component FSM is
    port(
        i_mem_data: in std_logic_vector (7 downto 0);
        i_k: in std_logic_vector(15 downto 0);
        i_out_elaborator: in std_logic_vector (7 downto 0);
        i_out_end: in std_logic;
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

        o_fd_out: out std_logic_vector(7 downto 0);
        o_fd_end: out std_logic
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
    
    signal sr_enable: std_logic;
    signal k:std_logic_vector(15 downto 0);
    signal coeff: std_logic_vector(111 downto 0);
    signal opmode: std_logic_vector(7 downto 0); 
    signal fd_out: std_logic_vector(7 downto 0);
    signal fd_end: std_logic;
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
        i_out_end => fd_end,
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

        o_fd_out => fd_out,
        o_fd_end => fd_end
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

        