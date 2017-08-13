const Elm = require('./Main.elm')
import * as fs from 'fs'
import * as minimist from 'minimist'

const args = minimist(process.argv.slice(2))
const inputPaths = args._
const tsDeclarationPath = args.output
const missingFiles = inputPaths.filter(inputPath => !fs.existsSync(inputPath))

if (missingFiles !== []) {
  const elmModuleFileContents = inputPaths.map(inputPath =>
    fs.readFileSync(inputPath).toString()
  )

  let app = Elm.Main.worker({ elmModuleFileContents })
  app.ports.generatedFiles.subscribe(function(typescriptDeclarationFile: any) {
    fs.writeFileSync(tsDeclarationPath, typescriptDeclarationFile)
  })

  app.ports.parsingError.subscribe(function(errorString: string) {
    console.error(`Error parsing input file ${inputPaths}\n`)
    console.error(errorString)
    process.exit(1)
  })
} else {
  console.error(`Could not find input file(s) ${missingFiles}`)
  process.exit(1)
}
