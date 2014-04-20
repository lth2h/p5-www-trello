package WWW::Trello::Board;

use 5.006;
use strict;

use URI;
use JSON;

use WWW::Trello::Error;
use WWW::Trello::Utility;

our %ObjectMap;

=head1 NAME

WWW::Trello::Board - Board objects for WWW::Trello

=head1 SUBROUTINES/METHODS

=head2 Public Methods

=head3 new()

Create a new WWW::Trello::Board object

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

	my $self;
	map {
		$self->{$_} = $params->{$_}
	} grep {
		defined($params->{$_})
	} qw(base host mode port scheme appkey token);

	if (!$self->{appkey} or !$self->{token}) {
		WWW::Trello::Error->throw(message  => 'appkey and token must be provided.')->icantdothatdave;
	}
	my @modes = qw(delete get head post put);
	if (! grep (/$self->{mode}/i, @modes)) {
		WWW::Trello::Error->throw(
			message => 'mode must be one of the following: ' . join(', ', @modes) . '. You supplied: ' . $self->{mode},
		)->icantdothatdave;
	}
	my @schemes = qw(http https);
	if (! grep (/$self->{scheme}/i, @schemes)) {
		WWW::Trello::Error->throw(
			message  => 'scheme must be one of the following: ' . join(', ', @schemes) . '. You supplied: ' . $self->{scheme},
		)->icantdothatdave;
	}

	while (my ($key, $val) = each %defaults) {
		$self->{$key} ||= $val;
	}

	$self->{uri} = URI->new;
	$self->{uri}->scheme($self->{scheme});
	$self->{uri}->host($self->{host});
	$self->{uri}->port($self->{port}) if exists $self->{port};
	return bless $self, $class;
}

=head3 actions

Provides board actions: https://trello.com/docs/api/board/index.html#get-1-boards-board-id-actions

=cut

sub actions {
	return 'FIXME';
}

=head2 Private Methods

=head3 AUTOLOAD()

Catch unexpected method calls and be informative

=cut

sub AUTOLOAD {
	my $self = shift;
	our $AUTOLOAD;
	my ($key) = $AUTOLOAD =~ /.*::([\w_]+)/o;
	return if ($key eq 'DESTROY');
	WWW::Trello::Error->throw(message => "$key is not a valid method for " . ref($self))->icantdothatdave;
}

=head3 _call()

This method will make an eventual API call to trello's api,
and then will return expected objects.

=cut

sub _call {
	my $self = shift;
	my $args = ref($_[0]) ? $_[0] : {@_};
	my $method = delete($args->{__chain});

	if ($method && (my $call = shift(@{$method}))) {
		return $self->$call($args);
	}

	my $url;
	$url .= "/$self->{base}" if $self->{base};
	$url .= '/boards';

	my $id = delete $args->{id};
	$url .= "/$id";
	$self->{uri}->path($url);
	return $self->_httpCheck(WWW::Trello::Utility::_doRestCall($self, $self->{mode}, $self->{uri}, $args));
}

=head3 _httpCheck()

Tries the API call given via an HTTP::Request::Common,
and attempts to "do the right thing".

=cut

sub _httpCheck {
	my $self = shift;
	my $http = shift;
	if ($http->{_rc} != 200) {
		return WWW::Trello::Error->throw(
			category => 'http',
			message  => "$http->{_msg}: $http->{_content}",
			type     => $http->{rc},
		);
	} else {
		return decode_json($http->{_content}) || WWW::Trello::Error->throw(
			message  => "could not decode json response: $@",
		);
	}
}

1;