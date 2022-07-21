import { writeFile, comment } from "./generator_common.js";

export default ({ h, g, n, k }) => {
  const msg = Array.from({ length: k }, () =>
    Array.from({ length: k }, () => (Math.random() > 0.5 ? 1 : 0))
  );
  const pkgName = "test_values";
  const vhdl = `-- generated from ${process.argv[1]}
library ieee;
USE work.types.ALL;
PACKAGE ${pkgName} IS
    CONSTANT MESSAGE_MATRIX : MSG_MAT := (
        ${msg
          .map((row) => row.join(""))
          .map((row, index) =>
            String(index).concat(' => "').concat(row).concat('"')
          )
          .join(",\n    ")}
    );
    CONSTANT MESSAGE_SERIAL : MSG_SERIAL := "${msg
      .map((v) => v.join(""))
      .join("")}";
END PACKAGE ${pkgName};
`;
  writeFile(pkgName, vhdl);
};
