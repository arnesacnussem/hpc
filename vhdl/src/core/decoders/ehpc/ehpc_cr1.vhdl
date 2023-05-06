LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.mxio_util.ALL;
USE work.decoder_utils.ALL;

ENTITY ehpc_cr1 IS
    PORT (
        enable : IN STD_LOGIC;
        reset  : IN STD_LOGIC;
        rec    : IN CODEWORD_MAT;
        rdy    : OUT STD_LOGIC;

        row_vector    : OUT bit_vector(CODEWORD_MAT'RANGE)    := (OTHERS => '0');
        col_vector    : OUT bit_vector(CODEWORD_MAT'RANGE(1)) := (OTHERS => '0');
        row_uncorrect : OUT bit_vector(CODEWORD_MAT'RANGE)    := (OTHERS => '0');
        col_uncorrect : OUT bit_vector(CODEWORD_MAT'RANGE(1)) := (OTHERS => '0')
    );
END ENTITY;

ARCHITECTURE rtl OF ehpc_cr1 IS
    SIGNAL col_rdy : STD_LOGIC_VECTOR(rec'RANGE(1)) := (OTHERS => '0');
    SIGNAL row_rdy : STD_LOGIC_VECTOR(rec'RANGE)    := (OTHERS => '0');
BEGIN
    row_chk : FOR i IN 0 TO CODEWORD_LENGTH GENERATE
        row_chk_proc : PROCESS (enable, reset)
            VARIABLE code_line : CODEWORD_LINE;
            VARIABLE err_exist : BOOLEAN;
            VARIABLE err_pos   : INTEGER;
        BEGIN
            IF reset = '1' THEN
                row_rdy(i) <= '0';
            ELSIF rising_edge(enable) THEN
                code_line := rec(i);
                line_decode(code_line, err_exist, err_pos);
                IF err_exist THEN
                    row_vector(i) <= '1';
                    IF err_pos =- 1 THEN
                        row_uncorrect(i) <= '1';
                    END IF;
                END IF;
                row_rdy(i) <= '1';
            END IF;
        END PROCESS;
    END GENERATE;

    col_chk : FOR i IN 0 TO 0 GENERATE
        col_chk_proc : PROCESS (enable, reset)
            VARIABLE code_line : CODEWORD_LINE;
            VARIABLE err_exist : BOOLEAN;
            VARIABLE err_pos   : INTEGER;
        BEGIN
            IF reset = '1' THEN
                col_rdy(i) <= '0';
            ELSIF rising_edge(enable) THEN
                code_line := getColumn(rec, i);
                line_decode(code_line, err_exist, err_pos);
                IF err_exist THEN
                    col_vector(i) <= '1';
                    IF err_pos =- 1 THEN
                        col_uncorrect(i) <= '1';
                    END IF;
                END IF;
                col_rdy(i) <= '1';
            END IF;
        END PROCESS;
    END GENERATE;

    PROCESS (col_rdy, row_rdy)
        VARIABLE col_found : BOOLEAN := false;
        VARIABLE row_found : BOOLEAN := false;
    BEGIN
        FOR i IN col_rdy'RANGE LOOP
            IF col_rdy(i) = '0' THEN
                col_found := true;
            ELSE

            END IF;
        END LOOP;
        FOR i IN row_rdy'RANGE LOOP
            IF row_rdy(i) = '0' THEN
                row_found := true;
            ELSE
            END IF;
        END LOOP;

        IF col_found = false AND row_found = false THEN
            rdy <= '1';
        ELSE
            rdy <= '0';
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;