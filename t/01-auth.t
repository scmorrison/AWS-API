#!/usr/bin/env perl6

use v6;

use Test;
use URI;
use lib 'lib';
use AWS::API::Auth;
use AWS::API::Auth::Utils;

plan 3;

my %config = access_key_id     => 'AKIAIOSFODNN7EXAMPLE',
#my %config = access_key_id     => 'AKIAIOSFODNN7EXAMPLE',
             secret_access_key => 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
             region            => 'us-east-1';

my $r1_expected = "GET\n/foo%3Abar%40baz\n\n\n\n\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
my $r1_path     = URI.new('http://perl6.org/foo:bar@baz').path;
my $r1_request  = build-canonical-request(
    http_method => 'get',
    path        => $r1_path,
    query       => '',
    headers     => %(),
    body        => '');

is $r1_request, $r1_expected, 'auth 1/3: build-canonical-request special characters in path';

my $r2_request  = presigned-url(
    http_method => 'get',
    url         => "https://examplebucket.s3.amazonaws.com/test.txt",
    service     => 's3',
    datetime    => DateTime.new('2013-05-24T00:00:00'), 
    config      => %config,
    expires     => 86400);

my $r2_expected = "https://examplebucket.s3.amazonaws.com/test.txt" ~
                  "?X-Amz-Algorithm=AWS4-HMAC-SHA256" ~
                  "&X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20130524%2Fus-east-1%2Fs3%2Faws4_request" ~
                  "&X-Amz-Date=20130524T000000Z" ~
                  "&X-Amz-Expires=86400" ~
                  "&X-Amz-SignedHeaders=host" ~
                  "&X-Amz-Signature=aeeed9bbccd4d02ee5c0109b86d86835f995330da4c265957d157751f604d404";
is $r2_request, $r2_expected, 'auth 2/3: presigned url';

my $r3_request  = presigned-url(
    http_method  => 'put',
    url          => "https://examplebucket.s3.amazonaws.com/test.txt",
    service      => 's3',
    datetime     => DateTime.new('2013-05-24T00:00:00'), 
    config       => %config,
    expires      => 86400,
    query_params => %(partNumber => 1, uploadId => "sample.upload.id") );

my $r3_expected = 'https://examplebucket.s3.amazonaws.com/test.txt' ~
                  '?partNumber=1' ~
                  '&uploadId=sample.upload.id' ~
                  '&X-Amz-Algorithm=AWS4-HMAC-SHA256' ~
                  '&X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20130524%2Fus-east-1%2Fs3%2Faws4_request' ~
                  '&X-Amz-Date=20130524T000000Z' ~
                  '&X-Amz-Expires=86400' ~
                  '&X-Amz-SignedHeaders=host' ~
                  '&X-Amz-Signature=1fdac5451b2996880dc23162853ce76e4cf0a05257e430aec59e309ecd126ade';
is $r3_request, $r3_expected, 'auth 3/3: presigned url with query params';

