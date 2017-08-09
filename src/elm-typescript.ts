const Elm = require('./Main.elm')
import * as fs from 'fs'
import * as minimist from 'minimist'

const args = minimist(process.argv.slice(2))
const inputPath = args._[0]
const tsDeclarationPath = args.output

if (fs.existsSync(inputPath)) {
  const elmModuleFileContents = fs.readFileSync(inputPath).toString()

  let app = Elm.Main.worker({ elmModuleFileContents })
  app.ports.generatedFiles.subscribe(function(typescriptDeclarationFile: any) {
    fs.writeFileSync(tsDeclarationPath, typescriptDeclarationFile)
  })

  app.ports.parsingError.subscribe(function(errorString: string) {
    console.error(`Error parsing input file ${inputPath}\n`)
    console.error(errorString)
    process.exit(1)
  })
} else {
  console.error(`Could not found input file ${inputPath}`)
  process.exit(1)
}
