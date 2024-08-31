package App::RemotePerlJobs::Test;

use strict;
use warnings;

use FindBin;
use File::Temp;
use File::Path ();
use Try::Tiny  ();
use Cwd        ();

use parent 'Test::More';

our $VERSION = '0.004';

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

    if ($args{skip_cleanup}) {
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
        or die "open $db_path: $!\n";
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
        or die "opendir $schema_dir: $!\n";

    my @schema_files =
        map {"$schema_dir/$_"}
        grep { !/^\./ && -f "$schema_dir/$_" } readdir $schema_dh;

    closedir $schema_dh;

    my @queries;
    foreach my $file ( sort @schema_files ) {
        open( my $schema_fh, '<', $file )
            or die "open $file: $!\n";

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
            die "insert query failed: $_\n";
        };

    }

    return;
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

=head1 COPYRIGHT AND LICENSE

C<App::RemotePerlJobs> is Copyright (c) 2022 Blaine Motsinger under the MIT license.

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
