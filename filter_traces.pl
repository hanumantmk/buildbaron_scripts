#!/usr/bin/perl -w

use strict;

my $in_trace = 0;

open OUT, "| c++filt" or die "terribly";

my @buffer = ();

while (my $line = <STDIN>) {
    if ($line =~ /invariant/i) {
        print $line;
        next;
    }
    if ($line =~ /assert failed/i) {
        print $line;
        next;
    }
    if ($line =~ /failed to load/i) {
        print $line;
        next;
    }
    if ($line =~ /----- BEGIN BACKTRACE -----/) {
        <STDIN>;
        $in_trace = 1;
    } elsif ($line =~ /-----  END BACKTRACE  -----/) {
        if (!grep { /traceIfNeeded/ || /logContext/ } @buffer) {
            print OUT @buffer, $line, "\n\n\n";
        }
        $in_trace = 0;
        @buffer = ();
    }

    if ($in_trace) {
        push @buffer, $line;
    }
}
print OUT @buffer;

close OUT or die "terribly";
