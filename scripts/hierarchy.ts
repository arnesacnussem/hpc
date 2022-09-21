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


class Graph{
  V: number;
  adj: number[][];
 
  // Constructor
  constructor(v:number)
  {
      // Number of vertices
      this.V = v

      // Adjacency List as ArrayList of ArrayList's
      this.adj = new Array(this.V)
      for (let i = 0 ; i < this.V ; i+=1){
          this.adj[i] = new Array()
      }
  }

  // Function to add an edge into the graph
  addEdge(v: number, w: number){
      this.adj[v].push(w)
  }

  // A recursive function used by topologicalSort
  topologicalSortUtil(v: number, visited: boolean[], stack: number[])
  {
      // Mark the current node as visited.
      visited[v] = true;
      let i = 0;

      // Recur for all the vertices adjacent
      // to thisvertex
      for(i = 0 ; i < this.adj[v].length ; i++){
          if(!visited[this.adj[v][i]]){
              this.topologicalSortUtil(this.adj[v][i], visited, stack)
          }
      }

      // Push current vertex to stack
      // which stores result
      stack.push(v);
  }

  // The function to do Topological Sort.
  // It uses recursive topologicalSortUtil()
  topologicalSort()
  {
      let stack = new Array()

      // Mark all the vertices as not visited
      let visited = new Array(this.V);
      for (let i = 0 ; i < this.V ; i++){
          visited[i] = false;
      }

      // Call the recursive helper
      // function to store
      // Topological Sort starting
      // from all vertices one by one
      for (let i = 0 ; i < this.V ; i++){
          if (visited[i] == false){
              this.topologicalSortUtil(i, visited, stack);
          }
      }

      return stack
  }
}


const topologicSort = (dict:VHDLDict)=>{
  const keyList = Object.keys(dict)
  const g = new Graph(keyList.length);
  for (let index = 0; index < keyList.length; index++) {
    const element = dict[keyList[index]];
    element.entityDeps.forEach(v=>{
      g.addEdge(index, keyList.indexOf(v))
    })
    element.packageDeps.forEach(v=>{
      g.addEdge(index,keyList.indexOf(v))
    })
  }
  
  const rdag = g.topologicalSort().map((i) => dict[keyList[i]]);
  console.log(
    "Sorted: ",
    rdag.map((v) => v.name)
  );
  return rdag;
}

// use tolologic sort build rDAG


// readFile("./vhdl/test/encoder_tb.vhdl");
// readFile("./vhdl/gen/config.vhdl");
const list = listFiles().map(readFile);
const dict = list.reduce((p, c) => {
  p[c.name] = c;
  return p;
}, {} as VHDLDict);
const rdag = topologicSort(dict);

fs.writeFileSync(
  "build/.list",
  rdag.map((n) => path.resolve(n.path)).join(" ")
);
console.log("Generated hierarchy list");
