package App::RemotePerlJobs;
  
use strictures version => 2;

use App::RemotePerlJobs::Feed ();
use App::RemotePerlJobs::DB   ();

our $VERSION = '0.001';

sub new {
    my $class = shift;
    my $self  = {};

    return bless $self, $class;
}

sub run {
    my $self = shift;

    my $feed = App::RemotePerlJobs::Feed::get();
    my $dbh  = App::RemotePerlJobs::DB::connect_db();

    foreach my $item ( $feed->items ) {
        my $title     = $item->title;
        my $link      = $item->link;
        $link         =~ /.+\/(\d+)$/;
        my $job_id    = $1;
        my $posted_on_epoch = $item->issued->epoch;
        my $posted_on_ymd   = $item->issued->ymd;
    }
}

1;

=pod

=head1 NAME

App::RemotePerlJobs - get feed and post to mastodon

=head1 SYNOPSIS

 use App::RemotePerlJobs ();
 my $app = App::RemotePerlJobs->new();

=head1 DESCRIPTION

C<App::RemotePerlJob> is an application to get the telecommute feed from jobs.perl.org and post it to mastodon.

=head1 SUBROUTINES/METHODS

=head2 new

Constructor for the object.

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
