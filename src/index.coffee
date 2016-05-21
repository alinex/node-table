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
    col = obj[0].indexOf col unless typeof col is 'number'
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
    debug "add row at position #{pos}"
    if pos
      obj.splice pos+i, 0, row for row, i in rows
    else
      obj.push.apply obj, rows
    obj

  @delete: (obj, pos, num) ->
    debug "remove #{num} rows at position #{pos}"
    obj.splice pos, num
    obj

  @shift: (obj) ->
    result = @row obj, 1
    @delete obj, 1, 1
    result

  @unshift: (obj, record) ->
    @insert obj, 1, [[]]
    @row obj, 1, record

  @pop: (obj) ->
    result = @row obj, obj.length-1
    @delete obj, obj.length-1, 1
    result

  @push: (obj, record) ->
    obj.push []
    @row obj, obj.length-1, record


  # Join
  # -------------------------------------------------

  @leftJoin: (base, tables...) ->
    debug "leftJoin"
  @rightJoin: (base, tables...) ->
    debug "rightJoin"
  @innerJoin: (base, tables...) ->
    debug "innerJoin"
  @outerJoin: (base, tables...) ->
    debug "outerJoin"


  # Transform
  # -------------------------------------------------

  # sort = '1,2-,4' or 'name,age-'
  @sort: (table, sort) ->
  @reverse: (table) ->
  @flip: (table) ->
  # formats = {<name>: <format>} or [<format>, ...]
  @format: (table, formats) ->


  # Filtering
  # -------------------------------------------------

  # columns = {<title>: <old name> or true or <num>}
  @columns: (table, columns) ->
  # columns = <num array> or <string array> (optional)
  @unique: (table, columns) ->
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



# Export class
# -------------------------------------------------
module.exports = Table
