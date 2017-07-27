#!/usr/bin/env perl6

use v6;

use Test;
use lib 'lib';
use AWS::API::Config;
use AWS::API::CredentialsIni;

plan 6;

%*ENV<AWSAPIConfigTest> = 'bar';
my $access_key_id = AWS::API::Config::new('s3',
    %(access_key_id     => :system("AWSAPIConfigTest"),
      secret_access_key => :system("AWS_SECURITY_TOKEN")))<access_key_id>;
is $access_key_id, %*ENV<AWSAPIConfigTest>, 'environment variable support';


%*ENV<AWS_SECURITY_TOKEN> = 'security_token';
my $aws_security_token = AWS::API::Config::new('s3',
    %(access_key_id  => :system("AWS_SECURITY_TOKEN"),
      security_token => :system("AWS_SECURITY_TOKEN")))<security_token>;
is $aws_security_token, %*ENV<AWS_SECURITY_TOKEN>, "security_token configured properly";

my $test_ini = q:to/END/;
[default]
aws_access_key_id     = TESTKEYID
aws_secret_access_key = TESTSECRET
aws_session_token     = TESTTOKEN
region                = eu-west-1
END

my %credentials =
    (AWS::API::CredentialsIni::parse-ini-file(
        ini     => $test_ini,
        profile => 'default')
     ==> AWS::API::CredentialsIni::replace-token-key());

is %credentials<access_key_id>, 'TESTKEYID', "parse credentials file [access_key_id]";
is %credentials<secret_access_key>, 'TESTSECRET', "parse credentials file [secret_access_key]";
is %credentials<security_token>, 'TESTTOKEN', "parse credentials file [security_token]";
is %credentials<region>, 'eu-west-1', "parse credentials file [region]";
