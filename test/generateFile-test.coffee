chai = require 'chai'
chai.should()
sinon = require 'sinon'
autometa = require '../src/autometa.coffee'

describe 'autometa generateFile function should return', ->

  sandbox = sinon.sandbox.create()

  it 'true if valid filename specified', ->
    sandbox.stub(console, 'log')
    autometa.generateFile('./test/test.xlsx').should.to.be.true
    sandbox.restore()

  it 'false if invalid filename specified', ->
    autometa.generateFile('not-exist-file').should.to.be.false

  it 'finish message if valid filename specified', ->
    sandbox.stub(console, 'log')
    autometa.generateFile('./test/test.xlsx')
    sinon.assert.calledTwice(console.log)
    sinon.assert.calledWithExactly(console.log, "Finish.")
    sandbox.restore()

  it 'finish message twice if input excel spreadsheet with 2 sheets', ->
    sandbox.stub(console, 'log')
    autometa.generateFile('./test/test-2sheets.xlsx')
    sinon.assert.callCount(console.log, 4)
    sinon.assert.calledWithExactly(console.log, "Finish.")
    sandbox.restore()

