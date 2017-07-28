#!/usr/bin/env perl6

use v6;

use Test;
use lib 'lib';
use AWS::API::Utils;

plan 3;

subtest {
    plan 6;

	is camelize-keys(%{ hello_world => "foo" }), %{ HelloWorld => "foo"}, "camelize-keys with hash";
	is camelize-keys(%{foo_bar => %{ foo_bar => "baz" }}), %{ FooBar => %{ foo_bar => "baz" }}, "shallow";
	is camelize-keys(%{ foo_bar => %{ foo_bar => "baz" }}, deep => True), %{ FooBar => %{ FooBar => "baz" }}, "deep";
	is camelize-keys(%{ foo_bar => [ foo_bar => "baz",  ]}, deep => True), %{ FooBar => %{ FooBar => "baz" }}, "list deep";
	is camelize-keys(%{ foo_bar => [ "foo_bar", "baz" ]}, deep => True), %{ FooBar => %{ FooBar => "baz" }}, "non-Pair list deep";
	is camelize-keys(%{ foo_bar => [ "foo", "bar" ] }, spec => %{ foo_bar => "non-standard" }),
	   %{ non-standard => %{ foo => "bar" }}, "non-standard";
}, 'camelize-keys';

is iso-z-to-secs(DateTime.new('2015-07-05T22:16:18Z')), 1436134604, 'iso-z-to-secs iso string to epoch seconds';
is rename-keys(%{ a => 1, b => 2, c => 3}, %{ a => 'd', c => 'e' }), %{ d => 1, b => 2, e => 3 }, 'rename-keys from keyword list';
