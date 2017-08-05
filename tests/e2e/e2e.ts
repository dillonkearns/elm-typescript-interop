const approvals = require('approvals')
const { describe, it } = require('mocha')
import { exec } from 'child_process'
import * as fs from 'fs'
import * as path from 'path'
import { assert } from 'chai'

const binFile = path.join(__dirname, '../../bin/elm-electron')
const ipcFile = path.join(__dirname, 'Ipc.elm')
const outputElmPath = path.join(__dirname, '../../generated', 'Result.elm')
const outputTsPath = path.join(__dirname, '../../generated', 'result.ts')
let command = `/usr/local/bin/npm run build && /usr/local/bin/node ${binFile} ${ipcFile} --ts ${outputTsPath} --elm ${outputElmPath}`

const approveFile = (approvalDescription: string, relativePath: string) => {
  const fileBuffer = fs.readFileSync(path.join(relativePath))
  approvals.verify(__dirname, approvalDescription, fileBuffer.toString())
}

describe('end to end', function() {
  it('generates ts and elm files with a valid input file', (done: any) => {
    exec(command, (err, stdout, stderr) => {
      approveFile('validInputTs', outputTsPath)
      approveFile('validInputElm', outputElmPath)
      done()
    }).on('exit', code => {
      assert.equal(0, code)
    })
  }).timeout(30000)
})
