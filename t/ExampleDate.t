#!/usr/bin/env perl

use strict;
use warnings;
use Test::Deep;
use Test::More;
use DDG::Test::Goodie;
use DDG::Test::Language;

zci answer_type => "example_date";
zci is_cached   => 0;

sub build_structured_answer {
    my ($format, $result, $is_standard) = @_;
    return $result,
        structured_answer => {

            data => {
              title => $result,
              subtitle => $is_standard
                ? "Random " . $format : "Random date for: $format",
            },

            templates => {
                group => "text",
            }
        };
}

sub build_test { test_zci(build_structured_answer(@_)) }

sub language_test {
    my ($code, $query, @test_params) = @_;
    my $lang = test_language($code);
    DDG::Request->new(
        language  => $lang,
        query_raw => $query
    ) => build_test(@test_params);
}

my $time_24 = qr/\d{2}:\d{2}:\d{2}/;
my $time_12 = qr/\d{1,2}:\d{2}:\d{2} [AP]M/;
my $time_12_my = qr/\d{1,2}:\d{2}:\d{2} PT?G/;
my $short_name = qr/[A-Z][a-z]{2}/;
my $long_name = qr/[A-Z][a-z]{2,}/;
my $week = qr/\d{2}/;
my $day_en = qr/Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday/;
my $day_my = qr/Isnin|Khamis|Jumaat|Ahad|Sabtu|Rabu|Selasa/;

ddg_goodie_test(
    [qw( DDG::Goodie::ExampleDate )],
    'random date for %Y'  => build_test('%Y', re(qr/\d{4}/)),
    'date for %a, %b %T'  => build_test('%a, %b %T', re(qr/$short_name, $short_name $time_24/)),
    'example date for %a' => build_test('%a', re(qr/$short_name/)),
    # 'Standard' Queries
    'random weekday' => build_test('Weekday', re($day_en), 1),
    'random month'   => build_test('Month', re($long_name), 1),
    'random time'    => build_test('Time', re($time_12), 1),
    'random week'    => build_test('Week', re($week), 1),
    # Other locales
    language_test('my', 'random time', 'Time', re($time_12_my), 1),
    language_test('my', 'random day', 'Weekday', re($day_my), 1),
    # Invalid Queries
    'date for %K'   => undef,
    'random number' => undef,
    'example date'  => undef,
);

done_testing;
