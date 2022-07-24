import { mkdirSync, writeFileSync } from "fs";
import { resolve } from "path";
import { exec, execSync } from "child_process";
import { gencfg } from "./generator_cfg.js";
const matrixs = ((check_bits) => {
  const octaveCMD = `octave-cli -q --eval '
  pkg load communications;
  [h,g,n,k]=hammgen(${check_bits});
  printf("h=%s\\n",mat2str(h));
  printf("g=%s\\n",mat2str(g));
  printf("n=%d\\n",n);
  printf("k=%d\\n",k);
  '`;
  const stdout = execSync(octaveCMD).toString();
  const matrixs = { h: [] as string[], g: [] as string[], n: -1, k: -1 };
  stdout
    .trim()
    .split("\n")
    .forEach((line) => {
      if (line.trim() === "") return;
      const current = line.at(0)?.trim();
      switch (current) {
        case "h":
        case "g":
          matrixs[current] = line
            .slice(3, line.length - 1)
            .split(";")
            .map((v) => v.split(" ").join(""));
          break;
        case "n":
        case "k":
          matrixs[current] = parseInt(line.split("=").map((l) => l.trim())[1]);
          break;
        default:
      }
    });

  return matrixs;
})(gencfg.check_bits);

import genConfig from "./config.vhdl.js";
import genTypes from "./types.vhdl.js";
import genTest from "./test_values.vhdl.js";
genConfig(matrixs);
genTypes(matrixs);
genTest(matrixs);
