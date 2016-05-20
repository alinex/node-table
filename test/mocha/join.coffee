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

describe.skip "Join", ->

  describe "append", ->

    it "should append equal tables", ->
      result = table.append example, [
        ['ID', 'Name']
        [4, 'four']
        [5, 'five']
        [6, 'six']
      ], [
        ['ID', 'Name']
        [7, 'seven']
      ]
      expect(result).is.deep.equal [
        ['ID', 'Name']
        [1, 'one']
        [2, 'two']
        [3, 'three']
        [4, 'four']
        [5, 'five']
        [6, 'six']
        [7, 'seven']
      ]
