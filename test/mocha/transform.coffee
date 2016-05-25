chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###

Table = require '../../src/index'
example = null
table = null

describe "Transform", ->

  beforeEach ->
    example = [
      ['ID', 'Name', 'DE']
      [1, 'one', 'eins']
      [2, 'two', 'zwei']
      [3, 'three', 'drei']
      [4, 'four', 'vier']
      [5, 'five', 'fünf']
      [6, 'six', 'sechs']
    ]
    table = new Table example

  describe "sort", ->

    it "should sort one column", ->
      result = Table.sort example, 1
      expect(result).to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [ 5, 'five', 'fünf' ]
        [ 4, 'four', 'vier' ]
        [ 1, 'one', 'eins' ]
        [ 6, 'six', 'sechs' ]
        [ 3, 'three', 'drei' ]
        [ 2, 'two', 'zwei' ]
      ]
    it "should sort one column (instance)", ->
      result = table.sort 1
      expect(result).to.be.instanceof Table
      expect(table.data).to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [ 5, 'five', 'fünf' ]
        [ 4, 'four', 'vier' ]
        [ 1, 'one', 'eins' ]
        [ 6, 'six', 'sechs' ]
        [ 3, 'three', 'drei' ]
        [ 2, 'two', 'zwei' ]
      ]

    it "should sort one column by name", ->
      result = Table.sort example, 'Name'
      expect(result).to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [ 5, 'five', 'fünf' ]
        [ 4, 'four', 'vier' ]
        [ 1, 'one', 'eins' ]
        [ 6, 'six', 'sechs' ]
        [ 3, 'three', 'drei' ]
        [ 2, 'two', 'zwei' ]
      ]

    it "should sort one column desc", ->
      result = Table.sort example, '-Name'
      expect(result).to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [ 2, 'two', 'zwei' ]
        [ 3, 'three', 'drei' ]
        [ 6, 'six', 'sechs' ]
        [ 1, 'one', 'eins' ]
        [ 4, 'four', 'vier' ]
        [ 5, 'five', 'fünf' ]
      ]

  describe "reverse", ->

    it "should reverse sort after one column", ->
      result = Table.reverse example, 0
      expect(result).to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [ 6, 'six', 'sechs' ]
        [ 5, 'five', 'fünf' ]
        [ 4, 'four', 'vier' ]
        [ 3, 'three', 'drei' ]
        [ 2, 'two', 'zwei' ]
        [ 1, 'one', 'eins' ]
      ]
    it "should reverse sort after one column (instance)", ->
      result = table.reverse 0
      expect(result).to.be.instanceof Table
      expect(table.data).to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [ 6, 'six', 'sechs' ]
        [ 5, 'five', 'fünf' ]
        [ 4, 'four', 'vier' ]
        [ 3, 'three', 'drei' ]
        [ 2, 'two', 'zwei' ]
        [ 1, 'one', 'eins' ]
      ]

    it "should reverse sort after one column by name", ->
      result = Table.reverse example, 'ID'
      expect(result).to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [ 6, 'six', 'sechs' ]
        [ 5, 'five', 'fünf' ]
        [ 4, 'four', 'vier' ]
        [ 3, 'three', 'drei' ]
        [ 2, 'two', 'zwei' ]
        [ 1, 'one', 'eins' ]
      ]

  describe "flip", ->

    it "should flip x and y columns", ->
      result = Table.flip example
      expect(result).to.deep.equal [
        [ 'ID', 1, 2, 3, 4, 5, 6 ]
        [ 'Name', 'one', 'two', 'three', 'four', 'five', 'six' ]
        [ 'DE', 'eins', 'zwei', 'drei', 'vier', 'fünf', 'sechs' ]
      ]
    it "should flip x and y columns (instance)", ->
      result = table.flip()
      expect(result).to.be.instanceof Table
      expect(table.data).to.deep.equal [
        [ 'ID', 1, 2, 3, 4, 5, 6 ]
        [ 'Name', 'one', 'two', 'three', 'four', 'five', 'six' ]
        [ 'DE', 'eins', 'zwei', 'drei', 'vier', 'fünf', 'sechs' ]
      ]
