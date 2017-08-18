const approvals = require('approvals')
const { describe, it } = require('mocha')
import * as path from 'path'
import {
  KaleidoscopeReporter,
  assertCommandOutput,
  expectCommandSuccess,
  approveFile
} from './helpers'

const binFile = path.join(__dirname, '../../bin/elm-typescript-interop')

describe('end to end', function() {
  it('generates ts definition for a valid input file file', () => {
    const elmInputFile = path.join(__dirname, '../../test_data/Main.elm')
    const outputTsPath = path.join(__dirname, '../../generated', 'result.d.ts')
    const command = `/usr/local/bin/node ${binFile} ${elmInputFile} --output ${outputTsPath}`

    expectCommandSuccess(`/usr/local/bin/npm run build`)
    expectCommandSuccess(command)
    approveFile('validInputTs', outputTsPath)
  })

  it('generates ts definition for a valid program with flags', () => {
    const elmInputFile = path.join(__dirname, '../../test_data/WithFlags.elm')
    const outputTsPath = path.join(__dirname, '../../generated', 'result.d.ts')
    const command = `/usr/local/bin/node ${binFile} ${elmInputFile} --output ${outputTsPath}`

    expectCommandSuccess(`/usr/local/bin/npm run build`)
    expectCommandSuccess(command)
    approveFile('withFlags', outputTsPath)
  })
})
