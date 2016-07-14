Table
=================================================

[![Build Status](https://travis-ci.org/alinex/node-table.svg?branch=master)](https://travis-ci.org/alinex/node-table)
[![Coverage Status](https://coveralls.io/repos/alinex/node-table/badge.png?branch=master)](https://coveralls.io/r/alinex/node-table?branch=master)
[![Dependency Status](https://gemnasium.com/alinex/node-table.png)](https://gemnasium.com/alinex/node-table)

This package contains methods for working with table like data. It collects all
methods for working with such a data type.

- read and write at various positions
- convert from and to this data type
- rearranging everything with flip, filter, sort and more
- optimizing for display
- and export/dump as table

As a new data type you may also use it's methods on an instance or statically.

> It is one of the modules of the [Alinex Universe](http://alinex.github.io/code.html)
> following the code standards defined in the [General Docs](http://alinex.github.io/develop).


Install
-------------------------------------------------

[![NPM](https://nodei.co/npm/table.png?downloads=true&downloadRank=true&stars=true)
 ![Downloads](https://nodei.co/npm-dl/table.png?months=9&height=3)
](https://www.npmjs.com/package/table)

The easiest way is to let npm add the module directly to your modules
(from within you node modules directory):

``` sh
npm install alinex-table --save
```

And update it to the latest version later:

``` sh
npm update alinex-table --save
```

Always have a look at the latest [changes](Changelog.md).


Usage
-------------------------------------------------

To use these methods include the package first:

``` coffee
Table = require 'alinex-table'

example = [
  ['ID', 'Name']
  [1, 'one']
  [2, 'two']
  [3, 'three']
]
```

Then this module gives you a lot of methods with which you may work and manipulate
this table.

### Class vs Static

You may use both. As an instance each method will return the instance itself if no need
to return something else. So you may concatenate most calls.

You can call each method on an instance like:

``` coffee
table = new Table example
record = table.shift()
```

Or you may use them statically on your own data objects:

``` coffee
record = Table.shift example
```

The class oriented approach often is more readable if multiple manipulations on
the data object are done, specially if you use command concatenation.


Data Types
-------------------------------------------------

The data objects which will be used here are:

__Table__

This format stores the data like a table calculation program. It is the format
derived from the CSV format and used as main format in the module.

``` coffee
[
  ['ID', 'Name']
  [1, 'one']
  [2, 'two']
  [3, 'three']
]
```

The first line has to be the header.

> Keep in mind that the table data always needs a header row as first line.

__Record List__

This equals to the format lots of database systems return there records as a list
of record objects.

``` coffee
[
  {ID: 1, Name: 'one'}
  {ID: 2, Name: 'two'}
  {ID: 3, Name: 'three'}
]
```

It can be fully converted to a table (see below).

__Record Object__

A slightly variation to the record list in which the records are collected in an
indexed objected instead of a list.

``` coffee
{
  '1': {Name: 'one'}
  '2': {Name: 'two'}
  '3': {Name: 'three'}
}
```

It can also be fully converted to a table (see below).


Conversion
------------------------------------------------------------

To convert from and to the different data structures described above, you can
use the following 4 methods:

``` coffee
table.fromRecordList recordList
table.fromRecordObject recordObject, idColumn
result = table.toRecordList()
result = table.toRecordObject()
```

The same calls using static methods:

``` coffee
result = Table.fromRecordList recordList
result = Table.fromRecordObject recordObject, idColumn
result = Table.toRecordList example
result = Table.toRecordObject example
```

The conversion to record object will loose the name of the first column so it
will always get 'ID' on back conversion ''fromRecordObject' if not defined otherwise.

To initialize a new Table instance from a RecordList use:

``` coffee
table = (new Table()).fromRecordList records
```

Additionally as one way conversion you may dump into a visible table using the
[report](http://alinex.github.io/node-report) package:

``` coffee
Report = require 'alinex-report'
report = new Report()
report.table example
console.log report.toString()
```

This will result in a markdown text displaying a table which can easily be
converted to ascii art using `toConsole()` or an html table using `toHtml()`.


Access
-------------------------------------------------------------

This methods allows you to easily read and edit the table data in your code.

### data

If used with an instance this is the internal storage of the table structure.
You may directly access this array of arrays which stores data in rows and columns:

``` coffee
console.log table.data
```

This may look like:

``` text
[ ['ID', 'Name'],
  [1, 'one'],
  [2, 'two'],
  [3, 'three'] ]
```

### field

This method is used to access cell values or set them.

__Arguments__

- `table` - (array of arrays) to access (only static calls)
- `row` - (integer) row number from 1.. (0 is the heading)
- `column` - (integer or string) number of column 0.. or the name of a column
- `value` - (optionally) new value for the given cell

__Return__

The current (new) value of the given cell or the instance itself if value have
been set.

__Examples__

Read a cell value:

``` coffee
value = table.field 1, 1
# will result value of field 1/1
value = table.field 1, 'Name'
# do the same but using the column name

# or statically:
value = Table.field example, 1, 1
# will result value of field 1/1
value = Table.field example, 1, 'Name'
# do the same but using the column name
```

And set a new value to a defined cell:

``` coffee
table.field 1, 1, 15.8
# will set value of field 1/1
table.field 1, 'Name', 15.8
# do the same but using the column name

# or statically:
Table.field example, 1, 1, 15.8
# will set value of field 1/1
Table.field example, 1, 'Name', 15.8
# do the same but using the column name
```

### row

Get or set a complete table row.

__Arguments__

- `table` - (array of arrays) to access (only static calls)
- `row` - (integer) row number from 1.. (0 is the heading)
- `record` - (optional object) new value for the given row

__Return__

The defined row as object or the inctance if row was set.

__Examples__

First you may read one row as record:

``` coffee
record = table.row 1
# may return something like {ID: 1, Name: 'one'}

# or statically called:
record = Table.row example, 1
# may return something like {ID: 1, Name: 'one'}
```

And then you may also overwrite it with a changed version:

``` coffee
table.row 1, {ID: 3, Name: 'three'}

# or statically called:
Table.row example, 1, {ID: 3, Name: 'three'}
```

### insert

Insert multiple rows as into the Table.

__Arguments__

- `table` - (array of arrays) to access (only static calls)
- `pos` - (integer) row position from 1.. (0 is the heading) use 'null' to add at the end
- `rows` - (array of arrays) table rows to add

__Examples__

``` coffee
table.insert 2, [
  [5, 'five']
  [6, 'six']
]
```

### delete

Delete some rows.

__Arguments__

- `table` - (array of arrays) to access (only static calls)
- `pos` - (integer) row number from 1.. (0 is the heading)
- `num` - (optional object) new value for the given row

__Return__

The defined row as object.

__Examples__


``` coffee
# delete the second data row:
table.delete 2
# delete the second and third data row:
table.delete 2, 2
```

### shift

Remove the first row as record object from the table. The header will be kept.

__Arguments__

- `table` - (array of arrays) to access (only static calls)

__Return__

The first row as object.

__Examples__

``` coffee
record = table.shift()
# record = {ID: 1, Name: 'one'}
```

### unshift

Add record object to the start of the table.

__Arguments__

- `table` - (array of arrays) to access (only static calls)
- `record` - (object) record to add

__Examples__

``` coffee
table.unshift {id: 0, Name: 'zero'}
```

### pop

Remove the last row as record object from the table. The header will be kept.

__Arguments__

- `table` - (array of arrays) to access (only static calls)

__Return__

The last row as object.

__Examples__

``` coffee
record = table.pop()
# record = {ID: 3, Name: 'three'}
```

### push

Add record object to the end of the table.

__Arguments__

- `table` - (array of arrays) to access (only static calls)
- `record` - (object) record to add

__Examples__

``` coffee
table.unshift {id: 4, Name: 'four'}
```

### column

Get a defined column as array.

__Arguments__

- `table` - (array of arrays) to access (only static calls)
- `column` - (number or string) the column to export
- `values` - (array) list of values for row 1...

The column number will start at 0...

__Return__

A list of values for the column fields from row 1... The header name is not
included.

__Examples__

``` coffee
result = table.column 'Name'
# result = ['one', 'two', 'three']
```

### columnAdd

Get a defined column.

__Arguments__

- `table` - (array of arrays) to access (only static calls)
- `column` - (number or string) position there inserting column
- `name` - (string) name of the new column
- `values` - (array) list of values for row 1..

__Return__

The instance if not called statically.

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

### columnRemove

Get a defined column.

__Arguments__

- `table` - (array of arrays) to access (only static calls)
- `column` - (number or string) position there deleting column

__Return__

The instance if not called statically.

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


Join
-------------------------------------------------------------

There are basically two methods of appending. First vertivally by appending the
tables below each one. And second vertically by combining the rows.

### append

This may append two tables under each other. The resulting table will have the
columns from both of them.

__Arguments__

- `table` - (array of arrays) to use as base (only static calls)
- `table2` - (array of arrays) to append
- `...` - more tables

__Return__

The instance if not called statically, the new table on static calls.

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

### join

This works like a sql database join and if it is possible better use it within
the database because of the performance.

__Arguments__

- `table` - (array of arrays) to use as base (only static calls)
- `type` - (string) type of join like: 'left', 'inner', 'right', 'outer'
- `table2` - (array of arrays) to join
- `...` - more tables

__Return__

The instance if not called statically, the new table on static calls.

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

Transform
-------------------------------------------------------------

### sort

Sort the data rows by the specified columns.

__Arguments__

- `table` - (array of arrays) to use as base (only static calls)
- `sort` - (string or array) sort columns

The sort columns may be number or names as array or comma delimited string. To
sort in reverse order prepend the column with '-'.

__Return__

The instance if not called statically, the new table on static calls.

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

### reverse

Reverse the order of all data rows in the table.

__Arguments__

- `table` - (array of arrays) to use as base (only static calls)

__Return__

The instance if not called statically, the table on static calls.

__Examples__

``` coffee
table.reverse()
```

### flip

You may switch the x-axis and y-axis of your table.

__Arguments__

- `table` - (array of arrays) to use as base (only static calls)

__Return__

The instance if not called statically, the new table on static calls.

__Examples__

``` coffee
table.flip()
# table.data = [
#   [ 'ID', 1, 2, 3 ]
#   [ 'Name', 'one', 'two', 'three' ]
# ]
```

### format

Format column values.

__Arguments__

- `table` - (array of arrays) to use as base (only static calls)
- `formats` - (map or array) formats for the columns
  - array with each columns format
  - object with 'column: format'

The format is defined like the [validator](http://alinex.github.io/node-validator)
schema or a user defined function which will be called with the cell value and should
return the formatted value.

__Return__

The instance if not called statically, the table on static calls.

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

### rename

Rename a column.

__Arguments__

- `table` - (array of arrays) to use as base (only static calls)
- `col` - (string or integer) column to rename
- `name` - (string) new name for defined column

__Return__

The instance if not called statically, the table on static calls.

__Examples__

``` coffee
table.rename 'Name', 'EN'
```


Filtering
-------------------------------------------------------------

### columns

Rename multiple columns, reorder them and filter them.

__Arguments__

- `table` - (array of arrays) to use as base (only static calls)
- `columns` - (object) column name: column to use

The columns can be defined all using true, meaning to use them in the existing order
or with the number or name so a resorting is also possible in one step.

__Return__

The instance if not called statically, the table on static calls.

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

### unique

Remove all duplicate data rows.

__Arguments__

- `table` - (array of arrays) to use as base (only static calls)
- `columns` - (array, string or integer) columns to check for uniqueness

__Return__

The instance if not called statically, the table on static calls.

__Examples__

``` coffee
# remove all completely duplicate rows
table.unique()
# remove all rows with duplicate Name column
table.unique 'Name'
```

### filter

Filter the rows using specific conditions per column.

__Arguments__

- `table` - (array of arrays) to use as base (only static calls)
- `conditions` - (array) conditions to be kept

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

__Return__

The instance if not called statically, the table on static calls.

__Examples__

``` coffee
table.filter ['ID > 1', 'ID < 8'] # AND
table.filter [['ID < 2', 'ID > 3']] # OR
```


Styling and Meta Data
-------------------------------------------------------------
If you use a table instance you may also store meta data in the object which may
later be used for styling outside of this module.

Supported in [Report](http://alinex.github.io/node-report):

- 'align' on column or sheet with values: 'left', 'center', 'right' ('left' is default)

### style

Set or clear style information.

__Arguments__

To set for a single cel, row, column or the complete sheet:

- `row` - (integer) row number or null for all rows
- `col` - (integer or string) column number or name, null for all columns
- `style` - (object) style settings to store or null to delete all

Or for a user defined range:

- `from-row` - (integer) row number
- `from-col` - (integer or string) column number or name
- `to-row` - (integer) row number
- `to-col` - (integer or string) column number or name
- `style` - (object) style settings to store or null to delete all cell settings

__Return__

The instance.

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

### meta

This object collects the resulting meta data. The following order will overwrite
the general ones.

- '*/*' contains settings for the complete sheet
- '*/1' contains settings for the column
- '1/*' contains settings for the row  
- '1/1' contains settings for the concrete cell  

### getMeta

This will calculate the resulting settings of the combinations of the above.

__Arguments__

To set for a single cel, row, column or the complete sheet:

- `row` - (integer) row number or null for all rows
- `col` - (integer or string) column number or name, null for all columns

__Return__

The settings object.

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


License
-------------------------------------------------

(C) Copyright 2016 Alexander Schilling

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

>  <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
