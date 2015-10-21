# perl-Futures-Rollover

Futures rollover helpers

# Introduction

This module helps decide which of currently traded Future feeds can go to the Generic Future feed. 
It determined index of the Future feed (which is either 1 or 2) that can go to the generic Future feed according to roll-over rules.
A Generic Future feed is a combination of two Future feeds, which are called current and front. The goal to create a Generic Future feed
is to have a more stable and accurate price feed for Future contracts.
Current Future feed (indexed 1) is the currently active Future contract that is the next expiring contract. 
The Front Future feed (indexed 2) is the next expiring Future contract after Current Future contract.
The rule is that, Generic Future will contains all data from "Current Future" unless on the day of expiry. On that
specific day we will switch to "Front". After the day of expiry (upon which, the Current Future will be expired), 
Front Future will be published under the Current Future name and a new contract will be created and published as
Front Future, this switching is called Roll-over.
This module provides one method:

* get_feed_index_for_generic_future: 
Input: $tick_tpoch (current time), $current_feed_expiry_day (expiry date of the current Future feed in the format of yyyymmdd)
Output: 1 (if the current feed should be used in generic Future feed creation), 2 (if front feed should be used for generic feed), 0 (wrong input or unknown situation)

# Example

```perl

use Futures::Rollover qw(get_feed_index_for_generic_future);

my $current_expiry_date = "20151015";
my $current_epoch = time;

my $index = get_feed_index_for_generic_future($current_epoch, $current_expiry_date);

```

