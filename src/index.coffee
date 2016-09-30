###
Class - API Usage
=================================================
The exported class allows you to work with table data using it's class methods or
by creating an instance.
###


# Node Modules
# -------------------------------------------------
debug = require('debug') 'table'
deasync = require 'deasync'
# include alinex modules
util = require 'alinex-util'
validator = require 'alinex-validator'


# Class Definition
# -------------------------------------------------
class Table


  ###
  Static Conversion
  -------------------------------------------------
  To convert from and to the different data structures described above, you can
  use the following 4 methods:

  ``` coffee
  result = Table.fromRecordList recordList
  result = Table.fromRecordObject recordObject, idColumn
  result = Table.toRecordList example
  result = Table.toRecordObject example
  ```

  The conversion to record object will loose the name of the first column so it
  will always get 'ID' on back conversion ''fromRecordObject' if not defined otherwise.
  ###

  ###
  Convert from record list to table structure.

  @param {Array<Object>} obj record list to read
  @return {Array<Array>} table structure
  ###
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

  ###
  Convert from table structure to record list.

  @param {Array<Array>} obj table structure
  @return {Array<Object>} record list to read
  ###
  @toRecordList: (obj) ->
    debug "table -> record list"
    obj = util.clone obj
    keys = obj.shift()
    obj.map (e) ->
      map = {}
      map[k] = e[i] for k, i in keys
      map

  ###
  Convert from record object to table structure.

  @param {Object<Object>} obj record object to read
  @param {String} [idColumn] title for the id column to be used
  @return {Array<Array>} table structure
  ###
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

  ###
  Convert from table structure to record object.

  @param {Array<Array>} obj table structure
  @return {Object<Object>} record object to read
  ###
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


  ###
  Static Access
  -------------------------------------------------
  This methods allows you to easily read and edit the table data in your code.
  ###

  ###
  This method is used to access cell values or set them.

  __Examples__

  Read a cell value:

  ``` coffee
  value = Table.field example, 1, 1
  # will result value of field 1/1
  value = Table.field example, 1, 'Name'
  # do the same but using the column name
  ```

  And set a new value to a defined cell:

  ``` coffee
  Table.field example, 1, 1, 15.8
  # will set value of field 1/1
  Table.field example, 1, 'Name', 15.8
  # do the same but using the column name
  ```

  @param {Array<Array>} obj to access
  @param {Integer} row number from 1.. (0 is the heading)
  @param {Integer|String} column number of column 0.. or the name of a column
  @param [value] new value for the given cell
  @return the current (new) value of the given cell
  ###
  @field: (obj, row, col, value) ->
    col = obj[0].indexOf col unless typeof col is 'number' or col.match /^\d+$/
    debug "get field #{row}/#{col}"
    # set value
    obj[row][col] = value if value?
    # get value
    obj[row][col]

  ###
  Get or set a complete table row.

  __Examples__

  First you may read one row as record:

  ``` coffee
  record = Table.row example, 1
  # may return something like {ID: 1, Name: 'one'}
  ```

  And then you may also overwrite it with a changed version:

  ``` coffee
  Table.row example, 1, {ID: 3, Name: 'three'}
  ```

  @param {Array<Array>} obj to access
  @param {Integer} row number from 1.. (0 is the heading)
  @param {Array} [value] new value for the given row
  @return the defined row as object
  ###
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


  ###
  Static Join Functions
  -------------------------------------------------
  ###

  @append: (base, tables...) ->
    debug "append"
    for table in tables
      table = table.data if table instanceof Table
      # go on if table is empty
      continue unless table.length
      # easy step to do if base table is empty
      unless base.length
        base = table[0..]
        continue
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
      table = table.data if table instanceof Table
      # get equal columns
      res = [util.clone base[0] ? []]
      baseJoin = []
      baseJoinToTable = []
      tableJoin = []
      tableAdd = []
      for name, k in table[0]
        i = base[0]?.indexOf name
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


  ###
  Static Transform Functions
  -------------------------------------------------
  ###

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
    debug "format columns"
    # get format object with numbered columns
    map = {}
    if Array.isArray formats
      map[i] = f for f, i in formats
    else
      for col, v of formats
        col = table[0].indexOf col unless typeof col is 'number' or col.match /^\d+$/
        map[col] = v
    # format columns
    for col, format of map
      for row in table[1..]
        check = deasync validator.check
        row[col] = if typeof format is 'function'
          format row[col]
        else
          check
            name: "format-cell"
            value: row[col]
            schema: format
    # return
    table

  @rename: (table, col, name) ->
    debug "rename #{col} to #{name}"
    col = table[0].indexOf col unless typeof col is 'number' or col.match /^\d+$/
    table[0][col] = name
    table


  ###
  Static Filtering Functions
  -------------------------------------------------
  ###

  # cols = {<title>: <old name> or true or <num>}
  @columns: (table, cols) ->
    debug "change columns #{cols}"
    # get column numbers
    num = 0
    for key, col of cols
      if col is true
        col = num++
      else unless typeof col is 'number' or col.match /^\d+$/
        col = table[0].indexOf col
      cols[key] = col
    # rearrange
    changed = [Object.keys cols]
    for row in table[1..]
      changed.push Object.keys(cols).map (name) -> row[cols[name]]
    changed

  # cols = <num array> or <string array> (optional)
  @unique: (table, cols) ->
    debug "unique in #{cols ? 'all'} columns"
    # get columns
    cols = [0..table[0].length-1] unless cols
    cols = [cols] unless Array.isArray cols
    cols = cols.map (col) ->
      if typeof col is 'number' or col.match /^\d+$/ then col else table[0].indexOf col
    # find duplicates
    checked = []
    del = []
    for row, num in table[1..]
      c = stringify cols.map (e) -> row[e]
      if c in checked
        del.push num+1
      else
        checked.push c
    # and remove them
    del.reverse()
    Table.delete table, num for num in del
    table

  # conditions = [<cond>, ...]
  @filter: (table, conditions) ->
    debug "filter #{conditions}"
    # optimize conditions
    conditions = [conditions] unless Array.isArray conditions
    # internal function checking one cell against value
    check = (cell, op, val) ->
      switch typeof cell
        when 'number' then val = Number val
        when 'boolean' then val = Boolean val
      res = switch op.toLowerCase()
        when 'is', '=', '==' then cell is val
        when 'not', '!=', '<>' then cell isnt val
        when '>' then cell > val
        when '<' then cell < val
        when '>=', '=>' then cell >= val
        when '<=', '=<' then cell <= val
      res
    resolveCols = (cond, logic = false) ->
      if Array.isArray cond
        rules = cond.map (e) -> resolveCols e, not logic
        return if logic
          (row) ->
            # OR
            ok = false
            for rule in rules when rule row
              ok = true
              break
            ok
        else
          (row) ->
            # AND
            ok = true
            for rule in rules when not rule row
              ok = false
              break
            ok
      [col, op, val] = cond.split /\s+/
      col = if typeof col is 'number' or col.match /^\d+$/ then col else table[0].indexOf col
      (row) -> check row[col], op, val
    conditions = resolveCols conditions
    # check conditions on each row
    del = []
    for row, num in table[1..]
      del.push num+1 unless conditions row
    # and remove them
    del.reverse()
    Table.delete table, num for num in del
    table


  ###
  Create Instrances
  -------------------------------------------------
  A new `Table` instance can be done by using it's
  ###

  constructor: (base) ->
    @data = base ? []
    @meta = {}


  ###
  Conversion Methods
  -----------------------------------------------------
  To convert from and to the different data structures described above, you can
  use the following 4 methods:

  ``` coffee
  table.fromRecordList recordList
  table.fromRecordObject recordObject, idColumn
  result = table.toRecordList()
  result = table.toRecordObject()
  ```

  The conversion to record object will loose the name of the first column so it
  will always get 'ID' on back conversion ''fromRecordObject' if not defined otherwise.
  ###

  ###
  Convert from record list to table structure.

  @param {Array<Object>} obj record list to read
  @return {Table} class instance itself
  ###
  fromRecordList: (obj) ->
    @data = Table.fromRecordList obj
    this

  ###
  Convert from table structure to record list.

  @return {Array<Object>} record list to read
  ###
  toRecordList: -> Table.toRecordList @data

  ###
  Convert from record object to table structure.

  @param {Object<Object>} obj record object to read
  @param {String} [idColumn] title for the id column to be used
  @return {Table} class instance itself
  ###
  fromRecordObject: (obj, idColumn) ->
    @data = Table.fromRecordObject obj, idColumn
    this

  ###
  Convert from table structure to record object.

  @return {Object<Object>} record object to read
  ###
  toRecordObject: -> Table.toRecordObject @data


  ###
  Access Methods
  -------------------------------------------------
  This methods allows you to easily read and edit the table data in your code.
  ###

  ###
  #3 data

  This is the internal storage of the table structure.
  You may directly access this array of arrays which stores data in rows and columns:

  ``` coffee
  console.log table.data
  ```

  This may look like:

      [ ['ID', 'Name'],
        [1, 'one'],
        [2, 'two'],
        [3, 'three'] ]
  ###

  ###
  This method is used to access cell values or set them.

  __Examples__

  Read a cell value:

  ``` coffee
  value = table.field 1, 1
  # will result value of field 1/1
  value = table.field 1, 'Name'
  # do the same but using the column name
  ```

  And set a new value to a defined cell:

  ``` coffee
  table.field 1, 1, 15.8
  # will set value of field 1/1
  table.field 1, 'Name', 15.8
  # do the same but using the column name
  ```

  @param {Integer} row number from 1.. (0 is the heading)
  @param {Integer|String} column number of column 0.. or the name of a column
  @param [value] new value for the given cell
  @return the current (new) value of the given cell or the instance itself if no
  new value was given
  ###
  field: (row, col, value) ->
    result = Table.field @data, row, col, value
    if value? then this else result

  ###
  Get or set a complete table row.

  __Examples__

  First you may read one row as record:

  ``` coffee
  record = table.row 1
  # may return something like {ID: 1, Name: 'one'}
  ```

  And then you may also overwrite it with a changed version:

  ``` coffee
  table.row 1, {ID: 3, Name: 'three'}
  ```

  @param {Integer} row number from 1.. (0 is the heading)
  @param {Array} [value] new value for the given row
  @return the defined row as object or the inctance if value was given
  ###
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
      @data = Table.append @data, table
    this
  join: (type, tables...) ->
    for table in tables
      @data = Table.join @data, type, table
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
  rename: (col, name) ->
    Table.rename @data, col, name
    this
  format: (formats) ->
    Table.format @data, formats
    this

  columns: (cols) ->
    @data = Table.columns @data, cols
    this
  unique: (cols) ->
    Table.unique @data, cols
    this
  filter: (conditions) ->
    Table.filter @data, conditions
    this

  # Styling
  # -------------------------------------------------
  style: ->
    args = [].slice.apply arguments
    style = args.pop()
    [fr, fc, tr, tc] = args
    if fc
      fc = if typeof fc is 'number' or fc.match /^\d+$/ then fc else @data[0].indexOf fc ? fc
    unless tc? or tr?
      # cell
      range = "#{fr ? '*'}/#{fc ? '*'}"
      if style is null
        delete @meta[range]
      else
        @meta[range] ?= {}
        util.extend @meta[range], style
      return
    # range
    tc = if typeof tc is 'number' or tc.match /^\d+$/ then tc else @data[0].indexOf tc
    for row in [fr..tr]
      for col in [fc..tc]
        range = "#{row}/#{col}"
        if style is null
          delete @meta[range]
        else
          @meta[range] ?= {}
          util.extend @meta[range], style
    this

  getMeta: (row, col) ->
    if col
      col = if typeof col is 'number' or col.match /^\d+$/ then col else @data[0].indexOf col
    res = util.clone(@meta['*/*']) ? {}
    if col?
      util.extend res, util.clone @meta["*/#{col}"]
    if row?
      util.extend res, util.clone @meta["#{row}/*"]
    if row? and col?
      util.extend res, util.clone @meta["#{row}/#{col}"]
    res


# Exported `table` Class
# -------------------------------------------------
module.exports = Table


# Helper methods
# -------------------------------------------------
stringify = JSON.stringify
