# Main controlling class
# =================================================


# Node Modules
# -------------------------------------------------

# include base modules
debug = require('debug') 'table'
# include alinex modules
util = require 'alinex-util'

class Table

  # Converion
  # -------------------------------------------------

  @fromRecordList: (obj) ->
    debug "record list -> table"
    keys = []
    list = obj.map (e) ->
      rows = []
      for k of e
        keys.push k unless k in keys
      for k in keys
        rows.push e[k]
      rows
    list.unshift keys
    list

  @toRecordList: (obj) ->
    debug "table -> record list"
    obj = util.clone obj
    keys = obj.shift()
    obj.map (e) ->
      map = {}
      map[k] = e[i] for k, i in keys
      map

  @fromRecordObject: (obj, idColumn) ->
    debug "record object -> table"
    keys = [idColumn ? 'ID']
    for k, v of obj
      for c of v
        keys.push c unless c in keys
    list = [keys]
    for k, v of obj
      row = [if isNaN k then k else parseInt k]
      for c in keys[1..]
        row.push v[c]
      list.push row
    list

  @toRecordObject: (obj) ->
    debug "table -> record object"
    res = {}
    keys = obj[0]
    for row in obj[1..]
      continue unless row[0]
      res[row[0]] = {}
      for k, i in keys[1..]
        res[row[0]][k] = row[i+1]
    res


  # Access Entries
  # -------------------------------------------------

  @field: (obj, row, col, value) ->
    col = obj[0].indexOf col unless typeof col is 'number' or col.match /^\d+$/
    debug "get field #{row}/#{col}"
    # set value
    obj[row][col] = value if value?
    # get value
    obj[row][col]

  @row: (obj, row, value) ->
    if value? and typeof value isnt 'object'
      throw Error "Could only set object as value of row"
    debug "get row #{row}"
    # set value
    if value
      for key, i in obj[0]
        obj[row][i] = value[key] if value[key]?
    # get value
    result = {}
    result[key] = obj[row][i] for key, i in obj[0]
    result

  @insert: (obj, pos, rows) ->
    unless rows
      rows = pos
      pos = null
    pos = obj.length unless pos
    debug "add row at position #{pos}"
    if pos
      obj.splice pos+i, 0, row for row, i in rows
    else
      obj.push.apply obj, rows
    obj

  @delete: (obj, pos, num = 1) ->
    debug "remove #{num} rows at position #{pos}"
    obj.splice pos, num
    obj

  @shift: (obj) ->
    debug "shift"
    result = @row obj, 1
    @delete obj, 1, 1
    result

  @unshift: (obj, record) ->
    debug "unshift"
    @insert obj, 1, [[]]
    @row obj, 1, record

  @pop: (obj) ->
    debug "pop"
    result = @row obj, obj.length-1
    @delete obj, obj.length-1, 1
    result

  @push: (obj, record) ->
    debug "push"
    obj.push []
    @row obj, obj.length-1, record

  @column: (obj, col, values) ->
    debug "add or set column #{col}"
    col = obj[0].indexOf col unless typeof col is 'number' or col.match /^\d+$/
    if values
      for row, i in obj
        row.splice col, 0, values?[i-1] ? null
    obj[1..].map (row) -> row[col]

  @columnAdd: (obj, col, name, values) ->
    col = obj[0].length unless col
    debug "add column before #{col}"
    col = obj[0].indexOf col unless typeof col is 'number' or col.match /^\d+$/
    for row, i in obj
      row.splice col, 0, values?[i-1] ? null
    obj[0][col] = name

  @columnRemove: (obj, col) ->
    col = obj[0].length unless col?
    debug "remove column #{col}"
    col = obj[0].indexOf col unless typeof col is 'number' or col.match /^\d+$/
    row.splice col, 1 for row in obj


  # Join
  # -------------------------------------------------

  @append: (base, tables...) ->
    debug "append"
    for table in tables
      # check or add cols
      baseCols = []
      for name in table[0]
        i = base[0].indexOf name
        if i >= 0
          baseCols.push i
        else
          baseCols.push base[0].length
          exports.columnAdd base, 1
      # add data
      for row, i in table[1..]
        nrow = base[0].map -> null
        for e, i in baseCols
          nrow[e] = row[i]
        base.push nrow
    base

  @join: (base, type, tables...) ->
    debug "join #{type}"
    for table in tables
      # get equal columns
      res = [util.clone base[0]]
      baseJoin = []
      baseJoinToTable = []
      tableJoin = []
      tableAdd = []
      for name, k in table[0]
        i = base[0].indexOf name
        if i >= 0
          baseJoin.push i
          baseJoinToTable.push [i, k]
          tableJoin.push k
        else
          res[0].push name
          tableAdd.push k
      # index
      index = {}
      for row, num in base[1..]
        name = stringify(baseJoin.map (e) -> row[e])
        index[name] ?=
          source: []
          dest: []
        index[name].source.push num+1
      # join dest
      for row, num in table[1..]
        name = stringify(tableJoin.map (e) -> row[e])
        index[name] ?=
          source: []
          dest: []
        index[name].dest.push num+1
      # set values from table
      for _, v of index
        # all inner
        if v.source.length and v.dest.length
          continue unless type in ['left', 'inner', 'right']
          for source in v.source
            for dest in v.dest
              res.push base[source].concat tableAdd.map (e) -> table[dest][e]
        else if v.source.length
          continue unless type in ['left', 'outer']
          for source in v.source
            res.push base[source].concat tableAdd.map -> null
        else if v.dest.length
          continue unless type in ['right', 'outer']
          for dest in v.dest
            nrow = (base[0].map -> null).concat tableAdd.map (e) -> table[dest][e]
            for e in baseJoinToTable
              nrow[e[0]] = table[dest][e[1]]
            res.push nrow
      base = res
    base


  # Transform
  # -------------------------------------------------

  # sort = '1,-2,4' or 'name,-age'
  @sort: (table, sort) ->
    sort = sort.split /,\s*/ if typeof sort is 'string'
    if Array.isArray sort
      sort = sort.map (col) ->
        order = ''
        if col[0] is '-'
          order = '-'
          col = col.substr 1
        col = table[0].indexOf col unless typeof col is 'number' or col.match /^\d+$/
        "#{order}#{col}"
      sort = sort.join ','
    sort = sort.toString()
    debug "sort by #{sort}"
    header = table.shift()
    table = util.array.sortBy.apply this, [table].concat sort
    table.unshift header
    table

  @reverse: (table) ->
    debug "reverse"
    header = table.shift()
    table.reverse()
    table.unshift header
    table

  @flip: (table) ->
    debug "flip"
    # flip
    flipped = []
    for row, x in table
      for col, y in row
        flipped[y] ?= []
        flipped[y][x] = col
    flipped




# formats = {<name>: <format>} or [<format>, ...]
  @format: (table, formats) ->
#    return cb() unless file.format
#    debug chalk.grey "#{meta.job}.#{name}: format columns"
#    async.each file.data, (row, cb) ->
#      async.each Object.keys(row), (col, cb) ->
#        return cb() unless file.format[col]
#        validator.check
#          name: "format-cell"
#          value: row[col]
#          schema: file.format[col]
#        , (err, result) ->
#          row[col] = result
#          cb()
#      , cb
#    , (err) ->
#      return cb err if err
#      cb()

  @rename: (table, col, name) ->


  # Filtering
  # -------------------------------------------------

  # columns = {<title>: <old name> or true or <num>}
  @columns: (table, columns) ->

  # columns = <num array> or <string array> (optional)
  @unique: (table, columns) ->
    file.data = util.array.unique file.data

  # conditions = {<name>: <cond>} or [<cond>, ...]
  @filter: (table, conditions) ->

  # conditions = {<name>: <cond>} or [<cond>, ...]
  @group: (table, conditions) ->


  # Instrances
  # -------------------------------------------------

  constructor: (base) ->
    @data = base ? []

  fromRecordList: (obj) ->
    @data = Table.fromRecordList obj
    this
  fromRecordObject: (obj) ->
    @data = Table.fromRecordObject obj
    this
  toRecordList: -> Table.toRecordList @data
  toRecordObject: -> Table.toRecordObject @data

  field: (row, col, value) ->
    result = Table.field @data, row, col, value
    if value? then this else result
  row: (row, value) ->
    result = Table.row @data, row, value
    if value? then this else result
  insert: (pos, rows) ->
    Table.insert @data, pos, rows
    this
  delete: (pos, num) ->
    Table.delete @data, pos, num
    this
  shift: -> Table.shift @data
  unshift: (record) ->
    Table.unshift @data, record
    this
  pop: -> Table.pop @data
  push: (record) ->
    Table.push @data, record
    this
  column: (col, values) ->
    result = Table.column @data, col, values
    if values? then this else result
  columnAdd: (col, name, values) ->
    Table.columnAdd @data, col, name, values
    this
  columnRemove: (col) ->
    Table.columnRemove @data, col
    this

  append: (tables...) ->
    for table in tables
      @data = Table.append @data, table.data ? table
    this
  join: (type, tables...) ->
    for table in tables
      @data = Table.join @data, type, table.data ? table
    this

  sort: (sort) ->
    @data = Table.sort @data, sort
    this
  reverse: ->
    @data = Table.reverse @data
    this
  flip: ->
    @data = Table.flip @data
    this


# Export class
# -------------------------------------------------
module.exports = Table


# Helper methods
# -------------------------------------------------
stringify = JSON.stringify
