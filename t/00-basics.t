use v6;
use Test;
use lib 'lib';
 
plan 6;

# use
use-ok('AWS::API');
use-ok('AWS::API::Auth');
use-ok('AWS::API::Auth::Credentials');
use-ok('AWS::API::Auth::Signatures');
use-ok('AWS::API::Auth::Utils');
use-ok('AWS::API::Config');
