use v6;

use Config::INI;

unit module AWS::API::CredentialsIni;

our sub parse-ini-file(
    Str :$ini,
    Str :$profile
    --> Hash()
) {
    Config::INI::parse($ini){$profile}
    ==> map(&strip-key-prefix);
}

sub strip-key-prefix(
    Hash $credentials
    --> Hash()
) {
    $credentials<aws_access_key_id aws_secret_access_key aws_session_token region>:kv
    ==> map( -> $k, $v { Pair.new: $k.subst('aws_', ''), $v });
}

our sub replace-token-key(
    Hash $credentials
    --> Hash()
) {
    $credentials.kv
    ==> map( -> $k, $v { 
        given $k {
            when 'session_token' { Pair.new: 'security_token', $v }
            default { Pair.new: $k, $v }
        }
    });
}
