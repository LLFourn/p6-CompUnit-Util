=pod This is just some pod to test at-unit('CompUnit::Util','$=pod');
unit module CompUnit::Util;

# I would like to have .wrap to do this automaticaly but you
# can't call .wrap stuff at compile time apparently.
# also coercion would be nice but that doesn't seem possible.
sub handle($_) {
    when CompUnit::Handle:D { $_ }
    when CompUnit:D { .handle }
    default { find-loaded($_).handle }
}

sub load(Str:D $short-name,*%opts --> CompUnit:D) is export(:load){
    $*REPO.need(CompUnit::DependencySpecification.new(:$short-name,|%opts));
}


sub find-loaded($match --> CompUnit) is export(:find-loaded)  {
    my $repo = $*REPO;
    my $found;

    repeat {
        if my $compunit = $repo.loaded.first($match) {
            $found = $compunit;
            last;
        }
    } while $repo .= next-repo;

    return $found || fail "unable find loaded compunit matching '{$match.gist}'";
}

sub all-loaded is export(:all-loaded){
    my $repo = $*REPO;
    do repeat { |$repo.loaded } while $repo .= next-repo;
}

sub all-repos is export(:all-repos) {
    my $repo = $*REPO;
    do repeat { $repo } while $repo .= next-repo;
}

sub at-unit($handle is copy,Str:D $key) is export(:at-unit){
    use nqp;
    $handle .= &handle;
    nqp::atkey($handle.unit,$key);
}

sub unit-to-hash($handle is copy) is export(:unit-to-hash) {
    use nqp;
    my $unit := $handle.unit;
    my Mu $iter := nqp::iterator($unit);
    my %hash;
    while $iter {
        my $i := nqp::shift($iter);
        %hash{nqp::iterkey_s($i)} = nqp::iterval($i);
    }
    return %hash;
}

sub capture-import($handle is copy, *@pos, *%named --> Hash:D) is export(:capture-import){
    $handle .= &handle;
    my $EXPORT     = $handle.export-package;
    my %sym;

    %named<DEFAULT> = True unless %named or @pos;

    for %named.keys {
        %sym.append($EXPORT{$_}.WHO);
    }

    with $handle.export-sub {
        %sym.append: .(|@pos);
    }

    with $handle.globalish-package {
        %sym.append: .WHO;
    }

    return %sym;
}


multi re-export($handle is copy)  is export(:re-export) {
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
        $handle .= &handle;
    $*UNIT.symbol('EXPORT')<value>.WHO.merge-symbols($handle.export-package);
}

sub re-exporthow($handle is copy) is export(:re-export){
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    $handle .= &handle;

    if $handle.export-how-package -> $target-WHO {
        my $existing := $*UNIT.symbol('EXPORTHOW');

        my $EXPORTHOW := do if $existing<value>:exists {
            $existing<value>;
        } else {
            Metamodel::PackageHOW.new_type(:name("EXPORTHOW"));
        }

        my $my-WHO := $EXPORTHOW.WHO;
        $my-WHO.merge-symbols($target-WHO);
        $*W.install_lexical_symbol($*UNIT,'EXPORTHOW',$EXPORTHOW);
    }
}

sub steal-export-sub($handle is copy) is export(:re-export){
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    $handle .= &handle;
    if my $EXPORT  = $handle.export-sub {
        $*W.install_lexical_symbol($*UNIT,'&EXPORT',$EXPORT,:clone);
    }
}

sub steal-globalish($handle is copy) is export(:re-export){
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    $handle .= &handle;
    my $target = $handle.globalish-package;
    $*UNIT.symbol('GLOBALish')<value>.WHO.merge-symbols($target.WHO);
}

sub re-export-everything($_ is copy) is export(:re-export) {
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    $_ .= &handle;
    .&re-export;
    .&re-exporthow;
    .&steal-export-sub;
    .&steal-globalish;
}

sub set-export(%syms,Str:D $tag = 'DEFAULT') is export(:set-symbols){
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    for %syms {
        $*UNIT.symbol('EXPORT').<value>.WHO.package_at_key($tag).WHO.{.key} := .value;
    }
}

sub set-globalish(%syms) is export(:set-symbols) {
    use nqp;
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;

    for %syms.kv -> $key,\value is raw {
        # if no  decont the value here it goofs
        $*GLOBALish.WHO.{$key} := nqp::decont(value);
    }
}

sub set-unit(%syms) is export(:set-symbols) {
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    for %syms {
        $*W.install_lexical_symbol($*UNIT,.key,.value);
    }
}

sub set-lexical(%syms) is export(:set-symbols) {
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    for %syms {
        $*W.install_lexical_symbol($*W.cur_lexpad(),.key,.value);
    }
}

sub mixin_LANG($lang = 'MAIN',:$grammar,:$actions) is export(:mixin_LANG){
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;

    if $grammar !=== Any {
        %*LANG{$lang} := %*LANG{$lang}.^mixin($grammar);
    }

    if $actions !=== Any {
        my $actions-key = $lang ~ '-actions';
        %*LANG{$actions-key} := %*LANG{$actions-key}.^mixin($actions);
    }
    # needed so it will work in EVAL
    set-lexical(%('%?LANG' => $*W.p6ize_recursive(%*LANG)));
}
