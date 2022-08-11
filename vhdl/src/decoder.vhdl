library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.types.all;
  use work.config.all;

entity decoder is
  port (
    code  : in    CODEWORD_MAT; -- codeword matrix
    chk   : in    CHK_MAT;      -- check matrix
    msg   : out   MSG_MAT;      -- message matrix
    ready : out   std_logic;    -- signal of work ready
    rst   : in    std_logic;    -- reset ready status and clock of work
    clk   : in    std_logic     -- clock
  );
end entity decoder;

architecture decoder of decoder is

  procedure find (
    VARIABLE val : IN integer;
    VARIABLE pos : OUT integer
  ) is
  begin

    pos := (-1);

    for i IN 0 to REF_TABLE'length - 1 loop

      if (REF_TABLE(i) = val) then
        pos := i;
      end if;

    end loop;

  end procedure;

  procedure hdecode (
    VARIABLE lin             : IN CODEWORD_LINE;
    VARIABLE err_exist       : OUT std_logic;
    VARIABLE err_correctable : OUT std_logic;
    VARIABLE err_position    : OUT std_logic
  ) is

    variable syndrome : BIT_VECTOR(0 to CHECK_LENGTH);
    variable dsyn     : integer;
    variable pos      : integer;

  begin

    syndrome := (OTHERS => '0');

    for col IN 0 to CODEWORD_LENGTH loop

      for row IN 0 to CHECK_LENGTH loop

        syndrome(col) := (lin(row) and chk(row, col)) xor syndrome(col);

      end loop;

    end loop;

    dsyn := to_integer(unsigned(to_stdlogicvector(syndrome)));

    if (dsyn = 0) then
      err_exist       := '0';
      err_correctable := '0';
      err_position    := '0';
    else
      err_exist := '1';
      find(val => dsyn, pos => pos);
      if (pos = (-1)) then
      end if;
    end if;

  end procedure;

begin

  process is
  begin

    report "[DEC] Decoding first round.";

    decode_lines_r1 : for L IN 0 to CODEWORD_LENGTH loop

    end loop; -- decode_lines_r1

  end process;

end architecture decoder;
