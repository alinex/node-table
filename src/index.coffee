# Main controlling class
# =================================================


# Node Modules
# -------------------------------------------------

# include base modules
debug = require('debug') 'table'
# include alinex modules
util = require 'alinex-util'


# Converion
# -------------------------------------------------

exports.fromRecordList = (obj) ->
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

exports.toRecordList = (obj) ->
  debug "table -> record list"
  obj = util.clone obj
  keys = obj.shift()
  obj.map (e) ->
    map = {}
    map[k] = e[i] for k, i in keys
    map

exports.fromRecordObject = (obj, idColumn) ->
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

exports.toRecordObject = (obj) ->
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

exports.field = (obj, row, col, value) ->
  col = obj[0].indexOf col unless typeof col is 'number'
  debug "get field #{row}/#{col}"
  # set value
  obj[row][col] = value if value?
  # get value
  obj[row][col]

exports.row = (obj, row, value) ->
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

exports.insert = (obj, pos, rows) ->
  debug "add row at position #{pos}"
  if pos
    obj.splice pos+i, 0, row for row, i in rows
  else
    obj.push.apply obj, rows
  obj

exports.delete = (obj, pos, num) ->
  debug "remove #{num} rows at position #{pos}"
  obj.splice pos, num
  obj

exports.shift = (obj) ->
  result = exports.row obj, 1
  exports.delete obj, 1, 1
  result

exports.unshift = (obj, record) ->
  exports.insert obj, 1, [[]]
  exports.row obj, 1, record

exports.pop = (obj) ->
  result = exports.row obj, obj.length-1
  exports.delete obj, obj.length-1, 1
  result

exports.push = (obj, record) ->
  obj.push []
  exports.row obj, obj.length-1, record


# Join
# -------------------------------------------------

exports.leftJoin = (base, tables...) ->
  debug "leftJoin"
exports.rightJoin = (base, tables...) ->
  debug "rightJoin"
exports.innerJoin = (base, tables...) ->
  debug "innerJoin"
exports.outerJoin = (base, tables...) ->
  debug "outerJoin"


# Transform
# -------------------------------------------------

# sort = '1,2-,4' or 'name,age-'
exports.sort = (table, sort) ->
exports.reverse = (table) ->
exports.flip = (table) ->
# formats = {<name>: <format>} or [<format>, ...]
exports.format = (table, formats) ->


# Filtering
# -------------------------------------------------

# columns = {<title>: <old name> or true or <num>}
exports.columns = (table, columns) ->
# columns = <num array> or <string array> (optional)
exports.unique = (table, columns) ->
# conditions = {<name>: <cond>} or [<cond>, ...]
exports.filter = (table, conditions) ->
# conditions = {<name>: <cond>} or [<cond>, ...]
exports.group = (table, conditions) ->
