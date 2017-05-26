use AWS::API::Auth::Utils;

unit module AWS::API::Auth::Signatures;

our sub generate-signature-v4(
    :$service, 
    :$config,
    :$datetime,
    :$string_to_sign
) is export {
    my $signing_key = signing-key($service, $datetime, $config);
    my $signature   = hmac-sha256($signing_key, $string_to_sign);
    bytes-to-hex($signature);
}

sub signing-key(
    $service,
    $datetime,
    $config
) {
     my $hdate    = hmac-sha256( "AWS4{$config<secret_access_key>}",  date($datetime) );
     my $hregion  = hmac-sha256($hdate, $config<region>);
     my $hservice = hmac-sha256($hregion, $service);
     hmac-sha256($hservice, 'aws4_request');
}
