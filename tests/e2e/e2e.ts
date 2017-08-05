const approvals = require('approvals')
const { describe, it } = require('mocha')
import * as child_process from 'child_process'
import * as fs from 'fs'
import * as path from 'path'
import { assert } from 'chai'

class KaleidoscopeReporter {
  public name: string = 'ksdiff'
  canReportOn(receivedFilePath: string) {
    return true
  }
  report(approvedFilePath: string, receivedFilePath: string) {
    let commandOutput = child_process.execSync(
      `ksdiff ${approvedFilePath} ${receivedFilePath}`
    )
  }
}
approvals.configure({
  reporters: [new KaleidoscopeReporter()]
})

interface ExpectedStdOut {
  type: 'stdout'
  expected: string
}

interface ExpectedStdErr {
  type: 'stderr'
  expected: string
}

interface SuccessResult {
  type: 'success-result'
  stdout: string
}

interface ErrorResult {
  type: 'error-result'
  stderr: string
  stdout: string
  status: number
}
const approveFile = (approvalDescription: string, relativePath: string) => {
  const fileBuffer = fs.readFileSync(path.join(relativePath))
  approvals.verify(__dirname, approvalDescription, fileBuffer.toString())
}

type ExpectedOutput = ExpectedStdOut | ExpectedStdErr
type CommandResult = SuccessResult | ErrorResult

const assertCommandOutput = (command: string, approvalName: string) => {
  let commandResult: CommandResult
  try {
    let commandOutput = child_process.execSync(command).toString()
    commandResult = { type: 'success-result', stdout: commandOutput }
  } catch (error) {
    const { status, stdout, stderr } = error
    commandResult = {
      type: 'error-result',
      stderr: stderr && stderr.toString(),
      stdout: stdout && stdout.toString(),
      status: status
    }
  }
  approvals.verifyAsJSON(__dirname, approvalName, commandResult)
}

const expectCommandSuccess = (command: string) => {
  try {
    let commandOutput = child_process.execSync(command).toString()
  } catch (error) {
    const { status, stdout, stderr } = error
    let result = {
      type: 'error-result',
      stderr: stderr && stderr.toString(),
      stdout: stdout && stdout.toString(),
      status: status
    }
    assert.equal(
      status,
      0,
      `Command '${command} failed unexpectedly: ${JSON.stringify(result)}'`
    )
  }
}

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
    let output = child_process.execSync(command)
  }).timeout(30000)
})
