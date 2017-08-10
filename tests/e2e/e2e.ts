const approvals = require('approvals')
const { describe, it } = require('mocha')
import * as path from 'path'
import {
  KaleidoscopeReporter,
  assertCommandOutput,
  expectCommandSuccess,
  approveFile
} from './helpers'

describe('end to end', function() {
  // it('gives error for non-existent input file', () => {
  //   const binFile = path.join(__dirname, '../../bin/elm-typescript')
  //   const ipcFile = path.join(__dirname, 'NonExistentIpc.elm')
  //   const outputElmPath = path.join(__dirname, '../../generated', 'Result.elm')
  //   const outputTsPath = path.join(__dirname, '../../generated', 'result.ts')
  //   const command = `/usr/local/bin/node ${binFile} ${ipcFile} --ts ${outputTsPath} --elm ${outputElmPath}`
  //   expectCommandSuccess(`/usr/local/bin/npm run build`)
  //   assertCommandOutput(command, 'nonexistentInputFileError')
  // })
  //
  // it('gives error for invalid syntax input file', () => {
  //   const binFile = path.join(__dirname, '../../bin/elm-typescript')
  //   const ipcFile = path.join(__dirname, '../../InvalidIpc.elm')
  //   const outputElmPath = path.join(__dirname, '../../generated', 'Result.elm')
  //   const outputTsPath = path.join(__dirname, '../../generated', 'result.ts')
  //   const command = `/usr/local/bin/node ${binFile} ${ipcFile} --ts ${outputTsPath} --elm ${outputElmPath}`
  //   expectCommandSuccess(`/usr/local/bin/npm run build`)
  //   assertCommandOutput(command, 'invalidSyntaxInputFileError')
  // })
  //
  // it('gives error for unsupported constructor parameter', () => {
  //   const binFile = path.join(__dirname, '../../bin/elm-typescript')
  //   const ipcFile = path.join(__dirname, '../../UnsupportedParameterIpc.elm')
  //   const outputElmPath = path.join(__dirname, '../../generated', 'Result.elm')
  //   const outputTsPath = path.join(__dirname, '../../generated', 'result.ts')
  //   const command = `/usr/local/bin/node ${binFile} ${ipcFile} --ts ${outputTsPath} --elm ${outputElmPath}`
  //   expectCommandSuccess(`/usr/local/bin/npm run build`)
  //   assertCommandOutput(command, 'unsupportedParameterError')
  // })

  it('generates ts definition for a valid input file file', () => {
    const binFile = path.join(__dirname, '../../bin/elm-typescript')
    const elmInputFile = path.join(__dirname, '../../test_data/Main.elm')
    const outputTsPath = path.join(__dirname, '../../generated', 'result.d.ts')
    const command = `/usr/local/bin/node ${binFile} ${elmInputFile} --output ${outputTsPath}`

    expectCommandSuccess(`/usr/local/bin/npm run build`)
    expectCommandSuccess(command)
    approveFile('validInputTs', outputTsPath)
  })

  it('generates ts definition for a valid program with flags', () => {
    const binFile = path.join(__dirname, '../../bin/elm-typescript')
    const elmInputFile = path.join(__dirname, '../../test_data/WithFlags.elm')
    const outputTsPath = path.join(__dirname, '../../generated', 'result.d.ts')
    const command = `/usr/local/bin/node ${binFile} ${elmInputFile} --output ${outputTsPath}`

    expectCommandSuccess(`/usr/local/bin/npm run build`)
    expectCommandSuccess(command)
    approveFile('withFlags', outputTsPath)
  })
})
