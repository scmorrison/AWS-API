#!/usr/bin/env perl6

use v6;

use Test;
use lib 'lib';
use AWS::API::Auth::Signatures;

plan 1;

my %config = access_key_id     => 'AKIAIOSFODNN7EXAMPLE',
             secret_access_key => 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
             region            => 'us-east-1';

my $r1_expected = "690b8431208dae486dd00df93bde9370d8aba587098b9a26bfd07c259df395c9";
my $r1_request  = generate-signature-v4(
    service        => 's3',
    config         => %config,
    datetime       => DateTime.new('2016-08-29T19:41:33'),
    string_to_sign => 'hello world');

is $r1_request, $r1_expected, 'signatures 1/1: generate-signature-v4';
