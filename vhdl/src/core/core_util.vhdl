LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.mxio_util.ALL;

PACKAGE core_util IS
    TYPE ReadyStateType IS (NOT_READY, PARTIAL_READY, FULL_READY);
    TYPE WorkerStateType IS (IDLE, RUNNING, READY);
    TYPE CheckResultType IS(UNCHECKED, FAIL, GOOD);

    FUNCTION and_reduce(vec : STD_LOGIC_VECTOR)RETURN STD_LOGIC;
    FUNCTION or_reduce(vec  : STD_LOGIC_VECTOR)RETURN STD_LOGIC;
END PACKAGE;

PACKAGE BODY core_util IS
    FUNCTION and_reduce(vec : STD_LOGIC_VECTOR) RETURN STD_LOGIC IS
        VARIABLE result         : STD_LOGIC := '1';
    BEGIN
        FOR i IN vec'RANGE LOOP
            result := result AND vec(i);
        END LOOP;
        RETURN result;
    END FUNCTION;

    FUNCTION or_reduce(vec : STD_LOGIC_VECTOR) RETURN STD_LOGIC IS
        VARIABLE result        : STD_LOGIC := '0';
    BEGIN
        FOR i IN vec'RANGE LOOP
            result := result OR vec(i);
        END LOOP;
        RETURN result;
    END FUNCTION;

    FUNCTION all_equal_sig(vec : STD_LOGIC_VECTOR; val : STD_LOGIC)RETURN STD_LOGIC IS
        CONSTANT all_bits : STD_LOGIC_VECTOR(vec'RANGE) := (OTHERS => val);
    BEGIN
        IF vec = all_bits THEN
            RETURN '1';
        ELSE
            RETURN '0';
        END IF;
    END FUNCTION;
END PACKAGE BODY;