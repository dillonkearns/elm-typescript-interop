const Elm = require('./Main.elm')
import * as fs from 'fs'

const inputPath: string = process.argv[2]

if (fs.existsSync(inputPath)) {
  const elmIpcFileContents = fs.readFileSync(inputPath).toString()
  // elmIpcFileContents.toString()

  let app = Elm.Main.worker({ elmIpcFileContents })
  app.ports.generatedTypescript.subscribe(function(outputFile: any) {
    console.log(outputFile)
  })
} else {
  console.log(`Could not found input file ${inputPath}`)
}
