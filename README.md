# perl-Futures-Rollover
Futures rollover date calculation

# Introduction

This module calculates expiration date and contract codes for Future contracts named according to eSignal provider. 

According to eSignal naming convention a Future contract is specified using three elements: Symbol name, Expiration month and Exchange name. 

For example if a Future contract's code is "APS U5-SFE" then:
- Symbol name is "APS"
- Expiration date is "U5"
- Exchange name is "SFE"

Expiration date has two parts: month and year. In above example expiration month is "U" (meaning September) and expiration year is 5 (meaning 2015).
Here is the coding of months in expiration date:

* Jan => F
* Feb => G
* Mar => H
* Apr => J
* May => K
* Jun => M
* Jul => N
* Aug => Q
* Sep => U
* Oct => V
* Nov => X
* Dec => Z

The rule for determining exact date of expiry for each Future contract is different. For example for "FTSE" it is third Friday of the expiration month. 

This module provides two methods:

* _get\_expiration\_epoch_: Given "symbol name", "expiration date" and a HashRef of related exchange holidays will return the exact epoch of the expiration of the Future contract.
* _get\_previous\_contract\_code_: Given a "symbol name" and "expiration date" returns the contract code (One letter month + year) for the previous Future contract. Note that this is not always equal the previous month as some contracts are traded in 3 month periods.

# Examples

```perl
my $prev_code = get_previous_contract_code("BSX", "U5");
#prev_code should be M5

my $expiration_epoch = get_expiration_epoch("ST", "X5");
#expiration_epoch should be 2015-11-27 23:59:59 GMT
```

