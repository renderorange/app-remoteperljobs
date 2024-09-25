use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../lib", "$FindBin::RealBin/../../lib";
use App::RemotePerlJobs::Test;

App::RemotePerlJobs::Test::load_sql_files([
    "$FindBin::RealBin/../db/data/add_source_testlocal.sql",
    "$FindBin::RealBin/../db/data/add_source_anotherlocal.sql",
]);

App::RemotePerlJobs::Test::override(
    package => 'App::RemotePerlJobs::Feed',
    name => 'get',
    subref => sub {
        my $class = shift;
        my $source = shift;

        my $feeds = {
            'https://test.test.local/rss/test.rss' => {
                feed => {
                    title => 'test.test.local',
                    link => 'https://test.test.local/',
                    description => 'The Test Job Feed',
                    language => 'en-us',
                    author => 'test@testerton.com',
                    copyright => 'Copyright 2024 Test Testerton',
                    date => '2024-09-01T12:00:00+00:00',
                },
                entries => [
                    {
                        link => 'https://test.test.local/one',
                        title => 'Test Entry One',
                        summary => 'Test Summary One',
                        content => 'More olives on the pizza! One',
                        author => 'test@testerton.com (Test Testerton)',
                        date => '2024-09-01T12:01:00+00:00',
                    },
                    {
                        link => 'https://test.test.local/two',
                        title => 'Test Entry Two',
                        summary => 'Test Summary Two',
                        content => 'More olives on the pizza! Two',
                        author => 'test@testerton.com (Test Testerton)',
                        date => '2024-09-02T12:01:00+00:00',
                    },
                ],
            },
            'https://another.test.local/rss/test.rss' => {
                feed => {
                    title => 'another.test.local',
                    link => 'https://another.test.local/',
                    description => 'Another Test Job Feed',
                    language => 'en-us',
                    author => 'test@testerton.com',
                    copyright => 'Copyright 2024 Test Testerton',
                    date => '2024-09-23T12:00:00+00:00',
                },
                entries => [
                    {
                        link => 'https://another.test.local/one',
                        title => 'Another Entry One',
                        summary => 'Another Summary One',
                        content => 'Even more olives on the pizza! One',
                        author => 'test@testerton.com (Test Testerton)',
                        date => '2024-09-23T12:01:00+00:00',
                    },
                    {
                        link => 'https://another.test.local/two',
                        title => 'Another Entry Two',
                        summary => 'Another Summary Two',
                        content => 'Even more olives on the pizza! Two',
                        author => 'test@testerton.com (Test Testerton)',
                        date => '2024-09-24T12:01:00+00:00',
                    },
                ],
            },
        };

        return App::RemotePerlJobs::Test::create_feed($feeds->{$source->{rss}});
    },
);

use_ok('App::RemotePerlJobs');

my $app = App::RemotePerlJobs->new();
$app->fetch();

my $jobs_expected = [
    {
        id => 1,
        title => 'Test Entry Two',
        link => 'https://test.test.local/two',
        posted_on => 1725278460,
        feeds_id => 1,
        reposted => 0,
    },
    {
        id => 2,
        title => 'Test Entry One',
        link => 'https://test.test.local/one',
        posted_on => 1725192060,
        feeds_id => 1,
        reposted => 0,
    },
    {
        id => 3,
        title => 'Another Entry Two',
        link => 'https://another.test.local/two',
        posted_on => 1727179260,
        feeds_id => 2,
        reposted => 0,
    },
    {
        id => 4,
        title => 'Another Entry One',
        link => 'https://another.test.local/one',
        posted_on => 1727092860,
        feeds_id => 2,
        reposted => 0,
    },
];

my $jobs = $App::RemotePerlJobs::Test::dbh->selectall_arrayref( 'select * from jobs', { Slice => {} } );

cmp_deeply( $jobs, $jobs_expected, 'fetched jobs entries match expected' );

done_testing();
