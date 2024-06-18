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
    indirect is up to date. (0.39)
    multidimensional is up to date. (0.014)
    bareword::filehandles is up to date. (0.007)
    strictures is up to date. (2.000006)
    XML::Feed is up to date. (0.63)
    DBD::SQLite is up to date. (1.74)
    
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
    updating repo
    Already up to date.
    applying database patches
    applying patch 005_add_db_patch_history.sqlite3

# COPYRIGHT AND LICENSE

`App::RemotePerlJobs` is Copyright (c) 2022 Blaine Motsinger under the MIT license.

# AUTHOR

Blaine Motsinger `blaine@renderorange.com`
