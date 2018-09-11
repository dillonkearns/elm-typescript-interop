const Elm = require("./Main.elm");
import * as fs from "fs";
import * as glob from "glob";
import * as path from "path";

const elmProjectConfig = elmConfigFile();

function elmConfigFile(): object {
  if (fs.existsSync("./elm-package.json")) {
    return JSON.parse(fs.readFileSync("./elm-package.json").toString());
  } else if (fs.existsSync("./elm.json")) {
    return JSON.parse(fs.readFileSync("./elm.json").toString());
  } else {
    console.error(
      "I couldn't find an `elm.json` or `elm-package.json` file. Please run `elm-typescript-interop` from your Elm project's root folder."
    );
    process.exit(1);
    return {};
  }
}
const program: any = Elm.Main.worker({
  argv: process.argv,
  elmProjectConfig: elmProjectConfig
});
program.ports.print.subscribe((message: string) => console.log(message));
program.ports.printAndExitFailure.subscribe((message: string) => {
  console.log(message);
  process.exit(1);
});

program.ports.printAndExitSuccess.subscribe((message: string) => {
  console.log(message);
  process.exit(0);
});
program.ports.generatedFiles.subscribe(function(object: any) {
  const filePath = object.path;
  const contents = object.contents;

  const outputFolder = path.dirname(filePath);
  if (!fs.existsSync(outputFolder)) {
    fs.mkdirSync(outputFolder);
  }

  fs.writeFileSync(filePath, contents);
});

program.ports.parsingError.subscribe(function(errorString: string) {
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

program.ports.requestReadSourceDirectories.subscribe(
  (srcDirectories: string[]) => {
    const missingDirectories = srcDirectories.filter(
      sourcePath => !fs.existsSync(sourcePath)
    );

    if (isEmpty(missingDirectories)) {
      const files = srcDirectories.map(srcDirectory =>
        glob.sync(`${srcDirectory}/**/*.elm`, { sync: true })
      );

      const flatFiles = flatten(files);
      const elmModuleFileContents = flatFiles.map(sourcePath =>
        fs.readFileSync(sourcePath).toString()
      );
      program.ports.readSourceFiles.send(elmModuleFileContents);
    } else {
      console.error(`Could not find src directories: ${missingDirectories}`);
      process.exit(1);
    }
  }
);
