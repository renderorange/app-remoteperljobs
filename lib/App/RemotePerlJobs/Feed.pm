package App::RemotePerlJobs::Feed;

use strictures version => 2;

use App::RemotePerlJobs::DB ();
use URI;
use XML::Feed;

our $VERSION = '0.002';

sub get_all {
    my $class = shift;

    my $dbh = App::RemotePerlJobs::DB->connect_db();
    my $select_sources_sql = 'select id, title, rss from feeds';
    my $sources = $dbh->selectall_arrayref( $select_sources_sql, { Slice => {} } );

    my $feeds = [];
    foreach my $source ( @$sources ) {
        $source->{feed} = $class->get( $source );
    }

    return $sources;
}

sub get {
    my $class  = shift;
    my $source = shift;

    if ( !$source ) {
        die 'source is required';
    }

    my $rss = URI->new( $source->{'rss'} );

    my $feed = XML::Feed->parse( $rss )
        or die "get '$source->{'title'}' feed failed: " . XML::Feed->errstr;

    return $feed;
}

1;

=pod

=head1 NAME

App::RemotePerlJobs::Feed - methods for interacting with the perljobs feed

=head1 SYNOPSIS

 use App::RemotePerlJobs::Feed ();
 my $feeds = App::RemotePerlJobs::Feed->get_all();
 my $feed  = App::RemotePerlJobs::Feed->get( $url );

=head1 DESCRIPTION

This module provides methods for other modules to interact with the perljobs feed.

=head1 SUBROUTINES/METHODS

=head2 get_all

=head2 get

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
