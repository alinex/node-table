Data Types
================================================================

The `Table` class supports three different data structures to be red or written.
See the examples below which are also used in the API examples.


Table
----------------------------------------------------------------
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


Record List
----------------------------------------------------------------
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


Record Object
----------------------------------------------------------------
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
