use CompUnit::Util :set-symbols;

BEGIN set-export(%('&foo' => sub foo { }));
BEGIN set-export({EXPORT-Foo => 'foo'});
BEGIN set-globalish({GLOBALish-Foo => 'foo'});
#BEGIN note $*GLOBALish.WHO.{'GLOBALish-Foo'};
#note GLOBALish-Foo;

sub EXPORT {
    set-unit({UNIT-EXPORT-sub-Foo => 'foo'});
    set-lexical({lex-EXPORT-sub-Foo => 'foo'});
    {};
}
