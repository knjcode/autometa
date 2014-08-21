chai = require 'chai'
chai.should()
cp = require 'child_process'
pack = require '../package.json'

csv_template_specified = 'node bin/autometa.js -r templates/test.csv'
ejs_template_specified = 'node bin/autometa.js -r templates/test.ejs'
csv_and_ejs_template_specified =
  'node bin/autometa.js -r templates/test.csv templates/test.ejs'
not_template_specified = 'node bin/autometa.js -r test/test.xlsx'
not_exists_template_specified = 'node bin/autometa.js -r not-exists-template'

describe 'autometa registerTemplates function should return', ->

  it 'success message if csv template specified', (done) ->
    cp.exec csv_template_specified, (error, stdout, stderr) ->
      stdout.toString().should.string('Register success: test.csv placed on')
      done()

  it 'success message if ejs template specified', (done) ->
    cp.exec ejs_template_specified, (error, stdout, stderr) ->
      stdout.toString().should.string('Register success: test.ejs placed on')
      done()

  it 'success message twice if csv and ejs template specified', (done) ->
    cp.exec csv_and_ejs_template_specified, (error, stdout, stderr) ->
      stdout.toString().should.string('Register success: test.csv placed on')
      stdout.toString().should.string('Register success: test.ejs placed on')
      done()

  it 'error message if not template specified', (done) ->
    cp.exec not_template_specified, (error, stdout, stderr) ->
      stdout.toString().should.string('Error. test.xlsx is not template.')
      done()

  it 'error messsage if not exists template specified', (done) ->
    cp.exec not_exists_template_specified, (error, stdout, stderr) ->
      stdout.toString().should.string('Error. Input file does not exist.')
      done()

