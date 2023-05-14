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

    FUNCTION isAllSLVEqualTo (vec : STD_LOGIC_VECTOR; val : STD_LOGIC) RETURN BOOLEAN;
    FUNCTION and_reduce(vec : STD_LOGIC_VECTOR)RETURN STD_LOGIC;
END PACKAGE;

PACKAGE BODY core_util IS
    FUNCTION isAllSLVEqualTo(vec : STD_LOGIC_VECTOR; val : STD_LOGIC) RETURN BOOLEAN IS
        CONSTANT all_bits : STD_LOGIC_VECTOR(vec'RANGE) := (OTHERS => val);
    BEGIN
        RETURN vec = all_bits;
    END FUNCTION;

    FUNCTION and_reduce(vec : STD_LOGIC_VECTOR)RETURN STD_LOGIC IS
        VARIABLE t              : STD_LOGIC;
    BEGIN
        t := vec(1);
        FOR i IN 1 TO vec'length - 1 LOOP
            t := t AND vec(i);
        END LOOP;
        RETURN t;
    END FUNCTION;
END PACKAGE BODY;