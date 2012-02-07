package Citation;
require Exporter;

use Globals;
use CGI;

@ISA = qw(Exporter);
@EXPORT = qw(make_bibtex_citation
	     make_text_citation
	     make_html_citation
);
$VERSION = 1.0;


sub protect_and_serve {
  $_ =~ s/^:protect:(.+)/\{$1\}/;
  return $_;
}

# In:  Article data hash
# Out: A string with a bibtex citation
sub make_bibtex_citation {
  my $art=shift @_;
  my @strl=();
  my $elem=undef;
  my $key=undef;
  my $author=undef;

  $elem = $art->{'AU'};
  if (defined $elem) {
    @l = map(protect_and_serve, @$elem);

    @authorl = ();
    foreach $a (@l) {
      #
      # Improvement by Einar A Rödland: Handle initials better
      # Remove double initials (error in Physical Review)
      #
      #print STDERR "Name ",$a;
      my ($b,$warning)=interpret_author($a);
      #print STDERR "  -->  ",$b,"\n";
      if ($warning) {
	# Advarsel i HTML-dokument ved problemer!
	print STDERR "Note: ",$warning,"\n";
      }
      push @authorl, $b;

    }
    $author = join(' and ', @authorl);

    # Compute a tentative BiBTeX key
    if ($authorl[0] =~ /^([^,]+),/) {
      $key = $1;
      $key =~ s/[^a-zA-Z]//g;
      if ($BibTeXKeysAsAuthorYear == 0) {
	$key .= $art->{'PMID'};
      }
    } else {
      $key = $art->{'PMID'};
    }
  } else {
    $key=$art->{'PMID'};
  }

  if (defined $author) {
    push @strl, "author = {$author}";
  }

  $elem = $art->{'TI'};
  if (defined $elem) {
    $elem =~ s/%/\\%/g;
    if ($RemovedTitlePeriod) {
      $elem =~ s/\.\s*$//;	# Strip away a "." at the end of the title, and possible trailing space.
    }
    $elem =~ s/(\w*[A-Z][A-Z]+\w*)/{$1}/g; # Protect capitalized words
    push @strl, "title = {$elem}";
  }

  $elem = $art->{'TA'};
  if (defined $elem) {
    push @strl, "journal = {$elem}";
  }

  $elem = $art->{'VI'};
  if (defined $elem) {
    push @strl, "volume = {$elem}";
  }

  $elem = $art->{'IP'};
  if (defined $elem) {
    push @strl, "number = {$elem}";
  }

  $elem = $art->{'DP'};		# Date published, typically "1997 Dec"?
  my ($year, $month);
  if (defined $elem) {
    if ($elem =~ /(\d\d\d\d)\s(\w\w\w)/) {
      $year = $1;
      $month = $2;
      push @strl, "year = {$year}";
      push @strl, "month = {$month}";
    } else {
      $year = $elem;
      push @strl, "year = {$year}";
    }
    if ($BibTeXKeysAsAuthorYear == 1) {
      $key .= $year;
    } elsif ($BibTeXKeysAsAuthorYear == 2) {
      $key .= '-' . substr($year, 2, 2);
    }
  }

  $elem = $art->{'PG'};
  if (defined $elem) {
    my ($from, $to);
    if ($elem =~/^(\d+)-(\d+)$/) {
      $from = $1;
      $to = $2;
      if ($to < $from) {	# Sometimes 474-88 or similar
	$to = substr($from, 0, -length($to)) . $to;
      }
      push @strl, "pages = {$from-$to}";
    } else {			# Don't try to be intelligent about "RESEARCH003" and such
      push @strl, "pages = {$elem}";
    }
  }
  push @strl, 'pmid = {' . $art->{'PMID'} . '}';


  $elem = $art->{'AID'};
  if (defined $elem) {
    foreach my $e (@$elem) {
      if ($e =~ m/\s*(\S+)\s+\[doi\]\s*$/) {
	push @strl, "doi = {$1}";
      }
    }
  }

  if ($IncludeURLInBibTeX) {
    push @strl, 'url  = {' . $art->{'PubMedURL'} . '}';
  }

  $elem = $art->{'AB'};
  if (defined $elem) {
#    $elem =~ /((\S+\s+){5})\S+/;
#    print STDERR "'$1'\n";
#    $elem =~ s/((\S+\s+){9}\S+\s+)/$1\n/g;
    $elem =~ s/%/\\%/g;		# Percentage signs are comments in TeX
    $elem =~ s/((ftp|http|https):\/\/(\w+\.)+\w+(:\d+)?(\/\S+)*)/\\verb+$1+/g;
    $elem =~ s/((\S|\s){60}\s*\S+)\s+/$1\n/g;
    push @strl, "abstract = {$elem}";
  }

  return "\@article{$key,\n\t" . join(",\n\t", @strl) . "\n}\n";
}

#
## Interpret Medline author field for conversion to BibTeX
#
# Contributed by Einar A Rödland
#
sub interpret_author {
  my $au=shift @_;
  my $warning='';
  # Remove double initials of type X X (Phys.Rev.)

  if ($au =~ m/\{.+\}/) {
    return $a, '';		# Protected string
  }
  if ($au =~ s/\s([A-Z])\s\1\b/ $1/) {
    $warning .= "Removing double occurance of initial $1 to make $au; this is a problem with several Phys.Rev. citations. \n";
  }
  #
  if ( $au=~/^et[\s\.]al\.?$/i ) {
    return "others";
  } elsif ( $au=~/^([a-zA-Z\-\'\s]*?)(\s+(([A-Z][a-z]?)+)(\s+(\S*[a-z]\S*|JR|SR))?)?$/ ) {
    my @name=($1,$3,$6);
    if ($name[0]=~s/([A-Z])([A-Z]+)/$1\L$2\E/g ) {
      $warning .= "Recapitalizing name from capital letters into '$name[0]'. \n";
    }
    if (defined $name[1]) {
      $name[1]=~s/([A-Z][a-z]?)/$&\./g;
    }
    if (defined $name[2]) {
      $name[2]=~s/([A-Z][a-z]+)$/$&\./g;
      return $name[0].", ".$name[2].", ".$name[1],$warning;
    } elsif ($name[1]) {
      return $name[0].", ".$name[1],$warning;
    } else {
      return $name[0],$warning;
    }
  } else {
    $warning='Could not interpret name "'.$au.'".';
    return $au,$warning;
  }
}


sub remove_protection {
  $_ =~ s/^:protect://;
  return $_;
}

#
# In:  A ref to a hash with article info, Medline based
# Out: A text string
#
sub make_text_citation {
  my $art=shift @_;
  my $str='';

  my $elem = $art->{'AU'};	# Author
  if (defined $elem) {
    @l = map(remove_protection, @$elem);

    my $astr;
    if ($MaxNAuthors != 0 && scalar(@l) > $MaxNAuthors) {
      $astr = $l[0] . ' et al';
    } else {
      $astr = join(', ', @l);
    }
    $str .= $astr;
  }

  $elem = $art->{'DP'};		# Date published, typically "1997 Dec"?
  my ($year, $month);
  if (defined $elem) {
    if ($elem =~ /(\d\d\d\d)\s(\w\w\w)/) {
      $year = $1;
      $month = $2;
    } else {
      $year = $elem;
    }
    $str .= " ($year) ";
  }

  $elem = $art->{'TI'};		# Title
  if (defined $elem) {
    $str .= "\"$elem\"";
  }

  $elem = $art->{'TA'};		# Journal
  if (defined $elem) {
    $str .= " $elem";
  }

  $elem = $art->{'VI'};		# Volume
  if (defined $elem) {
    $str .= " $elem";
  }

  $elem = $art->{'IP'};		# Issue
  if (defined $elem) {
    $str .= "($elem)";
  }

  $elem = $art->{'PG'};		# Pages
  my ($from, $to);
  if (defined $elem) {
    if ($elem =~ /(\d+)-(\d+)/) {
      $from = $1;
      $to = $2;
      if (length($from) > length($to)) {
	$to = substr($from, 0, -length($to)) . $to;
      }
      $str .= ", $from-$to";
    } else {
      $str .= ", $elem";
    }
  }

  return $str;
}




#
# In:  Article hash
# Out: Possible email address found in AD (affiliation) field. Empty string if
#      no email address.
sub look_for_email_address {
  my $art = shift @_;

  if (exists $art->{'AD'}) {
    my $ad = $art->{'AD'};
    if ($ad =~ m/(\W\S*@(\S+\.)+\w{2,3})/) {
      return $1;
    }
  }
  return '';
}




#
# In:  A ref to a hash with article info, Medline based
# Out: An HTML string
#
sub make_html_citation {
  my $art=shift @_;
  my $str='';

  my $elem = $art->{'AU'};	# Author
  if (defined $elem) {
    @l = map(remove_protection, @$elem);
    my $astr = join(', ', @l);
#    if (length($astr) > $MaxAuthorStringLength) {
    if ($MaxNAuthors != 0 && scalar(@l) > $MaxNAuthors) {
      $astr = $l[0] . CGI::em(' et al');;
    }
    # See if there is an email for first author.
    my $emailaddress = look_for_email_address($art);
    if (length($emailaddress) > 0) {
      $str .= CGI::a({-class => 'authoremail',
		      -href => "mailto:$emailaddress"},
		     CGI::strong($astr));
    } else {
      $str .= CGI::strong($astr);
    }
  }
#  print STDERR "\n'$str'\n";
  $elem = $art->{'DP'};		# Date published, typically "1997 Dec"?
  my ($year, $month);
  if (defined $elem) {
    if ($elem =~ /(\d\d\d\d)\s(\w\w\w)/) {
      $year = $1;
      $month = $2;
    } else {
      $year = $elem;
    }
    $str .= " ($year) ";
  }

  $elem = $art->{'TI'};		# Title
  if (defined $elem) {
    my $title = CGI::em($elem);
    if (exists $art->{'URLS'}) {
      $title = CGI::span({-class => 'articleurl'},
			 CGI::a({-href => $art->{'URLS'}}, $title));
    } elsif (exists $art->{'URLF'}) {
      $title = CGI::span({-class => 'articleurl'},
			 CGI::a({-href => $art->{'URLF'}}, $title));
    } elsif (exists $art->{'PubMedURL'}) {
      $title = CGI::a({-href => $art->{'PubMedURL'}},
		      $title);
    }
    $str .= $title;
  }

  $elem = $art->{'TA'};		# Journal
  if (defined $elem) {
    $elem =~ s/ /&nbsp;/g;
    $str .= " $elem";
  }

  $elem = $art->{'VI'};		# Volume
  if (defined $elem) {
    $str .= " $elem";
  }

  $elem = $art->{'IP'};		# Issue
  if (defined $elem) {
    $str .= "($elem)";
  }

  $elem = $art->{'PG'};		# Pages
  my ($from, $to);
  if (defined $elem) {
    if ($elem =~ /(\d+)-(\d+)/) {
      $from = $1;
      $to = substr($from, 0, -length($2)) . $2;
      $str .= ", $from&#8212;$to";
    } else {
      $str .= ", $elem";
    }
  }

  return $str;
}





# In:  Button string, button URL, new-frame-indicator (same frame if undef)
# Out: Button HTML
sub article_button {
  my ($bstr, $url, $newframe) = @_;
  my $linkdata = {-href => $url};

  if (defined $newframe) {
    $linkdata->{'-target'} = '_blank';
  }
  my $html = CGI::span({-class => 'articlebutton',
			-id => "${bstr}Button"},
		       CGI::a($linkdata, "&gt;$bstr"));
  return $html;
}





#
# In:  A ref to a hash with article info, Medline based
# Out: An HTML string
#
sub art2html {
  my ($art, $dodrop) = @_;
  my $str='';

  $str = make_html_citation($art);

  my $pmid = $art->{'PMID'};

  my $remove_button = '';
  if (defined $dodrop) {
    $q->param('mode', 'Drop');
    $q->param('victim', $pmid);
    $remove_button = CGI::span({-class => 'articlebutton',
				   -id => 'RemoveButton'},
				  CGI::a({-href => $q->self_url}, 'Drop!'));
    $q->delete('victim');
  }

  my $pubmedlink = article_button('PubMed',
				  make_pubmed_url($pmid),
				  'true');
  my $searchlink = article_button('WebSearch',
				  $q->url(-relative=>1) . "?mode=websearchcomposer&id=$pmid",
				  'true');
  $q->param('mode', 'bibsearchcomposer');
  my $bibliosearchlink = article_button('BibSearch',
					$q->self_url . "&template=$pmid",
					undef);
  my $bibtexlink = article_button('BibTeX',
				  $q->url(-relative=>1) . "?mode=bibtex&id=$pmid",
				  'true');
  my $trawlerlink = article_button('Trawler',
				   "$TrawlerCGIUrl/trawler?mode=import&pmids=$pmid",
				     undef);
  my $emaillink = article_button('Email',
				  make_email_url($pmid),
				  undef);
  $q->delete('mode');
  my $links = CGI::div({-class => 'articlelinks'},
		       $remove_button . "&nbsp;&nbsp;&nbsp;" .
		       $bibtexlink . "&nbsp;" .
		       $pubmedlink . "&nbsp;" .
		       $searchlink . "&nbsp;" .
		       $bibliosearchlink . "&nbsp;" .
		       $emaillink . "&nbsp;" .
		       $trawlerlink);
 $str .= $links;
#   my $links = CGI::table({-class => 'table.links'},
# 			 CGI::Tr(CGI::td($pubmedlink),
# 				 CGI::td($searchlink),
# 				 CGI::td($bibliosearchlink),
# 				 CGI::td($bibtexlink)));
#   $str = $links . $str;
  return $str;
}
