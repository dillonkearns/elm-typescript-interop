const Elm = require("./Main.elm");
import * as fs from "fs";

const program: any = Elm.Main.worker({ argv: process.argv });
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
  const path = object.path;
  const contents = object.contents;

  fs.writeFileSync(path, contents);
});

program.ports.parsingError.subscribe(function(errorString: string) {
  console.error(errorString);
  process.exit(1);
});

function isEmpty<T>(list: Array<T>) {
  return list.length === 0;
}
program.ports.requestReadSourceFiles.subscribe((sourceFilePaths: string[]) => {
  const missingFiles = sourceFilePaths.filter(
    sourcePath => !fs.existsSync(sourcePath)
  );

  if (isEmpty(missingFiles)) {
    const elmModuleFileContents = sourceFilePaths.map(sourcePath =>
      fs.readFileSync(sourcePath).toString()
    );
    program.ports.readSourceFiles.send(elmModuleFileContents);
  } else {
    console.error(`Could not find input file(s) ${missingFiles}`);
    process.exit(1);
  }
});
