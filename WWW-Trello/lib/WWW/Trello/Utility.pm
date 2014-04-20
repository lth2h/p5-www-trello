package WWW::Trello::Utility;

use 5.006;
use strict;
use warnings FATAL => 'all';

use LWP::UserAgent;
use HTTP::Request::Common;

=head1 NAME

WWW::Trello::Utility - Utility methods for arbitrary api functionality

=cut

sub _doRestCall {
        my ($api, $method, $url, $args) = @_;
        $method = uc($method);
        $args ||= {};
        if ($api->{useragent_options} && ref($api->{useragent_options}) eq 'HASH') {
                $api->{ua} ||= LWP::UserAgent->new(%{$api->{useragent_options}});
        }
        else {
                $api->{ua} ||= LWP::UserAgent->new();
        }
        $url .= '?key=' . $api->{appkey} . '&token=' . $api->{token};
        my ($request, @params) = _generateRequest($api, $method, $url, $args);
        return $api->{ua}->request($request, @params);
}

sub _generateRequest {
        my ($api, $method, $url, $args) = @_;
        my $ua = $api->{ua};
        my @parameters = ($url, (), %{$args});
        my $parameterOffset;
        if ($method eq 'PUT'||$method eq 'POST') {
                $parameterOffset = ref($parameters[1])? 2 : 1;
        }
        else {
                $parameterOffset = 1;
        }

        my @stuff = $ua->_process_colonic_headers(\@parameters, 0);
        {
                no strict qw(refs);
                my $request = &{"HTTP::Request::Common::${method}"}(@parameters);
                return ($request, @stuff);
        }

}

1;
