chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###

Table = require '../../src/index'


example = [
  ['ID', 'Name']
  [1, 'one']
  [2, 'two']
  [3, 'three']
]

describe "Instance", ->

  it "should create empty instance", ->
    table = new Table()
    expect(table).to.be.an.instanceof Table
    expect(table.data).to.deep.equal []

  it "should create instance from table", ->
    table = new Table example
    expect(table).to.be.an.instanceof Table
    expect(table.data).to.deep.equal example
