const approvals = require('approvals')
const { describe, it } = require('mocha')
import * as child_process from 'child_process'
import * as fs from 'fs'
import * as path from 'path'
import { assert } from 'chai'

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
  it('generates ts and elm files with a valid input file', () => {
    const binFile = path.join(__dirname, '../../bin/elm-electron')
    const ipcFile = path.join(__dirname, 'Ipc.elm')
    const outputElmPath = path.join(__dirname, '../../generated', 'Result.elm')
    const outputTsPath = path.join(__dirname, '../../generated', 'result.ts')
    const command = `/usr/local/bin/npm run build && /usr/local/bin/node ${binFile} ${ipcFile} --ts ${outputTsPath} --elm ${outputElmPath}`

    expectCommandSuccess(command)
    approveFile('validInputTs', outputTsPath)
    approveFile('validInputElm', outputElmPath)
    let output = child_process.execSync(command)
  }).timeout(30000)
})
