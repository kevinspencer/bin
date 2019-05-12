#!/usr/bin/env perl

use strict;
use warnings;

# change this for different top n users...
my $max_user_count = 10;

my $file = shift;

open(my $fh, '<', $file) || die "Could not open $file - $!\n";
my %users_by_bytes;
my $total_bytes = 0;
while(<$fh>) {
    chomp;
    my $line = $_;
    my ($username, $bytes)  = split(',', $line);
    $users_by_bytes{$bytes} = $username;
    $total_bytes += $bytes;
}
close($fh);

my $user_counter     = 0;
my $top_n_byte_count = 0;

for my $byte_count(sort { $b <=> $a } keys(%users_by_bytes)) {
    print "$users_by_bytes{$byte_count}, $byte_count\n";
    $user_counter++;
    $top_n_byte_count += $byte_count;
    last if ($user_counter == $max_user_count);
}

my $top_n_percentage_of_whole = sprintf("%.2f", (($top_n_byte_count / $total_bytes) * 100));

print "\nTotal user bytes: $total_bytes\n";
print "Top $max_user_count user bytes: $top_n_byte_count\n";
print "Top $max_user_count % of total: $top_n_percentage_of_whole\n";
