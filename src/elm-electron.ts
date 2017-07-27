const Elm = require('./Main.elm')
import * as fs from 'fs'
import * as minimist from 'minimist'

const args = minimist(process.argv.slice(2))
const inputPath = args._[0]
const tsPath = args.ts
const elmPath = args.elm

if (fs.existsSync(inputPath)) {
  const elmIpcFileContents = fs.readFileSync(inputPath).toString()

  let app = Elm.Main.worker({ elmIpcFileContents })
  app.ports.generatedFiles.subscribe(function([typescriptCode, elmCode]: any) {
    fs.writeFileSync(tsPath, typescriptCode)
    fs.writeFileSync(elmPath, elmCode)
  })

  app.ports.parsingError.subscribe(function(outputFile: any) {
    console.log(`Error parsing input file ${inputPath}\n`)
    console.log(outputFile)
    process.exit(1)
  })
} else {
  console.log(`Could not found input file ${inputPath}`)
}
