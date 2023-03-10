# NAME

App::RemotePerlJobs - get job feeds and post to mastodon

# DESCRIPTION

`App::RemotePerlJobs` is an application to fetch remote perl job feeds and post them to mastodon.

# INSTALLATION

To install on a Debian/Ubuntu system:

## install perl dependencies

    $ apt install git cpanminus sqlite3
    $ cpanm App:Toot indirect multidimensional bareword::filehandles strictures XML::Feed DBD::SQLite

## download repo

    $ cd
    $ mkdir git
    $ cd git
    $ git clone https://github.com/renderorange/app-remoteperljobs.git

## create sqlite3 db

    $ cd app-remoteperljobs
    $ sqlite3 db/remoteperljobs.sqlite3
    sqlite> .databases
    sqlite> .q
    $ sqlite3 db/remoteperljobs.sqlite3 < db/schema/001_schema.sqlite3
    $ sqlite3 db/remoteperljobs.sqlite3 < db/schema/002_add_source_jobsperlorg.sqlite3

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

# COPYRIGHT AND LICENSE

`App::RemotePerlJobs` is Copyright (c) 2022 Blaine Motsinger under the MIT license.

# AUTHOR

Blaine Motsinger `blaine@renderorange.com`
