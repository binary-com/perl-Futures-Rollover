package Futures::Rollover;

use 5.006;
use strict;
use warnings;
use Carp;
use base qw( Exporter );
our @EXPORT_OK = qw ( is_tick_fit_for_generic_feed );

use Date::Utility;

=head1 NAME

Futures::Rollover - Helper methods for future feed switching and generation

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Feed listeners can use this module to decide whether the present tick 
can be stored as a generic future feed or no.

=head1 EXPORT

is_tick_fit_for_generic_feed 

=head1 SUBROUTINES/METHODS

=head2 is_tick_fit_for_generic_feed

This methods returns 1 if the given tick's information are good to be stored
for generic future, 0 otherwise.

=cut

sub is_tick_fit_for_generic_feed {
    my ($symbol, $tick_epoch, $current_feed_expiry_date) = @_;

    #all inputs are required
    return 0 unless defined $symbol and defined $tick_epoch and defined $current_feed_expiry_date;

    my $tick_date = Date::Utility->new($tick_epoch);
    my $tick_day = sprintf("%02d", $tick_date->month) . sprintf("%02d", $tick_date->day_of_month) . $tick_date->year;

    #if the tick is for _1 (1! or current future feed) and we are NOT
    #at the day of expiry, then it can be stored for generic future feed
    if ($symbol =~ /_1$/ && $tick_day ne $current_feed_expiry_date) {
        return 1;
    } elsif ($symbol =~ /_2$/ && $tick_day eq $current_feed_expiry_date) {
        #if tick is for _2 feed and we are at the day of expiry of
        #corresponding _1 future feed, then use this one as generic future
        # (as in this single day, the _1 feed does not have good quality)
        return 1;
    }

    #return 0 if this tick is not good for generic future feed
    return 0;
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

1;    # End of Futures::Rollover
