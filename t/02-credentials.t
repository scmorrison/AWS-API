#!/usr/bin/env perl6

use v6;

use Test;
use Test::Output;
use URI;
use lib 'lib';
use AWS::API::Auth::Credentials;

plan 2;

my %config = access_key_id     => 'AKIAIOSFODNN7EXAMPLE',
             region            => 'us-east-1';

my $r1_expected = "AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request";
my $r1_request  = generate-credential-v4(
    service  => 's3',
    config   => %config,
    datetime => DateTime.new('2013-05-24T00:00:00'));

is $r1_request, $r1_expected, 'credentials 1/2: generate-credential-v4';

my $r2_expected = "20130524/us-east-1/s3/aws4_request";
my $r2_request  = generate-credential-scope-v4(
    service  => 's3',
    config   => %config,
    datetime => DateTime.new('2013-05-24T00:00:00'));

is $r2_request, $r2_expected, 'credentials 2/2: generate-credential-scope-v4';
