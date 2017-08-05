const approvals = require('approvals')
const { describe, it } = require('mocha')
import * as path from 'path'
import {
  KaleidoscopeReporter,
  assertCommandOutput,
  expectCommandSuccess,
  approveFile
} from './helpers'

approvals.configure({
  reporters: [new KaleidoscopeReporter()]
})

describe('end to end', function() {
  it('gives error for non-existent input file', () => {
    const binFile = path.join(__dirname, '../../bin/elm-electron')
    const ipcFile = path.join(__dirname, 'NonExistentIpc.elm')
    const outputElmPath = path.join(__dirname, '../../generated', 'Result.elm')
    const outputTsPath = path.join(__dirname, '../../generated', 'result.ts')
    const command = `/usr/local/bin/node ${binFile} ${ipcFile} --ts ${outputTsPath} --elm ${outputElmPath}`
    expectCommandSuccess(`/usr/local/bin/npm run build`)
    assertCommandOutput(command, 'nonexistentInputFileError')
  }).timeout(30000)

  it('gives error for invalid syntax input file', () => {
    const binFile = path.join(__dirname, '../../bin/elm-electron')
    const ipcFile = path.join(__dirname, '../../InvalidIpc.elm')
    const outputElmPath = path.join(__dirname, '../../generated', 'Result.elm')
    const outputTsPath = path.join(__dirname, '../../generated', 'result.ts')
    const command = `/usr/local/bin/node ${binFile} ${ipcFile} --ts ${outputTsPath} --elm ${outputElmPath}`
    expectCommandSuccess(`/usr/local/bin/npm run build`)
    assertCommandOutput(command, 'invalidSyntaxInputFileError')
  }).timeout(30000)

  it('gives error for unsupported constructor parameter', () => {
    const binFile = path.join(__dirname, '../../bin/elm-electron')
    const ipcFile = path.join(__dirname, '../../UnsupportedParameterIpc.elm')
    const outputElmPath = path.join(__dirname, '../../generated', 'Result.elm')
    const outputTsPath = path.join(__dirname, '../../generated', 'result.ts')
    const command = `/usr/local/bin/node ${binFile} ${ipcFile} --ts ${outputTsPath} --elm ${outputElmPath}`
    expectCommandSuccess(`/usr/local/bin/npm run build`)
    assertCommandOutput(command, 'unsupportedParameterError')
  }).timeout(30000)

  it('generates ts and elm files with a valid input file', () => {
    const binFile = path.join(__dirname, '../../bin/elm-electron')
    const ipcFile = path.join(__dirname, 'Ipc.elm')
    const outputElmPath = path.join(__dirname, '../../generated', 'Result.elm')
    const outputTsPath = path.join(__dirname, '../../generated', 'result.ts')
    const command = `/usr/local/bin/node ${binFile} ${ipcFile} --ts ${outputTsPath} --elm ${outputElmPath}`

    expectCommandSuccess(`/usr/local/bin/npm run build`)
    expectCommandSuccess(command)
    approveFile('validInputTs', outputTsPath)
    approveFile('validInputElm', outputElmPath)
  }).timeout(30000)
})
