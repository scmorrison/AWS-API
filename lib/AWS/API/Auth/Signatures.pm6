use AWS::API::Auth::Utils;

unit module AWS::API::Auth::Signatures;

our sub generate-signature-v4(
    :$service, 
    :$config,
    :$datetime,
    :$string_to_sign
) is export {
    signing-key($service, $datetime, $config)
    ==> hmac-sha256( $string_to_sign)
    ==> bytes-to-hex();
}

sub signing-key(
    $service,
    $datetime,
    $config
) {
     "AWS4{$config<secret_access_key>}"
     ==> hmac-sha256(date($datetime))
     ==> hmac-sha256($config<region>)
     ==> hmac-sha256($service)
     ==> hmac-sha256('aws4_request');
}
