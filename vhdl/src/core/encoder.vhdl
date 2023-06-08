LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.mxio_util.ALL;
USE work.core_util.ALL;

ENTITY encoder IS
    PORT (
        msg   : IN MSG_MAT;       -- message matrix
        code  : OUT CODEWORD_MAT; -- codeword matrix
        ready : OUT STD_LOGIC;    -- signal of work ready
        rst   : IN STD_LOGIC;     -- reset ready status and clock of work
        clk   : IN STD_LOGIC      -- clock
    );
END encoder;

ARCHITECTURE Encoder OF encoder IS
    FUNCTION line_encoder (lin : MSG_LINE) RETURN CODEWORD_LINE IS
        VARIABLE lout              : CODEWORD_LINE;
    BEGIN
        lout := (OTHERS => '0');
        FOR col IN 0 TO CODEWORD_LENGTH LOOP
            FOR row IN 0 TO MSG_LENGTH LOOP
                lout(col) := (lin(row) AND GENERATE_MATRIX(row)(col)) XOR lout(col);
            END LOOP;
        END LOOP;
        RETURN lout;
    END FUNCTION;

    SIGNAL row_enc       : MXIO(0 TO MSG_LENGTH)(0 TO CODEWORD_LENGTH) := (OTHERS => (OTHERS => '0'));
    SIGNAL row_enc_t     : MXIO(0 TO CODEWORD_LENGTH)(0 TO MSG_LENGTH) := (OTHERS => (OTHERS => '0'));
    SIGNAL row_rdy       : STD_LOGIC_VECTOR(0 TO MSG_LENGTH)           := (OTHERS => '0');
    SIGNAL col_rdy       : STD_LOGIC_VECTOR(0 TO CODEWORD_LENGTH)      := (OTHERS => '0');
    SIGNAL rdyx          : STD_LOGIC                                   := '0';
    SIGNAL code_internal : CODEWORD_MAT                                := (OTHERS => (OTHERS => '0'));
    SIGNAL col_clk       : STD_LOGIC;
    SIGNAL row_rdyx      : STD_LOGIC;
BEGIN
    r : FOR i IN 0 TO MSG_LENGTH GENERATE
        inst : ENTITY work.line_encoder
            PORT MAP(
                msg   => msg(i),
                code  => row_enc(i),
                ready => row_rdy(i),
                reset => rst,
                clk   => clk
            );

    END GENERATE;

    t : ENTITY work.mxio_transposer
        GENERIC MAP(
            row_count => MSG_LENGTH,
            col_count => CODEWORD_LENGTH
        )
        PORT MAP(
            input  => row_enc,
            output => row_enc_t
        );

    c : FOR i IN 0 TO CODEWORD_LENGTH GENERATE
        inst : ENTITY work.line_encoder
            PORT MAP(
                msg   => row_enc_t(i),
                code  => code_internal(i),
                ready => col_rdy(i),
                reset => rst,
                clk   => col_clk
            );
    END GENERATE;

    col_clk  <= row_rdyx AND clk;
    code     <= code_internal;
    ready    <= rdyx;
    rdyx     <= and_reduce(col_rdy) AND row_rdyx;
    row_rdyx <= and_reduce(row_rdy);

    debug : PROCESS (rdyx)
    BEGIN
        IF rising_edge(rdyx) THEN
            REPORT "[ENC] msg = " & LF & MXIO_toString(msg);
            REPORT "[ENC] code = " & LF & MXIO_toString(code_internal);
        END IF;
    END PROCESS;
END ARCHITECTURE;