import * as child_process from 'child_process'
import { assert } from 'chai'
import * as fs from 'fs'
import * as path from 'path'
const approvals = require('approvals')

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

export {
  KaleidoscopeReporter,
  expectCommandSuccess,
  assertCommandOutput,
  approveFile
}
