#!/usr/bin/env perl6

use v6;

use Test;
use lib 'lib';
use AWS::API::Request::Url;

plan 8;

my %query  = path   => '/path',
             params => %( foo => 'bar' );

my %config = scheme => 'https',
             host   => 'example.com',
             port   => 443;

is AWS::API::Request::Url::build( %query, %config ), 'https://example.com/path?foo=bar', 'build urls for query operation';

my %config2 = %( |%config, port => 4430 );
is AWS::API::Request::Url::build( %query, %config2 ), 'https://example.com:4430/path?foo=bar', 'build urls custom port (Int)';

my %config3 = %( |%config, port => "4430" );
is AWS::API::Request::Url::build( %query, %config3 ), 'https://example.com:4430/path?foo=bar', 'build urls custom port (Str)';

my %config4 = %( |%config, scheme => "https://" );
is AWS::API::Request::Url::build( %query, %config4 ), 'https://example.com/path?foo=bar', 'build urls scheme trailing ://';

my %query5 = %( |%query, params => %( ) );
is AWS::API::Request::Url::build( %query5, %config ), 'https://example.com/path', 'build urls without trailing ?';

my %query6 = path => '/path';
is AWS::API::Request::Url::build( %query6, %config ), 'https://example.com/path', 'build urls without params hash';

my %query7 = %( |%query, path => "//path///with/too/many//slashes//" );
is AWS::API::Request::Url::build( %query7, %config ), 'https://example.com/path/with/too/many/slashes?foo=bar', 'build urls strip extra slashes';

my %query8 = %( |%query, params => %( foo => 'bar', "" => 1 ) );
is AWS::API::Request::Url::build( %query8, %config ), 'https://example.com/path?foo=bar', 'build urls ignore empty keys';
