package PMCache;
require Exporter;

use PubMed;
use EasyGet;
use LWP::Simple;

@ISA = qw(Exporter);
@EXPORT = qw(cached_get_pmids cached_get_linked);

$VERSION = 1.0;
$CACHE_PATH="/tmp/";

# In:  A ref to a list of PMID:s
# Out: A ref to a hash table, mapping PMID to hash of article 
#      data (see get_pmid_articles in PMID.pm).
#      undef is returned in case of problems.
sub cached_get_pmids {
  my $ids = shift @_;
  my @not_cached = ();
  my $str;
  my @cached_art=();
  my @uncached_art=();

  foreach $id (@$ids) {
    if ($id =~ m/\d+/) {
      $str = get_cached_data($id);
    } else {
      next;
    }
    if (defined $str) {
      push @cached_art, $str;
    } else {
      push @not_cached, $id;
    }
  }
  if (scalar(@not_cached) > 0){
    $long_art_str_ref = get_pmids({'report' => 'medline',
				   'id' => \@not_cached});
    if (defined $long_art_str_ref) {
      @uncached_art = split(/\n\n\n\n\n/, $$long_art_str_ref);
    } else {
      return undef;
    }
  }

  foreach my $art (@uncached_art) {
    my $pmid = undef;
    if ($art =~ /<ArticleId IdType=.pubmed.>(\d+)<\/ArticleId>/) {
      $pmid = $1 + 0;
    } elsif ($art =~ /PMID- (\d+)/) {
      $pmid = $1 + 0;# This turns '00017' into '17'.
    }
    if (defined $pmid) {
      my $fname = "$CACHE_PATH/$pmid";
      open(FH, ">$fname") || print STDERR "Failed to open '$fname'\n";
      print FH $art;
      close(FH);
    } else {
      print STDERR "Found article string without PMID:\n\t'" . substr($art, 0, 60) . "'\n";
    }
  }

  my $h = parse_article_medline(\@cached_art, \@uncached_art);
  return $h;
}


# In:  A pmid, and possibly a timeout value in seconds (if file is 
#      older than that: Reload!).
# Out: A string with file contents, or undef if nonexistant, unreadable,
#      or similar
sub get_cached_data {
  my ($fname, $maxage) = @_;
  my $buf="";
  my $inbuf;

  open(FH, "<$CACHE_PATH$fname") || return undef;
  if (defined $maxage) {
    my @statdata = stat(FH);
    if ($statdata[9] + $maxage < time()) {
      close(FH);
      unlink "$CACHE_PATH$fname";
#      my @date = localtime($statdata[9]);
#      print STDERR "File age: ", $date[5], '-', $date[4], '-', $date[3], "\n";
      return undef;
    }
  }
  while (read(FH, $inbuf, 16384)) {
    $buf .= $inbuf;
  }
  close(FH);
#   if (length($buf)==0) {
#     return undef;
#   }
  return $buf;
}


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
