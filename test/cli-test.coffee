chai = require 'chai'
chai.should()
cp = require 'child_process'
pack = require '../package.json'
cmd_version = 'node bin/autometa -v'
cmd_help = 'node bin/autometa -h'
cmd_stdout = 'node bin/autometa -o test/test.xlsx'
cmd_notexistsfile = 'node bin/autometa not-exists-file'

# Fix the problem that cannot capture
# a child process's stdout and stderr in Windows
# https://gist.github.com/cowboy/3427148
exit = (exitCode) ->
  if (process.stdout._pendingWriteReqs || process.stderr._pendingWriteReqs)
    process.nextTick =>
      exit(exitCode)
  else
    process.exit(exitCode)

describe 'autometa command-line interface test', ->

  it 'return version if -v option specified', (done) =>
    cp.exec cmd_version, (error, stdout, stderr) =>
      stdout.toString().should.string(pack['version'])
      done()

  it 'return help message if -h option specified', (done) =>
    cp.exec cmd_help, (error, stdout, stderr) =>
      stdout.toString().should.string('help')
      done()

  it 'return output to stdout if -o option specified', (done) =>
    cp.exec cmd_stdout, (error, stdout, stderr) =>
      stdout.toString().should.string('test.xml')
      done()

  it 'return error messsage if not exists file specified', (done) =>
    cp.exec cmd_notexistsfile, (error, stdout, stderr) =>
      stdout.toString().should.equal('Error. Check input file.\n')
      done()

