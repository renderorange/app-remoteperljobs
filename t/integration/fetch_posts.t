use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../lib", "$FindBin::RealBin/../../lib";
use App::RemotePerlJobs::Test;

App::RemotePerlJobs::Test::load_sql_files( [ "$FindBin::RealBin/../db/data/add_source_testlocal.sql" ] );

App::RemotePerlJobs::Test::override(
    package => 'App::RemotePerlJobs::Feed',
    name => 'get',
    subref => sub {
        my $class = shift;
        my $source = shift;

        return App::RemotePerlJobs::Test::create_feed(
            feed => {
                title => 'test.test.local',
                link => 'https://test.test.local/',
                description => 'The Test Job Site',
                language => 'en-us',
                author => 'test@testerton.com',
                copyright => 'Copyright 2024 Test Testerton',
                date => '2024-09-01T12:10:10+00:00',
            },
            entries => [
                {
                    link => 'https://test.test.local/one',
                    title => 'Test Entry One',
                    summary => 'Test Summary One',
                    content => 'More olives on the pizza! One',
                    author => 'test@testerton.com (Test Testerton)',
                    date => '2024-09-01T12:10:20+00:00',
                },
            ],
        );
    },
);

use_ok('App::RemotePerlJobs');

my $app = App::RemotePerlJobs->new();
$app->fetch();

my $jobs_expected = [
    {
        id => 1,
        title => 'Test Entry One',
        link => 'https://test.test.local/one',
        posted_on => 1725192620,
        feeds_id => 1,
        reposted => 0,
    },
];

my $jobs = $App::RemotePerlJobs::Test::dbh->selectall_arrayref( 'select * from jobs', { Slice => {} } );

cmp_deeply( $jobs, $jobs_expected, 'fetched jobs entries match expected' );

done_testing();

__END__

TODO:
this is mocking too much.  if we want to mock at Feed::get, it should have logic to get a specific response based on the inserted source from the database.
update this to add two feeds and return different entries for each feed.
this is doing an okay job of making sure we're parsing and storing the data from the feed, though, but could be better.
also, expand this to parse and store multiple entries within a single feed.
