use v6;

use Config::INI;

unit module AWS::API::CredentialsIni;

our sub parse-ini-file(
    Str :$ini,
    Str :$profile
    --> Hash()
) {
    map &strip-key-prefix, Config::INI::parse($ini){$profile};
}

sub strip-key-prefix(
    Hash $credentials
    --> Hash()
) {
    map -> $k, $v {
        (S/'aws_'// given $k) => $v
    }, $credentials<aws_access_key_id aws_secret_access_key aws_session_token region>:kv;
}

our sub replace-token-key(
    Hash $credentials
    --> Hash()
) {
    map -> $k, $v { 
        given $k {
            when 'session_token' { security_token => $v }
            default { $k => $v }
        }
    }, kv $credentials;
}
