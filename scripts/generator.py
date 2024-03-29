import oct2py
import sys
import os
import numpy as np

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
octave = oct2py.Oct2Py()
octave.addpath(SCRIPT_DIR)
octave.eval("pkg load communications;")

output_type = "73"
if sys.argv[1] in ["73", "84"]:
    output_type = sys.argv[1]

chk_bit = 3
if sys.argv[2] is not None:
    chk_bit = int(sys.argv[2])

if output_type == "84":
    arg_tup = octave.gen84(chk_bit, nout=4)
else:
    arg_tup = octave.gen73(chk_bit, nout=4)
H, G, n, k = arg_tup
n, k = int(n), int(k)

brief = f"""
generate by arg type={output_type} chk_bit={chk_bit}
n,k   = {(n,k)}
H     = {np.shape(H)}
G     = {np.shape(G)}
"""


def header(pkg):
    return f"""
library ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE {pkg} IS

"""


def footer(pkg):
    return f"""
END PACKAGE {pkg};
"""


def headerAndFooter(pkg):
    return header(pkg), footer(pkg)


shapeH = np.shape(H)
types = f"""
    TYPE int_array IS ARRAY (NATURAL RANGE <>) OF INTEGER;
    SUBTYPE MXIO_ROW IS STD_LOGIC_VECTOR;
    TYPE MXIO IS ARRAY(NATURAL RANGE <>) OF MXIO_ROW;

    SUBTYPE GEN_MAT IS MXIO (0 TO {k - 1})(0 TO {n - 1});
    SUBTYPE CHK_MAT IS MXIO (0 TO {shapeH[0] - 1})(0 TO {shapeH[1] - 1});

    SUBTYPE MSG_LINE IS MXIO_ROW (0 TO {k - 1});
    SUBTYPE MSG_MAT IS MXIO (0 TO {k - 1})(0 TO {k - 1});
    SUBTYPE MSG_SERIAL IS MXIO_ROW (0 TO {k * k - 1});

    SUBTYPE CODEWORD_LINE IS MXIO_ROW(0 TO {n - 1});
    SUBTYPE CODEWORD_MAT IS MXIO (0 TO {n - 1})(0 TO {n - 1});
    SUBTYPE CODEWORD_SERIAL IS MXIO_ROW (0 TO {n * n - 1});
"""


def mat2VHDstr(mat):
    return ",\n\t\t".join(
        [f'{index} => "{"".join(arr.astype(int).astype(str))}"' for index,
         arr in enumerate(mat)]
    )


constants = f"""
    CONSTANT MSG_LENGTH : INTEGER := {k - 1};
    CONSTANT CODEWORD_LENGTH : INTEGER := {n - 1};
    CONSTANT CHECK_LENGTH    : INTEGER := {shapeH[1] - 1};

    CONSTANT GENERATE_MATRIX : GEN_MAT := (
        {mat2VHDstr(G)}
    );

    CONSTANT CHECK_MATRIX_T : CHK_MAT := (
        {mat2VHDstr(H)}
    );
"""

test_message = np.vectorize(
    lambda x: "0" if x < 0.5 else "1")(np.random.rand(k, k))

test_data = f"""
library ieee;
USE work.types.ALL;
USE work.constants.ALL;
USE ieee.std_logic_1164.ALL;
PACKAGE test_data IS
    CONSTANT MESSAGE_MATRIX : MSG_MAT := (
        {mat2VHDstr(test_message)}
    );

    CONSTANT MESSAGE_SERIAL : MSG_SERIAL := "{
        "".join(["".join(msgI) for _, msgI in enumerate(test_message)])}";
END PACKAGE test_data;
"""
print(brief, file=sys.stderr)

output_dir = sys.argv[3]
print(f"output write to {output_dir}", file=sys.stderr)
if not os.path.isdir(f"{output_dir}"):
    os.mkdir(f"{output_dir}")


open(f"{output_dir}/constants.vhdl", "w+"
     ).write(header("constants") + "\nUSE work.types.ALL;\n"
             + constants + footer("constants"))

open(f"{output_dir}/types.vhdl", "w+"
     ).write(header("types") + types + footer("types"))
open(f"{output_dir}/test_data.vhdl", "w+").write(test_data)
