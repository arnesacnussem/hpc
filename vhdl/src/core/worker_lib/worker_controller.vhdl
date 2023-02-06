LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_bit.ALL;
USE work.generated.ALL;
USE work.mxio_util.ALL;
USE work.core_util.ALL;

ENTITY worker_controller IS
    GENERIC (
        WORKER_COUNT : POSITIVE := 4
    );
    PORT (
        disable : IN STD_LOGIC;
        clk     : IN STD_LOGIC;
        ready   : OUT ReadyStateType := NOT_READY;

        cutoff_pos    : IN INTEGER;
        mem_inL       : IN MXIO;  -- memory input
        mem_out       : OUT MXIO; -- memory out
        WorkerInputsR : IN MXIO   -- a static value used in worker
    );
END ENTITY;

ARCHITECTURE rtl OF worker_controller IS
    -- Worker controls and io
    SUBTYPE WORKER_RANGE IS NATURAL RANGE 0 TO WORKER_COUNT - 1;
    SIGNAL WorkerOutput  : MXIO(WORKER_RANGE)(mem_out(0)'RANGE);
    SIGNAL WorkerInputsL : MXIO(WORKER_RANGE)(mem_inL(0)'RANGE);
    SIGNAL WorkerCtlAct  : STD_LOGIC                      := '0';
    SIGNAL WorkerCtlRst  : STD_LOGIC                      := '0';
    SIGNAL WorkerCtlStat : STD_LOGIC_VECTOR(WORKER_RANGE) := (OTHERS => '1');

    TYPE WorkerMapType IS RECORD
        LastLoaded     : INTEGER; -- 该值表示最后一个已读入的数据块地址
        LastWorkerUsed : INTEGER; -- 该值表示最后一个有效worker的编号
    END RECORD;

    -- FSM States and control
    TYPE StateType IS(IDLE, LOAD, RUNNING, RDY);
    SIGNAL State : StateType := IDLE;

    SIGNAL internal_mem : MXIO(mem_out'RANGE)(mem_out(0)'RANGE);
BEGIN
    mem_out <= internal_mem;
    parallel_enc_worker : FOR w IN WORKER_RANGE GENERATE
        worker_inst : ENTITY work.mat_mul_rem2
            PORT MAP(
                mInL  => WorkerInputsL(w),
                mInR  => WorkerInputsR,
                mOUT  => internal_mem(w),
                act   => WorkerCtlAct,
                reset => WorkerCtlRst,
                stat  => WorkerCtlStat(w)
            );
    END GENERATE;
    PROCESS (clk, disable)
        VARIABLE WorkerMap : WorkerMapType;
        VARIABLE AllLoaded : BOOLEAN := False;
        IMPURE FUNCTION loadWorkerInput RETURN BOOLEAN IS
            VARIABLE firstAddr : NATURAL := WorkerMap.LastLoaded + 1;
        BEGIN
            FOR w IN WORKER_RANGE LOOP
                WorkerMap := (LastLoaded => firstAddr + w, LastWorkerUsed => w);
                WorkerInputsL(w) <= mem_inL(WorkerMap.LastLoaded);
            END LOOP;

            -- return true if all data has been loaded
            RETURN WorkerMap.LastLoaded = mem_inL'RANGE'high OR WorkerMap.LastLoaded = cutoff_pos;
        END FUNCTION;

    BEGIN
        IF disable = '1' THEN
            State <= IDLE;
            ready <= NOT_READY;
        ELSIF rising_edge(clk) THEN
            CASE State IS
            
                WHEN IDLE =>
                    WorkerMap := (LastLoaded => (-1), LastWorkerUsed => (-1));
                    internal_mem <= (OTHERS => (OTHERS => '0'));
                    WorkerCtlRst <= '1';
                    State        <= LOAD;

                WHEN LOAD =>
                    AllLoaded := loadWorkerInput;
                    WorkerCtlRst <= '0';
                    State        <= RUNNING;

                WHEN RUNNING =>
                    WorkerCtlAct <= '1';
                    IF isAllSLVEqualTo(WorkerCtlStat, '1') THEN
                        IF NOT AllLoaded THEN
                            State <= LOAD;
                        ELSE
                            State <= RDY;
                        END IF;
                    END IF;

                WHEN RDY =>
                    WorkerCtlAct <= '0';
                    ready        <= FULL_READY;
            END CASE;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;