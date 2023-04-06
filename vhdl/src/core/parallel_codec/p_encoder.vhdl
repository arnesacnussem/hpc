LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_bit.ALL;
USE work.generated.ALL;
USE work.core_util.ALL;

ENTITY p_encoder IS
    GENERIC (
        WORKER_COUNT : POSITIVE := 4
    );
    PORT (
        msg   : IN MSG_MAT;                     -- message matrix
        rst   : IN STD_LOGIC := '0';            -- reset ready status and clock of work
        clk   : IN STD_LOGIC;                   -- clock
        code  : OUT CODEWORD_MAT;               -- codeword matrix
        ready : OUT ReadyStateType := NOT_READY -- signal of work ready
    );
END ENTITY p_encoder;

ARCHITECTURE rtl OF p_encoder IS

    -- Worker controls
    SIGNAL cutoff_pos    : INTEGER := (-1);
    SIGNAL mem_inL       : MXIO(0 TO CODEWORD_LENGTH)(0 TO MSG_LENGTH);
    SIGNAL mem_out       : MXIO(0 TO CODEWORD_LENGTH)(0 TO CODEWORD_LENGTH);
    SIGNAL WorkerReady   : ReadyStateType;
    SIGNAL WorkerDisable : STD_LOGIC := '0';
    SIGNAL WorkerInputsR : GEN_MAT   := GENERATE_MATRIX;

    -- FSM
    TYPE StateType IS (IDLE, WAIT_WORKER, MOVE_RESULT_1, PARTIAL_READY, TRANSPOSE, MOVE_RESULT_2, FULL_READY);
    SIGNAL State     : StateType := IDLE;
    SIGNAL nextState : StateType := IDLE;

BEGIN
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

    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            WorkerDisable <= '1';
            State         <= IDLE;
            code          <= (OTHERS => (OTHERS => '0'));
        ELSIF rising_edge(clk) THEN
            CASE State IS
                WHEN IDLE =>
                    -- copy msg into mem_inL
                    mem_inL(msg'RANGE) <= msg;
                    cutoff_pos         <= msg'length;
                    nextState          <= MOVE_RESULT_1;
                    State              <= WAIT_WORKER;
                WHEN WAIT_WORKER => -- enable worker and wait for result
                    IF WorkerReady = FULL_READY THEN
                        State         <= nextState;
                        WorkerDisable <= '1';
                    ELSE
                        WorkerDisable <= '0';
                    END IF;
                WHEN MOVE_RESULT_1 =>
                    -- move result to output
                    code(0 TO MSG_LENGTH) <= mem_out(0 TO MSG_LENGTH);
                    State                 <= PARTIAL_READY;
                WHEN PARTIAL_READY =>
                    WorkerDisable <= '1';
                    State         <= TRANSPOSE;
                WHEN TRANSPOSE =>
                    nextState <= MOVE_RESULT_2;
                    State     <= WAIT_WORKER;

                    -- transpose-ly copy mem_out into mem_inL with map: col[1] -> row[1]
                    FOR ci IN 0 TO CODEWORD_LENGTH LOOP
                        FOR mi IN 0 TO MSG_LENGTH LOOP
                            mem_inL(ci)(mi) <= mem_out(mi)(ci);
                        END LOOP;
                    END LOOP;
                WHEN MOVE_RESULT_2 =>
                    -- this state we have nothing to do?
                    State <= FULL_READY;

                WHEN FULL_READY =>
                    code  <= mem_out;
                    ready <= FULL_READY;
            END CASE;
        END IF;
    END PROCESS;
END ARCHITECTURE;