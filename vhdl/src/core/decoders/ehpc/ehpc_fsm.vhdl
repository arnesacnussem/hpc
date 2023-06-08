LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.ehpc_declare.ALL;

ENTITY ehpc_fsm IS
    PORT (
        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        ready : OUT STD_LOGIC := '0';

        state          : OUT ehpc_state_t := CHK_CR1;
        rdy            : IN ehpc_state_map(ehpc_state_t'left TO ehpc_state_t'right);
        col_count      : IN NATURAL;
        row_count      : IN NATURAL;
        col_sum        : IN NATURAL;
        row_sum        : IN NATURAL;
        flag_transpose : OUT STD_LOGIC := '0';
        sel_cr2        : OUT STD_LOGIC := '0';
        sel_erase      : OUT STD_LOGIC := '0';
        sel_r3req      : OUT STD_LOGIC := '0'

    );
END ENTITY;
ARCHITECTURE rtl OF ehpc_fsm IS

BEGIN

    fsm : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                state <= CHK_CR1;
                ready <= '0';
            ELSE
                IF rdy(state) = '1' THEN
                    CASE state IS
                        WHEN CHK_CR1 =>
                            state <= VEC_CHK;
                        WHEN CHK_CR2 =>
                            state <= VEC_CHK;
                        WHEN C2R3C =>
                            state <= R3REQ;
                        WHEN R3REQ =>
                            ready <= '1';
                        WHEN VEC_CHK =>
                            IF rdy(CHK_CR2) = '1' THEN
                                sel_erase <= '1';
                                IF row_sum * 2 = 3 * col_sum THEN
                                    state     <= ERASE;
                                    sel_r3req <= '0';
                                ELSE
                                    state     <= C2R3C;
                                    sel_r3req <= '1';
                                END IF;
                            ELSIF rdy(CHK_CR1) = '1' THEN
                                sel_erase <= '0';
                                IF col_sum > row_sum OR col_count > row_count THEN
                                    state          <= CHK_CR2;
                                    flag_transpose <= '1';
                                ELSE
                                    -- not_transpose    
                                    flag_transpose <= '0';
                                    IF col_count * col_count < 2 * col_sum AND col_sum = row_sum AND col_count = row_count THEN
                                        state   <= ERASE;
                                        sel_cr2 <= '1';
                                    ELSE
                                        state   <= CHK_CR2;
                                        sel_cr2 <= '0';
                                    END IF;
                                END IF;
                            END IF;
                        WHEN ERASE =>
                            IF rdy(CHK_CR2) = '1' THEN
                                state <= R3REQ;
                            ELSIF rdy(CHK_CR1) = '1' THEN
                                state <= CHK_CR2;
                            END IF;
                    END CASE;
                END IF;
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE rtl;