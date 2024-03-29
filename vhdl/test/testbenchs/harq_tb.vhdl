LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.test_data.ALL;
USE work.decoder_types.ALL;

ENTITY harq_tb IS
END;

ARCHITECTURE bench OF harq_tb IS

    -- Ports
    SIGNAL code         : CODEWORD_MAT;
    SIGNAL msg          : MSG_MAT := MESSAGE_MATRIX;
    SIGNAL msg_o        : MSG_MAT;
    SIGNAL ready        : STD_LOGIC_VECTOR(0 TO 1);
    SIGNAL rst          : STD_LOGIC_VECTOR(0 TO 1) := "00";
    SIGNAL clk_c        : STD_LOGIC_VECTOR(0 TO 1) := "00"; -- first bit connect encoder clk, second bit connect decoder clk
    SIGNAL clk_r        : STD_LOGIC_VECTOR(0 TO 1);
    SIGNAL clk          : STD_LOGIC := '0';
    SIGNAL exit1        : BOOLEAN   := false;
    SIGNAL has_err      : STD_LOGIC;
    SIGNAL enableRBF    : STD_LOGIC := '0';
    SIGNAL codeModified : CODEWORD_MAT;
BEGIN

    encoder_inst : ENTITY work.encoder
        PORT MAP(
            msg   => msg,
            code  => code,
            ready => ready(0),
            rst   => rst(0),
            clk   => clk_r(0)
        );

    RandomBitFlipper_inst : ENTITY work.RandomBitFlipper
        GENERIC MAP(
            FLIP_COUNT => 5
        )
        PORT MAP(
            enable => enableRBF,
            matIn  => code,
            matOut => codeModified
        );

    decoder_inst : ENTITY work.decoder
        GENERIC MAP(
            decoder_type => DUMMY
        )
        PORT MAP(
            codeIn  => codeModified,
            msg     => msg_o,
            ready   => ready(1),
            rst     => rst(1),
            clk     => clk_r(1),
            has_err => has_err
        );

    PROCESS (has_err, clk)
        VARIABLE actCnt : INTEGER := 0;
    BEGIN
        IF rising_edge(clk) THEN
            IF rising_edge(has_err) THEN
                actCnt := actCnt + 1;
                REPORT "ARQ retry: " & INTEGER'image(actCnt);
                rst(1)    <= '1';
                enableRBF <= '1';
            ELSE
                rst(1)    <= '0';
                enableRBF <= '0';
            END IF;
        END IF;

    END PROCESS;
    PROCESS
        VARIABLE clk_real : STD_LOGIC := '0';
    BEGIN
        FOR i IN clk_c'RANGE LOOP
            IF clk_c(i) = '1' THEN
                clk_r(i) <= clk;
            ELSE
                clk_r(i) <= '0';
            END IF;
        END LOOP;

        clk <= NOT clk;
        WAIT FOR 1 ps;
        IF exit1 THEN
            WAIT;
        END IF;
    END PROCESS;

    PROCESS
    BEGIN
        clk_c <= "10";
        WAIT UNTIL ready(0) = '1';

        clk_c <= "00";
        WAIT UNTIL rising_edge(clk);
        -- modify the codeword
        enableRBF <= '1';
        WAIT UNTIL rising_edge(clk);

        enableRBF <= '0';
        WAIT UNTIL rising_edge(clk);

        clk_c <= "01";
        WAIT UNTIL ready = "11";

        clk_c <= "00";
        WAIT UNTIL rising_edge(clk);

        rst(1) <= '1';
        WAIT UNTIL rising_edge(clk);

        exit1 <= true;
        WAIT;
    END PROCESS;

END;