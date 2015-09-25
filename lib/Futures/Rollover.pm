package Futures::Rollover;

use 5.006;
use strict;
use warnings;
use Carp;
use base qw( Exporter );
our @EXPORT_OK = qw ( get_expiration_epoch get_previous_contract_code);


use Date::Utility;

=head1 NAME

Futures::Rollover - The great new Futures::Rollover!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Futures::Rollover;

    my $foo = Futures::Rollover->new();
    ...

=head1 EXPORT

get_expiration_epoch

=head1 SUBROUTINES/METHODS

=head2 get_expiration_epoch

This method calculates the epoch for expiration of a given future contract.
Inputs are symbol and month_y. symbol is the name of the future contract instrument (e.g. Z means FTSE)
month_y is month code and one digit year ( e.g. U5 means September 2015)

=cut

#this is the notation that eSignal uses for denoting expiration month of a future contract
my %month_letters = (
    'F' => 1,
    'G' => 2,
    'H' => 3,
    'J' => 4,
    'K' => 5,
    'M' => 6,
    'N' => 7,
    'Q' => 8,
    'U' => 9,
    'V' => 10,
    'X' => 11,
    'Z' => 12,
);

my %r_month_letters = reverse %month_letters;

sub get_previous_contract_code {
    my ($symbol, $month_y) = @_;

    #for example if we are given "SP H5" where SP is symbol and H5 is month-year we will return Z4
    my ($month, $year) = $month_y =~ /^(.)(\d{1,2})$/ or croak "Invalid month/year format";
    my $month_number = $month_letters{$month} or croak "Invalid month letter";

    #FTSE and DJI futures are renewed each 3 months
    if ($symbol eq 'Z' || $symbol eq 'YM') {
        $month_number -= 3;
    } else {
        $month_number -= 1;
    }

    if ($month_number < 1) {
        $month_number += 12;
        $year--;
    }

    return $r_month_letters{$month_number} . $year;
}

#sub get_nth_day_of_week {
#    my ($year, $month, $nth, $dow) = @_;
#    use Time::Local qw/timegm/;
#
#    $dow %= 7;     # accept both 0 and 7 as Sunday
#    my $time = timegm(0, 0, 0, 1, $month - 1, $year - 1900);
#    my $_dow = (gmtime $time)[6];    # 0 - Sun .. 6 - Sat
#    my $days_add = ($dow + 7 - $_dow) % 7 + ($nth - 1) * 7;
#
#    my $result = Date::Utility->new($time + 24 * 3600 * $days_add);
#
#    return unless $result->month == $month;
#    return $result;
#
#    #
#    #
#    #                        return if $nth == 0 or $dow == 0;
#    #                        
#    #    my $dt = Date::Utility->new($year . "-" . $month . "-1");
#    #
#    #    my $count_seen = 0;
#    #    for (my $i = 0; $i <= 31; $i++) {
#    #        $count_seen++ if $dt->day_of_week == $dow and $dt->month == $month;
#    #        last if $count_seen == $nth;
#    #
#    #        $dt = $dt->plus_time_interval('1d');
#    #    }
#    #
#    #    #return empty result if not enough day-of-weeks exist in the given month
#    #    return if $count_seen < $nth;
#    #    return $dt;
#}

sub get_expiration_epoch {
    my ($symbol, $month_y, $exchange_holidays) = @_;

    #according to eSignal KB year is one digit for dates < 2018 and 18,19,20, ... for afterwards
    my ($month, $year) = $month_y =~ /^(.)(\d{1,2})$/ or croak "Invalid month/year code";
    my $month_number = $month_letters{$month};
    my $dt;

    $year += 10 if $year < 18; 
    $year = 2000 + $year;

    #STI and HSI: The day before the last trading day day
    if ($symbol eq 'HSI' || $symbol eq 'ST') {
        $month_number++;

        if ( $month_number == 13 ) {
            $dt = Date::Utility->new(($year+1) . "-1-1");
        } else {
            $dt = Date::Utility->new($year . "-" . $month_number . "-1");
        }

        $dt = $dt->minus_time_interval("1d");
        
        #find the last trading day of this month
        while (exists $exchange_holidays->{$dt->epoch} || $dt->day_of_week == 6 || $dt->day_of_week == 0) {
            $dt = $dt->minus_time_interval("1d");
        }
        $dt = $dt->minus_time_interval("1d");
    } elsif ($symbol eq 'BSX') {    #for BSESENSEX30 it is last Thu of the month
        $dt = Date::Utility->new($year . "-" . $month_number . "-1");

        $dt = $dt->get_nth_day_of_week(5, 'Thu') // $dt->get_nth_day_of_week(4, 'Thu');
    } else {
        my $target_count = 0;       #nth occurence
        my $target_dow   = 0;       #nth day of week

        #dow counting for Date::Utility: sunday is 0
        ($target_count, $target_dow) = (3, 'Fri') if $symbol eq 'AEX';    #AEX: 3rd Fri
        ($target_count, $target_dow) = (3, 'Thu') if $symbol eq 'APS';    #AS51: 3rd Thu
        ($target_count, $target_dow) = (3, 'Fri') if $symbol eq 'BXF';    #BFX: 3rd Fri
        ($target_count, $target_dow) = (3, 'Fri') if $symbol eq 'YM';     #DJI: 3rd Fri
        ($target_count, $target_dow) = (3, 'Fri') if $symbol eq 'FCE';    #FCHI: 3rd Fri
        ($target_count, $target_dow) = (3, 'Fri') if $symbol eq 'Z';      #FTSE: 3rd Fri

        croak "Invalid symbol" if $target_count == 0;
        $dt = Date::Utility->new($year . "-" . $month_number . "-1");
        $dt = $dt->get_nth_day_of_week($target_count, $target_dow);
    }

    return if not defined $dt;

    #bypass Sat/Sun/Holidays
    while (exists $exchange_holidays->{$dt->epoch} || $dt->day_of_week == 6 || $dt->day_of_week == 0) {
        $dt = $dt->minus_time_interval("1d");
    }

    #now dt has the expiration date - just return last moment of that day as expiration date
    return $dt->plus_time_interval("1d")->epoch - 1;
}

=head1 AUTHOR

Binary.com , C<< <support at binary.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-futures-rollover at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Futures-Rollover>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Futures::Rollover


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Futures-Rollover>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Futures-Rollover>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Futures-Rollover>

=item * Search CPAN

L<http://search.cpan.org/dist/Futures-Rollover/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2015 Binary.com

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Futures::Rollover
