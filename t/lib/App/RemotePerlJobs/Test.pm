package App::RemotePerlJobs::Test;

use strict;
use warnings;

use FindBin;
use File::Temp;
use File::Path ();
use Try::Tiny  ();
use Cwd        ();
use Carp       ();

use parent 'Test::More';

our $VERSION = '0.005';

our ( $tempdir, $dbh );

my $cleanup = 1;

my $module_path = Cwd::realpath(__FILE__);
$module_path =~ s/\/\w+\.pm//;

sub import {
    my $class = shift;
    my %args  = @_;

    if ( $args{tests} ) {
        if ( $args{tests} ne 'no_declare' ) {
            $class->builder->plan( tests => $args{tests} );
        }
    }
    elsif ( $args{skip_all} ) {
        $class->builder->plan( skip_all => $args{skip_all} );
    }

    if ( $args{skip_cleanup} ) {
        $cleanup = 0;
    }

    $tempdir = File::Temp->newdir(
        DIR     => $FindBin::RealBin,
        CLEANUP => 0,
    );

    if ( !$args{skip_db} ) {
        init_db();
    }

    Test::More->export_to_level(1);

    require Test::Exception;
    Test::Exception->export_to_level(1);

    require Test::Deep;
    Test::Deep->export_to_level(1);

    require Test::Warnings;

    return;
}

sub override {
    my %args = (
        package => undef,
        name    => undef,
        subref  => undef,
        @_,
    );

    eval "require $args{package}";

    my $fullname = sprintf "%s::%s", $args{package}, $args{name};

    no strict 'refs';
    no warnings 'redefine', 'prototype';
    *$fullname = $args{subref};

    return;
}

sub init_db {
    my $db_path = $tempdir . '/test.sqlite3';
    open( my $db_fh, '>', $db_path )
        or Carp::confess "open $db_path: $!";
    close($db_fh);

    Test::More::note("created test db - $db_path");

    override(
        package => 'App::RemotePerlJobs::DB',
        name    => 'load',
        subref  => sub {
            return "dbi:SQLite:dbname=$db_path";
        },
    );

    require App::RemotePerlJobs::DB;
    $dbh = App::RemotePerlJobs::DB->connect_db();

    my $schema_dir = "$module_path/../../../../db/schema";
    opendir( my $schema_dh, $schema_dir )
        or Carp::confess "opendir $schema_dir: $!";

    my @schema_files =
        map  {"$schema_dir/$_"}
        sort { $a cmp $b }
        grep { !/^\./ && -f "$schema_dir/$_" } readdir $schema_dh;

    closedir $schema_dh;

    load_sql_files( \@schema_files );

    return;
}

sub load_sql_files {
    my $files = shift;

    my @queries;
    foreach my $file ( @{$files} ) {
        Test::More::note("loading $file");

        open( my $schema_fh, '<', $file )
            or Carp::confess "open $file: $!";

        # each file might contain multiple queries, but should always end each
        # query with a semicolon.
        my $query;
        foreach my $line (<$schema_fh>) {
            $query .= $line;

            if ( $line =~ /;$/ ) {
                push @queries, $query;
                $query = undef;
            }
        }

        close($schema_fh);
    }

    foreach my $query (@queries) {
        my $result = Try::Tiny::try {
            return $dbh->do($query);
        }
        Try::Tiny::catch {
            Carp::confess "insert query failed: $_";
        };
    }
}

sub _verify_date {
    my $date = shift;

    if ( $date =~ /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2}/ ) {
        return 1;
    }
    else {
        return ( undef, "date ($date) must match YYYY-MM-DDThh:mm:ss+00:00" );
    }
}

sub create_feed {
    my $arg = shift;

    require XML::RSS;
    require XML::Feed;

    foreach my $required (qw{feed entries}) {
        if ( !defined $arg->{$required} ) {
            Carp::confess "arg $required is required";
        }
    }

    if ( ref $arg->{feed} ne 'HASH' ) {
        Carp::confess 'arg feed must be a hashref';
    }

    foreach my $required (qw{title link description language author copyright date}) {
        if ( !$arg->{feed}{$required} ) {
            Carp::confess "arg feed $required key is required";
        }
    }

    my ( $ret, $err ) = _verify_date( $arg->{feed}{date} );
    if ( !$ret ) {
        Carp::confess $err;
    }

    if ( ref $arg->{entries} ne 'ARRAY' ) {
        Carp::confess 'arg entries must be an arrayref';
    }

    foreach my $entry ( @{ $arg->{entries} } ) {
        foreach my $required (qw{link title summary content author date}) {
            if ( !$entry->{$required} ) {
                Carp::confess "arg entries $required key is required";
            }
        }

        my ( $ret, $err ) = _verify_date( $entry->{date} );
        if ( !$ret ) {
            Carp::confess $err;
        }
    }

    my $rss = XML::RSS->new( version => '1.0' );
    $rss->channel(
        title       => $arg->{feed}{title},
        link        => $arg->{feed}{link},
        description => $arg->{feed}{description},
        dc          => {
            date      => $arg->{feed}{date},
            subject   => $arg->{feed}{description},
            creator   => $arg->{feed}{author},
            publisher => $arg->{feed}{author},
            rights    => $arg->{feed}{copyright},
            language  => $arg->{feed}{language},
        },
    );

    foreach my $entry ( @{ $arg->{entries} } ) {
        $rss->add_item(
            title       => $entry->{title},
            link        => $entry->{link},
            description => $entry->{summary},
            dc          => {
                creator => $entry->{author},
                date    => $entry->{date},
            },
        );
    }

    return XML::Feed->parse( \$rss->as_string );
}

END {
    if ( $cleanup && $tempdir ) {
        if ( File::Path::rmtree($tempdir) ) {
            Test::More::note("cleaned up tempdir - $tempdir");
        }
        else {
            Test::More::diag("rmtree: $!\n");
        }
    }
}

1;

__END__

=pod

=head1 NAME

App::RemotePerlJobs::Test - test setup helper for C<App::RemotePerlJobs>.

=head1 DESCRIPTION

C<App::RemotePerlJobs::Test> is a module to make test setup easy for the C<App::RemotePerlJobs> project.

=head1 SYNOPSIS

 use FindBin;
 use lib "$FindBin::RealBin/../lib", "$FindBin::RealBin/../../lib";
 use App::RemotePerlJobs::Test;

=head1 ARGUMENTS

C<App::RemotePerlJobs::Test> accepts arguments to control initialization.

The following arguments are available:

=over

=item tests

The C<tests> argument is passed into C<Test::Builder> and defines the number of tests the test contains.

 use App::RemotePerlJobs::Test tests => 3;

=item skip_all

The C<skip_all> argument is passed into C<Test::Builder> and tells the test harness to skip the tests defined in the test.

 use App::RemotePerlJobs::Test skip_all => 1;

=item skip_cleanup

The C<skip_cleanup> argument instructs C<App::RemotePerlJobs::Test> to not cleanup the temp directory after the test is done.

 use App::RemotePerlJobs::Test skip_cleanup => 1;

=item skip_db

The C<skip_db> argument instructs C<App::RemotePerlJobs::Test> to not initialize the test database during the test setup.

 use App::RemotePerlJobs::Test skip_db => 1;

=back

=head1 SUBROUTINES

The following subroutines are helpers to use within the tests.

=head2 override

This subroutine can be used to override (mock) methods or subroutines within the test.

 App::RemotePerlJobs::Test::override(
     package => 'App::RemotePerlJobs::Feed',
     name    => 'get',
     subref  => sub {
         my $class  = shift;
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
                     link => 'https://test.test.local/',
                     title => 'Test Entry',
                     summary => 'Test Summary',
                     content => 'More olives on the pizza!',
                     author => 'test@testerton.com (Test Testerton)',
                     date => '2024-09-01T12:10:20+00:00',
                 },
             ],
         );
     },
 );

=head2 load_sql_files

This subroutine can be used to load sql files, for example containing test data, within the tests.

 App::RemotePerlJobs::Test::load_sql_files( [ "$FindBin::RealBin/../db/data/add_source_testlocal.sql" ] )

=head2 create_feed

This subroutine creates feeds for tests.

 App::RemotePerlJobs::Test::create_feed(
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
             link => 'https://test.test.local/',
             title => 'Test Entry',
             summary => 'Test Summary',
             content => 'More olives on the pizza!',
             author => 'test@testerton.com (Test Testerton)',
             date => '2024-09-01T12:10:20+00:00',
         },
     ],
 );

=head3 ARGUMENTS

=over

=item feed

The C<feed> argument is required and must be a hashref with the following keys:

=over

=item title

=item link

=item description

=item language

=item author

=item copyright

=item date

The C<date> value must match the following format:

 YYYY-MM-DDThh:mm:ss+00:00

=back

=item entries

The C<entries> argument is required and must be an arrayref of hashrefs with the following keys:

=over

=item link

=item title

=item summary

=item content

=item author

=item date

The C<date> value must match the following format:

 YYYY-MM-DDThh:mm:ss+00:00

=back

=back

=head1 COPYRIGHT AND LICENSE

C<App::RemotePerlJobs> is Copyright (c) 2022 Blaine Motsinger under the MIT license.

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
