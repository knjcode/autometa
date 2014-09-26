chai = require 'chai'
chai.should()
exec = require('child_process').exec

cmd = 'node bin/autometa.js '
csv_template_specified = cmd + '-f -r templates/test.csv'
ejs_template_specified = cmd + '-f -r templates/test.ejs'
csv_and_ejs_template_specified =
  cmd + '-f -r templates/test.csv templates/test.ejs'
not_template_specified = cmd + '-r test/test.xlsx'
not_exists_template_specified = cmd + '-r not-exists-template'

describe 'autometa registerTemplates function should return', ->
  this.timeout 5000

  it 'success message if csv template specified', (done) ->
    exec csv_template_specified, (error, stdout, stderr) ->
      stdout.should.string('Register success: test.csv placed on')
      done()

  it 'success message if ejs template specified', (done) ->
    exec ejs_template_specified, (error, stdout, stderr) ->
      stdout.should.string('Register success: test.ejs placed on')
      done()

  it 'success message twice if csv and ejs template specified', (done) ->
    exec csv_and_ejs_template_specified, (error, stdout, stderr) ->
      unless error
        stdout.should.string('Register success: ')
        stdout = stdout.replace('Register success: ','')
        stdout.should.string('Register success: ')
        done()

  it 'error message if not template specified', (done) ->
    exec not_template_specified, (error, stdout, stderr) ->
      stderr.should.string('Error. test.xlsx is not template.')
      done()

  it 'error messsage if not exists template specified', (done) ->
    exec not_exists_template_specified, (error, stdout, stderr) ->
      stderr.should.string('Error. Input file does not exist.')
      done()

