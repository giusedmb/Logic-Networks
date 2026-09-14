library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb2425 is
end tb2425;

architecture project_tb_arch of tb2425 is

    constant CLOCK_PERIOD : time := 20 ns;

    -- Signals to be connected to the component
    signal tb_clk : std_logic := '0';
    signal tb_rst, tb_start, tb_done : std_logic;
    signal tb_add : std_logic_vector(15 downto 0);

    -- Signals for the memory
    signal tb_o_mem_addr, exc_o_mem_addr, init_o_mem_addr : std_logic_vector(15 downto 0);
    signal tb_o_mem_data, exc_o_mem_data, init_o_mem_data : std_logic_vector(7 downto 0);
    signal tb_i_mem_data : std_logic_vector(7 downto 0);
    signal tb_o_mem_we, tb_o_mem_en, exc_o_mem_we, exc_o_mem_en, init_o_mem_we, init_o_mem_en : std_logic;

    -- Memory
    type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);
    signal RAM : ram_type := (OTHERS => "00000000");

    -- Scenario
    type scenario_config_type is array (0 to 16) of integer;
    constant SCENARIO_LENGTH : integer := 7;
    constant SCENARIO_LENGTH_STL : std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(SCENARIO_LENGTH, 16));
    type scenario_type is array (0 to SCENARIO_LENGTH-1) of integer;

    -- Scenario configurations
    signal scenario_config : scenario_config_type := (
        to_integer(unsigned(SCENARIO_LENGTH_STL(15 downto 8))),   -- K1
        to_integer(unsigned(SCENARIO_LENGTH_STL(7 downto 0))),    -- K2
        0,                                                       -- S
        0, -1, 8, 0, -8, 1, 0, 1, -9, 45, 0, -45, 9, -1          -- C1-C14
    );
    signal scenario_config1 : scenario_config_type := (
        to_integer(unsigned(SCENARIO_LENGTH_STL(15 downto 8))),   -- K1
        to_integer(unsigned(SCENARIO_LENGTH_STL(7 downto 0))),    -- K2
        1,                                                       -- S
        0, -1, 8, 0, -8, 1, 0, 1, -9, 45, 0, -45, 9, -1          -- C1-C14
    );
    signal scenario_config2 : scenario_config_type := (
        to_integer(unsigned(SCENARIO_LENGTH_STL(15 downto 8))),   -- K1
        to_integer(unsigned(SCENARIO_LENGTH_STL(7 downto 0))),    -- K2
        1,                                                       -- S
        0, -1, 8, 0, -8, 1, 0, 1, -9, 45, 0, -45, 9, -1          -- C1-C14
    );

    -- Scenario input and output data
    signal scenario_input : scenario_type := (51, 68, -26, 25, 64, 14, -125);
    signal scenario_input1 : scenario_type := (51, 68, -26, 25, 64, 14, -125);
    signal scenario_input2 : scenario_type := (13, 14, 15, 16, 17, 18, -127);
    signal scenario_output : scenario_type := (-45, 52, 28, -63, 0, 121, 3);
    signal scenario_output1 : scenario_type := (-54, 59, 32, -72, -5, 127, 1);
    signal scenario_output2 : scenario_type := (-7, 0, -1, 1, -22, 105, 10);

    signal memory_control : std_logic := '0';      -- A signal to decide when the memory is accessed
                                                  -- by the testbench or by the project

    constant SCENARIO_ADDRESS1 : integer := 1234;  -- per il secondo giro
    constant SCENARIO_ADDRESS2 : integer := 1234;  -- per il terzo giro
    constant SCENARIO_ADDRESS : integer := 1234;   -- This value may arbitrarily change

    component project_reti_logiche is
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_start : in std_logic;
            i_add : in std_logic_vector(15 downto 0);

            o_done : out std_logic;

            o_mem_addr : out std_logic_vector(15 downto 0);
            i_mem_data : in std_logic_vector(7 downto 0);
            o_mem_data : out std_logic_vector(7 downto 0);
            o_mem_we   : out std_logic;
            o_mem_en   : out std_logic
        );
    end component project_reti_logiche;

begin
    UUT : project_reti_logiche
    port map(
        i_clk => tb_clk,
        i_rst => tb_rst,
        i_start => tb_start,
        i_add => tb_add,

        o_done => tb_done,

        o_mem_addr => exc_o_mem_addr,
        i_mem_data => tb_i_mem_data,
        o_mem_data => exc_o_mem_data,
        o_mem_we => exc_o_mem_we,
        o_mem_en => exc_o_mem_en
    );

    -- Clock generation
    tb_clk <= not tb_clk after CLOCK_PERIOD/2;

    -- Process related to the memory
    MEM : process (tb_clk)
    begin
        if tb_clk'event and tb_clk = '1' then
            if tb_o_mem_en = '1' then
                if tb_o_mem_we = '1' then
                    RAM(to_integer(unsigned(tb_o_mem_addr))) <= tb_o_mem_data after 1 ns;
                    tb_i_mem_data <= tb_o_mem_data after 1 ns;
                else
                    tb_i_mem_data <= RAM(to_integer(unsigned(tb_o_mem_addr))) after 1 ns;
                end if;
            end if;
        end if;
    end process;

    memory_signal_swapper : process(memory_control, init_o_mem_addr, init_o_mem_data,
                                  init_o_mem_en, init_o_mem_we, exc_o_mem_addr,
                                  exc_o_mem_data, exc_o_mem_en, exc_o_mem_we)
    begin
        -- This is necessary for the testbench to work: we swap the memory
        -- signals from the component to the testbench when needed.

        tb_o_mem_addr <= init_o_mem_addr;
        tb_o_mem_data <= init_o_mem_data;
        tb_o_mem_en <= init_o_mem_en;
        tb_o_mem_we <= init_o_mem_we;

        if memory_control = '1' then
            tb_o_mem_addr <= exc_o_mem_addr;
            tb_o_mem_data <= exc_o_mem_data;
            tb_o_mem_en <= exc_o_mem_en;
            tb_o_mem_we <= exc_o_mem_we;
        end if;
    end process;

    -- This process provides the correct scenario on the signal controlled by the TB
    create_scenario : process
    begin
        -- First scenario initialization
        wait for 50 ns;
        tb_start <= '0';
        tb_add <= (others => '0');
        tb_rst <= '1';
        wait for 50 ns;
        tb_rst <= '0';
        memory_control <= '0';
        wait until falling_edge(tb_clk);

        -- Load first scenario configuration
        for i in 0 to 16 loop
            init_o_mem_addr <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS+i, 16));
            init_o_mem_data <= std_logic_vector(to_unsigned(scenario_config(i), 8));
            init_o_mem_en <= '1';
            init_o_mem_we <= '1';
            wait until rising_edge(tb_clk);   
        end loop;

        -- Load first scenario input data
        for i in 0 to SCENARIO_LENGTH-1 loop
            init_o_mem_addr <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS+17+i, 16));
            init_o_mem_data <= std_logic_vector(to_unsigned(scenario_input(i), 8));
            init_o_mem_en <= '1';
            init_o_mem_we <= '1';
            wait until rising_edge(tb_clk);   
        end loop;

        wait until falling_edge(tb_clk);
        memory_control <= '1';
        tb_add <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS, 16));
        tb_start <= '1';

        -- Wait for first scenario completion
        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;

        -- Reset signals for second scenario
        wait for CLOCK_PERIOD;
        tb_start <= '0';
        wait for CLOCK_PERIOD;

        -- Second scenario initialization
        memory_control <= '0';
        wait for CLOCK_PERIOD;

        -- Load second scenario configuration
        for i in 0 to 16 loop
            init_o_mem_addr <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS1+i, 16));
            init_o_mem_data <= std_logic_vector(to_unsigned(scenario_config1(i), 8));
            init_o_mem_en <= '1';
            init_o_mem_we <= '1';
            wait until rising_edge(tb_clk);   
        end loop;

        -- Load second scenario input data
        for i in 0 to SCENARIO_LENGTH-1 loop
            init_o_mem_addr <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS1+17+i, 16));
            init_o_mem_data <= std_logic_vector(to_unsigned(scenario_input1(i), 8));
            init_o_mem_en <= '1';
            init_o_mem_we <= '1';
            wait until rising_edge(tb_clk);   
        end loop;

        wait until falling_edge(tb_clk);
        memory_control <= '1';
        tb_add <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS1, 16));
        tb_start <= '1';

        -- Wait for second scenario completion
        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;

        -- Reset signals for third scenario
        wait for CLOCK_PERIOD;
        tb_start <= '0';
        wait for CLOCK_PERIOD;

        -- Third scenario initialization
        memory_control <= '0';
        wait for CLOCK_PERIOD;

        -- Load third scenario configuration
        for i in 0 to 16 loop
            init_o_mem_addr <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS2+i, 16));
            init_o_mem_data <= std_logic_vector(to_unsigned(scenario_config2(i), 8));
            init_o_mem_en <= '1';
            init_o_mem_we <= '1';
            wait until rising_edge(tb_clk);   
        end loop;

        -- Load third scenario input data
        for i in 0 to SCENARIO_LENGTH-1 loop
            init_o_mem_addr <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS2+17+i, 16));
            init_o_mem_data <= std_logic_vector(to_unsigned(scenario_input2(i), 8));
            init_o_mem_en <= '1';
            init_o_mem_we <= '1';
            wait until rising_edge(tb_clk);   
        end loop;

        wait until falling_edge(tb_clk);
        memory_control <= '1';
        tb_add <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS2, 16));
        tb_start <= '1';

        -- Wait for third scenario completion
        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;

        wait for CLOCK_PERIOD;
        tb_start <= '0';
        wait;
    end process;

    -- Process to test the component
    test_routine : process
    begin
        -- Wait for and verify reset
        wait until tb_rst = '1';
        wait for 25 ns;
        assert tb_done = '0' report "TEST FALLITO o_done !=0 during reset" severity failure;
        wait until tb_rst = '0';

        -- First scenario verification
        wait until falling_edge(tb_clk);
        assert tb_done = '0' report "TEST FALLITO o_done !=0 after reset before start" severity failure;

        wait until rising_edge(tb_start);
        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;

        -- Verify first scenario results
        for i in 0 to SCENARIO_LENGTH-1 loop
            assert RAM(SCENARIO_ADDRESS+17+SCENARIO_LENGTH+i) = std_logic_vector(to_unsigned(scenario_output(i), 8)) 
                report "TEST FALLITO @ OFFSET=" & integer'image(17+SCENARIO_LENGTH+i) & 
                       " expected= " & integer'image(scenario_output(i)) & 
                       " actual=" & integer'image(to_integer(unsigned(RAM(SCENARIO_ADDRESS+17+SCENARIO_LENGTH+i)))) 
                severity failure;
        end loop;

        -- Wait for second scenario start
        wait until falling_edge(tb_done);
        wait until rising_edge(tb_start);

        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;

        -- Verify second scenario results
        for i in 0 to SCENARIO_LENGTH-1 loop
            assert RAM(SCENARIO_ADDRESS1+17+SCENARIO_LENGTH+i) = std_logic_vector(to_unsigned(scenario_output1(i), 8)) 
                report "TEST FALLITO AL SECONDO GIRO @ OFFSET=" & integer'image(17+SCENARIO_LENGTH+i) & 
                       " expected= " & integer'image(scenario_output1(i)) & 
                       " actual=" & integer'image(to_integer(unsigned(RAM(SCENARIO_ADDRESS1+17+SCENARIO_LENGTH+i)))) 
                severity failure;
        end loop;

        -- Wait for third scenario start
        wait until falling_edge(tb_done);
        wait until rising_edge(tb_start);

        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;

        -- Verify third scenario results
        for i in 0 to SCENARIO_LENGTH-1 loop
            assert RAM(SCENARIO_ADDRESS2+17+SCENARIO_LENGTH+i) = std_logic_vector(to_unsigned(scenario_output2(i), 8)) 
                report "TEST FALLITO AL TERZO GIRO @ OFFSET=" & integer'image(17+SCENARIO_LENGTH+i) & 
                       " expected= " & integer'image(scenario_output2(i)) & 
                       " actual=" & integer'image(to_integer(unsigned(RAM(SCENARIO_ADDRESS2+17+SCENARIO_LENGTH+i)))) 
                severity failure;
        end loop;

        wait until falling_edge(tb_done);
        assert false report "Simulation Ended! TEST PASSATO (EXAMPLE)" severity failure;
        wait;
    end process;

end architecture;