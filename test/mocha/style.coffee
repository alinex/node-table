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
table = new Table example

describe "Style", ->

  describe "cell", ->

    it "should set align", ->
      table.style 2, 1,
        align: 'left'
      expect(table.meta['2/1']).to.deep.equal {align: 'left'}

    it "should clear meta", ->
      table.style 1, 1, null
      expect(table.meta['1/1']).to.not.exist

  describe "col", ->

    it "should set align", ->
      table.style null, 1,
        align: 'left'
      expect(table.meta['*/1']).to.deep.equal {align: 'left'}

    it "should clear meta", ->
      table.style null, 1, null
      expect(table.meta['*/1']).to.not.exist

  describe "row", ->

    it "should set align", ->
      table.style 1, null,
        align: 'left'
      expect(table.meta['1/*']).to.deep.equal {align: 'left'}

    it "should clear meta", ->
      table.style 1, null, null
      expect(table.meta['1/*']).to.not.exist

  describe "sheet", ->

    it "should set align", ->
      table.style null, null,
        bg: 'left'
      expect(table.meta['*/*']).to.deep.equal {bg: 'left'}

    it "should clear meta", ->
      table.style null, null, null
      expect(table.meta['*/*']).to.not.exist

  describe "get", ->

    before ->
      table.meta =
        '*/*': {bg: 'white'}
        '*/1': {bg: 'silver'}
        '1/*': {weight: 'bold'}
        '1/1': {bg: 'yellow'}

    it "should get meta for sheet", ->
      expect(table.getMeta null, null).to.deep.equal {bg: 'white'}

    it "should get meta for column", ->
      expect(table.getMeta null, 1).to.deep.equal {bg: 'silver'}

    it "should get meta for row", ->
      expect(table.getMeta 1, null).to.deep.equal {bg: 'white', weight: 'bold'}

    it "should get meta for cell", ->
      expect(table.getMeta 1, 1).to.deep.equal {bg: 'yellow', weight: 'bold'}
