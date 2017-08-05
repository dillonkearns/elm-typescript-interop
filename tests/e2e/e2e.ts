const approvals = require('approvals')
const { describe, it } = require('mocha')
import { exec } from 'child_process'
import * as fs from 'fs'
import * as path from 'path'
import { assert } from 'chai'

const binFile = path.join(__dirname, '../../bin/elm-electron')
const ipcFile = path.join(__dirname, 'Ipc.elm')
let command = `/usr/local/bin/npm run build && /usr/local/bin/node ${binFile} ${ipcFile} --ts result.ts --elm Result.elm`

const approveFile = (approvalDescription: string, relativePath: string) => {
  const fileBuffer = fs.readFileSync(path.join(__dirname, relativePath))
  approvals.verify(__dirname, approvalDescription, fileBuffer.toString())
}

describe('end to end', function() {
  it('generates ts and elm files with a valid input file', (done: any) => {
    exec(command, (err, stdout, stderr) => {
      if (err || stderr) {
        throw err
      } else {
        approveFile('validInputTs', '../../result.ts')
        approveFile('validInputElm', '../../Result.elm')
      }
    }).on('exit', code => {
      assert.equal(0, code)
      done()
    })
  }).timeout(30000)
})
