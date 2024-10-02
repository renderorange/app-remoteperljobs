use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../lib", "$FindBin::RealBin/../../lib";
use App::RemotePerlJobs::Test;

App::RemotePerlJobs::Test::load_sql_files([
    "$FindBin::RealBin/../db/data/add_jobs_testlocal.sql",
]);

App::RemotePerlJobs::Test::override(
    package => 'App::Toot',
    name => 'new',
    subref => sub {
        my $class = shift;
        my $arg   = shift;

        return bless {}, $class;
    },
);

App::RemotePerlJobs::Test::override(
    package => 'App::Toot',
    name => 'run',
    subref => sub {
        my $self = shift;
        return $self;
    },
);

App::RemotePerlJobs::Test::override(
    package => 'App::Toot',
    name => 'id',
    subref => sub {
        return 1;
    },
);

use_ok('App::RemotePerlJobs');

my $app = App::RemotePerlJobs->new();
$app->post();

my $jobs_expected = [
    {
        id => 1,
        title => 'Test Entry One',
        link => 'https://test.test.local/one',
        posted_on => 1725192060,
        feeds_id => 1,
        reposted => 1,
    },
    {
        id => 2,
        title => 'Test Entry Two',
        link => 'https://test.test.local/two',
        posted_on => 1725278460,
        feeds_id => 1,
        reposted => 1,
    },
];

my $jobs = $App::RemotePerlJobs::Test::dbh->selectall_arrayref( 'select * from jobs', { Slice => {} } );

cmp_deeply( $jobs, $jobs_expected, 'fetched jobs entries match expected' );

done_testing();
