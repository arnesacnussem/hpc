LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.generated.ALL;
USE work.utils.ALL;
USE work.decoder_utils.ALL;

ENTITY decoder_pms2 IS
    PORT (
        codeIn  : IN CODEWORD_MAT;      -- codeword matrix
        msg     : OUT MSG_MAT;          -- message matrix
        ready   : OUT STD_LOGIC := '0'; -- signal of work ready
        rst     : IN STD_LOGIC  := '0'; -- reset ready status and clock of work
        clk     : IN STD_LOGIC;         -- clock
        has_err : OUT STD_LOGIC
    );
END ENTITY decoder_pms2;

ARCHITECTURE DecoderMAJ2 OF decoder_pms2 IS
    TYPE state_t IS (COPY, R1, R2, R3, EXTRACT, RDY);
    TYPE r3_type_t IS (A, B, C);
    SIGNAL stat : state_t := COPY;

    TYPE row_error_array IS ARRAY(0 TO CODEWORD_MAT'length - 1) OF INTEGER;
    TYPE col_error_array IS ARRAY(0 TO CODEWORD_LINE'length - 1) OF INTEGER;
BEGIN
    PROCESS (clk)
        VARIABLE code      : CODEWORD_MAT;
        VARIABLE message   : MSG_MAT;
        VARIABLE index     : NATURAL   := 0;
        VARIABLE r3_stat   : NATURAL   := 0;
        VARIABLE r3_type   : r3_type_t := A;
        VARIABLE err_exist : BOOLEAN;
        VARIABLE err_pos   : INTEGER;

        VARIABLE row_error     : row_error_array := (OTHERS => 0);
        VARIABLE col_error     : col_error_array := (OTHERS => 0);
        VARIABLE row_err_index : NATURAL         := 0;
        VARIABLE col_err_index : NATURAL         := 0;

        VARIABLE synd        : INTEGER;
        VARIABLE column_temp : CODEWORD_LINE;

        PROCEDURE row_correct_for (
            VARIABLE mat : INOUT MXIO
        ) IS
            VARIABLE synd1 : INTEGER;
        BEGIN
            syndrome(lin => mat(index), synd => synd1);
            FOR i IN mat'RANGE LOOP
                mat(index)(i) := mat(index)(i) XOR SYNDTABLE(synd1 + 1)(i);
            END LOOP;
        END PROCEDURE;

        PROCEDURE col_correct_for (
            VARIABLE mat : INOUT MXIO
        ) IS
            VARIABLE synd1 : INTEGER;
        BEGIN
            extract_column(mat => mat, index => index, col => column_temp);
            syndrome(lin => column_temp, synd => synd1);
            FOR i IN mat(0)'RANGE LOOP
                mat(i)(index) := column_temp(i) XOR SYNDTABLE(synd1 + 1)(i);
            END LOOP;
        END PROCEDURE;
    BEGIN
        IF rising_edge(clk) THEN
            IF rst = '1' THEN
                msg   <= (OTHERS => MXIO_ROW(ieee.numeric_bit.to_unsigned(0, msg(0)'length)));
                ready <= '0';
                stat  <= COPY;
            ELSE
                CASE stat IS
                    WHEN COPY =>
                        code    := codeIn;
                        r3_stat := 0;
                        stat <= R1;
                    WHEN R1 =>
                        syndrome(lin => code(index), synd => synd);
                        IF synd /= 0 THEN
                            row_error(row_err_index) := index;
                            row_err_index            := row_err_index + 1;
                        END IF;

                        index := index + 1;
                        IF index = CODEWORD_MAT'length THEN
                            REPORT "[DEC/MAJ2] R1 ok";
                            index := 0;
                            stat <= R2;
                        END IF;
                    WHEN R2 =>
                        extract_column(mat => code, index => index, col => column_temp);
                        syndrome(lin => column_temp, synd => synd);
                        IF synd /= 0 THEN
                            col_error(col_err_index) := index;
                            col_err_index            := col_err_index + 1;
                        END IF;

                        index := index + 1;
                        -- 这玩意是正方形的，所以col和row长度一样...
                        IF index = CODEWORD_MAT'length THEN
                            REPORT "[DEC/MAJ2] R2 ok";
                            index := 0;
                            stat <= R3;
                            IF col_err_index = row_err_index THEN
                                IF 2 >= row_err_index THEN
                                    r3_type := A;
                                    REPORT "[DEC/MAJ2] Enting R3_A";
                                ELSE
                                    r3_type := B;
                                    REPORT "[DEC/MAJ2] Enting R3_B";
                                END IF;
                            ELSE
                                IF row_err_index > col_err_index THEN
                                    r3_type := B;
                                    REPORT "[DEC/MAJ2] Enting R3_B";
                                ELSE
                                    r3_type := C;
                                    REPORT "[DEC/MAJ2] Enting R3_C";
                                END IF;
                            END IF;
                        END IF;
                    WHEN R3 =>
                        CASE r3_type IS
                            WHEN A =>
                                IF r3_stat = 0 THEN
                                    IF col_err_index = 0 THEN
                                        r3_stat := 1;
                                    ELSE
                                        -- 这些个下标是先用再+1，所以下标的值是数组长度
                                        FOR i IN col_error'RANGE LOOP
                                            IF i = col_err_index THEN
                                                code(row_error(index))(col_error(i)) := NOT code(row_error(index))(col_error(i));
                                            END IF;
                                        END LOOP;
                                    END IF;
                                ELSIF r3_stat = 1 THEN
                                    row_correct_for(code);
                                ELSE
                                    stat <= EXTRACT;
                                    index := 0;
                                END IF;
                            WHEN B =>
                                IF r3_stat = 0 THEN
                                    row_correct_for(code);
                                ELSIF r3_stat = 1 THEN
                                    col_correct_for(code);
                                ELSIF r3_stat = 2 THEN
                                    row_correct_for(code);
                                ELSE
                                    stat <= EXTRACT;
                                    index := 0;
                                END IF;
                            WHEN C =>
                                IF r3_stat = 0 THEN
                                    col_correct_for(code);
                                ELSIF r3_stat = 1 THEN
                                    row_correct_for(code);
                                ELSIF r3_stat = 2 THEN
                                    col_correct_for(code);
                                ELSE
                                    stat <= EXTRACT;
                                    index := 0;
                                END IF;
                        END CASE;
                        index := index + 1;
                        IF index > row_err_index THEN
                            r3_stat := r3_stat + 1;
                            index   := 0;
                        END IF;
                    WHEN EXTRACT =>
                        REPORT "[DEC/MAJ2] R3 ok.";
                        stat <= RDY;
                    WHEN RDY =>
                        ready <= '1';
                        msg   <= message;
                        REPORT LF & "[DEC/MAJ2] codeIn=" & LF & MXIO_toString(codeIn);
                        REPORT LF & "[DEC/MAJ2] corr=" & LF & MXIO_toString(code);
                        REPORT LF & "[DEC/MAJ2] msg=" & LF & MXIO_toString(message);
                    WHEN OTHERS =>
                END CASE;
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE;