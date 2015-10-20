
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Futures::Rollover qw(get_feed_index_for_generic_future);
use Date::Utility;

plan tests => 3;
my $now = Date::Utility->new();
my $tomorrow = $now->plus_time_interval("1d");

my $now_date = $now->year . sprintf("%02d", $now->month) . sprintf("%02d", $now->day_of_month);
my $tomorrow_date = $tomorrow->year . sprintf("%02d", $tomorrow->month) . sprintf("%02d", $tomorrow->day_of_month);

is get_feed_index_for_generic_future($now->epoch, $now_date), 2, "Correctly disregards current Future feed at the date of expiry";
is get_feed_index_for_generic_future($now->epoch, $tomorrow_date), 1, "Correctly accepts 1! feed before the date of expiry";

is get_feed_index_for_generic_future(), undef, "Check for requires arguments is done";

1;



