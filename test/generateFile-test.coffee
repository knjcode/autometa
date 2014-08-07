chai = require 'chai'
chai.should()
sinon = require 'sinon'
autometa = require '../src/autometa.coffee'

describe 'autometa generateFile function test', ->

  sandbox = sinon.sandbox.create()

  it 'return finish message if valid filename specified', ->
    sandbox.stub(console, 'log')
    autometa.generateFile('./test/test.xlsx')
    sinon.assert.calledTwice(console.log)
    sinon.assert.calledWithExactly(console.log, "Finish.")
    sandbox.restore()

  it 'return true if valid filename specified', ->
    sandbox.stub(console, 'log')
    autometa.generateFile('./test/test.xlsx').should.to.be.true
    sandbox.restore()

  it 'return false if invalid filename specified', ->
    autometa.generateFile('not-exist-file').should.to.be.false

