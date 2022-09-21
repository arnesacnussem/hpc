import { gencfg } from "./generator_cfg.js";
import { writeFile, comment } from "./generator_common.js";
import { exported_data } from "./generator.d.js";
export default (mat: exported_data) => {
  const { ht: h, n, k, table } = mat;
  const pkgName = "types";
  const vhdl = `-- generated from ${process.argv[1]}
LIBRARY ieee;
PACKAGE ${pkgName} IS
    TYPE REF_TABLE_ARR IS ARRAY (0 TO ${(<[]>table).length - 1}) OF INTEGER;
    TYPE MXIO_ROW IS ARRAY(NATURAL RANGE <>) OF BIT;
    TYPE MXIO IS ARRAY(NATURAL RANGE <>) OF MXIO_ROW;

    TYPE GEN_MAT IS ARRAY (0 TO ${k - 1}, 0 TO ${n - 1}) OF BIT;
    TYPE CHK_MAT IS ARRAY (0 TO ${h.length - 1}, 0 TO ${
    h[0].length - 1
  }) OF BIT;

    SUBTYPE MSG_LINE IS MXIO_ROW (0 TO ${k - 1});
    SUBTYPE MSG_MAT IS MXIO (0 TO ${k - 1}) (0 TO ${k - 1});
    SUBTYPE MSG_SERIAL IS MXIO_ROW (0 TO ${k * k - 1});
    
    SUBTYPE CODEWORD_LINE IS MXIO_ROW(0 TO ${n - 1});
    SUBTYPE CODEWORD_MAT IS MXIO (0 TO ${n - 1}) (0 TO ${n - 1});
    SUBTYPE CODEWORD_SERIAL IS MXIO_ROW (0 TO ${n * n - 1});
END PACKAGE ${pkgName};
`;

  writeFile(pkgName, vhdl);
};
