#! /usr/bin/perl -w

if (scalar(@ARGV) != 3) {
  die "pmcomplete: Programming error or problems with Biblio installation.\n";
}

my $fragment=$ARGV[1];		# The little string to match
open(F, "<$ENV{HOME}/.biblio")
  || exit(0);

my $pmid = undef;		# Last read PMID
my $str = undef;		# Current entry string
my $have_match = 0;		# Record if the entry has matched or not

my @pmids = ();			# Stored matching pmids here, in order
my %entry = ();			# Stored matched entries here.

while (<F>) {
  if (m/^\s*$/) {		# Empty line
    if ($have_match == 1) {
      push @pmids, $pmid;
      $entry{$pmid} = $str;
      $have_match = 0;		# Restore
    }

  } elsif (m/^\s*[+-]?(\d+)\s+.*$/) { # New entry 
    $pmid = $1;
    $str = $_;
  } else {			# Continue old entry
    $str .= $_;
  }

  if (m/$fragment/i) {		# The entry matches! Case insensitive
    $have_match = 1;
  }
}

if (scalar(@pmids) == 0) {	# Nothing!
} elsif (scalar(@pmids) == 1) {	# Unique pmid! Completion done.
  print $pmids[0];
} else {			# Show what you've got
  print STDERR "\n--- Completions for $ARGV[1] ---";
  foreach my $pmid (@pmids) {
    print $pmid, "\n";
    print STDERR "\n", $entry{$pmid};
  }
  print STDERR "---\n";
}
