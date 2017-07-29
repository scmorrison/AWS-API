use v6;

use URI::Template;

unit module AWS::API::Request::Url;

our sub build(
    Hash $operation,
    Hash $config
    --> Str
) {
    my %params = normalize-params($operation<params>); 
    my $path   = S/\/$// given (S:g/\/?(\/+)+/\// given $operation<path>);

    my $template = URI::Template.new:
        template => normalize-scheme($config<scheme>) ~ '://' \
            ~ $config<host> ~ non-standard-port($config<port>) \
            ~ '{+path}{?' ~ %params.keys.join(',') ~ '}';

    $template.process:
        path => $path,
        port => $config<port>,
        |%params;
}

sub normalize-scheme(
    Str $scheme
    --> Str
) {
    S/'://'// given $scheme;
}

subset Port of Any where * ~~ Str|Int;
sub non-standard-port(
    Port $port
    --> Str
) {
    return $port !~~ 443|80 ?? ':{port}' !! '';
}

multi sub normalize-params(
    Hash $params
    --> Hash
) {
    return %( $params.grep: { .key !~~ ''|Empty } );
}

multi sub normalize-params(
    Any $params
    --> Hash
) {
    return %();
}
