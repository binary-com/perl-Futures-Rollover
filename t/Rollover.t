
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Futures::Rollover qw(is_tick_fit_for_generic_feed);
use Date::Utility;

plan tests => 5;
my $now = Date::Utility->new();
my $tomorrow = $now->plus_time_interval("1d");

my $now_date = sprintf("%02d", $now->month) . sprintf("%02d", $now->day_of_month) . $now->year;
my $tomorrow_date = sprintf("%02d", $tomorrow->month) . sprintf("%02d", $tomorrow->day_of_month) . $tomorrow->year;

is is_tick_fit_for_generic_feed("ABC_1", $now->epoch, $now_date), 0, "Correctly disregards 1! feed at the date of expiry";
is is_tick_fit_for_generic_feed("ABC_1", $now->epoch, $tomorrow_date), 1, "Correctly accepts 1! feed before the date of expiry";

is is_tick_fit_for_generic_feed("ABC_2", $now->epoch, $now_date), 1, "Correctly accepts 2! feed at the date of expiry";
is is_tick_fit_for_generic_feed("ABC_2", $now->epoch, $tomorrow_date), 0, "Correctly disregards 2! feed before the date of expiry";

is is_tick_fit_for_generic_feed, 0, "Check for requires arguments is done";

1;



