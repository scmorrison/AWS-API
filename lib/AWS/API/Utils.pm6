use v6;

unit module AWS::API::Utils;

sub camelize-keys(
    Any  $h,
    Bool :$deep = False,
    :$spec
    --> Hash()
) is export {
    $h.kv.map(-> $k, $v {
        my $key   = $spec ~~ Hash ?? $spec{$k} !! camelize($k);
        my $value = $v ~~ List && $v.elems %% 2 ?? ( [Z=>] $v ).Hash !! $v.head;
        if $value !~~ Str && $deep {
            $key => camelize-keys($value, deep => True, spec => $spec);
        } else {
            $key => $value;
        }
    });
};

sub camelize(
    Str $string
    --> Str
) {
    $string.split(/\-|_/).map(-> $word { $word.tclc }).join;
}
