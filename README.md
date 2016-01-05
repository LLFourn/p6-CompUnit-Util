<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [CompUnit::Util](#compunitutil)
  - [Utilities](#utilities)
    - [load](#load)
    - [find-loaded](#find-loaded)
    - [all-loaded](#all-loaded)
    - [at-unit](#at-unit)
    - [capture-import](#capture-import)
  - [Re-Exporting](#re-exporting)
    - [re-export](#re-export)
    - [re-exporthow](#re-exporthow)
    - [steal-EXPORT-sub](#steal-export-sub)
    - [steal-globalish](#steal-globalish)
    - [re-export-everything](#re-export-everything)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# CompUnit::Util

Utility functions for introspecting `CompUnit`s and re-exporting their symbols

Apart from `load` none of the routines here will load a compunit. All
parameters called `$handle` will converted to a `CompUnit::Handle`
automatically. If the `$handle` you pass is not a defined `CompUnit` or
`CompUnit::Handle`, `&find-loaded` will be used to search for an
loaded compunit matching your argument.

**warning** this module relies on unspec'd rakudo internals and could
break without warning

## Utilities

### load
`(Str:D $short-name,*%opts --> CompUnit:D)`

``` perl6
    use CompUnit::Util :load;
    my CompUnit $cu = load('Test');
    # or even
    my $cu = load('MyModule', version => v3);
```

loads a compunit by name. All named arguments to
`CompUnit::DependencySpecification` are accepted (other
than `short-name` which is the positional argument).

### find-loaded
`($match --> CompUnit)`

``` perl6
    use CompUnit::Util :find-loaded;
    need SomeModule;
    my CompUnit $some-module = find-loaded('SomeModule');
```

Searches all the `CompUnit::Repository`s until it finds a loaded
compunit matching `$match`. Returns a failure otherwise.

### all-loaded

```perl6
    use CompUnit::Util :all-loaded;
    .note for all-loaded;
```

Returns all presently loaded `CompUnit`s.

### at-unit
`($handle,Str:D $key)`

``` perl6
    use CompUnit::Util :at-unit;
    say at-unit('CompUnit::Util','$=pod');
```

Gets a symbol from the `UNIT` scope of the compunit.

### capture-import
`($handle, *@pos, *%named --> Hash:D)`

``` perl6
    use CompUnit::Util :capture-import;
    need SomeModule;
    my %symbols = capture-import('SomeModule',:tag);
```

Attempts to simulate a `use` statement. Returns a hash of all the
symbols the compunit would export if it were `use`d.

## Re-Exporting

The following routines provide re-exporting which is not yet implemented in rakudo.

### re-export
`($handle)`

``` perl6
    use CompUnit::Util :re-export;
    need SomeModule;
    BEGIN re-export('SomeModule');
    # This compunit will now export everything that SomeModule does
```

Merges the `EXPORT` package from `$handle` into the
present `UNIT::EXPORT`.

**this routine can only be called at `BEGIN` time**

### re-exporthow
`($handle)`

``` perl6
    use CompUnit::Util :re-export;
    need SomeModule;
    BEGIN re-exporthow('SomeModule');
    # This compunit now exports SomeModule's custom declarators
```

Merges the `EXPORTHOW` from `$handle` into the present
`UNIT::EXPORTHOW`. `UNIT::EXPORTHOW` will be created if it doesn't
exist but it won't clobber it if it does.

**this routine can only be called at `BEGIN` time**

### steal-EXPORT-sub
`($handle)`

``` perl6
    use CompUnit::Util :re-export;
    need SomeModule;
    BEGIN steal-EXPORT-sub('SomeModule');
    # This compunit now has the same &EXPORT as SomeModule
```

Sets `UNIT::<&EXPORT>` to `$handle`'s `&EXPORT`.

**this routine can only be called at `BEGIN` time**

### steal-globalish
`($handle)`

``` perl6
    use CompUnit::Util :re-export,:load;
    BEGIN steal-globalish(load('SomeModule'));
    # This compunit now has everything in SomeModule in it's globalish
```

Merges `UNIT::GLOBALish` with another compunit's `GLOBALish`.

This is the least interesting of all the re-exports, and if you've
already done `need SomeModule;` you won't need it. But it's here for
completeness. The above example should be the same as this anyway:

``` perl6
    BEGIN require ::('SomeModule');
```

**this routine can only be called at `BEGIN` time**

### re-export-everything
`($handle)`

``` perl6
    use CompUnit::Util :re-export;
    BEGIN re-export-everything('SomeModule');
    # use [this-module]; should now do the same thing as use SomeModule;
```

A convenience method for calling all the other functions under
re-export functions with the same argument.

**this routine can only be called at `BEGIN` time**
