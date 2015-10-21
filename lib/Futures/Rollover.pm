package Futures::Rollover;

use 5.006;
use strict;
use warnings;
use Carp;
use base qw( Exporter );
our @EXPORT_OK = qw ( get_feed_index_for_generic_future );

use Date::Utility;

=head1 NAME

Futures::Rollover - Helper methods for Future feed switching and generation

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Feed listeners can use this module to decide whether the current or front feed needs to be
stored as the generic Future feed.

=head1 EXPORT

get_feed_index_for_generic_future

=head1 SUBROUTINES/METHODS

=head2 get_feed_index_for_generic_future

This method returns index of the Future feed that can go to the generic Future feed according to roll-over rules.
A Generic Future feed is a combination of two Future feeds, which are called current and front. Current Future feed
is the currently active Future contract that will expire first. The Front Future is the next expiring Future contract.
The rule is that, Generic Future will contains all data from "Current Future" unless on the day of expiry. On that
specific day we will switch to "Front". After the day of expiry (upon which, the Current Future will be expired), 
Front Future will be published under the Current Future name and a new contract will be created and published as
Front Future, this switching is called Roll-over.

Input: $tick_tpoch (current time), $current_feed_expiry_day (expiry date of the current Future feed in the format of yyyymmdd)
Output: 1 (if the current feed should be used in generic Future feed creation), 2 (if front feed should be used for generic feed), 0 (wrong input or unknown situation)

=cut

sub get_feed_index_for_generic_future {
    my ($tick_epoch, $current_feed_expiry_day) = @_;

    #all inputs are required
    return unless defined $tick_epoch and defined $current_feed_expiry_day;

    my ($day, $month, $year) = (localtime($tick_epoch))[3, 4, 5];
    $year += 1900;
    $month++;

    my $tick_day = $year . sprintf("%02d", $month) . sprintf("%02d", $day);

    return 2 if $tick_day == $current_feed_expiry_day;
    return 1 if $tick_day < $current_feed_expiry_day;

    #unknown situation - return nothing
    return;
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
