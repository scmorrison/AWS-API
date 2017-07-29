use v6;

unit module AWS::API::Utils;

sub camelize-keys(
    Any  $h,
    Bool :$deep = False,
    Hash :$spec
    --> Hash()
) is export {
    map -> $k, $v {
        my $key   = $spec.defined ?? $spec{$k} !! camelize($k);
        my $value = $v ~~ List ?? %( [Z=>] $v ) !! $v;
        if $value !~~ Str && $deep {
            $key => camelize-keys $value, deep => True, spec => $spec;
        } else {
            $key => $value;
        }
    }, kv $h;
};

sub camelize(
    Str $string
    --> Str
) {
    join '', map &tclc, split /\-|_/, $string;
}

sub epoch {
    DateTime.new: '1970-01-01T00:00:00Z';
}

sub iso-z-to-secs(
    DateTime $date
    --> Duration
) is export {
    $date - epoch;
}

sub now-in-seconds(--> Duration) is export {
    now - epoch;
}

sub rename-keys(
    Hash $params,
    Hash $mapping
    --> Hash()
) is export {
    map -> $k, $v {
        $mapping{$k}||$k => $v;
    }, kv $params;
}


