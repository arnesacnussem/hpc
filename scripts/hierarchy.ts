const pakcage_dep = /^use\swork\.(.+)\.all;$/gim;
const package_name = /^package\s(.+)\sis$/gim;
const entity_name = /^ENTITY\s(.+)\sIS$/gim;
const entity_deps = /^\s*.+\s?\:\s?ENTITY\swork\.(.+)$/gim;

import fs from "fs";
import path from "path";
const clog = console.log;
interface VHDLFile {
  name: string;
  path: string;
  package: string | "";
  entity: string | "";
  packageDeps: string[];
  entityDeps: string[];
}
type VHDLDict = { [key: string]: VHDLFile };
const listFiles = (file?: string): string[] => {
  const filePath = file || "vhdl";
  return fs.readdirSync(path.resolve(filePath)).flatMap((f) => {
    const fp = path.join(filePath, f);
    if (fs.lstatSync(fp).isDirectory()) return listFiles(fp);
    else return fp.match(/.*\.vhdl$/gim) ? fp : [];
  });
};
const readFile = (filePath: string): VHDLFile => {
  const content = fs.readFileSync(filePath).toString();
  const file = {
    name: path.parse(filePath).name,
    path: filePath,
    packageDeps: [...content.matchAll(pakcage_dep)].map((m) => m[1]),
    entityDeps: [...content.matchAll(entity_deps)].map((m) => m[1]),
    package: [...content.matchAll(package_name)].map((m) => m[1])[0] || "",
    entity: [...content.matchAll(entity_name)].map((m) => m[1])[0] || "",
  };
  console.log(
    `${filePath} depends on ${[...file.packageDeps, ...file.entityDeps].join(
      ", "
    )}`
  );
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
      .filter(
        (vl) =>
          vl.packageDeps.includes(vhdl.name) ||
          vl.entityDeps.includes(vhdl.entity)
      )
      .map((v) => v.name);
    rdag[vhdl.name] = {
      ...vhdl,
      dependBy: dpBy,
    };
  });

  // update prior of each
  const fileList = Object.keys(rdag)
    .sort((a, b) => {
      if (
        rdag[a].dependBy.includes(rdag[b].name) ||
        rdag[a].dependBy.includes(rdag[b].entity)
      )
        return -1;
      else return 1;
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
fs.writeFileSync(
  "build/.list",
  nList.map((n) => path.resolve(n.path)).join(" ")
);
console.log("Generated hierarchy list");
