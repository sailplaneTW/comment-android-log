#!/usr/bin/env perl

use strict;
use warnings;
use File::Copy qw(copy);
use File::Find;

my $working_dir = $ARGV[0];
my $tmpfile = '/tmp/qwertyuioplkjhgfdsa';

my @remove_list = (
    'import android.util.Log;',
    'Log.d',
    'Log.i',
    'Log.e',
    'Log.v',
    'onoLog.d',
    'onoLog.e',
    'onoLog.writeFile',
);

find({ wanted => \&process_file, no_chdir => 1 }, $working_dir);

sub process_file {
    my $file = $_;
    my ($pattern) = @_;

    print "proccessing [$file] ...\n";

    if (-f $file and $file =~ m/\.java$/) {
        for my $pattern (@remove_list) {
            open (INPUT, $file) || die "can't open $file: $!";
            open (OUTPUT, '>', $tmpfile) || die "can't open $tmpfile: $!";

            while (<INPUT>) {
                if (/^\s*$pattern/) {
                    s/^(\s*)($pattern)/$1\/\/$2/g;
                }
                print OUTPUT;
            }

            close(INPUT);
            close(OUTPUT);

            # rename result file to source
            unlink $file;
            copy $tmpfile, $file;
        }
    }
}
