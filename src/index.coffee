# Main controlling class
# =================================================


# Node Modules
# -------------------------------------------------

# include base modules
debug = require('debug') '###<name>###'
chalk = require 'chalk'
# include alinex modules
util = require 'alinex-util'


# Converion
# -------------------------------------------------
exports.fromRecordList = (obj) ->
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
  obj = util.clone obj
  keys = obj.shift()
  obj.map (e) ->
    map = {}
    map[k] = e[i] for k, i in keys
    map

exports.fromRecordObject = (obj) ->
  keys = ['ID']
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
  res = {}
  keys = obj[0]
  for row in obj[1..]
    continue unless row[0]
    res[row[0]] = {}
    for k, i in keys[1..]
      res[row[0]][k] = row[i+1]
  res
