package App::RemotePerlJobs::Feed;

use strictures version => 2;

use URI;
use XML::Feed;

our $VERSION = '0.001';

sub get {
    my $rss = URI->new( 'https://jobs.perl.org/rss/telecommute.rss' );

    my $feed = XML::Feed->parse( $rss )
        or die "get telecommute.rss failed: " . XML::Feed->errstr;

    return $feed;
}

1;

=pod

=head1 NAME

App::RemotePerlJobs::Feed - methods for interacting with the perljobs feed

=head1 SYNOPSIS

 use App::RemotePerlJobs::Feed ();
 my $feed = App::RemotePerlJobs::Feed::get();

=head1 DESCRIPTION

This module provides methods for other modules to interact with the perljobs feed.

=head1 SUBROUTINES/METHODS

=head2 get

Constructor for the object.

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
