package PubMed;
require Exporter;

use EasyGet;

@ISA = qw(Exporter);
@EXPORT = qw(extract_pmids query_pubmed parse_article_medline get_pmids get_gi_neighbors get_linked get_pmid_neighbors make_pubmed_url make_entrez_url);
#our @EXPORT_OK = ();
$VERSION = 1.0;

# For tool recognition at PubMed. Please replace by appropriate string!
$TOOLSTRING = "arvestad";


my $entrez_url ='http://www.ncbi.nlm.nih.gov/entrez';
my $neighbor_url = "$entrez_url/utils/pmneighbor.fcgi?pmid=";
#my $fetch_url = "$entrez_url/utils/pmfetch.fcgi";
#my $search_url = "$entrez_url/utils/pmqty.fcgi?cmd=search&tool=$TOOLSTRING&db=Nucleotide&term=";
#my $query_url = "$entrez_url/utils/pmqty.fcgi?";
my $out_format = '&pmid';

my $fetch_url = "$entrez_url/utils/pmfetch.fcgi";
my $query_url = "$entrez_url/utils/pmqty.fcgi?";
my $retrieve_url = "$entrez_url/query.fcgi";

# Given SGML from a PubMed query, get the list of ID:s
# In:  SGML-string
# Out: A reference to a list of PMID:s
#      If the input string does not contain an ID list, but contains
#      the substring "ERROR", undef is returned.
sub extract_pmids {
  my $str = shift @_;
  my @list = ();

  if (length $str == 0) {
    return \@list;
  } else {
    if ($str =~ m/<Id>((\d+\s+)*\d+)<\/Id>/g) {
      my $ids = $1;
      @list = split /\s+/, $ids;
      return \@list;
    } elsif ($str =~ m/ERROR/) {
	return undef;
    } else {
      return \@list;
    }
  }
}



# A better version of search_pubmed is QUERY_PUBMED:
# In:  A hash containing the building blocks of the search
# Out: A list of ids.
#
# Here are the default parameters. If a key in the following hash table
# is missing from your query hash, it will be taken from %def_str.
# Any other key/value pair in the argument hash will be added to the URL.
my %def_str = ('tool' => 'arvestad',
	       'db'   => 'm',
	       'dispmax' => '25',
	       'mode' => 'sgml'	# In contrast to the PubMed default 'html'
	      );

sub query_pubmed {
  my $h = shift @_;
  my @result=();
  my @url_parts=();
  my $url;;
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
  $url = $query_url;
  $url .= join('&', @url_parts);
#  print STDERR "URL: $url\n";
  return easyget $url;
}


# Parse article data in the traditional Medline format (<keyword>\s-\s<data>).
# In:  An array of refs to arrays of strings with article data
# Out: A hash of hashes with article data. First hash indexed by PMID.
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
		     'ID'=> undef};
sub parse_article_medline {
  my %art_h=();			# PMID --> hash
  my $data;

  foreach $art_v (@_) {
    my $current_label='';
    foreach $art (@$art_v) {
      my @art_lines = split(/\n/, $art);
      my %tmp_h=();		# keyword --> data
      for ($i=0; $i<=$#art_lines; $i++) {
	if ($art_lines[$i] =~ /^(\S*)\s*-\s(\w.*)/) {
	  $label = $1;
	  $current_label = $label;
	  $value = $2;
	  #print STDERR "$label: $value\n";
	  if (exists $is_multi_line->{$label}) {
	    push @{$tmp_h{$label}}, $value;
# 	    if (exists $tmp_h{$label}) {
# 	      my $av = $tmp_h{$label};
# 	      push @$av, $value;
# 	    } else {
# 	      $tmp_h{$label} = [$value];
# 	    }
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
	$art_h{$tmp_h{'PMID'}} = \%tmp_h;
      }
    }
  }
  return \%art_h;
}


# In:  A hash table. Elements should correspond to the arguments to fetch_url.
#      A mandatory element is 'id', which should be mapped to an array of PMID:s
# Out: A reference to a string containing the requested article data.
# Note that the 'batchsize' parameter determines how many times we query PubMed.
# With 100 pmid:s and default batchsize, four queries will be made.

my %def_fetch_param = ('db' => 'PubMed', # PubMed, Protein, Nucleotide, Popset
		       'report' => 'sgml', # For PubMed: docsum, brief, abstract,
		                           # citation, medline, asn.1, sgml
		                           # For all other databases: asn.1, gen
		       'mode' => 'text', # html, file, text
		       'batchsize' => 25,# Number of articles to download at one time.
		       'tool' => $TOOLSTRING);
sub get_pmids {
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
    while ($i < $size) {
      if ($i + $batchsize <= $size) {
	@id_slice = @$ids[$i..$i+$batchsize-1];
      } else {
	@id_slice = @$ids[$i..$lastidx];
      }
      $i += $batchsize;
      my $id_string = join(',', @id_slice);
      my $url = "$fetch_url?$arg_str&id=$id_string";
      $result_string .= easyget $url;
    }
    return \$result_string;
  } else {
    return undef;
  }
}

#
# In:  A ref to an array of PMID:s
# Out: A ref to a hash of PubMed neighbours to the input PMID:s, with
#      PMID:s indexing the ranks according to PubMed.
sub get_pmid_neighbors {
  my $set = shift;
  my $pmid_str = join ',', @$set;
  my %ranked_pmids = ();
  my $rank=1;

  if (scalar @$set == 0) {
    return \%ranked_pmids;
  }
#  print STDERR "Neighbour URL: \'$neighbor_url$pmid_str$out_format\'\n";
  my $nbs =  easyget "$neighbor_url$pmid_str$out_format";
  my $len = length $nbs;
  if ($len > 200) {
    $len = 200;
  }
#  print STDERR "\nnbs: " . substr($nbs,0,$len) . "\n";
  if ($nbs =~ m/ERROR : Invalid parameters/) {
    return undef;
  } elsif ($nbs =~ m/Can not find neighbors/s) {
    return \%ranked_pmids;
  } else {
    while ($nbs =~ m/<id>(\d+)<\/id>/g) {
      $ranked_pmids{$1} = $rank;
      $rank++;
    }
    return \%ranked_pmids;
  }
}


#
# In: a list of GI:s
# Out: A hash of arrays. The hash keys are PMID:s and they
#      index arrays of GI:s.

my $gi_articles_url = $entrez_url . '/query.fcgi?cmd=Link&db=PubMed&dbFrom=Nucleotide&dopt=Brief&from_uid=';

sub get_gi_neighbors {
  my %pmid_gi=();

  foreach $gi (@_) {
    my $related_articles = easyget $gi_articles_url . $gi;
#    print STDERR "\n---\n$related_articles\n---\n";
    while ($related_articles =~ m/PMID:\s?(\d+)/g) {
      if (exists($pmid_gi{$1})) {
	push @{$pmid_gi{$1}}, $gi;
      } else {
#	print STDERR "ID: $1\tGI: $gi\n";
	$pmid_gi{$1} = [$gi];
      }
    }
  }
  return \%pmid_gi;
}


# In:  Name of source database, name of target database, and
#      an id in the source DB.
# Out: Ref to HTML string for the resulting PubMed page.
#      Sorry, no Entrez utility available.
sub get_linked {
  my ($dbFrom, $dbTo, $id) = @_;

  if (defined $dbFrom && defined $dbTo && defined $id) {
    my $url = "$entrez_url/query.fcgi?cmd=Link&db=$dbTo&dbFrom=$dbFrom&dopt=Brief&from_uid=$id";
    my $result = easyget $url;
    return \$result;
  } else {
    return undef;
  }
}


# In:  A pmid list on the form 'id1,id2,id3' et.c.
# Out: A string containing a URL to PubMed
sub make_pubmed_url {
  my $pmid = shift @_;
  if ($pmid =~ /(\d+,)*\d+/) {
    return "$retrieve_url?cmd=Retrieve&db=PubMed&dopt=Abstract&list_uids=$pmid";
  } else {
    return undef;
  }
}


# In:  The latter part of a url to the Entrez utilities
sub make_entrez_url {
  my $url_post = shift;

  return "$entrez_url/$url_post";
}
