import { gencfg } from "./generator_cfg.js";
import { writeFile, comment } from "./generator_common.js";

export default ({ h, g, n, k }) => {
  const pkgName = "consts";
  const vhdl = `-- generated from ${process.argv[1]}
library ieee;
USE work.types.ALL;
PACKAGE ${pkgName} IS
    CONSTANT GENERATE_MATRIX : GEN_MAT := (
      ${g
        .map((l, i) => i.toString().concat(' => "').concat(l).concat('"'))
        .join(",\n    ")}
    );
    CONSTANT CHECK_MATRIX : CHK_MAT := (
      ${h
        .map((l, i) => i.toString().concat(' => "').concat(l).concat('"'))
        .join(",\n    ")}
    );
END PACKAGE ${pkgName};
`;
  writeFile(pkgName, vhdl);
};
