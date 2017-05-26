#!/usr/bin/env perl6

use v6;

use Test;
use lib 'lib';
use AWS::API::Auth::Utils;

plan 2;

my $datetime = DateTime.new('2017-05-26T21:18:15');

is amz-date($datetime), '20170526T211815Z', 'utils 1/2: amz-date [YYYYMMDDTHHMMSSZ]';
is date($datetime),     '20170526',         'utils 2/2: date     [YYYYMMDD]';
