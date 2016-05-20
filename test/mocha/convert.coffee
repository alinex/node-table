chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###

table = require '../../src/index'


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
      result = table.toRecordList example
      expect(result).is.deep.equal recordList

    it "should transform into table", ->
      result = table.fromRecordList recordList
      expect(result).is.deep.equal example

  describe "recordObject", ->

    it "should transform from table", ->
      result = table.toRecordObject example
      expect(result).is.deep.equal recordObject

    it "should transform into table", ->
      result = table.fromRecordObject recordObject
      expect(result).is.deep.equal example

  describe "dump using report module", ->

    Report = require 'alinex-report'

    it "should dump table", ->
      report = new Report()
      report.table example
      expect(report.toString()).is.equal """
        \n| ID | Name  |
        |:-- |:----- |
        | 1  | one   |
        | 2  | two   |
        | 3  | three |\n"""
