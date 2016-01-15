use Test;
use lib $?FILE.IO.parent.child("lib").Str;

plan 7;

{
    use push-multi;
    is &foo.candidates.elems,2,"correct candidates";
    is foo('one'),'one',"multi #1 installed";
    is foo('two'),'two',"multi #2 installed";

    ok Numeric === &bar.signature.params[0].type,'proto';
    is bar(Int),'Int','multi #1 installed for custom proto';
    is bar(Num),'Num','multi #2 installed for custom proto';
    is &bar.candidates.elems,2,'correct candidates';
}
