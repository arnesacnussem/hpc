import sourceMapSupport from "source-map-support";
sourceMapSupport.install();
const pakcage_dep = /^use\swork\.(.+)\.all;$/gim;
const package_name = /^package\s(.+)\sis$/gim;
const entity_name = /^ENTITY\s(.+)\sIS$/gim;
const entity_deps = /^\s*.+\s?\:\s?ENTITY\swork\.(.+)$/gim;

import fs from "fs";
import path from "path";
const clog = console.error;
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
  clog(
    `${filePath} depends on [${[...file.packageDeps, ...file.entityDeps].join(
      ", "
    )}]`
  );
  return file;
};

class Graph {
  V: number;
  adj: number[][];

  // Constructor
  constructor(v: number) {
    // Number of vertices
    this.V = v;

    // Adjacency List as ArrayList of ArrayList's
    this.adj = new Array(this.V);
    for (let i = 0; i < this.V; i += 1) {
      this.adj[i] = new Array();
    }
  }

  // Function to add an edge into the graph
  addEdge(v: number, w: number) {
    this.adj[v].push(w);
  }

  // A recursive function used by topologicalSort
  topologicalSortUtil(v: number, visited: boolean[], stack: number[]) {
    // Mark the current node as visited.
    visited[v] = true;
    let i = 0;

    // Recur for all the vertices adjacent
    // to thisvertex
    for (i = 0; i < this.adj[v].length; i++) {
      if (!visited[this.adj[v][i]]) {
        this.topologicalSortUtil(this.adj[v][i], visited, stack);
      }
    }

    // Push current vertex to stack
    // which stores result
    stack.push(v);
  }

  // The function to do Topological Sort.
  // It uses recursive topologicalSortUtil()
  topologicalSort() {
    let stack = new Array();

    // Mark all the vertices as not visited
    let visited = new Array(this.V);
    for (let i = 0; i < this.V; i++) {
      visited[i] = false;
    }

    // Call the recursive helper
    // function to store
    // Topological Sort starting
    // from all vertices one by one
    for (let i = 0; i < this.V; i++) {
      if (visited[i] == false) {
        this.topologicalSortUtil(i, visited, stack);
      }
    }

    return stack;
  }
}

const topologicSort = (dict: VHDLDict) => {
  const keyList = Object.keys(dict);
  const g = new Graph(keyList.length);
  for (let index = 0; index < keyList.length; index++) {
    const element = dict[keyList[index]];
    element.entityDeps.forEach((v) => {
      g.addEdge(index, keyList.indexOf(v));
    });
    element.packageDeps.forEach((v) => {
      g.addEdge(index, keyList.indexOf(v));
    });
  }

  const rdag = g.topologicalSort().map((i) => dict[keyList[i]]);
  clog(
    "Sorted: ",
    rdag.map((v) => v.name)
  );
  return rdag;
};

const filterDependencies = (list: VHDLFile[], top: VHDLFile | undefined) => {
  const nameDict = list.reduce((p, c) => {
    p[c.name] = c;
    return p;
  }, {} as VHDLDict);
  if (top === undefined) {
    clog(`Top level entity not specificed or not found, listing all sources.`);
    return nameDict;
  }

  const dfsWalk = (
    dict: VHDLDict,
    name: string,
    visited: Set<string>,
    pkg: boolean,
    callback: (vf: VHDLFile) => void = (_) => {}
  ) => {
    if (visited.has(name)) return;

    visited.add(name);
    const vFile = dict[name];
    if (!vFile) {
      throw Error(
        `Unable to find ${pkg ? "package" : "entity"} with name "${name}"`
      );
    }
    callback(vFile);

    for (const dep of pkg ? vFile.packageDeps : vFile.entityDeps) {
      dfsWalk(dict, dep, visited, pkg, callback);
    }
  };

  const entityDict = list
    .filter((v) => v.entity != "")
    .reduce((p, c) => {
      p[c.entity] = c;
      return p;
    }, {} as VHDLDict);
  const pkgDict = list
    .filter((v) => v.package != "")
    .reduce((p, c) => {
      p[c.package] = c;
      return p;
    }, {} as VHDLDict);

  const entitySet = new Set<string>();
  const packageSet = new Set<string>();
  dfsWalk(entityDict, topLevel, entitySet, false, (vf) => {
    for (const p of vf.packageDeps) {
      dfsWalk(pkgDict, p, packageSet, true);
    }
  });

  return Array.from(
    new Set<string>([
      ...Array.from(entitySet).map((e) => entityDict[e].name),
      ...Array.from(packageSet).map((p) => pkgDict[p].name),
    ])
  )
    .map((n) => nameDict[n])
    .reduce((p, c) => {
      p[c.name] = c;
      return p;
    }, {} as VHDLDict);
};

// use tolologic sort build rDAG
const list = listFiles().map(readFile);
const topLevel = process.argv[2] || "";
const top = list.find((v) => v.entity == topLevel);
const rdag = topologicSort(filterDependencies(list, top));

const out = {
  topLevelEntity: topLevel,
  topLevelFile: top?.path || "",
  hierarchy: rdag.map((n) => path.resolve(n.path)).join(" "),
};
const output = JSON.stringify(out, null, 2);
const outputFile = process.argv[3] || null;

if (outputFile === null) {
  process.stdout.write(output);
} else fs.writeFileSync(outputFile, output);
clog(
  JSON.stringify(
    {
      ...out,
      hierarchy: "tuncated",
    },
    null,
    2
  )
);
clog("Generated hierarchy list");
