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
recordList = [
  {ID: 1, Name: 'one'}
  {ID: 2, Name: 'two'}
  {ID: 3, Name: 'three'}
]
recordObject =
  '1': {Name: 'one'}
  '2': {Name: 'two'}
  '3': {Name: 'three'}

describe "Convert", ->

  describe "recordList", ->

    it "should transform from table", ->
      result = Table.toRecordList example
      expect(result).is.deep.equal recordList

    it "should transform from table (instance)", ->
      table = new Table example
      result = table.toRecordList()
      expect(result).is.deep.equal recordList

    it "should transform into table", ->
      result = Table.fromRecordList recordList
      expect(result).is.deep.equal example

    it "should transform into table (instance)", ->
      table = new Table()
      result = table.fromRecordList recordList
      expect(table.data).is.deep.equal example
      expect(result).to.be.instanceof Table

  describe "recordObject", ->

    it "should transform from table", ->
      result = Table.toRecordObject example
      expect(result).is.deep.equal recordObject

    it "should transform from table (instance)", ->
      table = new Table example
      result = table.toRecordObject()
      expect(result).is.deep.equal recordObject

    it "should transform into table", ->
      result = Table.fromRecordObject recordObject
      expect(result).is.deep.equal example

    it "should transform into table (instance)", ->
      table = new Table()
      result = table.fromRecordObject recordObject
      expect(table.data).is.deep.equal example
      expect(result).to.be.instanceof Table
