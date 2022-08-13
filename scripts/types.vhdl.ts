import { gencfg } from "./generator_cfg.js";
import { writeFile, comment } from "./generator_common.js";
import { matrix } from "./generator.d.js";
export default (mat: matrix) => {
  const { h, n, k, table } = mat;
  const pkgName = "types";
  const vhdl = `-- generated from ${process.argv[1]}
LIBRARY ieee;
PACKAGE ${pkgName} IS
    TYPE GEN_MAT IS ARRAY (0 TO ${k - 1}, 0 TO ${n - 1}) OF BIT;
    TYPE CHK_MAT IS ARRAY (0 TO ${h.length - 1}, 0 TO ${n - 1}) OF BIT;

    TYPE MSG_LINE IS ARRAY (0 TO ${k - 1}) OF BIT;
    TYPE MSG_MAT IS ARRAY (0 TO ${k - 1}) OF MSG_LINE;
    TYPE MSG_SERIAL IS ARRAY (0 TO ${k * k - 1}) OF BIT;
    
    TYPE CODEWORD_LINE IS ARRAY (0 TO ${n - 1}) OF BIT;
    TYPE CODEWORD_MAT IS ARRAY(0 TO ${n - 1}) OF CODEWORD_LINE;
    TYPE CODEWORD_SERIAL IS ARRAY (0 TO ${n * n - 1}) OF BIT;

    TYPE REF_TABLE_ARR IS ARRAY (0 TO ${(<[]>table).length - 1}) OF INTEGER;
    TYPE MXIO_ROW IS ARRAY(NATURAL RANGE <>) OF BIT;
    TYPE MXIO_TYPE IS ARRAY(NATURAL RANGE <>) OF MXIO_ROW;
END PACKAGE ${pkgName};
`;

  writeFile(pkgName, vhdl);
};
