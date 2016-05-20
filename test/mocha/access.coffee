chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###

table = require '../../src/index'
example = null


describe "Access", ->

  beforeEach ->
    example = [
      ['ID', 'Name']
      [1, 'one']
      [2, 'two']
      [3, 'three']
    ]

  describe "field", ->

    it "should get entries by number", ->
      expect(table.field(example, 1, 1), '1/1').to.equal 'one'
      expect(table.field(example, 3, 0), '3/0').to.equal 3

    it "should get entries by name", ->
      expect(table.field(example, 1, 'Name'), '1/1').to.equal 'one'
      expect(table.field(example, 3, 'ID'), '3/0').to.equal 3

    it "should set entries by number", ->
      expect(table.field(example, 1, 1, 'two'), '1/1').to.equal 'two'
      expect(table.field(example, 3, 0, '3.0'), '3/0').to.equal '3.0'

    it "should set entries by name", ->
      expect(table.field(example, 1, 'Name', 'two'), '1/1').to.equal 'two'
      expect(table.field(example, 3, 'ID', '3.0'), '3/0').to.equal '3.0'

  describe "row", ->

    it "should get entries by number", ->
      expect(table.row(example, 1), '1').to.deep.equal {ID: 1, Name: 'one'}

    it "should set entries by number", ->
      expect(table.row(example, 1, {ID: 3, Name: 'three'}), '1').to.deep.equal {ID: 3, Name: 'three'}

  describe "insert", ->

    it "should insert two rows", ->
      table.insert example, 2, [[5, 'five'], [6, 'six']]
      expect(example).to.deep.equal [
        ['ID', 'Name']
        [1, 'one']
        [5, 'five']
        [6, 'six']
        [2, 'two']
        [3, 'three']
      ]

    it "should insert two rows at the end", ->
      table.insert example, null, [[5, 'five'], [6, 'six']]
      expect(example).to.deep.equal [
        ['ID', 'Name']
        [1, 'one']
        [2, 'two']
        [3, 'three']
        [5, 'five']
        [6, 'six']
      ]

  describe "delete", ->

    it "should delete one row", ->
      table.delete example, 2, 1
      expect(example).to.deep.equal [
        ['ID', 'Name']
        [1, 'one']
        [3, 'three']
      ]

  describe "shift", ->

    it "should get first row", ->
      record = table.shift example
      expect(record).to.deep.equal {ID: 1, Name: 'one'}
      expect(example).to.deep.equal [
        ['ID', 'Name']
        [2, 'two']
        [3, 'three']
      ]

  describe "unshift", ->

    it "should add row to the front", ->
      table.unshift example, {ID: 6, Name: 'six'}
      expect(example).to.deep.equal [
        ['ID', 'Name']
        [6, 'six']
        [1, 'one']
        [2, 'two']
        [3, 'three']
      ]

  describe "pop", ->

    it "should get last row", ->
      record = table.pop example
      expect(record).to.deep.equal {ID: 3, Name: 'three'}
      expect(example).to.deep.equal [
        ['ID', 'Name']
        [1, 'one']
        [2, 'two']
      ]

  describe "push", ->

    it "should add row at the end", ->
      table.push example, {ID: 6, Name: 'six'}
      expect(example).to.deep.equal [
        ['ID', 'Name']
        [1, 'one']
        [2, 'two']
        [3, 'three']
        [6, 'six']
      ]
