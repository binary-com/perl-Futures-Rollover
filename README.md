# perl-Futures-Rollover
Futures rollover helpers

# Introduction

This module helps a feed listener decide whether a given tick can be used as a generic future feed or no (depending on the expiry date of the tick and it's complementary future feed).

This module provides one method:

* is_tick_fit_for_generic_feed: Given a future symbol name (e.g. ABC_1 for current period or ABC_2 for front period), tick's contract expiration date and current Future contract expiration date, returns 1 if 
the given tick can be used for a generic future feed, 0 otherwise.

# Example

```perl

use Futures::Rollover qw(is_tick_fit_for_generic_feed);

my $current_expiry_date = "10152015";
my $symbol = "ABC_1";

my $is_good = is_tick_fit_for_generic_feed($symbol, $tick_epoch, $current_expiry_date);

```

