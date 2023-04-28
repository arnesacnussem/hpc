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
END PACKAGE;

PACKAGE BODY core_util IS
    FUNCTION isAllSLVEqualTo(vec : STD_LOGIC_VECTOR; val : STD_LOGIC) RETURN BOOLEAN IS
        CONSTANT all_bits : STD_LOGIC_VECTOR(vec'RANGE) := (OTHERS => val);
    BEGIN
        RETURN vec = all_bits;
    END FUNCTION;
END PACKAGE BODY;