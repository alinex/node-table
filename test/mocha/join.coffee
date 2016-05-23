chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###

Table = require '../../src/index'
example = null
table = null
example1 = null
table1 = null
example2 = null
table2 = null

describe "Join", ->

  beforeEach ->
    example = [
      ['ID', 'Name']
      [1, 'one']
      [2, 'two']
      [3, 'three']
    ]
    table = new Table example
    example1 = [
      ['ID', 'Name']
      [4, 'four']
      [5, 'five']
      [6, 'six']
    ]
    table1 = new Table example1
    example2 = [
      ['Name', 'DE']
      ['two', 'zwei']
      ['seven', 'sieben']
    ]
    table2 = new Table example2

  describe "append", ->

    it "should append two tables", ->
      result = Table.append example, example1
      expect(result).to.deep.equal [
        ['ID', 'Name']
        [1, 'one']
        [2, 'two']
        [3, 'three']
        [4, 'four']
        [5, 'five']
        [6, 'six']
      ]

  describe "join", ->

    it "should left join tables", ->
      result = Table.join example, 'left', example2
      expect(result).to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [ 1, 'one', null ]
        [ 2, 'two', 'zwei' ]
        [ 3, 'three', null ]
      ]

    it "should inner join tables", ->
      result = Table.join example, 'inner', example2
      expect(result).to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [ 2, 'two', 'zwei' ]
      ]

    it "should right join tables", ->
      result = Table.join example, 'right', example2
      expect(result).to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [ 2, 'two', 'zwei' ]
        [ null, 'seven', 'sieben' ]
      ]

    it "should outer join tables", ->
      result = Table.join example, 'outer', example2
      expect(result).to.deep.equal [
        [ 'ID', 'Name', 'DE' ]
        [ 1, 'one', null ]
        [ 3, 'three', null ]
        [ null, 'seven', 'sieben' ]
      ]
