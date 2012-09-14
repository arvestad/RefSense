package BibCache;
require Exporter;

@ISA = qw(Exporter);

@EXPORT = ('pm_get_cached_bibdata',
	   'csb_get_cached_bibdata',
	   'pm_get_cached_seqdata',
	   'pm_write_cache',
	   'csb_write_cache',
	   'pm_write_seq_cache',
);

$VERSION = 1.0;

$CACHE_PATH="/tmp/";

$PUBMED_PREFIX = 'pm';
$CSB_PREFIX    = 'csb';
$PMSEQ_PREFIX  = 'seq';
$CACHE_FLAG    = 'REFSENSE_DONT_CACHE';

#
sub pm_get_cached_bibdata {
  my ($fileid, $maxage) = @_;
  return get_cached_bibdata($PUBMED_PREFIX, $fileid, $maxage);
}


#
sub csb_get_cached_bibdata {
  my ($fileid, $maxage) = @_;
  return get_cached_bibdata($CSB_PREFIX, $fileid, $maxage);
}

#
sub pm_get_cached_seqdata {
  my ($fileid, $maxage) = @_;
  return get_cached_bibdata($PMSEQ_PREFIX, $fileid, $maxage);
}


# In:  A citation id (e.g., PMID), and possibly a timeout value in seconds (if file is 
#      older than that: Reload!).
# Out: A string with file contents, or undef if nonexistant, unreadable,
#      or similar
sub get_cached_bibdata {
  my ($prefix, $fileid, $maxage) = @_;
  my $buf="";
  my $inbuf;

  open(FH, "<$CACHE_PATH/$prefix$fileid") || return undef;
  if (defined $maxage) {
    my @statdata = stat(FH);
    if ($statdata[9] + $maxage < time()) {
      close(FH);
      unlink "$CACHE_PATH/$prefix$fname";
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


#
sub pm_write_cache {
  my ($bibid, $contents) = @_;

  write_cache($PUBMED_PREFIX, $bibid, $contents);
}

#
sub csb_write_cache {
  my ($bibid, $contents) = @_;

  write_cache($CSB_PREFIX, $bibid, $contents);
}

#
sub pm_write_seq_cache {
  my ($id, $contents) = @_;

  write_cache($PMSEQ_PREFIX, $id, $contents);
}

#
# In:  
# Out: 
#
sub write_cache {
  my ($prefix,$bibid, $contents) = @_;

  if (!exists $ENV{$CACHE_FLAG}) {
    my $fname = "$CACHE_PATH/$prefix$bibid";
    open(FH, ">$fname") 
      || print STDERR "BibCache error: Failed to open '$fname'\n";
    print FH $contents;
    close(FH);
  }
}

