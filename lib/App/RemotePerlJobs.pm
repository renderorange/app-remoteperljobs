package App::RemotePerlJobs;
  
use strictures version => 2;

use App::RemotePerlJobs::Feed ();
use App::RemotePerlJobs::DB   ();
use Try::Tiny                 ();
use App::Toot                 ();

our $VERSION = '0.001';

sub new {
    my $class = shift;
    my $self  = {};

    return bless $self, $class;
}

sub fetch {
    my $self = shift;

    my $dbh = App::RemotePerlJobs::DB->connect_db();

    my $feeds = App::RemotePerlJobs::Feed->get_all();
    foreach my $feed ( @$feeds ) {
        my $feed_title = $feed->{feed}->title;
        my $feed_link  = $feed->{feed}->link;
        my $feed_id    = $feed->{id};

        foreach my $item ( reverse $feed->{feed}->items ) {
            my $title           = $item->title;
            my $link            = $item->link;
            my $posted_on_epoch = $item->issued->epoch;

            my $select_job_sql = 'select count(*) from jobs where link = ? and posted_on = ?';
            my ( $count ) = $dbh->selectrow_array( $select_job_sql, undef, $link, $posted_on_epoch );

            if ( !$count ) {
                my $insert_job_sql = 'insert into jobs ( title, link, posted_on, feeds_id ) values ( ?, ?, ?, ? )';
                Try::Tiny::try {
                    $dbh->do( $insert_job_sql, undef, $title, $link, $posted_on_epoch, $feed_id );
                }
                Try::Tiny::catch {
                    die "insert failed: $_";
                };
            }
        }
    }

    return;
}

sub post {
    my $self = shift;

    my $dbh = App::RemotePerlJobs::DB->connect_db();

    my $select_posts_sql = 'select id, title, link, posted_on from jobs where reposted = 0';
    my $jobs = $dbh->selectall_arrayref( $select_posts_sql, { Slice => {} } );

    require Time::Piece;

    foreach my $job ( @$jobs ) {
        my $title = $job->{'title'};
        my $link  = $job->{'link'};
        my $posted_on = $job->{'posted_on'};

        my $time_piece = Time::Piece->strptime( $posted_on, '%s' );
        my $posted_ymd = $time_piece->ymd;

        my $status = "$title\n" .
                     "Posted on $posted_ymd\n" .
                     "$link\n" .
                     "#Perl\n";

        my $app_toot = App::Toot->new({ config => 'remoteperljobs', status => $status });
        my $ret = $app_toot->run();
        if ( !$ret->id ) {
            die 'post failed';
        }

        my $update_post_sql = 'update jobs set reposted = 1 where id = ?';
        Try::Tiny::try {
            $dbh->do( $update_post_sql, undef, $job->{'id'} );
        }
        Try::Tiny::catch {
            die "update failed: $_";
        };
    }

    return;
}

sub run {
    my $self = shift;

    $self->fetch();
    $self->post();

    return;
}

1;

=pod

=head1 NAME

App::RemotePerlJobs - get job feeds and post to mastodon

=head1 SYNOPSIS

 use App::RemotePerlJobs ();
 my $app = App::RemotePerlJobs->new();

=head1 DESCRIPTION

C<App::RemotePerlJobs> is an application to fetch remote perl job feeds and post them to mastodon.

=head1 SUBROUTINES/METHODS

=head2 new

Constructor for the object.

=head2 fetch

Fetch the jobs from the configured feeds.

=head2 post

Post the jobs to the configured mastodon account.

=head2 run

Run both fetch and post methods.

=head1 COPYRIGHT AND LICENSE

C<App::RemotePerlJobs> is Copyright (c) 2022 Blaine Motsinger under the MIT license.

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
