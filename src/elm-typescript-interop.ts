import * as Elm from "./Main";
import * as fs from "fs";
import * as glob from "glob";
import * as path from "path";
const version = require("../package.json")["version"];

if (process.argv[2] === "--version") {
  console.log(version);
  process.exit(0);
} else if (process.argv.length > 2) {
  console.error(
    "`elm-typescript-interop` doesn't accept any CLI arguments, see github README."
  );
  process.exit(1);
}

const elmProjectConfig = elmConfigFile();

function elmConfigFile() {
  if (fs.existsSync("./elm.json")) {
    return JSON.parse(fs.readFileSync("./elm.json").toString());
  } else if (fs.existsSync("./elm-package.json")) {
    return JSON.parse(fs.readFileSync("./elm-package.json").toString());
  } else {
    console.error(
      "I couldn't find an `elm.json` or `elm-package.json` file. Please run `elm-typescript-interop` from your Elm project's root folder."
    );
    process.exit(1);
    return {};
  }
}

const program = Elm.Main.worker({
  elmProjectConfig: elmProjectConfig
});
program.ports.print.subscribe(message => console.log(message));
program.ports.printAndExitFailure.subscribe(message => {
  console.log(message);
  process.exit(1);
});

program.ports.printAndExitSuccess.subscribe(message => {
  console.log(message);
  process.exit(0);
});

function writeGeneratedFile(object: { path: string; contents: string }) {
  const filePath = object.path;
  const contents = object.contents;

  const outputFolder = path.dirname(filePath);
  if (!fs.existsSync(outputFolder)) {
    fs.mkdirSync(outputFolder);
  }

  fs.writeFileSync(filePath, contents);
}
program.ports.generatedFiles.subscribe(function(filesToGenerate) {
  filesToGenerate.forEach(writeGeneratedFile);
});

program.ports.parsingError.subscribe(function(errorString) {
  console.error(errorString);
  process.exit(1);
});

function isEmpty<T>(list: Array<T>): boolean {
  return list.length === 0;
}

function flatten<T>(list: Array<Array<T>>): Array<T> {
  const empty: Array<T> = [];
  return empty.concat(...list);
}

program.ports.requestReadSourceDirectories.subscribe(srcDirectories => {
  const missingDirectories = srcDirectories.filter(
    sourcePath => !fs.existsSync(sourcePath)
  );

  if (isEmpty(missingDirectories)) {
    const files = srcDirectories.map(srcDirectory =>
      glob.sync(`${srcDirectory}/**/*.elm`, {
        sync: true,
        ignore: ["**/node_modules/**/*", "**/elm-stuff/**/*"]
      })
    );

    const flatFiles = flatten(files);
    const elmModuleFileContents = flatFiles.map(sourcePath => {
      return {
        path: sourcePath,
        contents: fs.readFileSync(sourcePath).toString()
      };
    });
    program.ports.readSourceFiles.send(elmModuleFileContents);
  } else {
    console.error(`Could not find src directories: ${missingDirectories}`);
    process.exit(1);
  }
});
