package PMCache;
require Exporter;

use PubMed;
use EasyGet;
use LWP;

@ISA = qw(Exporter);
@EXPORT = qw(pm_cached_fetch_pubmed cached_get_linked);

$VERSION = 1.0;




# This is a cached version of get_linked in PubMed.pm.
#
# In:  Name of source database, name of target database, and
#      an id in the source DB.
# Out: Ref to array with ids.
#
# If the cached version is more than a week old, a new copy
# is retrieved. NOTE! For space reasons, I strip the content 
# to only contain a list (one ID per line) of actual PMID:s!

my $oneweek = 7*24*60*60;	# Seconds per week
#my $oneweek = 1; # For testing!

sub cached_get_linked {
  my ($dbFrom, $dbTo, $id) = @_;
  my @ids = ();

  if (defined $dbFrom && defined $dbTo && defined $id) {
    my $cachedname = substr($dbFrom, 0, 2)
                   . substr($dbTo, 0, 2)
		   . $id;
    my $result = get_cached_data($cachedname, $oneweek);
    if (defined $result) {
#      print STDERR "Cached copy exists ($cachedname)\n";
      while ($result =~ m/(\d+)/g) {
	push @ids, $1;
#	print STDERR "Stale: $1\n";
      }
      return \@ids;
    } else {
#      print STDERR "Fetches fresh copy ($cachedname)\n";
      my $url = make_entrez_url("query.fcgi?cmd=Link&db=$dbTo&dbFrom=$dbFrom&dopt=Brief&from_uid=$id");
      $result = easyget $url;
      my $fname = "$CACHE_PATH/$cachedname";
      open(FH, ">$fname") || print STDERR "PMCache, cached_get_linked: Failed to open '$fname'\n";
      while ($result =~ m/(PMID|gi):\s?(\d+)/g) {
	print FH "$2\n";
#	print STDERR "Fresh: $2\n";
	push @ids, $2;
      }
      close(FH);

      return \@ids;
    }

  } else {
    return undef;
  }
}
