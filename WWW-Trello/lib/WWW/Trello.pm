package WWW::Trello;

use 5.006;
use strict;
use warnings;

use Want;

use WWW::Trello::Board;
use WWW::Trello::Error;
use WWW::Trello::Utility;

our %SetupArgs;
our %ObjectMap;
our %SubClasses = (
	boards => 'WWW::Trello::Board',
);

=head1 NAME

WWW::Trello - A perl interface to the API for www.trello.com

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

=head1 SUBROUTINES/METHODS

=head2 new()

Create a new WWW::Trello object.

=cut

sub new {
	my $class = shift;
	my $params = ref($_[0]) ? $_[0] : {@_};
	my %defaults = (
		base   => 1,
		host   => 'api.trello.com',
		mode   => 'get',
		scheme => 'https',
	);

	map {
		$SetupArgs{$_} = $params->{$_}
	} grep {
		defined($params->{$_})
	} qw(base host mode port scheme appkey token);

	while (my ($key, $val) = each %defaults) {
		$SetupArgs{$key} ||= $val;
	}

	unless ($SetupArgs{appkey} && $SetupArgs{token}) {
		WWW::Trello::Error->throw(message  => 'appkey and token must be provided.')->icantdothatdave;
	}

	my $self = \%SetupArgs;
	bless $self, $class;
	$ObjectMap{$self} = {};

	return $self;
}

=head2 AUTOLOAD()

Builds data to make objects and api calls

=cut

sub AUTOLOAD {
	my $self = shift;

	our $AUTOLOAD;
	my ($key) = $AUTOLOAD =~ /.*::([\w_]+)/o;
	return if ($key eq 'DESTROY');

	push @{$self->{__chain}}, $key;

	my $args = ref($_[0]) ? $_[0] : {@_};
	$self->{"__$key"} = $args if (@{$self->{__chain}} == 1);
	if (want('OBJECT') || want('VOID')) {
		return $self;
	}

	my @chain = @{delete($self->{__chain})};

	my $type = shift(@chain);
	unless (grep {$_ eq $type} keys(%SubClasses)) {
		WWW::Trello::Error->throw(message => "$type is not a valid Trello API object.")->icantdothatdave;
	}

	$args->{__chain} = \@chain if @chain;
	my $id = delete($self->{"__$type"})->{id};
	unless ($id) {
		WWW::Trello::Error->throw(message  => "$type requires an id.")->icantdothatdave;
	}

	$self->_addRelatedObject($type, {id => $id});
	my $object = $self->{__lastObject} = $ObjectMap{$self}{$type}{$id};
	my $response = $object->_call($args);

	return $response;
}

=head2 last()

Returns the last object that was used

=cut

sub last {
	return shift->{__lastObject};
}

=head2 _addRelatedObject()

Stores objects under the topical object

=cut

sub _addRelatedObject {
	my $self = shift;
	my $type = shift;
	my $args = shift;
	my $buildArgs = {%SetupArgs, %{$args}};
	my $object = $SubClasses{$type}->new($buildArgs);
	$ObjectMap{$self}{$type}{$args->{id}} = $object;
	return $self;
}

=head1 AUTHOR

Shane Utt, C<< <shaneutt at linux.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-WWW-Trello at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Trello>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Trello

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Trello>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Trello>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Trello>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Trello/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2014 Shane Utt, All Rights Reserved.

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

1;
