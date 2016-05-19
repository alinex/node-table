eTable
=================================================

[![Build Status](https://travis-ci.org/alinex/node-table.svg?branch=master)](https://travis-ci.org/alinex/node-table)
[![Coverage Status](https://coveralls.io/repos/alinex/node-table/badge.png?branch=master)](https://coveralls.io/r/alinex/node-table?branch=master)
[![Dependency Status](https://gemnasium.com/alinex/node-table.png)](https://gemnasium.com/alinex/node-table)

This package contains methods for working with table like data.

- convert
- filter
- sort
- join
- and more

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
table = require 'alinex-table'
```

### Data Types

The data objects which will be used here are:

__Table__

This format stores the data like a table calculation program. It is the format
derived from the CSV format.

``` coffee
[
  ['ID', 'Name']
  [1, 'one']
  [2, 'two']
  [3, 'three']
]
```

The first line has to be the header.

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

### Conversion

To convert from and to the different data structures described above, you can
use the following 4 methods:

``` coffee
  result = table.toRecordList example
  result = table.fromRecordList recordList
  result = table.toRecordObject example
  result = table.fromRecordObject recordObject, idColumn
```

The conversion to record object will loose the name of the first column so it
will always get 'ID' on back conversion to table if not defined otherwise.

> Keep in mind that the table data needs a header row as first line.

### Manipulation


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
