# CompUnit::Util

Utility functions for introspecting `CompUnit`s and re-exporting their symbols

``` perl6
    need Test;
    my $Test-compunit = find-loaded('Test');
    my %exported-symbols = capture-import($Test-compunit);

    # anything importing from this will get everything from Test
    BEGIN re-export($Test-compunit);
```

**warning** this module relies on unspec'd rakudo internals and could
break without warning

Each time you see `$handle` as the argument will converted into a
`CompUnit::Handle`. If it's not a defined `CompUnit` or
`CompUnit::Handle`, `&find-loaded` will be used to search for an
already loaded compunit matching your argument.


## &load(Str:D $short-name,*%opts --> CompUnit:D)

``` perl6
    use CompUnit::Util :load;
    my $cu = load('Test');
    # or even
    my $cu = load('MyModule', version => v3);
```

loads a compunit by name. All named arguments to
`CompUnit::DependencySpecification` are accepted (other
than `short-name`).

## &find-loaded($match --> CompUnit)

``` perl6
    use CompUnit::Util :find-loaded;
    need SomeModule;
    my CompUnit $test = find-loaded('SomeModule);
```

Searches all the `CompUnit::Repository`s until it finds a loaded
compunit matching `$match`. Returns a failure otherwise.

## &all-loaded()

```perl6
    use CompUnit::Util :all-loaded;
    .note for all-loaded;
```

Returns all presently loaded modules.

## at-unit($handle is copy,Str:D $key)

``` perl6
    use CompUnit::Util :at-unit;
    say at-unit('CompUnit::Util','$=pod');
```

Gets a symbol from the `UNIT` scope of the compunit.

## &capture-import($handle, *@pos, *%named --> Hash:D)

``` perl6
    use CompUnit::Util :capture-import;
    need SomeModule;
    my %symbols = capture-import('SomeModule',:tag);
```

Attempts to simulate a `use` statement. Returns a hash of all the
symbols the module exports.

## &re-export($handle)

``` perl6
    use CompUnit::Util :re-export;
    need SomeModule;
    BEGIN re-export('SomeModule');
    # This compunit will now export everything from SomeModule
```

Merges the `EXPORT` package from `$handle` into the
present `UNIT::EXPORT`.

**this routine can only be called at `BEGIN` time**

## &steal-EXPORT-sub($handle)

``` perl6
    use CompUnit::Util :re-export;
    need SomeModule;
    BEGIN steal-EXPORT-sub('SomeModule');
    # This compunit now has the same &EXPORT as SomeModule
```

Sets `UNIT::<&EXPORT>` to `$handle`'s `&EXPORT`.

**this routine can only be called at `BEGIN` time**

## &re-exporthow($handle)

``` perl6
    use CompUnit::Util :re-export;
    need SomeModule;
    BEGIN re-exporthow('SomeModule');
    # This compunit now exports SomeModule's custom declarators
```

Merges `UNIT::EXPORTHOW` with another compunit's
`EXPORTHOW`. `UNIT::EXPORTHOW` will be created if it doesn't exist but
it won't clobber it if it already exists.

**this routine can only be called at `BEGIN` time**

## &steal-globalish($handle)

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

## re-export-everything($handle)

``` perl6
    use CompUnit::Util :re-export;
    BEGIN re-export-everything('SomeModule');
    # use [this-module]; should now do the same thing as use SomeModule;
```

A convenience method for calling all the other functions under
`:re-export` with the same argument.

**this routine can only be called at `BEGIN` time**
