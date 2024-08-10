package App::RemotePerlJobs::DB;

use strictures version => 2;

use Cwd ();
use DBI;

our $VERSION = '0.003';

sub connect_db {
    my $class = shift;

    my $dsn = $class->load();
    my $dbh = DBI->connect(
        $dsn, undef, undef,
        {   PrintError       => 0,
            RaiseError       => 1,
            AutoCommit       => 1,
            FetchHashKeyName => 'NAME_lc',
        }
    ) or die("connect db: $DBI::errstr\n");

    return $dbh;
}

sub load {
    my $class = shift;

    my $module_path = Cwd::realpath(__FILE__);
    $module_path =~ s/\w+\.pm//;
    my $db = Cwd::realpath( $module_path . '/../../../db/remoteperljobs.sqlite3' );

    unless ( -f $db ) {
        die "$db is not readable";
    }

    return "dbi:SQLite:dbname=$db";
}

1;

=pod

=head1 NAME

App::RemotePerlJobs::DB - creates and connects to the database handle

=head1 SYNOPSIS

 use App::RemotePerlJobs::DB ();
 my $dbh = App::RemotePerlJobs::DB->connect_db();

=head1 DESCRIPTION

This module provides methods for other modules to connect to the database.

=head1 SUBROUTINES/METHODS

=head2 connect_db

=head3 ARGUMENTS

None.

=head3 RETURNS

The DBI db database handle.

=head2 load

=head3 ARGUMENTS

None.

=head3 RETURNS

The C<dsn> string.

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
