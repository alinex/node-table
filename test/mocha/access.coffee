chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###

Table = require '../../src/index'
example = null
table = null

describe "Access", ->

  beforeEach ->
    example = [
      ['ID', 'Name']
      [1, 'one']
      [2, 'two']
      [3, 'three']
    ]
    table = new Table example

  describe "field", ->

    it "should get entries by number", ->
      expect(Table.field(example, 1, 1), '1/1').to.equal 'one'
      expect(Table.field(example, 3, 0), '3/0').to.equal 3

    it "should get entries by number (instance)", ->
      expect(table.field(1, 1), '1/1').to.equal 'one'
      expect(table.field(3, 0), '3/0').to.equal 3

    it "should get entries by name", ->
      expect(Table.field(example, 1, 'Name'), '1/1').to.equal 'one'
      expect(Table.field(example, 3, 'ID'), '3/0').to.equal 3

    it "should get entries by name (instance)", ->
      expect(table.field(1, 'Name'), '1/1').to.equal 'one'
      expect(table.field(3, 'ID'), '3/0').to.equal 3

    it "should set entries by number", ->
      expect(Table.field(example, 1, 1, 'two'), '1/1').to.equal 'two'
      expect(Table.field(example, 3, 0, '3.0'), '3/0').to.equal '3.0'

    it "should set entries by number (instance)", ->
      result = table.field 1, 1, 'two'
      expect(table.field(1, 1), '1/1').to.equal 'two'
      expect(result).to.be.instanceof Table

    it "should set entries by name", ->
      expect(Table.field(example, 1, 'Name', 'two'), '1/1').to.equal 'two'
      expect(Table.field(example, 3, 'ID', '3.0'), '3/0').to.equal '3.0'

    it "should set entries by name (instance)", ->
      result = table.field 1, 'Name', 'two'
      expect(table.field(1, 1), '1/1').to.equal 'two'
      expect(result).to.be.instanceof Table

  describe "row", ->

    it "should get entries by number", ->
      expect(Table.row(example, 1), '1').to.deep.equal {ID: 1, Name: 'one'}

    it "should get entries by number (instance)", ->
      expect(table.row(1), '1').to.deep.equal {ID: 1, Name: 'one'}

    it "should set entries by number", ->
      expect(Table.row(example, 1, {ID: 3, Name: 'three'}), '1').to.deep.equal {ID: 3, Name: 'three'}

    it "should set entries by number (instance)", ->
      result = table.row 1, {ID: 3, Name: 'three'}
      expect(table.row(1), '1').to.deep.equal {ID: 3, Name: 'three'}
      expect(result).to.be.instanceof Table

  describe "insert", ->

    it "should insert two rows", ->
      Table.insert example, 2, [[5, 'five'], [6, 'six']]
      expect(example).to.deep.equal [
        ['ID', 'Name']
        [1, 'one']
        [5, 'five']
        [6, 'six']
        [2, 'two']
        [3, 'three']
      ]

    it "should insert two rows (instance)", ->
      result = table.insert 2, [[5, 'five'], [6, 'six']]
      expect(result).to.be.instanceof Table
      expect(table.data).to.deep.equal [
        ['ID', 'Name']
        [1, 'one']
        [5, 'five']
        [6, 'six']
        [2, 'two']
        [3, 'three']
      ]

    it "should insert two rows at the end", ->
      Table.insert example, null, [[5, 'five']]
      Table.insert example, [[6, 'six']]
      expect(example).to.deep.equal [
        ['ID', 'Name']
        [1, 'one']
        [2, 'two']
        [3, 'three']
        [5, 'five']
        [6, 'six']
      ]

    it "should insert two rows at the end (instance)", ->
      result = table.insert null, [[5, 'five'], [6, 'six']]
      expect(result).to.be.instanceof Table
      expect(table.data).to.deep.equal [
        ['ID', 'Name']
        [1, 'one']
        [2, 'two']
        [3, 'three']
        [5, 'five']
        [6, 'six']
      ]

  describe "delete", ->

    it "should delete one row", ->
      Table.delete example, 2
      expect(example).to.deep.equal [
        ['ID', 'Name']
        [1, 'one']
        [3, 'three']
      ]

    it "should delete two rows", ->
      Table.delete example, 2, 2
      expect(example).to.deep.equal [
        ['ID', 'Name']
        [1, 'one']
      ]

    it "should delete one row (instance)", ->
      result = table.delete 2
      expect(result).to.be.instanceof Table
      expect(table.data).to.deep.equal [
        ['ID', 'Name']
        [1, 'one']
        [3, 'three']
      ]

  describe "shift", ->

    it "should get first row", ->
      record = Table.shift example
      expect(record).to.deep.equal {ID: 1, Name: 'one'}
      expect(example).to.deep.equal [
        ['ID', 'Name']
        [2, 'two']
        [3, 'three']
      ]

    it "should get first row (instance)", ->
      record = table.shift()
      expect(record).to.deep.equal {ID: 1, Name: 'one'}
      expect(table.data).to.deep.equal [
        ['ID', 'Name']
        [2, 'two']
        [3, 'three']
      ]

  describe "unshift", ->

    it "should add row to the front", ->
      Table.unshift example, {ID: 6, Name: 'six'}
      expect(example).to.deep.equal [
        ['ID', 'Name']
        [6, 'six']
        [1, 'one']
        [2, 'two']
        [3, 'three']
      ]

    it "should add row to the front (instance)", ->
      result = table.unshift {ID: 6, Name: 'six'}
      expect(result).to.be.instanceof Table
      expect(table.data).to.deep.equal [
        ['ID', 'Name']
        [6, 'six']
        [1, 'one']
        [2, 'two']
        [3, 'three']
      ]

  describe "pop", ->

    it "should get last row", ->
      record = Table.pop example
      expect(record).to.deep.equal {ID: 3, Name: 'three'}
      expect(example).to.deep.equal [
        ['ID', 'Name']
        [1, 'one']
        [2, 'two']
      ]

    it "should get last row (instance)", ->
      record = table.pop()
      expect(record).to.deep.equal {ID: 3, Name: 'three'}
      expect(table.data).to.deep.equal [
        ['ID', 'Name']
        [1, 'one']
        [2, 'two']
      ]

  describe "push", ->

    it "should add row at the end", ->
      Table.push example, {ID: 6, Name: 'six'}
      expect(example).to.deep.equal [
        ['ID', 'Name']
        [1, 'one']
        [2, 'two']
        [3, 'three']
        [6, 'six']
      ]

    it "should add row at the end (instance)", ->
      result = table.push {ID: 6, Name: 'six'}
      expect(result).to.be.instanceof Table
      expect(table.data).to.deep.equal [
        ['ID', 'Name']
        [1, 'one']
        [2, 'two']
        [3, 'three']
        [6, 'six']
      ]

  describe "column", ->

    it "should get a column by number", ->
      result = Table.column example, 1
      expect(result).to.deep.equal ['one', 'two', 'three']

    it "should get a column by name", ->
      result = Table.column example, 'Name'
      expect(result).to.deep.equal ['one', 'two', 'three']

    it "should set a column by number", ->
      result = Table.column example, 1, ['eins', 'zwei', 'drei']
      expect(result).to.deep.equal ['eins', 'zwei', 'drei']

    it "should get a column by number (instance)", ->
      result = table.column 1
      expect(result).to.deep.equal ['one', 'two', 'three']

    it "should set a column by number (instance)", ->
      result = table.column 1, ['eins', 'zwei', 'drei']
      expect(result).to.be.instanceof Table
      result = table.column 1
      expect(result).to.deep.equal ['eins', 'zwei', 'drei']

  describe "columnAdd", ->

    it "should add a column", ->
      Table.columnAdd example, 1, 'DE'
      expect(example).to.deep.equal [
        [ 'ID', 'DE', 'Name' ]
        [ 1, null, 'one' ]
        [ 2, null, 'two' ]
        [ 3, null, 'three' ]
      ]

    it "should add a column with values", ->
      Table.columnAdd example, 1, 'DE', ['eins', 'zwei', 'drei']
      expect(example).to.deep.equal [
        [ 'ID', 'DE', 'Name' ]
        [ 1, 'eins', 'one' ]
        [ 2, 'zwei', 'two' ]
        [ 3, 'drei', 'three' ]
      ]

    it "should add a column (instance)", ->
      result = table.columnAdd 1, 'DE'
      expect(result).to.be.instanceof Table
      expect(table.data).to.deep.equal [
        [ 'ID', 'DE', 'Name' ]
        [ 1, null, 'one' ]
        [ 2, null, 'two' ]
        [ 3, null, 'three' ]
      ]

  describe "columnRemove", ->

    it "should remove a column", ->
      Table.columnRemove example, 0
      expect(example).to.deep.equal [
        [ 'Name' ]
        [ 'one' ]
        [ 'two' ]
        [ 'three' ]
      ]

    it "should remove a column (instance)", ->
      result = table.columnRemove 0
      expect(result).to.be.instanceof Table
      expect(table.data).to.deep.equal [
        [ 'Name' ]
        [ 'one' ]
        [ 'two' ]
        [ 'three' ]
      ]
