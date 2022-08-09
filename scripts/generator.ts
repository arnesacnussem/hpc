import { mkdirSync, writeFileSync } from "fs";
import { resolve } from "path";
import { exec, execSync } from "child_process";
import { gencfg } from "./generator_cfg.js";
import { matrix } from "./generator.d.js";
const matrixs = ((check_bits) => {
  const octaveCMD = `octave-cli -q -p scripts --eval 'gen(${check_bits})'`;
  const stdout = execSync(octaveCMD).toString();
  const matrixs = {} as matrix;

  stdout
    .trim()
    .split("\n")
    .forEach((line) => {
      console.log(line);

      if (line.trim() === "") return;
      if (!line.startsWith("!#")) return;
      const split = line
        .substring(2, line.indexOf("#!"))
        .trim()
        .split(" ")
        .map((v) => v.trim());
      const type = split[0];
      const tag = split[1];
      const value = line.substring(line.indexOf("#!") + 2).trim();
      switch (type) {
        case "mat":
          matrixs[tag] = value
            .substring(1, value.length - 1)
            .split(";")
            .map((v) => v.split(" ").join(""));
          break;
        case "val":
          matrixs[tag] = parseInt(value);
          break;
        default:
      }
    });
  console.log(matrixs);

  return matrixs;
})(gencfg.check_bits);

import genConfig from "./config.vhdl.js";
import genTypes from "./types.vhdl.js";
import genTest from "./test_values.vhdl.js";
genConfig(Object.assign({ table: [] }, matrixs));
genTypes(matrixs);
genTest(matrixs);
