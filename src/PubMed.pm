package PubMed;
require Exporter;

use EasyGet;
use BibCache;

@ISA = qw(Exporter);
@EXPORT = ('pm_query',		# Perform a search and return PMID:s
	   'pm_fetch',		# Supply a retrieval specs and retrieve result strings
	   'pm_fetch_pubmed',	# Supply PMID:s and retrieve a hashref with article data
	   'pm_fetch_linked',	# Retrieve items linked to given id(s).
	   'pm_valid_dbname',	# Test if valid database names
	   'pm_extract_pmids',	# Extract PMIDs from an XML file

	   'get_doi',		# Given an article hash, retrieve the DOI if present
	    );
$VERSION = 1.0;

# For tool recognition at EUtils.
$TOOLSTRING = 'pmbt';

### URL:s ################################################################################
# Shared URL prefix:
my $eutils_url ='http://www.ncbi.nlm.nih.gov/entrez/eutils';

# ESearch URL
my $search_url = $eutils_url . '/esearch.fcgi?';

# EFetch URL
my $fetch_url = $eutils_url . '/efetch.fcgi?';

# ELink URL
my $elink_url = $eutils_url . '/elink.fcgi?';

### Valid Entrez databases ###############################################################
#
# Don't know if all should really be supported though...
#
my %Entrez_DBs = ( 'omin' => undef,
		   'pubmed' => undef,
		   'nucleotide' => undef,
		   'protein' => undef,
		   'genome' => undef,
		   'popset' => undef,
		   'snp' => undef,
		   'unists' => undef,
		   'unigene' => undef,
		   'structure' => undef,
		   'domains' => undef,
		   'cdd' => undef,
		   'taxonomy' => undef,
		   'geo' => undef,
);

### Functions ############################################################################

# Func:  pm_query
#
# In:  A hash containing the building blocks of the search
# Out: A list of ids.
#
# Here are the default parameters. If a key in the following hash table
# is missing from your query hash, it will be taken from %def_str.
# Any other key/value pair in the argument hash will be added to the URL.
my %def_str = ('tool' => $TOOLSTRING,
	       'db'   => 'pubmed',
	       'retmax' => '100', # Currently 20 as default at Entrez!
	       'retmode' => 'xml' # No choice at EUtils!
	      );

sub pm_query {
  my $h = shift @_;
  my @result=();
  my @url_parts=();
  my $url = $search_url;
  my $str;

  foreach $key (keys %$h) {
    $str = $h->{$key};
#    print STDERR "opt: $key=$str\n";
    push @url_parts, "$key=" . $str
  }
  foreach $key (keys %def_str){
    if (!exists $h->{$key}) {
      $str = $def_str{$key};
#      print STDERR "def: $key=$str\n";
      push @url_parts, "$key=$str";
    }
  }
  $url = $search_url;
  $url .= join('&', @url_parts);
#  print STDERR "URL: $url\n";
  my $res = easyget $url;
  return $res;
}


# Func: pm_extract_pmids
#
# In:  An XML string on a very specific format.
# Out: A pair containing the number of hits in PubMed (which
#      of course may be larger than the number of hits retrieved!)
#      and a ref to a list of PMID:s
#      If the input string does not contain an ID list, but contains
#      the substring "ERROR", undef is returned.
#
sub pm_extract_pmids {
  my ($str) = @_;

  my @list = ();
  my $count = 0;

  if (length $str == 0) {
    return undef;
  } elsif ($str =~ m/ERROR/) {
    return undef;
  } else {
    if ($str =~ m/<Count>\s*(\d+)\s*<\/Count>/) {
      $count = $1;
    }
    while ($str =~ m/<Id>\s*(\d+)\s*<\/Id>/g) {
      push @list, $1;
    }
    return [$count, \@list];
  }
}


# Func: pm_fetch
#
# In:  A hash table. Elements should correspond to the arguments to fetch_url.
#      A mandatory element is 'id', which should be mapped to an array of PMID:s
#
# Out: Ref to string with Medline records.
#
# Note that the 'batchsize' parameter determines how many times we query PubMed.
# With 100 pmid:s and default batchsize, four queries will be made. The function
# sleeps a necessary amount of time too! (At most one query every 3 seconds!)

my %def_fetch_param = ('db' => 'PubMed',
		       'rettype' => 'xml',
		       'retmode' => 'text',
		       'batchsize' => 100, # Number of articles to download at one time.
		       'tool' => $TOOLSTRING);
sub pm_fetch {
  my $href = shift @_;
  my $result_string='';
  my $batchsize;

  if (exists $href->{'id'}) {
#    $arg_str .= join ',', $href->{'id'};
    foreach $arg (keys %def_fetch_param) {
      if (!exists $href->{$arg}) {
	$href->{$arg} = $def_fetch_param{$arg};
      }
    }
    my @arg_v = ();
    foreach $arg (keys %$href) {
#      print STDERR "$arg:\t" . $href->{$arg} . "\n";
      if ($arg eq 'batchsize') {
	$batchsize = $href->{'batchsize'};
      } elsif ($arg ne 'id') {
	push @arg_v, "$arg=" . $href->{$arg};
	#$arg_str .= "$arg=" . $href->{$arg} . "&";
      }
    }
    my $arg_str = join('&', @arg_v);
    # Now divide the id array into slices. Query PubMed with one slice at the time.
    my $ids = $href->{'id'};
    my @id_slice;
    my $size = scalar(@$ids);
    my $lastidx = $size - 1;
    my $i = 0;
    my $t1;
    my $t2;
    while ($i < $size) {
      if ($i + $batchsize <= $size) {
	@id_slice = @$ids[$i..$i+$batchsize-1];
      } else {
	@id_slice = @$ids[$i..$lastidx];
      }
      my $id_string = join(',', @id_slice);
      my $url = $fetch_url . "$arg_str&id=$id_string";
#      print STDERR "'$url'\n";
      $t2 = time() - 3;
      my $res = easyget($url);
      if (defined $res) {
	$result_string .= $res;
      } else {
	print STDERR "Warning: Problems accessing PubMed.\n";
      }
      $result_string .= "\n\n\n\n";
      $i += $batchsize;
      $t1 = time();		# Want to make sure that we wait 3 secs before bugging PubMed again!
      if ($i < $size) {
	my $pause = 3;
	print STDERR "Being polite to NCBI: Sleeping between queries ($pause s).\n";
	sleep($pause);
      }
    }

    return \$result_string;
  } else {
    return undef;
  }
}


# In:  A ref to a list of PMID:s
# Out: A ref to a hash table, mapping PMID to hash of article 
#      data (see get_pmid_articles in PMID.pm).
#      undef is returned in case of problems.
sub pm_fetch_pubmed {
  my $ids = shift @_;
  my @not_cached = ();
  my $str;
  my @cached_art=();
  my @uncached_art=();
  my %art_h = ();

# First get cached articles:
  foreach $id (@$ids) {
    if ($id =~ m/\d+/) {
      $str = pm_get_cached_bibdata($id);
      if (defined $str) {
	my $new_art = parse_article_medline(\$str);
	$new_art->{$id}{'PubMedURL'} = $elink_url . 'retmode=ref&cmd=prlinks&dbfrom=pubmed&id=' . $id;
	%art_h = (%art_h, %$new_art);
      } else {
	push @not_cached, $id;	# Collect stuff not in cache
      }
    } else {
      die("pm_fetch_pubmed: Expected a PMID, got '$id'.\n");
    }
  }

# Then pick up 'new' articles:
  if (scalar(@not_cached) > 0){
    $str = pm_fetch({'rettype' => 'medline',
			'id' => \@not_cached});
    if (defined $str) {
      @uncached_art = split(/\n\n+/, $$str);
    } else {
      print STDERR 'No abstracts retrieved for ', join(', ', @not_cached), ".\nPubMed may be heavily loaded.";
    }

    foreach my $art (@uncached_art) {
      my $pmid = undef;
      if ($art =~ /<ArticleId IdType=.pubmed.>(\d+)<\/ArticleId>/) {
	$pmid = $1 + 0;
      } elsif ($art =~ /PMID- (\d+)/) {
	$pmid = $1 + 0;# This turns '00017' into '17'.
      }
      if (defined $pmid) {
	pm_write_cache($pmid, $art);
      } else {
	print STDERR "Found article string without PMID:\n\t'" . substr($art, 0, 60) . "'\n";
      }
      my $h = parse_article_medline(\$art);
      if (defined $h) {
	$h->{$pmid}{'PubMedURL'} = $elink_url . 'retmode=ref&cmd=prlinks&dbfrom=pubmed&id=' . $pmid;
	%art_h = (%art_h, %$h);
      }
    }
  }

  return \%art_h;
}


# Parse article data in the traditional Medline format (<keyword>\s-\s<data>).
# In:  Ref to a string with one or more medline entries in
# Out: Ref to a hash of hashes with article data. First hash indexed by PMID.
my $is_multi_line = {'RO'=> undef,
		     'RN'=> undef,
		     'LA'=> undef,
		     'SB'=> undef,
		     'GS'=> undef,
		     'MH'=> undef,
		     'PT'=> undef,
		     'AU'=> undef,
		     'PS'=> undef,
		     'CM'=> undef,
		     'SI'=> undef,
		     'AID'=> undef,
		     'ID'=> undef};

my $synonym_labels = {'CN'=> 'AU',
		      };
# The synonym_labels hash is a hack to handle so-called Collective names. The can appear
# in the author list and we want to include them as-is.
sub parse_article_medline {
  my ($medline_strings) = @_;
  my %art_h=();			# PMID --> hash
  my $data;

  my @medlines = split(/\n\n+/, $$medline_strings);
  foreach $art (@medlines) {
    my $current_label='';
      my @art_lines = split(/\n/, $art);
      my %tmp_h=();		# keyword --> data
      for ($i=0; $i<=$#art_lines; $i++) {
	if ($art_lines[$i] =~ /^(\S*)\s*-\s*(\S.*)/) {
	  $label = $1;
	  $value = $2;
	  if (exists $synonym_labels->{$label}) {
	    $label = $synonym_labels->{$label};
	    $value = ':protect:' . $value; # This is a collective name or similar: Should no be interpreted as a name.
	  }
	  $current_label = $label;

	  if (exists $is_multi_line->{$label}) {
	    push @{$tmp_h{$label}}, $value;
	  } else {
	    $tmp_h{$label} = $value;
	  }
       	} elsif ($art_lines[$i] =~ /^      (.*)/) {
	  $value = $1;
	  $tmp_h{$current_label} .= " $value";
	}
      }
      if (!exists $tmp_h{'PMID'}) {
	print STDERR "Warning: No PMID present in Medline record!\n";
	return undef;
      } else {
	#### EINAR: Edited to handle PMIDs that start with 0
	if ($tmp_h{'PMID'}=~/^0/) {
          print STDERR "Warning: PMID ", $tmp_h{'PMID'},
	    " starts with 0!\n";
          $tmp_h{'PMID'}=~s/^0*//;
	}
	#### End of editing.
	$art_h{$tmp_h{'PMID'}} = \%tmp_h;
      }
    }
  return \%art_h;
}

# In:  A ref to a list of PMID:s, and two strings, FromDB and ToDB,
#      both take values from the set 'nucleotide', 'protein','pubmed', etc.
# Out: A ref to a hash table, mapping PMID to SEQIDs
sub pm_fetch_linked {
  my ($from_db, $other_db, $ids, $additional) = @_;
  my @valid_ids = ();

  if (! defined $additional) {
    $additional = '';
  } 
  if (length($additional) > 0) {
    $additional = "&$additional";
  }

  if (pm_valid_dbname($from_db)
      && pm_valid_dbname($other_db)) {

    foreach my $id (@$ids) {
      if ($id =~ m/\d+/) {
	push @valid_ids, $id;
      }
    }

    my $id_str = join(',', @valid_ids);
    my $url = $elink_url . "dbfrom=$from_db&db=$other_db&id=" . $id_str . $additional;
#    print STDERR $url, "\n";

    my $res = easyget($url);

    return pm_extract_linked_ids($res);
  } else {
    return (0, 0);
  }
}


# In:  An XML string
# Out: A pair containing the number of hits in PubMed (which
#      of course may be larger than the number of hits retrieved!)
#      and a ref to a hash of id:s mapped to relatedness score.
#      If the input string does not contain an ID list, but contains
#      the substring "ERROR", undef is returned.
#
sub pm_extract_linked_ids {
  my ($str) = @_;

  my %h = ();

  if (length $str == 0) {
    return undef;
  } elsif ($str =~ m/ERROR/) {
    return undef;
  } else {
    my @strarray = split(/\s+/, $str);
    while (scalar(@strarray) > 0 && $strarray[0] ne '<LinkSetDb>') {
      shift @strarray;
      ;
    }
    shift @strarray;		# DbTo
    shift @strarray;		# LinkName
    my $cur_id=undef;
    my $cur_score =0;		# Assume relatedness score is 0 until we know better
    foreach my $s (@strarray) {
      if ($s =~  m/<Id>(\d+)<\/Id>/g) {	# Found a new current id
	$cur_id = $1;
      } elsif ($s =~ m/<Score>(\d+)<\/Score>/g) { # Found a score related to current id
	$cur_score = $1;
      } elsif ($s =~ m/<\/Link>/) {
	# If end marker of a 'link' is found, put known info in hash
	if (defined $cur_id) {
	  $h{$cur_id} = $cur_score;
	  $cur_id = undef;
	  $cur_score = 0;
	}
      }
    }
    my $count = scalar(keys %h);
    return ($count, \%h);
  }
}

sub old_pm_extract_linked_ids {
  my ($str) = @_;

  my @list = ();

  if (length $str == 0) {
    return undef;
  } elsif ($str =~ m/ERROR/) {
    return undef;
  } else {
    my @strarray = split(/\s+/, $str);
    while (scalar(@strarray) > 0 && $strarray[0] ne '<LinkSetDb>') {
      shift @strarray;
      ;
    }
    shift @strarray;		# DbTo
    shift @strarray;		# LinkName
    foreach my $s (@strarray) {
      if ($s =~  m/<Id>(\d+)<\/Id>/g) {
	push @list, $1;
      }
    }
    my $count = scalar(@list);
    return ($count, \@list);
  }
}

sub pm_valid_dbname {
  my ($str) = @_;

  if (exists $Entrez_DBs{$str}) {
    return 1;
  } else {
    return 0;
  }
}


sub get_doi {
  my $art = shift @_;

  my $elem = $art->{'AID'};
  if (defined $elem) {
    foreach my $e (@$elem) {
      if ($e =~ m/\s*(\S+)\s+\[doi\]\s*$/) {
	return $1;
      }
    }
    return undef;
  } else {
    return undef;
  }
}
