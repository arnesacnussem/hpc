LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.textio.ALL;
USE work.types.ALL;

ENTITY encoder IS
    PORT (
        msg : IN MSG_MAT;
        -- generator matrix
        gen      : IN GEN_MAT;
        encoded  : OUT CODEWORD_MAT;
        done     : OUT STD_LOGIC;
        rst, clk : IN STD_LOGIC
    );
END encoder;

ARCHITECTURE Encoder OF encoder IS
    PROCEDURE matrix_multiplex_add(
        VARIABLE a, b : IN BIT;
        VARIABLE c    : OUT BIT
    ) IS
    BEGIN
        IF a = '1' AND b = '1' THEN
            c := '0';
        ELSIF a = '0' AND b = '0' THEN
            c := '0';
        ELSE
            c := '1';
        END IF;
    END matrix_multiplex_add;
    FUNCTION matrix_multiplex_mux (
        a, b : BIT
    ) RETURN BIT IS
    BEGIN
        IF a = '1' AND b = '1' THEN
            RETURN '1';
        ELSE
            RETURN '0';
        END IF;
    END FUNCTION;
    PROCEDURE line_encoder (
        VARIABLE lin  : IN MSG_LINE;
        VARIABLE lout : OUT CODEWORD_LINE
    ) IS
        VARIABLE mux : BIT;
    BEGIN
        lout := (OTHERS => '0');
        FOR col IN 0 TO CODEWORD_LENGTH LOOP
            FOR row IN 0 TO MSG_LENGTH LOOP
                mux := matrix_multiplex_mux(a => lin(row), b => gen(row, col));
                matrix_multiplex_add(a => mux, b => lout(col), c => lout(col));
            END LOOP;
        END LOOP;
    END PROCEDURE;
BEGIN
    encoding : PROCESS (msg, gen, clk, rst)
        VARIABLE temp : CODEWORD_MAT;
        VARIABLE msg_lin  : MSG_LINE;
    BEGIN
        IF rst = '1' THEN
            done <= '0';
        ELSIF rising_edge(clk) THEN
            encode_lines : FOR L IN 0 TO MSG_LENGTH LOOP
                msg_lin := msg(L);
                line_encoder(lin => msg_lin, lout => temp(L));
            END LOOP; -- encode_lines
            done <= '1';
        END IF;
        encoded <= temp;
    END PROCESS;
END ARCHITECTURE;