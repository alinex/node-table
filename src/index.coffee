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
    debug "get field #{row}/#{col}" if debug.enabled
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
    debug "get row #{row}" if debug.enabled
    # set value
    if value
      for key, i in obj[0]
        obj[row][i] = value[key] if value[key]?
    # get value
    result = {}
    result[key] = obj[row][i] for key, i in obj[0]
    result

  ###
  Insert multiple rows into the Table.

  __Examples__

  ``` coffee
  result = Table.insert example, 2, [
    [5, 'five']
    [6, 'six']
  ]
  ```

  If you want to insert record list or record object data you have to convert them
  first.

  @param {Array<Array>} obj table to access
  @param {Integer} pos row position from 1.. (0 is the heading) use 'null' to add at the end
  @param {Array|Array<Array>} rows table rows to add
  @return {Array<Array>} the changed object
  ###
  @insert: (obj, pos, rows) ->
    unless rows
      rows = pos
      pos = null
    pos = obj.length unless pos
    debug "add row at position #{pos}" if debug.enabled
    if pos
      obj.splice pos+i, 0, row for row, i in rows
    else
      obj.push.apply obj, rows
    obj

  ###
  Delete some rows.

  __Examples__

  ``` coffee
  # delete the second data row:
  result = Table.delete example, 2
  # delete the second and third data row:
  result = Table.delete example 2, 2
  ```

  @param {Array<Array>} obj table to access
  @param {Integer} pos row number from 1.. (0 is the heading)
  @param {Integer} [num] number of rows to delete (defaults to 0)
  @return {Array<Array>} the changed object
  ###
  @delete: (obj, pos, num = 1) ->
    debug "remove #{num} rows at position #{pos}" if debug.enabled
    obj.splice pos, num
    obj

  ###
  Remove the first row as record object from the table. The header will be kept.

  __Examples__

  ``` coffee
  record = Table.shift example
  # record = {ID: 1, Name: 'one'}
  ```

  @param {Array<Array>} obj table to access
  @return {Object} the first, removed record
  ###
  @shift: (obj) ->
    debug "shift"
    result = @row obj, 1
    @delete obj, 1, 1
    result

  ###
  Add record object to the start of the table.

  __Examples__

  ``` coffee
  Table.unshift example, {id: 0, Name: 'zero'}
  ```

  @param {Array<Array>} obj table to access
  @param {Object} record record to add
  @return {Object} the changed table structure
  ###
  @unshift: (obj, record) ->
    debug "unshift"
    @insert obj, 1, [[]]
    @row obj, 1, record

  ###
  Remove the last row as record object from the table. The header will be kept.

  __Examples__

  ``` coffee
  record = Table.pop example
  # record = {ID: 3, Name: 'three'}
  ```

  @param {Array<Array>} obj table to access
  @return {Object} the last row
  ###
  @pop: (obj) ->
    debug "pop"
    result = @row obj, obj.length-1
    @delete obj, obj.length-1, 1
    result

  ###
  Add record object to the end of the table.

  __Examples__

  ``` coffee
  Table.push example, {id: 4, Name: 'four'}
  ```

  @param {Array<Array>} obj table to access
  @param {Object} record to add
  @return {Object} the just added record
  ###
  @push: (obj, record) ->
    debug "push"
    obj.push []
    @row obj, obj.length-1, record

  ###
  Get a defined column as array.

  The column number will start at 0...

  __Examples__

  ``` coffee
  result = Table.column example, 'Name'
  # result = ['one', 'two', 'three']
  ```

  @param {Array<Array>} table to access
  @param {Integer|String} column the column to export
  @param {Array} [values] values for row 1...
  @return {Array} values for the column fields from row 1... The header name is not included.
  ###
  @column: (obj, col, values) ->
    debug "add or set column #{col}" if debug.enabled
    col = obj[0].indexOf col unless typeof col is 'number' or col.match /^\d+$/
    if values
      for row, i in obj
        row.splice col, 0, values?[i-1] ? null
    obj[1..].map (row) -> row[col]

  ###
  Get a defined column.

  __Examples__

  You may only add a column (here as second column - index 1):

  ``` coffee
  Table.columnAdd example, 1, 'DE'
  # table.data = [
  #   [ 'ID', 'DE', 'Name' ]
  #   [ 1, null, 'one' ]
  #   [ 2, null, 'two' ]
  #   [ 3, null, 'three' ]
  # ]
  ```

  Or also add values for this column:

  ``` coffee
  Table.columnAdd example, 1, 'DE', ['eins', 'zwei', 'drei']
  # table.data = [
  #   [ 'ID', 'DE', 'Name' ]
  #   [ 1, 'eins', 'one' ]
  #   [ 2, 'zwei', 'two' ]
  #   [ 3, 'drei', 'three' ]
  # ]
  ```

  @param {Array<Array>} table structure to access
  @param {Integer|String} column position there inserting new column
  @param {String} name of the new column
  @param {Array} [values] values for row 1..
  ###
  @columnAdd: (obj, col, name, values) ->
    col = obj[0].length unless col
    debug "add column before #{col}" if debug.enabled
    col = obj[0].indexOf col unless typeof col is 'number' or col.match /^\d+$/
    for row, i in obj
      row.splice col, 0, values?[i-1] ? null
    obj[0][col] = name

  ###
  Get a defined column.

  __Examples__

  This will remove the first column with the ID and keep only the Name column:

  ``` coffee
  Table.columnRemove example, 0
  # table = [
  #   [ 'Name' ]
  #   [ 'one' ]
  #   [ 'two' ]
  #   [ 'three' ]
  # ]
  ```

  @param {Array<Array>} table structure to access
  @param {Integer|String} column position there deleting column
  ###
  @columnRemove: (obj, col) ->
    col = obj[0].length unless col?
    debug "remove column #{col}" if debug.enabled
    col = obj[0].indexOf col unless typeof col is 'number' or col.match /^\d+$/
    row.splice col, 1 for row in obj


  ###
  Static Join
  -------------------------------------------------
  There are basically two methods of appending. First vertivally by appending the
  tables below each one. And second vertically by combining the rows.
  ###

  ###
  This may append two tables under each other. The resulting table will have the
  columns from both of them.

  __Examples__

  ``` coffee
  table.append [
    [4, 'four']
    [5, 'five']
    [6, 'six']
  ]
  # table.data = [
  #   ['ID', 'Name']
  #   [1, 'one']
  #   [2, 'two']
  #   [3, 'three']
  #   [4, 'four']
  #   [5, 'five']
  #   [6, 'six']
  # ]
  ```

  @param {Array<Array>} table the table structure to use as base
  @param {Array<Array>} table2 to append
  @param {Array<Array>} ... more tables
  @return {Array<Array>} the changed table
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

  ###
  This works like a sql database join and if it is possible better use it within
  the database because of the performance.

  __Examples__

  ``` coffee
  Table.join example, 'left', [
    ['Name', 'DE']
    ['two', 'zwei']
    ['seven', 'sieben']
  ]
  # table.data = [
  #   [ 'ID', 'Name', 'DE' ]
  #   [ 1, 'one', null ]
  #   [ 2, 'two', 'zwei' ]
  #   [ 3, 'three', null ]
  # ]
  ```

  ``` coffee
  Table.join example, 'right', [
    ['Name', 'DE']
    ['two', 'zwei']
    ['seven', 'sieben']
  ]
  # table.data = [
  #   [ 'ID', 'Name', 'DE' ]
  #   [ 2, 'two', 'zwei' ]
  #   [ null, 'seven', 'sieben' ]
  # ]
  ```

  ``` coffee
  Table.join example, 'inner', [
    ['Name', 'DE']
    ['two', 'zwei']
    ['seven', 'sieben']
  ]
  # table.data = [
  #   [ 'ID', 'Name', 'DE' ]
  #   [ 2, 'two', 'zwei' ]
  # ]
  ```

  ``` coffee
  Table.join example, 'outer', [
    ['Name', 'DE']
    ['two', 'zwei']
    ['seven', 'sieben']
  ]
  # table.data = [
  #   [ 'ID', 'Name', 'DE' ]
  #   [ 1, 'one', null ]
  #   [ 3, 'three', null ]
  #   [ null, 'seven', 'sieben' ]
  # ]
  ```

  @param {Array<Array>} table the table structure to use as base
  @param {String} type type of join like: 'left', 'inner', 'right', 'outer'
  @param {Array<Array>} table2 to join
  @param {Array<Array>} ... more tables
  @return {Array<Array>} the changed table
  ###
  @join: (base, type, tables...) ->
    debug "join #{type}" if debug.enabled
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
  Static Transform
  -------------------------------------------------
  ###

  ###
  Sort the data rows by the specified columns.

  __Examples__

  ``` coffee
  # sort after Name column
  Table.sort example, 'Name'
  # reverse sort
  Table.sort example, '-Name'
  # sort after ID then Name
  Table.sort example, ['ID', 'Name']
  # the same
  Table.sort example, 'ID, Name'
  ```

  @param {Array<Array>} table the table structure to use as base
  @param {String|Array} sort columns to order by.
  The sort columns may be number or names as array or comma delimited string. To
  sort. For reverse order prepend the column with '-'.
  @return {Array<Array>} the changed table
  ###
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
    debug "sort by #{sort}" if debug.enabled
    header = table.shift()
    table = util.array.sortBy.apply this, [table].concat sort
    table.unshift header
    table

  ###
  Reverse the order of all data rows in the table.

  __Examples__

  ``` coffee
  Table.reverse example
  ```

  @param {Array<Array>} table the table structure to use as base
  @return {Array<Array>} the changed table
  ###
  @reverse: (table) ->
    debug "reverse"
    header = table.shift()
    table.reverse()
    table.unshift header
    table

  ###
  You may switch the x-axis and y-axis of your table.

  __Examples__

  ``` coffee
  Table.flip example
  # table.data = [
  #   [ 'ID', 1, 2, 3 ]
  #   [ 'Name', 'one', 'two', 'three' ]
  # ]
  ```

  @param {Array<Array>} table the table structure to use as base
  @return {Array<Array>} the new table
  ###
  @flip: (table) ->
    debug "flip"
    # flip
    flipped = []
    for row, x in table
      for col, y in row
        flipped[y] ?= []
        flipped[y][x] = col
    flipped

  ###
  Format column values.

  The format is defined like the [validator](http://alinex.github.io/node-validator)
  schema or a user defined function which will be called with the cell value and should
  return the formatted value.

  __Examples__

  ``` coffee
  Table.format examples,
    ID:
      type: 'percent'
      format: '0%'
    Name:
      type: 'string'
      upperCase: 'first'
  # table.data = [
  #   [ 'ID', 'Name' ]
  #   [ '100%', 'One' ]
  #   [ '200%', 'Two' ]
  #   [ '300%', 'Three' ]
  # ]
  ```

  And with custom functions the call should look like:

  ``` coffee
  Table.format examples,
    Name: (cell) -> cell.toString().toUpperCase()
  ```

  @param {Array<Array>} table the table structure to use as base
  @param {Array|Object} formats for the columns
    - array with each columns format
    - object with 'column: format'
  @return {Array<Array>} the changed table
  ###
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
          try
            check
              name: "format-cell"
              value: row[col]
              schema: util.extend format,
                optional: true
    # return
    table

  ###
  Rename a column.

  __Examples__

  ``` coffee
  Table.rename example, 'Name', 'EN'
  ```

  @param {Array<Array>} table the table structure to use as base
  @param {Integer|String} col column to rename
  @param {String} name new name for defined column
  @return {Array<Array>} the changed table
  ###
  @rename: (table, col, name) ->
    debug "rename #{col} to #{name}" if debug.enabled
    col = table[0].indexOf col unless typeof col is 'number' or col.match /^\d+$/
    table[0][col] = name
    table


  ###
  Static Filtering
  -------------------------------------------------
  ###

  ###
  Rename multiple columns, reorder them and filter them.

  The columns can be defined all using true, meaning to use them in the existing order
  or with the number or name so a resorting is also possible in one step.

  __Examples__

  In the following example only the first two columns are kept and named:

  ``` coffee
  Table.columns example,
    ID: true
    EN: true
  # table.data = [
  #   [ 'ID', 'EN' ]
  #   [1, 'one']
  #   [2, 'two']
  #   [3, 'three']
  # ]
  ```

  And here the columns are also reordered:

  ``` coffee
  Table.columns example,
    EN: 'Name'
    ID: 'ID'
  # table.data = [
  #   ['EN', 'ID']
  #   ['one', 1]
  #   ['two', 2]
  #   ['three', 3]
  # ]
  ```

  @param {Array<Array>} table the table structure to use as base
  @param {Object<String>} columns column name: column to use
  @return {Array<Array>} the new table structure
  ###
  @columns: (table, cols) ->
    debug "change columns #{cols}" if debug.enabled
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

  ###
  Remove all duplicate data rows.

  __Examples__

  ``` coffee
  # remove all completely duplicate rows
  Table.unique example
  # remove all rows with duplicate Name column
  Table.unique example, 'Name'
  ```

  @param {Array<Array>} table the table structure to use as base
  @param {Integer|String|Array} columns to check for uniqueness
  @return {Array<Array>} the changed table
  ###
  @unique: (table, cols) ->
    debug "unique in #{cols ? 'all'} columns" if debug.enabled
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

  ###
  Filter the rows using specific conditions per column.

  The conditions are strings consisting of '<column> <operator> <value>'. If given
  as array the different conditions are logical combined using 'AND'. Subarrays
  are combined using 'OR' (even index) and 'AND' (odd index).

  ``` coffee
  conditions = ['Name not null', ['Name startsWith a', 'Name startsWith b']]
  ```

  This results in the following logic:

  ``` text
  Name not null
  # and
    Name startsWith a
    # or
    Name startsWith b
  ```

  __Examples__

  ``` coffee
  Table.filter example, ['ID > 1', 'ID < 8'] # AND
  Table.filter example, [['ID < 2', 'ID > 3']] # OR
  ```

  @param {Array<Array>} table the table structure to use as base
  @param {Array} conditions for records to be kept
  @return {Array<Array>} the changed table
  ###
  @filter: (table, conditions) ->
    debug "filter #{conditions}" if debug.enabled
    # optimize conditions
    conditions = [conditions] unless Array.isArray conditions
    # internal function checking one cell against value
    check = (cell, op, val) ->
      switch typeof cell
        when 'number' then val = Number val
        when 'boolean' then val = Boolean val
      res = switch op.toLowerCase()
        when 'is', '=', '=='
          if val is 'null' then cell is null else cell is val
        when 'not', '!=', '<>'
          if val is 'null' then cell isnt null else cell isnt val
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

  ###
  Insert multiple rows into the Table.

  __Examples__

  ``` coffee
  table.insert 2, [
    [5, 'five']
    [6, 'six']
  ]
  ```

  If you want to insert record list or record object data you have to convert them
  first.

  @param {Integer} pos row position from 1.. (0 is the heading) use 'null' to add at the end
  @param {Array|Array<Array>} rows table rows to add
  @return {Table} the inctance itself
  ###
  insert: (pos, rows) ->
    Table.insert @data, pos, rows
    this

  ###
  Delete some rows.

  __Examples__

  ``` coffee
  # delete the second data row:
  table.delete 2
  # delete the second and third data row:
  table.delete 2, 2
  ```

  @param {Integer} pos row number from 1.. (0 is the heading)
  @param {Integer} [num] number of rows to delete (defaults to 0)
  @return {Table} the inctance itself
  ###
  delete: (pos, num) ->
    Table.delete @data, pos, num
    this

  ###
  Remove the first row as record object from the table. The header will be kept.

  __Examples__

  ``` coffee
  record = table.shift()
  # record = {ID: 1, Name: 'one'}
  ```

  @return the first row as object
  ###
  shift: -> Table.shift @data

  ###
  Add record object to the start of the table.

  __Examples__

  ``` coffee
  table.unshift {id: 0, Name: 'zero'}
  ```

  @param {Object} record to add
  @return {Table} the inctance itself
  ###
  unshift: (record) ->
    Table.unshift @data, record
    this

  ###
  Remove the last row as record object from the table. The header will be kept.

  __Examples__

  ``` coffee
  record = table.pop()
  # record = {ID: 3, Name: 'three'}
  ```

  @return the last row as object.
  ###
  pop: -> Table.pop @data

  ###
  Add record object to the end of the table.

  __Examples__

  ``` coffee
  table.push {id: 4, Name: 'four'}
  ```

  @param {Object} record to add
  @return {Object} the just added record
  ###
  push: (record) ->
    Table.push @data, record
    this

  ###
  Get a defined column as array.

  The column number will start at 0...

  __Examples__

  ``` coffee
  result = table.column 'Name'
  # result = ['one', 'two', 'three']
  ```

  @param {Integer|String} column the column to export
  @param {Array} [values] values for row 1...
  @return {Array} values for the column fields from row 1... The header name is not included.
  ###
  column: (col, values) ->
    result = Table.column @data, col, values
    if values? then this else result

  ###
  Get a defined column.

  __Examples__

  You may only add a column (here as second column - index 1):

  ``` coffee
  table.columnAdd 1, 'DE'
  # table.data = [
  #   [ 'ID', 'DE', 'Name' ]
  #   [ 1, null, 'one' ]
  #   [ 2, null, 'two' ]
  #   [ 3, null, 'three' ]
  # ]
  ```

  Or also add values for this column:

  ``` coffee
  table.columnAdd 1, 'DE', ['eins', 'zwei', 'drei']
  # table.data = [
  #   [ 'ID', 'DE', 'Name' ]
  #   [ 1, 'eins', 'one' ]
  #   [ 2, 'zwei', 'two' ]
  #   [ 3, 'drei', 'three' ]
  # ]
  ```

  @param {Integer|String} column position there inserting new column
  @param {String} name of the new column
  @param {Array} [values] values for row 1..
  @return {Table} the instance itself
  ###
  columnAdd: (col, name, values) ->
    Table.columnAdd @data, col, name, values
    this

  ###
  Get a defined column.

  __Examples__

  This will remove the first column with the ID and keep only the Name column:

  ``` coffee
  table.columnRemove 0
  # table = [
  #   [ 'Name' ]
  #   [ 'one' ]
  #   [ 'two' ]
  #   [ 'three' ]
  # ]
  ```

  @param {Integer|String} column position there deleting column
  @return {Table} instance itself
  ###
  columnRemove: (col) ->
    Table.columnRemove @data, col
    this


  ###
  Join Methods
  -------------------------------------------------
  There are basically two methods of appending. First vertivally by appending the
  tables below each one. And second vertically by combining the rows.
  ###

  ###
  This may append two tables under each other. The resulting table will have the
  columns from both of them.

  __Examples__

  ``` coffee
  table.append [
    [4, 'four']
    [5, 'five']
    [6, 'six']
  ]
  # table.data = [
  #   ['ID', 'Name']
  #   [1, 'one']
  #   [2, 'two']
  #   [3, 'three']
  #   [4, 'four']
  #   [5, 'five']
  #   [6, 'six']
  # ]
  ```

  @param {Array<Array>} table2 to append
  @param {Array<Array>} ... more tables
  @return {Table} the instance itself
  ###
  append: (tables...) ->
    for table in tables
      @data = Table.append @data, table
    this

  ###
  This works like a sql database join and if it is possible better use it within
  the database because of the performance.

  __Examples__

  ``` coffee
  table.join 'left', [
    ['Name', 'DE']
    ['two', 'zwei']
    ['seven', 'sieben']
  ]
  # table.data = [
  #   [ 'ID', 'Name', 'DE' ]
  #   [ 1, 'one', null ]
  #   [ 2, 'two', 'zwei' ]
  #   [ 3, 'three', null ]
  # ]
  ```

  ``` coffee
  table.join 'right', [
    ['Name', 'DE']
    ['two', 'zwei']
    ['seven', 'sieben']
  ]
  # table.data = [
  #   [ 'ID', 'Name', 'DE' ]
  #   [ 2, 'two', 'zwei' ]
  #   [ null, 'seven', 'sieben' ]
  # ]
  ```

  ``` coffee
  table.join 'inner', [
    ['Name', 'DE']
    ['two', 'zwei']
    ['seven', 'sieben']
  ]
  # table.data = [
  #   [ 'ID', 'Name', 'DE' ]
  #   [ 2, 'two', 'zwei' ]
  # ]
  ```

  ``` coffee
  table.join 'outer', [
    ['Name', 'DE']
    ['two', 'zwei']
    ['seven', 'sieben']
  ]
  # table.data = [
  #   [ 'ID', 'Name', 'DE' ]
  #   [ 1, 'one', null ]
  #   [ 3, 'three', null ]
  #   [ null, 'seven', 'sieben' ]
  # ]
  ```

  @param {String} type type of join like: 'left', 'inner', 'right', 'outer'
  @param {Array<Array>} table2 to join
  @param {Array<Array>} ... more tables
  @return {Table} the instance itself
  ###
  join: (type, tables...) ->
    for table in tables
      @data = Table.join @data, type, table
    this


  ###
  Transform Methods
  -------------------------------------------------
  ###

  ###
  Sort the data rows by the specified columns.

  __Examples__

  ``` coffee
  # sort after Name column
  table.sort 'Name'
  # reverse sort
  table.sort '-Name'
  # sort after ID then Name
  table.sort ['ID', 'Name']
  # the same
  table.sort 'ID, Name'
  ```

  @param {String|Array} sort columns to order by.
  The sort columns may be number or names as array or comma delimited string. To
  sort. For reverse order prepend the column with '-'.
  @return {Table} the instance itself
  ###
  sort: (sort) ->
    @data = Table.sort @data, sort
    this

  ###
  Reverse the order of all data rows in the table.

  __Examples__

  ``` coffee
  table.reverse()
  ```

  @return {Table} the instance itself
  ###
  reverse: ->
    @data = Table.reverse @data
    this

  ###
  You may switch the x-axis and y-axis of your table.

  __Examples__

  ``` coffee
  table.flip()
  # table.data = [
  #   [ 'ID', 1, 2, 3 ]
  #   [ 'Name', 'one', 'two', 'three' ]
  # ]
  ```

  @return {Table} the instance itself
  ###
  flip: ->
    @data = Table.flip @data
    this

  ###
  Format column values.

  The format is defined like the [validator](http://alinex.github.io/node-validator)
  schema or a user defined function which will be called with the cell value and should
  return the formatted value.

  __Examples__

  ``` coffee
  table.format
    ID:
      type: 'percent'
      format: '0%'
    Name:
      type: 'string'
      upperCase: 'first'
  # table.data = [
  #   [ 'ID', 'Name' ]
  #   [ '100%', 'One' ]
  #   [ '200%', 'Two' ]
  #   [ '300%', 'Three' ]
  # ]
  ```

  And with custom functions the call should look like:

  ``` coffee
  table.format
    Name: (cell) -> cell.toString().toUpperCase()
  ```

  @param {Array|Object} formats for the columns
    - array with each columns format
    - object with 'column: format'
  @return {Table} the instance itself
  ###
  format: (formats) ->
    Table.format @data, formats
    this

  ###
  Rename a column.

  __Examples__

  ``` coffee
  table.rename 'Name', 'EN'
  ```

  @param {Integer|String} col column to rename
  @param {String} name new name for defined column
  @return {Table} the instance itself
  ###
  rename: (col, name) ->
    Table.rename @data, col, name
    this


  ###
  Filtering Methods
  -------------------------------------------------
  ###

  ###
  Rename multiple columns, reorder them and filter them.

  The columns can be defined all using true, meaning to use them in the existing order
  or with the number or name so a resorting is also possible in one step.

  __Examples__

  In the following example only the first two columns are kept and named:

  ``` coffee
  table.columns
    ID: true
    EN: true
  # table.data = [
  #   [ 'ID', 'EN' ]
  #   [1, 'one']
  #   [2, 'two']
  #   [3, 'three']
  # ]
  ```

  And here the columns are also reordered:

  ``` coffee
  table.columns
    EN: 'Name'
    ID: 'ID'
  # table.data = [
  #   ['EN', 'ID']
  #   ['one', 1]
  #   ['two', 2]
  #   ['three', 3]
  # ]
  ```

  @param {Object<String>} columns column name: column to use
  @return {Table} the instance itself
  ###
  columns: (cols) ->
    @data = Table.columns @data, cols
    this

  ###
  Remove all duplicate data rows.

  __Examples__

  ``` coffee
  # remove all completely duplicate rows
  table.unique()
  # remove all rows with duplicate Name column
  table.unique 'Name'
  ```

  @param {Integer|String|Array} columns to check for uniqueness
  @return {Table} the instance itself
  ###
  unique: (cols) ->
    Table.unique @data, cols
    this

  ###
  Filter the rows using specific conditions per column.

  The conditions are strings consisting of '<column> <operator> <value>'. If given
  as array the different conditions are logical combined using 'AND'. Subarrays
  are combined using 'OR' (even index) and 'AND' (odd index).

  ``` coffee
  conditions = ['Name not null', ['Name startsWith a', 'Name startsWith b']]
  ```

  This results in the following logic:

  ``` text
  Name not null
  # and
    Name startsWith a
    # or
    Name startsWith b
  ```

  __Examples__

  ``` coffee
  table.filter ['ID > 1', 'ID < 8'] # AND
  table.filter [['ID < 2', 'ID > 3']] # OR
  ```

  @param {Array} conditions for records to be kept
  @return {Table} the instance itself
  ###
  filter: (conditions) ->
    Table.filter @data, conditions
    this


  ###
  Styling
  -------------------------------------------------
  If you use a table instance you may also store meta data in the object which may
  later be used for styling outside of this module.

  Supported in [Report](http://alinex.github.io/node-report):

  - 'align' on column or sheet with values: 'left', 'center', 'right' ('left' is default)
  ###

  ###
  Set or clear style information.
  To set for a single cel, row, column or the complete sheet.

  __Examples__

  ``` coffee
  # set style for row 0 colummn 1
  table.style 0, 1, {align: 'left'}
  # the same with a named column
  table.style 0, 'Name', {align: 'left'}
  # and remove the styles
  table.style 0, 1, null

  # set style for row 1
  table.style 1, null, {align: 'left'}
  # and remove the styles
  table.style 1, null, null

  # set style for column 1
  table.style null, 1, {align: 'left'}
  # and remove the styles
  table.style null, 1, null

  # set style for the sheets
  table.style null, null, {align: 'left'}
  # and remove the styles
  table.style null, null, null

  # set style for user defined range
  table.style 1, 0, 3, 2, {align: 'left'}
  # and remove the styles
  table.style 1, 0, 3, 2, null
  ```

  @param {Integer} from-row row number
  @param {Integer|String} from-col column number or name
  @param {Integer} [to-row] row number
  @param {Integer|String} [to-col] column number or name
  @param {Object} [style] settings to store or null to delete all
  @return {Table} the instance itself
  ###
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

  # #3 meta
  #
  # This object collects the resulting meta data. The following order will overwrite
  # the general ones.
  #
  # - '*/*' contains settings for the complete sheet
  # - '*/1' contains settings for the column
  # - '1/*' contains settings for the row
  # - '1/1' contains settings for the concrete cell

  ###
  This will calculate the resulting settings of the combinations of the above.

  To set for a single cel, row, column or the complete sheet:

  __Examples__

  ``` coffee
  # get styles for cell
  style = table.getMeta 0, 1
  # style = {align: 'left'}

  # get styles for row
  style = table.getMeta 0

  # get styles for column
  style = table.getMeta null, 1

  # get styles for sheet
  style = table.getMeta()
  ```

  @param {Integer} row number or null for all rows
  @param {Integer|String} col column number or name, null for all columns
  @return {Object} the combined style settings
  ###
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
