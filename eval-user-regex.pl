#!/usr/bin/env perl
################################################################################

use Data::Dumper;
use Safe;
use strict;
use warnings;

$Data::Dumper::Indent = 1;

my $file_of_regexes = shift;
die "Need a file of regular expressions to parse!\n" if (! $file_of_regexes);
die "No such file - $file_of_regexes\n" if (! -e $file_of_regexes);

#
# Note: users provide Perl regex substitutions
#
# Any malformed regex will cause a compilation failure so we must check
# the validity by eval.  But doing that is a security risk because the users
# could place anything in the file.  Each regex will be evaluated inside a
# Safe container with a minimal set of allowable Perl code just to be safe.
#

open(my $fh, '<', $file_of_regexes) || die "Could not open $file_of_regexes - $!\n";

my $sandbox = Safe->new();
#
# ensure any unsafe code in the regex file is rejected see perldoc Opcode for
# what :base_core and :base_orig allow...
#
$sandbox->permit_only(qw(:base_core :base_orig));
my @substitutions;
while (<$fh>) {
    chomp;
    my $regex = $_;
    $_ = '';
    $sandbox->reval($regex);
    # error with the regex?
    if ($@) {
        # user supplied regex doesn't compile...
        close($fh);
        die "$file_of_regexes contains an invalid regular expression - $@\n";
    }
    push(@substitutions, eval("sub { $regex }" ));
}
close($fh);
print Dumper \@substitutions;
