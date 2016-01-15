use CompUnit::Util :push-multi;

BEGIN { push-unit-multi('EXPORT::DEFAULT::&foo', my multi foo ('one') { "one" } ) };
BEGIN { push-unit-multi('EXPORT::DEFAULT::&foo', my multi foo ('two') { "two" } ) };

BEGIN { push-unit-multi 'EXPORT::DEFAULT::&bar',my proto bar(Numeric) {*} }
BEGIN { push-unit-multi 'EXPORT::DEFAULT::&bar',my multi foo(Int) { 'Int' } }
BEGIN { push-unit-multi 'EXPORT::DEFAULT::&bar',my multi foo(Num) { 'Num' } }
