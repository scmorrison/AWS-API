use v6;
use URI::Escape;
use Digest::SHA;
use Digest::HMAC;

unit module AWS::API::Auth::Utils;

our sub char-reserved(Str $c --> Bool) {
    so $c ~~ / <[ : / ? # \[ \] @ ! $ & \\ ' ( ) * + , ; = ]> /;
}

our sub char-unreserved(Str $c --> Bool) {
    so $c ~~ / <alnum>|<[ ~ _ \- . ]> /;
}

our sub char-unescaped(Str $c --> Bool) {
    char-reserved($c) || char-unreserved($c);
}

our sub uri-encode(Str $url --> Str) is export {
    $url
    ==> &{ S:g/'+'/ / }()
    ==> split('')
    ==> map({ valid-path-char($_) ?? $_ !! uri-escape($_) })
    ==> join('');
}

our proto valid-path-char(Str --> Bool) {*}
multi valid-path-char(' ') { False }
multi valid-path-char('/') { True  }
multi valid-path-char($c ) { char-unescaped($c) && !char-reserved($c) }

our sub bytes-to-hex(@bytes) is export {
    [~] @bytes».fmt: '%02x';
}


our sub hash-sha256($data) is export {
    $data.encode('ascii')
    ==> sha256()
    ==> bytes-to-hex();
}


our sub hmac-sha256($data, $key) is export {
    hmac($key, $data, &sha256);
}

our sub amz-date(DateTime $date --> Str) is export {
    sprintf "%04d%02d%02dT%02d%02d%02dZ",
            .year, .month, .day, .hour, .minute, .second given $date;
}

our sub date(DateTime $date --> Str) is export {
    sprintf "%04d%02d%02d", .year, .month, .day given $date;    
}
