use Test;
use CompUnit::Util :find-loaded,:load,:all-loaded,:at-unit,:unit-to-hash,:set-in-who;
plan 15;

ok my $native-call = load('NativeCall'),'load';
ok $native-call === load('NativeCall'), 'load again returns same thing';

ok find-loaded('Test') ~~ CompUnit:D, 'found Test';
ok find-loaded('CompUnit::Util') ~~ CompUnit:D, 'found CompUnit::Util';
nok find-loaded('Foo'),'find-loaded on non-existent module returns false';
ok find-loaded('Foo') ~~ Failure:D,'returns Failure';

ok all-loaded()».short-name.pick(*) ~~ set('CompUnit::Util','NativeCall','Test'),
"all-loaded finds the correct units";

my $cu = load('CompUnit::Util');
my $pod = at-unit('CompUnit::Util','$=pod')[0];
ok  $pod ~~ Pod::Block:D, 'at-unit finds $=pod';
ok at-unit($cu,'$=pod')[0] === $pod,'at-units works with CompUnit';
ok at-unit($cu.handle,'$=pod')[0] === $pod,'at-units works with CompUnit::Handle';

ok unit-to-hash($cu)<$=pod>[0] === $pod, 'unit-to-hash returns same thing';


{
    eval-lives-ok q|
    use CompUnit::Util :set-in-who;
        my package tmp {};
        BEGIN set-in-who(tmp.WHO,'Foo','foo');
        is tmp::Foo,'foo','set-in-who 1 name'
    |;
}

{
    eval-lives-ok q|
        use CompUnit::Util :set-in-who;
        my package tmp {};
        BEGIN set-in-who(tmp.WHO,'Foo::Bar::$Baz','bar');
        is tmp::Foo::Bar::<$Baz>,'bar','set-in-who multiple';
    |;

}
