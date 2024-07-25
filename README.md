# NAME

App::RemotePerlJobs - get job feeds and post to mastodon

# DESCRIPTION

`App::RemotePerlJobs` is an application to fetch remote perl job feeds and post them to mastodon.

# INSTALLATION

To install on a Debian/Ubuntu system:

## install system dependencies

    $ apt install git cpanminus sqlite3 make

## download repo

    $ cd
    $ mkdir git
    $ cd git
    $ git clone https://github.com/renderorange/app-remoteperljobs.git

## run install make target

    $ cd app-remoteperljobs
    $ make install
    Are you sure? [y/N] y
    
    checking system dependencies
    git - found
    cpanm - found
    sqlite3 - found

    installing perl dependencies
    App::Toot is up to date. (0.04)
    bareword::filehandles is up to date. (0.007)
    Cwd is up to date. (3.89)
    DBD::SQLite is up to date. (1.74)
    DBI is up to date. (1.643)
    indirect is up to date. (0.39)
    LWP::Protocol::https is up to date. (6.14)
    multidimensional is up to date. (0.014)
    strictures is up to date. (2.000006)
    Time::Piece is up to date. (1.3401_01)
    Try::Tiny is up to date. (0.31)
    URI is up to date. (5.28)
    XML::Feed is up to date. (0.65)
    FindBin is up to date. (1.54)
    File::Path is up to date. (2.18)
    File::Temp is up to date. (0.2311)
    Test::Deep is up to date. (1.204)
    Test::Exception is up to date. (0.43)
    Test::More is up to date. (1.302199)
    Test::Warnings is up to date. (0.033)

    creating sqlite3 database
    applying 001_schema.sqlite3
    applying 002_add_source_jobsperlorg.sqlite3
    applying 003_update_source_jobsperlorg.sqlite3
    applying 004_update_source_jobsperlorg.sqlite3
    applying 005_add_db_patch_history.sqlite3
    
    installation is complete
    create the cronjob and add the mastodon credentials to automate posting

## add mastodon credentials

    $ mkdir -p ~/.config/toot
    $ vi ~/.config/toot/config.ini
    [remoteperljobs]
    instance = your.instance.name
    username = youruser
    client_id = OKE98_kdno_NOTAREALCLIENTID
    client_secret = mkjklnv_NOTAREALCLIENTSECRET
    access_token = jo83_NOTAREALACCESSTOKEN

## add cronjob for automated fetching and posting

    $ crontab -e
    # remoteperljobs
    @hourly /usr/bin/perl -I /home/user/perl5/lib/perl5 -I /home/user/git/app-remoteperljobs/lib /home/user/git/app-remoteperljobs/bin/run

# UPGRADE

To upgrade the local install and apply database patches which haven't been applied:

    $ cd git/app-remoteperljobs
    $ make upgrade
    Are you sure? [y/N] y

    checking system dependencies
    git - found
    cpanm - found
    sqlite3 - found

    updating repo
    Already up to date.

    installing perl dependencies
    App::Toot is up to date. (0.04)
    bareword::filehandles is up to date. (0.007)
    Cwd is up to date. (3.89)
    DBD::SQLite is up to date. (1.74)
    DBI is up to date. (1.643)
    indirect is up to date. (0.39)
    Successfully installed LWP-Protocol-https-6.14
    multidimensional is up to date. (0.014)
    strictures is up to date. (2.000006)
    Time::Piece is up to date. (1.3401_01)
    Try::Tiny is up to date. (0.31)
    URI is up to date. (5.28)
    XML::Feed is up to date. (0.65)
    FindBin is up to date. (1.54)
    File::Path is up to date. (2.18)
    File::Temp is up to date. (0.2311)
    Test::Deep is up to date. (1.204)
    Test::Exception is up to date. (0.43)
    Test::More is up to date. (1.302199)
    Test::Warnings is up to date. (0.033)
    1 distribution installed

    applying database patches
    006_update_source_jobsperlorg.sqlite3

# COPYRIGHT AND LICENSE

`App::RemotePerlJobs` is Copyright (c) 2022 Blaine Motsinger under the MIT license.

# AUTHOR

Blaine Motsinger `blaine@renderorange.com`
