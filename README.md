eTable
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
Table.insert example, 2, [
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

First you may read one row as record:

``` coffee
Table.delete example, 2, 1
```

### shift

Remove the first row as record object from the table.

__Arguments__

- `table` - (array of arrays) to access (only static calls)

__Return__

The first row as object.

### unshift

Add record object to the start of the table.

__Arguments__

- `table` - (array of arrays) to access (only static calls)
- `record` - (object) record to add

### pop

Remove the last row as record object from the table.

__Arguments__

- `table` - (array of arrays) to access (only static calls)

__Return__

The last row as object.

### push

Add record object to the end of the table.

__Arguments__

- `table` - (array of arrays) to access (only static calls)
- `record` - (object) record to add




### column

Get a defined column.

__Arguments__

- `table` - (array of arrays) to access (only static calls)
- `column` - (number or string) the column to export
- `values` - (array) list of values for row 1..

__Return__

A list of values for the column fields from row 1..

### columnAdd

Get a defined column.

__Arguments__

- `table` - (array of arrays) to access (only static calls)
- `column` - (number or string) position there inserting column
- `name` - (string) name of the new column
- `values` - (array) list of values for row 1..

__Return__

The instance if not called statically.

### columnRemove

Get a defined column.

__Arguments__

- `table` - (array of arrays) to access (only static calls)
- `column` - (number or string) position there deleting column

__Return__

The instance if not called statically.


Join
-------------------------------------------------------------



License
-------------------------------------------------

Copyright 2016 Alexander Schilling

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

>  <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
