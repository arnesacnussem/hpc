LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_bit.ALL;
USE work.types.ALL;
USE work.constants.ALL;

-- 并行计算组件，计算 mInL * mInR => mOUT
-- act置高则为开始计算，stat高则为计算完成
ENTITY mat_mul_rem2 IS
    PORT (
        mInL  : IN MXIO_ROW;
        mInR  : IN MXIO;
        mOUT  : OUT MXIO_ROW;
        act   : IN STD_LOGIC  := '0';
        reset : IN STD_LOGIC  := '0';
        stat  : OUT STD_LOGIC := '0'
    );
END ENTITY;

ARCHITECTURE MaxMulRem2 OF mat_mul_rem2 IS
BEGIN
    PROCESS (act, reset)
        VARIABLE tmp : MXIO_ROW(mInR(0)'RANGE) := (OTHERS => '0');
    BEGIN
        mOUT <= tmp;
        IF reset = '1' THEN
            stat <= '0';
            tmp := (OTHERS => '0');
        ELSIF rising_edge(act) THEN
            FOR col IN mInL'RANGE LOOP
                FOR row IN tmp'RANGE LOOP
                    tmp(row) := (mInL(col) AND mInR(col)(row)) XOR tmp(row);
                END LOOP;
            END LOOP;
            stat <= '1';
        END IF;
    END PROCESS;

END ARCHITECTURE MaxMulRem2;