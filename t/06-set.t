use Test;
use lib $?FILE.IO.parent.child("lib").Str;
use CompUnit::Util :set-symbols;

plan 6;

{
    use set-export;
    ok &foo, 'set-export code wtih name';
    is EXPORT-Foo,'foo',"name option worked";
    is GLOBALish-Foo,'foo','set-globalish';
    is lex-EXPORT-sub-Foo,'foo','set-lexical';
}

is UNIT-EXPORT-sub-Foo,'foo','set-unit';
nok ::('lex-EXPORT-sub-Foo'),<set-lexical doesn't leak>;
