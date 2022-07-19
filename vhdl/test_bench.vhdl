LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;
USE work.consts.ALL;

ENTITY test_bench IS
END test_bench;

ARCHITECTURE TestBench OF test_bench IS
    COMPONENT encoder
        PORT (
            msg : IN MESSAGE;
            gen : IN GEN_MAT;
            encoded : OUT MSG_ENC;
            rst, clk : IN STD_LOGIC;
            done : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL msg : MESSAGE := "10100011101";
    SIGNAL gen : GEN_MAT := GENERATE_MATRIX;
    SIGNAL encoded : MSG_ENC;
    SIGNAL rst, done, clk : STD_LOGIC;
BEGIN
    encoder1u : encoder PORT MAP(
        msg => msg,
        gen => gen,
        encoded => encoded,
        rst => rst,
        clk => clk,
        done => done
    );
    clock : PROCESS
    BEGIN
        rst <= '0';
        clk <= '0';
        WAIT FOR 1 ns;
        rst <= '1';
        WAIT FOR 1 ns;
        rst <= '0';
        WAIT FOR 1 ns;
        clk <= '1';
        WAIT FOR 1 ns;
        clk <= '0';
        WAIT;
    END PROCESS;

    check_output : PROCESS
    BEGIN
        WAIT ON done;
        WAIT UNTIL rising_edge(done);
        REPORT to_string(msg) & " ==> " & to_string(encoded)
            ;
        WAIT;
    END PROCESS;
END ARCHITECTURE;