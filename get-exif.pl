#!/usr/bin/env perl
# Copyright 2019 Kevin Spencer <kevin@kevinspencer.org>
#
# Permission to use, copy, modify, distribute, and sell this software and its
# documentation for any purpose is hereby granted without fee, provided that
# the above copyright notice appear in all copies and that both that
# copyright notice and this permission notice appear in supporting
# documentation.  No representations are made about the suitability of this
# software for any purpose.  It is provided "as is" without express or 
# implied warranty.
#
################################################################################

use Data::Dumper;
use Image::ExifTool;
use strict;
use warnings;

$Data::Dumper::Indent = 1;

my $file = shift;

process_import_file($file);

sub process_import_file {
    my $filefound_fullpath = shift;

    my $img_date = get_image_date($filefound_fullpath);
}

sub get_image_date {
    my $filefound_fullpath = shift;

    # we'll attempt to extract the date created from Exif information
    my $exiftool = Image::ExifTool->new();
    $exiftool->ExtractInfo($filefound_fullpath);

    my $date_created = $exiftool->GetValue('CreateDate');
    # 2018:12:05 03:07:41.082
    my %imgdate = ();
    if (($date_created) && ($date_created =~ /(\d{4}):(\d{2}):(\d{2})/)) {
        $imgdate{YYYY} = $1;
        $imgdate{MM}   = $2;
    }

    # if for some reason we don't have Exif data fall back to file date from disk
    if (! %imgdate) {
        my $stat = stat($filefound_fullpath);
        my $time = localtime($stat->mtime());
        $imgdate{YYYY} = $time->year() + 1900;
        $imgdate{MM}   = sprintf("%02d", $time->mon() + 1);
    }

    return \%imgdate;
}
