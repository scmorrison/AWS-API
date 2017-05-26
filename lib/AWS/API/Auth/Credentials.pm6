use AWS::API::Auth::Utils;

unit module AWS::API::Auth::Credentials;

our sub generate-credential-v4(
    :$service, :$config, :$datetime
) is export {
    my $scope = generate-credential-scope-v4(:$service, :$config, :$datetime);
    "{$config<access_key_id>}/{$scope}";
}

our sub generate-credential-scope-v4 (
    :$service, :$config, :$datetime
) is export {
    "{date($datetime)}/{$config<region>}/{$service}/aws4_request";
}
