#! /ms/dist/perl5/bin/perl5.10

# $Header:$
# Script to handle differing yacc/bison combos on the system.
# If we can, use bison. Otherwise use yacc, but strip the token
# string constants that cause bad compilation issues size '"sizeof"'
# results in a '#define sizeof' which is not desirable.
#
# Paul D. Fox
# Date: January 2011

use strict;
use warnings;

use File::Basename;
use FileHandle;
use Getopt::Long;
use IO::File;
use POSIX;

#######################################################################
#   Command line switches.					      #
#######################################################################
my %opts;

sub main
{
	Getopt::Long::Configure('require_order');
	Getopt::Long::Configure('no_ignore_case');
	usage() unless GetOptions(\%opts,
		'help',
		);

	usage() if $opts{help};

	my $fname;
	foreach my $a (@ARGV) {
		$fname = $a if $a !~ /^-/;
	}

	if (-f "/usr/bin/bison") {
		print "/usr/bin/bison ", join(" ", @ARGV), "\n";
		exec "/usr/bin/bison", @ARGV;
	}
	if (-f "/usr/bin/yacc") {
		my $fh = new FileHandle($fname);
		die "Cannot open $fname -- $!" if !$fh;
		my $fh1 = new FileHandle(">$fname.yacc");
		die "Cannot create $fname.yacc -- $!" if !$fh1;
		while (<$fh>) {
			if (/^%token/) {
				$_ =~ s/"[^"]*"//g;
			}
			print $fh1 $_;
		}
		$fh1->close();
		$ARGV[-1] = $fname;
		print "/usr/bin/yacc ", join(" ", @ARGV), "\n";
		exec "/usr/bin/yacc", @ARGV;
	}

	print "Error: Cannot locate yacc or bison in /usr/bin. Script may need updating\n";
	exit(1);
}
#######################################################################
#   Print out command line usage.				      #
#######################################################################
sub usage
{
	print <<EOF;
yacc.pl -- wrapper around yacc/bison.
Usage:

Switches:

EOF

	exit(1);
}

main();
0;

