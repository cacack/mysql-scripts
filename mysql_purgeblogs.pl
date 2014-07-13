#!/bin/env perl

use strict;

use DBI;
use Data::Dumper;


# Database connection info.
my $db_socket = '/var/lib/mysql/mysql.sock';
my $db_user   = 'username';
my $db_pw     = 'password';

# The filesystem paths.
my $backupdir = '/srv/backup/mysql';
my $dumpdir   = '/srv/dump/mysql/log-bin';


# Connect to the database using the supplied information.
my $dbh = DBI->connect(
   "dbi:mysql:mysql_socket=$db_socket",
   $db_user,
   $db_pw,
   { RaiseError => 1, PrintError => 1 },
) or die "Cannot connect to the database: " . DBI->errstr;


# Get list of all binary logs.
my $query = 'SHOW BINARY LOGS';
my $sth = $dbh->prepare( $query );
$sth->execute();
my $binlogs_ref = $sth->fetchall_arrayref({});
$sth->finish();

# We really just want to know the current logs
my $curlog = ${ $binlogs_ref }[-1]->{ 'Log_name' };

# Purge the logs save for our latest one.
my $query = 'PURGE BINARY LOGS TO ?';
my $dbh_result = $dbh->do( $query, undef, $curlog ) or
   die "Cannot purge binary logs: " . DBI->errstr;

#print "($dbh_result) logs purged.\n";


$dbh->disconnect or die("Cannot disconnect from the database");
