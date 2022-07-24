const work_package = /^use\swork\.(.+)\.all;$/gim;
const package_name = /^package\s(.+)\sis$/gim;

import fs from "fs";
import path from "path";
interface VHDLFile {
  name: string;
  path: string;
  package: string | "";
  dependsOn: string[];
}
type VHDLDict = { [key: string]: VHDLFile };
const listFiles = (): string[] => {
  const files = ["gen", "src", "test"]
    .map((d) => path.join("vhdl", d))
    .flatMap((d) => fs.readdirSync(d).map((t) => path.join(d, t)));
  console.log(files);
  return files;
};
const readFile = (filePath: string): VHDLFile => {
  const content = fs.readFileSync(filePath).toString();
  const file = {
    name: path.parse(filePath).name,
    path: filePath,
    dependsOn: [...content.matchAll(work_package)].map((m) => m[1]),
    package: [...content.matchAll(package_name)].map((m) => m[1])[0] || "",
  };
  console.log(`${filePath} depends on ${file.dependsOn.join(", ")}`);
  return file;
};

type DepDict = { [key: string]: DepDict | null };

type VHDLFile2 = {
  [key: string]: VHDLFile & { dependBy: string[] };
};

// this is like doing a reverse of a DAG: dependBy
const buildDepBy = (dict: VHDLDict, list: VHDLFile[]) => {
  const rdag = {} as VHDLFile2;
  // create the dependBy map
  list.forEach((vhdl) => {
    const dpBy = list
      .filter((vl) => vl.dependsOn.includes(vhdl.name))
      .map((v) => v.name);
    rdag[vhdl.name] = {
      ...vhdl,
      dependBy: dpBy,
    };
  });

  // update prior of each
  const fileList = Object.keys(rdag)
    .sort((a, b) => {
      const s1 = rdag[b].dependBy.length - rdag[a].dependBy.length;
      if (s1 !== 0) return s1;
      else {
        if (a in rdag[b].dependBy) return 1;
        else return -1;
      }
    })
    .map((k) => rdag[k]);
  console.log(
    "Sorted: ",
    fileList.map((f) => f.name)
  );

  return fileList;
};

// readFile("./vhdl/test/encoder_tb.vhdl");
// readFile("./vhdl/gen/config.vhdl");
const list = listFiles().map(readFile);
const dict = list.reduce((p, c) => {
  p[c.name] = c;
  return p;
}, {} as VHDLDict);
const nList = buildDepBy(dict, list);
console.log("\n\n====DependBy====");

nList.forEach((n) => {
  console.log(`${n.name} >> ${n.dependBy.join(", ")}`);
});
fs.writeFileSync("./vhdl/.list", nList.map((n) => n.path).join(" "));
