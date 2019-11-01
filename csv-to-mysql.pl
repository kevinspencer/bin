#!/usr/bin/env perl

use open qw(:std :utf8);
use Data::Dumper;
use DBIx::Simple;
use Text::CSV_XS;
use strict;
use warnings;

$Data::Dumper::Indent = 1;

my $file = shift;

open(my $fh, '<', $file) || die "Could not open $file - $!\n";

my $pdsn  = 'dbi:mysql:dbname=desktickets';
my $puser = '';
my $ppass = '';

my $pdbh = DBIx::Simple->connect($pdsn, $puser, $ppass);
die $DBI::errstr, "\n" if (! $pdbh);

my $parser = Text::CSV_XS->new({binary => 1});

my $header_row = 1;

#
# in case our CSV has embedded newlines we'll use getline() to parse each line
#

while (my $row = $parser->getline($fh)) {
    my @fields = @$row;
    if ($header_row) {
        my $count = @fields;
        # might need to do something with the header here
        $header_row = 0;
        next;
    }
    my $count = @fields;
    if ($count != 142) {
        print Dumper \@fields;
        next;
    }
    my $SQL_STRING = "INSERT INTO tickets VALUES(";
    my @bindvals;
    for my $field (@fields) {
        $field =~ s/'//g;
        $field =~ s/\\//g;
        $SQL_STRING .= '?,';
        push(@bindvals, $field);
    }
    # remove that last ending comma
    chop($SQL_STRING);
    $SQL_STRING .= ')';

    # FIXME: instead of bailing, handle this better
    if (! $pdbh->query($SQL_STRING, @bindvals)) {
        die $pdbh->error(), "\n";
    }
}
close($fh);
