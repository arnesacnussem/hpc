LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_bit.ALL;
USE work.generated.ALL;
USE work.core_util.ALL;
USE work.decoder_utils.ALL;

ENTITY p_decoder IS
    GENERIC (
        WORKER_COUNT : POSITIVE := 4
    );
    PORT (
        clk      : IN STD_LOGIC;
        rst      : IN STD_LOGIC;
        recv_rdy : IN ReadyStateType := NOT_READY;
        code     : IN CODEWORD_MAT;
        arq_ctl  : OUT STD_LOGIC_VECTOR(0 TO 1);
        rdy      : OUT CheckResultType := UNCHECKED;
        msg      : OUT MSG_MAT
    );
END ENTITY p_decoder;

ARCHITECTURE rtl OF p_decoder IS
    -- Worker controls
    SIGNAL cutoff_pos    : INTEGER := (-1);
    SIGNAL mem_inL       : MXIO(0 TO CODEWORD_LENGTH)(0 TO CODEWORD_LENGTH);
    SIGNAL mem_out       : MXIO(0 TO CODEWORD_LENGTH)(0 TO 2);
    SIGNAL WorkerReady   : ReadyStateType;
    SIGNAL WorkerDisable : STD_LOGIC := '0';
    SIGNAL WorkerInputsR : CHK_MAT   := CHECK_MATRIX_T;

    -- FSM
    TYPE StateType IS (IDLE, WAIT_FULL_CODE, RDY_OK, RDY_FAIL, CHK_PARTIAL, CHK_FULL);
    SIGNAL state : StateType := IDLE;

    -- External decoder ctl
    SIGNAL ext_ready   : STD_LOGIC;
    SIGNAL ext_rst     : STD_LOGIC;
    SIGNAL ext_has_err : STD_LOGIC;
    SIGNAL ext_clk     : STD_LOGIC;
    SIGNAL ext_act     : STD_LOGIC;

BEGIN
    main : PROCESS (clk, rst)
        VARIABLE lin       : CODEWORD_LINE;
        VARIABLE err_exist : BOOLEAN;
        VARIABLE err_pos   : INTEGER; -- err_pos大于等于0时表示该错误可纠正
    BEGIN
        IF rst = '1' THEN
            rdy     <= UNCHECKED;
            arq_ctl <= "00";
            state   <= IDLE;

            -- reset external decoder
            ext_rst <= '1';
            ext_act <= '0';
        ELSIF rising_edge(clk) THEN
            CASE state IS
                WHEN IDLE =>
                    ext_rst <= '0';
                    IF recv_rdy = PARTIAL_READY THEN
                        state <= CHK_PARTIAL;
                    ELSIF recv_rdy = FULL_READY THEN
                        state <= CHK_FULL;
                    END IF;

                WHEN CHK_PARTIAL =>
                    -- TODO: move workload into workers
                    FOR row IN msg'RANGE LOOP
                        lin := code(row);
                        line_decode(lin, err_exist, err_pos);
                    END LOOP;
                    IF err_exist THEN
                        state <= WAIT_FULL_CODE;
                    ELSE
                        state <= RDY_OK;
                    END IF;

                WHEN WAIT_FULL_CODE =>
                    IF recv_rdy = FULL_READY THEN
                        state <= CHK_FULL;
                    END IF;

                WHEN CHK_FULL =>
                    ext_act <= '1';
                    IF ext_ready = '1' THEN
                        -- !!!FIXME: This is incorrect!!!!!!
                        IF err_exist THEN
                            state <= RDY_OK;
                        ELSE
                            state <= RDY_FAIL;
                        END IF;
                    END IF;

                WHEN RDY_OK =>
                    ext_act <= '0';
                    rdy     <= GOOD;
                    state   <= IDLE;

                WHEN RDY_FAIL =>
                    ext_act <= '0';
                    rdy     <= FAIL;
                    state   <= IDLE;
            END CASE;
        END IF;
    END PROCESS;

    ext_clk_ctl : PROCESS (ext_act, clk)
    BEGIN
        IF ext_act = '1' THEN
            ext_clk <= clk;
        ELSE
            ext_clk <= '0';
        END IF;
    END PROCESS;

    decoder_inst : ENTITY work.decoder
        PORT MAP(
            codeIn  => code,
            msg     => msg,
            ready   => ext_ready,
            rst     => ext_rst,
            clk     => ext_clk,
            has_err => ext_has_err
        );

    worker_controller_inst : ENTITY work.worker_controller
        GENERIC MAP(
            WORKER_COUNT => WORKER_COUNT
        )
        PORT MAP(
            disable       => WorkerDisable,
            clk           => clk,
            ready         => WorkerReady,
            cutoff_pos    => cutoff_pos,
            mem_inL       => mem_inL,
            mem_out       => mem_out,
            WorkerInputsR => WorkerInputsR
        );
END ARCHITECTURE;