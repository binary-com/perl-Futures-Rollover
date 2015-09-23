
use 5.006;
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Futures::Rollover qw(get_expiration_epoch get_previous_contract_code);
use Date::Utility;

plan tests => 18;

is get_previous_contract_code("Z", "U5"), "M5", "Previous contract code for Z-U5 calculated correctly";
is get_previous_contract_code("BSX", "Q5"), "N5", "Previous contract code for BSX-U5 calculated correctly";
is get_previous_contract_code("YM", "H6"), "Z5", "Previous contract code for YM-U5 calculated correctly";
is get_previous_contract_code("YM", "Z5"), "U5", "Previous contract code for YM-U5 calculated correctly";

dies_ok { get_previous_contract_code("YM", "A5") } "Correctly failing for invalid month name";
dies_ok { get_previous_contract_code("YM", "ZZ") } "Correctly failing for invalid year";

is (Date::Utility->new(get_expiration_epoch("Z", "U5", {}))->datetime, "2015-09-18 23:59:59", "Expiration calculated correctly for Z");
is (Date::Utility->new(get_expiration_epoch("AEX", "Z5", {}))->datetime, "2015-12-18 23:59:59", "Expiration calculated correctly for AEX");
is (Date::Utility->new(get_expiration_epoch("APS", "X5", {}))->datetime, "2015-11-19 23:59:59", "Expiration calculated correctly for APS");
is (Date::Utility->new(get_expiration_epoch("BXF", "V5", {}))->datetime, "2015-10-16 23:59:59", "Expiration calculated correctly for BXF");
is (Date::Utility->new(get_expiration_epoch("YM", "H6", {}))->datetime, "2016-03-18 23:59:59", "Expiration calculated correctly for YM");
is (Date::Utility->new(get_expiration_epoch("FCE", "Q5", {}))->datetime, "2015-08-21 23:59:59", "Expiration calculated correctly for FCE");
is (Date::Utility->new(get_expiration_epoch("HSI", "Z5", {}))->datetime, "2015-12-30 23:59:59", "Expiration calculated correctly for HSI");
is (Date::Utility->new(get_expiration_epoch("ST", "X5", {}))->datetime, "2015-11-27 23:59:59", "Expiration calculated correctly for ST");
is (Date::Utility->new(get_expiration_epoch("BSX", "Q5", {}))->datetime, "2015-08-27 23:59:59", "Expiration calculated correctly for BSX");
is (Date::Utility->new(get_expiration_epoch("BSX", "Q5", {Date::Utility->new('2015-08-27')->epoch => 1}))->datetime, "2015-08-26 23:59:59", "Expiration calculated correctly for BSX when normal expiration date is a holiday");

dies_ok { get_expiration_epoch("YM", "ZZ", {}) } "Correctly failing for invalid expiration";
dies_ok { get_expiration_epoch("", "Q5") } "Correctly failing for invalid symbol name";

1;



