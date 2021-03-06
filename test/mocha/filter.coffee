chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###

util = require 'alinex-util'
Table = require '../../src/index'
example = null
table = null

describe "Filter", ->

  beforeEach ->
    example = [
      ['ID', 'Name', 'DE']
      [1, 'one', 'eins']
      [2, 'two', 'zwei']
      [2, 'two', 'zwo']
      [4, 'four', 'vier']
      [5, 'five', 'fünf']
      [5, 'five', 'fünf']
    ]
    table = new Table example

  describe "columns", ->

    it "should rename columns", ->
      result = Table.columns example,
        ID: true
        EN: true
        DE: true
      expect(result).to.deep.equal [
        [ 'ID', 'EN', 'DE' ]
        [1, 'one', 'eins']
        [2, 'two', 'zwei']
        [2, 'two', 'zwo']
        [4, 'four', 'vier']
        [5, 'five', 'fünf']
        [5, 'five', 'fünf']
      ]
    it "should rename columns (instance)", ->
      result = table.columns(
        ID: true
        EN: true
        DE: true
      )
      expect(result).to.be.instanceof Table
      expect(table.data).to.deep.equal [
        [ 'ID', 'EN', 'DE' ]
        [1, 'one', 'eins']
        [2, 'two', 'zwei']
        [2, 'two', 'zwo']
        [4, 'four', 'vier']
        [5, 'five', 'fünf']
        [5, 'five', 'fünf']
      ]

    it "should resort columns", ->
      result = Table.columns example,
        ID: true
        DE: 'DE'
        EN: 'Name'
      expect(result).to.deep.equal [
        [ 'ID', 'DE', 'EN' ]
        [ 1, 'eins', 'one' ]
        [ 2, 'zwei', 'two' ]
        [ 2, 'zwo', 'two' ]
        [ 4, 'vier', 'four' ]
        [ 5, 'fünf', 'five' ]
        [ 5, 'fünf', 'five' ]
      ]
    it "should resort columns (instance)", ->
      result = table.columns
        ID: true
        DE: 'DE'
        EN: 'Name'
      expect(result).to.be.instanceof Table
      expect(table.data).to.deep.equal [
        [ 'ID', 'DE', 'EN' ]
        [ 1, 'eins', 'one' ]
        [ 2, 'zwei', 'two' ]
        [ 2, 'zwo', 'two' ]
        [ 4, 'vier', 'four' ]
        [ 5, 'fünf', 'five' ]
        [ 5, 'fünf', 'five' ]
      ]

  describe "unique", ->

    it "should remove complete duplicates", ->
      result = Table.unique example
      expect(result).to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [1, 'one', 'eins']
        [2, 'two', 'zwei']
        [2, 'two', 'zwo']
        [4, 'four', 'vier']
        [5, 'five', 'fünf']
      ]
    it "should remove complete duplicates (instance)", ->
      result = table.unique()
      expect(result).to.be.instanceof Table
      expect(table.data).to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [1, 'one', 'eins']
        [2, 'two', 'zwei']
        [2, 'two', 'zwo']
        [4, 'four', 'vier']
        [5, 'five', 'fünf']
      ]

    it "should remove duplicates", ->
      result = Table.unique example, 'Name'
      expect(result).to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [1, 'one', 'eins']
        [2, 'two', 'zwei']
        [4, 'four', 'vier']
        [5, 'five', 'fünf']
      ]
    it "should remove duplicates (instance)", ->
      result = table.unique 'Name'
      expect(result).to.be.instanceof Table
      expect(table.data).to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [1, 'one', 'eins']
        [2, 'two', 'zwei']
        [4, 'four', 'vier']
        [5, 'five', 'fünf']
      ]

  describe "rows", ->

    it "should keep equal strings", ->
      result = Table.filter example, 'Name = two'
      expect(result).to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [2, 'two', 'zwei']
        [2, 'two', 'zwo']
      ]
    it "should keep equal strings (instance)", ->
      result = table.filter 'Name = two'
      expect(result).to.be.instanceof Table
      expect(table.data).to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [2, 'two', 'zwei']
        [2, 'two', 'zwo']
      ]

    it "should test integer comparison", ->
      result = Table.filter util.clone(example), ['ID < 2']
      expect(result, '<').to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [1, 'one', 'eins']
      ]
      result = Table.filter util.clone(example), ['ID <= 2']
      expect(result, '<=').to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [1, 'one', 'eins']
        [2, 'two', 'zwei']
        [2, 'two', 'zwo']
      ]
      result = Table.filter util.clone(example), ['ID == 2']
      expect(result, '==').to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [2, 'two', 'zwei']
        [2, 'two', 'zwo']
      ]
      result = Table.filter util.clone(example), ['ID >= 2']
      expect(result, '>=').to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [2, 'two', 'zwei']
        [2, 'two', 'zwo']
        [4, 'four', 'vier']
        [5, 'five', 'fünf']
        [5, 'five', 'fünf']
      ]
      result = Table.filter util.clone(example), ['ID > 2']
      expect(result, '>').to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [4, 'four', 'vier']
        [5, 'five', 'fünf']
        [5, 'five', 'fünf']
      ]

    it "should test 'and' rules", ->
      result = Table.filter example, ['ID < 3', 'ID > 1']
      expect(result).to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [2, 'two', 'zwei']
        [2, 'two', 'zwo']
      ]

    it "should test 'or' rules", ->
      result = Table.filter example, [['ID < 2', 'ID > 2']]
      expect(result).to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [1, 'one', 'eins']
        [4, 'four', 'vier']
        [5, 'five', 'fünf']
        [5, 'five', 'fünf']
      ]
