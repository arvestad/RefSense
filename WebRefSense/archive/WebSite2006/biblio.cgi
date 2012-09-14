#! /usr/bin/perl -wT

use URI::Escape;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
$CGI::POST_MAX=1024 * 100;	# max 100K posts

delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};
$ENV{PERL5LIB} = '/home/arve/public_html/refsense';
$ENV{PATH} = '';

use lib '/home/arve/public_html/refsense';
use PubMed;
use PMCache;
use Citation;


use Globals;
$debug=undef;

# For ref persistence
my $BiblioCookieName = 'RefSenseData';

# Take an article into a form to compose a web search
my $common_words = {
		    'a' => undef,
		    'about' => undef,
		    'above' => undef,
		    'across' => undef,
		    'after' => undef,
		    'afterwards' => undef,
		    'again' => undef,
		    'against' => undef,
		    'all' => undef,
		    'almost' => undef,
		    'alone' => undef,
		    'along' => undef,
		    'already' => undef,
		    'also' => undef,
		    'although' => undef,
		    'always' => undef,
		    'am' => undef,
		    'among' => undef,
		    'amongst' => undef,
		    'amoungst' => undef,
		    'amount' => undef,
		    'an' => undef,
		    'and' => undef,
		    'another' => undef,
		    'any' => undef,
		    'anyhow' => undef,
		    'anyone' => undef,
		    'anything' => undef,
		    'anyway' => undef,
		    'anywhere' => undef,
		    'are' => undef,
		    'around' => undef,
		    'as' => undef,
		    'at' => undef,
		    'back' => undef,
		    'be' => undef,
		    'became' => undef,
		    'because' => undef,
		    'become' => undef,
		    'becomes' => undef,
		    'becoming' => undef,
		    'been' => undef,
		    'before' => undef,
		    'beforehand' => undef,
		    'behind' => undef,
		    'being' => undef,
		    'below' => undef,
		    'beside' => undef,
		    'besides' => undef,
		    'between' => undef,
		    'beyond' => undef,
		    'bill' => undef,
		    'both' => undef,
		    'bottom' => undef,
		    'but' => undef,
		    'by' => undef,
		    'call' => undef,
		    'can' => undef,
		    'cannot' => undef,
		    'cant' => undef,
		    'co' => undef,
		    'computer' => undef,
		    'con' => undef,
		    'could' => undef,
		    'couldnt' => undef,
		    'cry' => undef,
		    'de' => undef,
		    'describe' => undef,
		    'detail' => undef,
		    'do' => undef,
		    'done' => undef,
		    'down' => undef,
		    'due' => undef,
		    'during' => undef,
		    'each' => undef,
		    'eg' => undef,
		    'eight' => undef,
		    'either' => undef,
		    'eleven' => undef,
		    'else' => undef,
		    'elsewhere' => undef,
		    'empty' => undef,
		    'enough' => undef,
		    'etc' => undef,
		    'even' => undef,
		    'ever' => undef,
		    'every' => undef,
		    'everyone' => undef,
		    'everything' => undef,
		    'everywhere' => undef,
		    'except' => undef,
		    'few' => undef,
		    'fifteen' => undef,
		    'fify' => undef,
		    'fill' => undef,
		    'find' => undef,
		    'fire' => undef,
		    'first' => undef,
		    'five' => undef,
		    'for' => undef,
		    'former' => undef,
		    'formerly' => undef,
		    'forty' => undef,
		    'found' => undef,
		    'four' => undef,
		    'from' => undef,
		    'front' => undef,
		    'full' => undef,
		    'further' => undef,
		    'get' => undef,
		    'give' => undef,
		    'go' => undef,
		    'had' => undef,
		    'has' => undef,
		    'hasnt' => undef,
		    'have' => undef,
		    'he' => undef,
		    'hence' => undef,
		    'her' => undef,
		    'here' => undef,
		    'hereafter' => undef,
		    'hereby' => undef,
		    'herein' => undef,
		    'hereupon' => undef,
		    'hers' => undef,
		    'herself' => undef,
		    'him' => undef,
		    'himself' => undef,
		    'his' => undef,
		    'how' => undef,
		    'however' => undef,
		    'hundred' => undef,
		    'i' => undef,
		    'ie' => undef,
		    'if' => undef,
		    'in' => undef,
		    'inc' => undef,
		    'indeed' => undef,
		    'interest' => undef,
		    'into' => undef,
		    'is' => undef,
		    'it' => undef,
		    'its' => undef,
		    'itself' => undef,
		    'keep' => undef,
		    'last' => undef,
		    'latter' => undef,
		    'latterly' => undef,
		    'least' => undef,
		    'less' => undef,
		    'ltd' => undef,
		    'made' => undef,
		    'many' => undef,
		    'may' => undef,
		    'me' => undef,
		    'meanwhile' => undef,
		    'might' => undef,
		    'mill' => undef,
		    'mine' => undef,
		    'more' => undef,
		    'moreover' => undef,
		    'most' => undef,
		    'mostly' => undef,
		    'move' => undef,
		    'much' => undef,
		    'must' => undef,
		    'my' => undef,
		    'myself' => undef,
		    'name' => undef,
		    'namely' => undef,
		    'neither' => undef,
		    'never' => undef,
		    'nevertheless' => undef,
		    'next' => undef,
		    'nine' => undef,
		    'no' => undef,
		    'nobody' => undef,
		    'none' => undef,
		    'noone' => undef,
		    'nor' => undef,
		    'not' => undef,
		    'nothing' => undef,
		    'now' => undef,
		    'nowhere' => undef,
		    'of' => undef,
		    'off' => undef,
		    'often' => undef,
		    'on' => undef,
		    'once' => undef,
		    'one' => undef,
		    'only' => undef,
		    'onto' => undef,
		    'or' => undef,
		    'other' => undef,
		    'others' => undef,
		    'otherwise' => undef,
		    'our' => undef,
		    'ours' => undef,
		    'ourselves' => undef,
		    'out' => undef,
		    'over' => undef,
		    'own' => undef,
		    'part' => undef,
		    'per' => undef,
		    'perhaps' => undef,
		    'please' => undef,
		    'put' => undef,
		    'rather' => undef,
		    're' => undef,
		    'same' => undef,
		    'see' => undef,
		    'seem' => undef,
		    'seemed' => undef,
		    'seeming' => undef,
		    'seems' => undef,
		    'serious' => undef,
		    'several' => undef,
		    'she' => undef,
		    'should' => undef,
		    'show' => undef,
		    'side' => undef,
		    'since' => undef,
		    'sincere' => undef,
		    'six' => undef,
		    'sixty' => undef,
		    'so' => undef,
		    'some' => undef,
		    'somehow' => undef,
		    'someone' => undef,
		    'something' => undef,
		    'sometime' => undef,
		    'sometimes' => undef,
		    'somewhere' => undef,
		    'still' => undef,
		    'such' => undef,
		    'system' => undef,
		    'take' => undef,
		    'ten' => undef,
		    'than' => undef,
		    'that' => undef,
		    'the' => undef,
		    'their' => undef,
		    'them' => undef,
		    'themselves' => undef,
		    'then' => undef,
		    'thence' => undef,
		    'there' => undef,
		    'thereafter' => undef,
		    'thereby' => undef,
		    'therefore' => undef,
		    'therein' => undef,
		    'thereupon' => undef,
		    'these' => undef,
		    'they' => undef,
		    'thick' => undef,
		    'thin' => undef,
		    'third' => undef,
		    'this' => undef,
		    'those' => undef,
		    'though' => undef,
		    'three' => undef,
		    'through' => undef,
		    'throughout' => undef,
		    'thru' => undef,
		    'thus' => undef,
		    'to' => undef,
		    'together' => undef,
		    'too' => undef,
		    'top' => undef,
		    'toward' => undef,
		    'towards' => undef,
		    'twelve' => undef,
		    'twenty' => undef,
		    'two' => undef,
		    'un' => undef,
		    'under' => undef,
		    'until' => undef,
		    'up' => undef,
		    'upon' => undef,
		    'us' => undef,
		    'very' => undef,
		    'via' => undef,
		    'was' => undef,
		    'we' => undef,
		    'well' => undef,
		    'were' => undef,
		    'what' => undef,
		    'whatever' => undef,
		    'when' => undef,
		    'whence' => undef,
		    'whenever' => undef,
		    'where' => undef,
		    'whereafter' => undef,
		    'whereas' => undef,
		    'whereby' => undef,
		    'wherein' => undef,
		    'whereupon' => undef,
		    'wherever' => undef,
		    'whether' => undef,
		    'which' => undef,
		    'while' => undef,
		    'whither' => undef,
		    'who' => undef,
		    'whoever' => undef,
		    'whole' => undef,
		    'whom' => undef,
		    'whose' => undef,
		    'why' => undef,
		    'will' => undef,
		    'with' => undef,
		    'within' => undef,
		    'without' => undef,
		    'would' => undef,
		    'yet' => undef,
		    'you' => undef,
		    'your' => undef,
		    'yours' => undef,
		    'yourself' => undef,
		    'yourselves' => undef,
		   };

my @journals = ('Choose from this list...',
		'Acad Emerg Med',
		'Acta Anaesthesiol Scand',
		'Acta Crystallogr D Biol Crystallogr',
		'Adv Protein Chem',
		'Altern Lab Anim',
		'Am Heart J',
		'Am J Clin Oncol',
		'Am J Dermatopathol',
		'Am J Psychiatry',
		'Am J Respir Crit Care Med',
		'Anal Chem',
		'Annu Rev Genomics Hum Genet',
		'Antonie Van Leeuwenhoek',
		'APMIS',
		'Appl Environ Microbiol',
		'Arch Pediatr Adolesc Med',
		'Arch Toxicol',
		'Biochemistry',
		'Biochim Biophys Acta',
		'Bioessays',
		'Bioinformatics',
		'Biol Chem Hoppe Seyler',
		'Biomacromolecules',
		'Biometrics',
		'Bioorg Med Chem Lett',
		'Biophys Chem',
		'Blood',
		'Blut',
		'BMC Bioinformatics',
		'BMC Cell Biol',
		'BMC Evol Biol',
		'BMJ',
		'Breast Cancer Res Treat',
		'Br J Cancer',
		'Br J Community Nurs',
		'Br J Dermatol',
		'Br J Gen Pract',
		'Br J Ophthalmol',
		'Cell Mol Life Sci',
		'Chem Biol',
		'Chemistry',
		'Circulation',
		'Clin Endocrinol (Oxf)',
		'Clin Infect Dis',
		'Cochrane Database Syst Rev',
		'Colloids Surf B Biointerfaces',
		'Commentary',
		'Comput Appl Biosci',
		'Curr Biol',
		'Curr Opin Chem Biol',
		'Curr Opin Genet Dev',
		'Cytogenet Cell Genet',
		'Development',
		'Diabetes Care',
		'Diagn Cytopathol',
		'Diagn Microbiol Infect Dis',
		'EMBO J',
		'Environ Sci Technol',
		'Eur J Biochem',
		'Eur J Immunol',
		'Eur J Pain',
		'Eur J Pharmacol',
		'Eur Respir J',
		'Exp Cell Res',
		'Exp Parasitol',
		'Fam Pract',
		'FEBS Lett',
		'Gastrointest Endosc',
		'Gen Comp Endocrinol',
		'Genes Chromosomes Cancer',
		'Genes Dev',
		'Genome Biol',
		'Genome Res',
		'Genomics',
		'Head Neck',
		'Hum Fertil (Camb)',
		'Hum Life Rev',
		'Hum Mol Genet',
		'Intensive Crit Care Nurs',
		'Int J Epidemiol',
		'Int J Mol Med',
		'Int J Radiat Oncol Biol Phys',
		'JAMA',
		'J Am Acad Child Adolesc Psychiatry',
		'J Am Acad Dermatol',
		'J Am Soc Nephrol',
		'J Assoc Acad Minor Phys',
		'J Biol Chem',
		'J Colloid Interface Sci',
		'J Comput Biol',
		'J Emerg Med',
		'J Environ Qual',
		'J Environ Radioact',
		'J Ethnopharmacol',
		'J Forensic Sci',
		'J Gynecol Obstet Biol Reprod (Paris)',
		'J Mol Biol',
		'J Mol Evol',
		'J Mol Graph Model',
		'J Mol Microbiol Biotechnol',
		'J Neurol Neurosurg Psychiatry',
		'JOP',
		'J Org Chem',
		'J Pers',
		'J Pers Soc Psychol',
		'J Vasc Interv Radiol',
		'J Virol',
		'Laryngoscope',
		'Medinfo',
		'Methods Cell Biol',
		'Methods Enzymol',
		'Mil Med',
		'Mol Biol Evol',
		'Mol Cell Biol',
		'Mol Ther',
		'Mycoses',
		'Nat Biotechnol',
		'Nat Genet',
		'Nat Med',
		'Nature',
		'N Engl J Med',
		'Neurology',
		'Neurosci Lett',
		'Nucleic Acids Res',
		'Occup Health Saf',
		'Org Lett',
		'Pediatrics',
		'Pharmacogenetics',
		'Phys Rev E Stat Phys Plasmas Fluids Relat Interdiscip Topics',
		'Phys Rev Lett',
		'Plant Cell',
		'Proc Int Conf Intell Syst Mol Biol',
		'Proc Natl Acad Sci U S A',
		'Protein Eng',
		'Proteins',
		'Protein Sci',
		'Psychon Bull Rev',
		'Q Rev Biophys',
		'Radiol Technol',
		'Schweiz Med Wochenschr',
		'Science',
		'Theor Popul Biol',
		'Trends Biochem Sci',
		'Trends Genet',
		'Virology',
		'Yeast',);


### Main ######################################################################
my $q = new CGI;
my $mode = $q->param('mode');	# What to do: search, view, export et.c.
#my $search = $q->param('Search');
my $BiblioUrl = $q->url();

my $cpmid = $q->cookie(-name => $BiblioCookieName, -path=>'/');
my @pmid = split(/,/, $cpmid);
my @suggestion=();
if (defined $q->param('Keep All')) {
  my @newpmids = split(/,/, $q->param('allnew'));
  @pmid = (@pmid, @newpmids);
  $q->delete('Keep All');
  $q->delete('allnew');
} elsif (defined $q->param('Keep Selected')) {
  my @newpmids = $q->param('pmid');
  @pmid = (@pmid, @newpmids);
  $q->delete('Keep Selected');
  $q->delete('pmid');
} elsif (defined $q->param('refs')) {
  @pmid = split(/,/, $q->param('refs'));
  $q->delete('refs');
} elsif (defined $q->param('suggestion')) {
  @suggestion = $q->param('suggestion');
  $q->delete('suggestion');
  $mode = 'suggestion';
}


if (! defined $mode) {		# First entry
  entry_view($q, \@pmid);
} elsif ($mode eq 'view') {
  simple_view($q, \@pmid);
} elsif ($mode eq 'suggestion') {
  view_suggestion($q, \@suggestion);
} elsif ($mode eq 'search') {
  do_search($q, \@pmid);
} elsif ($mode eq 'websearchcomposer') {
  do_web_search($q, \@pmid);
} elsif ($mode eq 'bibsearchcomposer') {
  compose_bib_search($q);
} elsif ($mode eq 'bibtex' || $mode eq 'text' || $mode eq 'html') {
  present_refs($q, $mode, \@pmid);
} elsif ($mode =~ /Send to (\S+(\s+\S+))!/) {
  send_to_search_engine($q, $1);
} elsif ($mode eq 'clear') {
  @pmid = ();
  $q->delete('pmid');
  simple_view($q, \@pmid);
} elsif ($mode eq 'sort_by_author') {
  simple_view($q, sort_by_author(\@pmid));
} elsif ($mode eq 'sort_by_date') {
  simple_view($q, sort_by_date(\@pmid));
} elsif ($mode eq 'sort_by_journal') {
  simple_view($q, sort_by_journal(\@pmid));
} elsif ($mode eq 'Drop') {
  drop_one($q, \@pmid);
} elsif ($mode eq 'BringToTop') {
  bring_to_top($q, \@pmid);
} else {			# Huh?
  show_params($q);
}

### Subroutines for creating displays #########################################

# View at first entry
sub entry_view {
  my ($q, $pmid) = @_;
  my @urlpmid = $q->param('pmid');
  my $page = '';
  my $body = '';

  if (! @urlpmid) {
    if (scalar(@$pmid) > 0) {
      simple_view($q, $pmid);
      exit 0;
    } else {
      $page .= $q->header;
      $page .= $q->start_html(-title => "$Biblio - Welcome",
			      -meta => {'keywords' => 'biblio,pubmed,bibtex,references,convert,display'},
			      -link => {rel => 'shortcut icon',
					href => $article_logo},
			      -style => {src => $BiblioStyleSheet});
      $body = $q->h1("Welcome to $Biblio")
	. $q->p("Search PubMed through the $Biblio interface!")
          . make_search_form($q);
    }
  } else {
    my $newcookie = $q->cookie(-name => $BiblioCookieName,
			       -path => '/',
			       -value => join(',', @$pmid),
			      -expires => '+1y');
    $page .= $q->header(-cookie => $newcookie);
    $page .= $q->start_html(-title => "$Biblio - Welcome",
			    -meta => {'keywords' => 'biblio,pubmed,bibtex,references,convert,display'},
			    -style => {src => $BiblioStyleSheet});
    $body = $q->h1("Welcome to $Biblio")
          . make_simple_view($q) 
	  . $q->h2('&nbsp;Add references')
	  . make_search_form($q);
  }

  $page .= page_wrapper($q, $body, $pmid);
  $page .= cgi_variables($q);
  $page .= $q->end_html;

  print $page;
}

# Standard view, including search form
sub simple_view {
  my ($q, $pmid) = @_;
  my $page = '';
  my $main = '';

#  print STDERR "Viewing: " . join(', ', @$pmid) . "\n";
  my $newcookie = $q->cookie(-name => $BiblioCookieName,
			     -path => '/',
			     -value => join(',', @$pmid),
			      -expires => '+1y');
  $page .= $q->header(-cookie => $newcookie);
  $page .= $q->start_html(-title => $Biblio,
			  -meta => {'keywords' => 'biblio,pubmed,bibtex,references,convert,display'
				   },
			  -style => {src => $BiblioStyleSheet});

  $main .= make_search_form($q);
  $main .= make_simple_view($q, $pmid);
  $page .= page_wrapper($q, $main, $pmid);
  $page .= cgi_variables($q);
  $page .= $q->end_html;

  print $page;
}

sub view_suggestion {
  my ($q, $suggestion) = @_;
  my $page = $q->header;
  $page .= $q->start_html(-title => "$Biblio - suggestion",
			   -style => {src => $BiblioStyleSheet});
  $page .= pageheader($q);

  print STDERR "SUGGEST\n";

  if (@$suggestion > 0) {
    $page .= $q->h1('List of suggestions');
    $page .= $q->p('Please choose the articles you want to keep in your regular set of articles from the listing below.');
    my $art_h = pm_fetch_pubmed($suggestion);
    $page .= make_article_choice_page($q, $art_h)
  } else {
    $q->div({-class => 'warning'},
	    'No suggestion offered. Please check the URL and try again.');
  }
  $page .= footer();
  $page .= cgi_variables($q);
  $page .= $q->end_html;

  print $page;
}


# View search results and working set of articles
sub do_search {
  my ($q, $pmid) = @_;
  my $page = '';
  my $outerpage = $q->header
    . $q->start_html(-title => "$Biblio - Search results",
		     -style => {src => $BiblioStyleSheet});

  my $narticles = $q->param('narticles');
  my $term = $q->param('term');
  if (!defined $term) {		# "complex" search
    my $authors=$q->param('author');
    my $title=$q->param('title');
    my $journal=$q->param('journal');
    my $journal_choice=$q->param('journal_menu');
    my $year=$q->param('year');

    if (defined $authors) {
      foreach $a (split(/,\s*/, $authors)) {
	$a =~ s/\s+/+/;
	push @termlist, "\"$a\"\[AU\]";
      }
    }
    if (defined $title) {
      foreach $a (split(/[^\w\d]+/, $title)) {
	if (!exists($common_words->{$a})) {
	  push @termlist, "\"$a\"\[TI\]";
	}
      }
    }
    if (defined $journal && length($journal) > 0) {
      $journal =~ s/\s+/+/;
      push @termlist, "\"$journal\"\[TA\]";
    } elsif (defined $journal_choice && $journal_choice ne 'Choose from this list...') {
      push @termlist, "\"$journal_choice\"\[TA\]";
    }
    if (defined $year) {
      if ($year =~ /\d{4}/) {
	push @termlist, "$year\[DP\]";	
      }
    }
    if (scalar(@termlist) == 0) {
      $page .= $q->p('Bad search parameters');
    } else {
      $term = join('+AND+', @termlist);
    }
  }
  my $results = pm_query({'tool' => $Biblio,
			  'dispmax' => $narticles,
			  'term' => $term});
  my $res = pm_extract_pmids($results);
  my $new_pmids = [];
  if (defined $res) {
    $new_pmids = $res->[1];
  }

  if (!defined $new_pmids) {
    $page .= $q->p('Search error!');
  } elsif (scalar(@$new_pmids) == 0) {
    $page .= make_search_form($q);
    $page .= $q->div({-class => 'warning'},
		     "No matching citations found. ($term)");
    $page .= make_simple_view($q, $pmid);
  } else {
    my $arts_h = pm_fetch_pubmed($new_pmids);
    my %labels=();
    foreach $id (@$pmid) {
#      print STDERR "Checking $id";
      if (exists $arts_h->{$id}) {
	delete $arts_h->{$id};
#	print STDERR "Dropped.\n";
      }
    }
    if (scalar(keys  %$arts_h) == 0) {
      $page .= $q->h3('Matching citations found, but you already have them listed.');
      $page .= make_simple_view($q);
    } else {
      $page .= $q->h1('Search results');
      $page .= make_article_choice_page($q, $arts_h);
    }
  }

#  $outerpage .= page_wrapper($q, $page, $pmid);
  $outerpage .= pageheader($q) . $page . footer();
  $outerpage .= cgi_variables($q);
  $outerpage .= $q->end_html;

  print $outerpage;
}


sub make_article_choice_page {
  my ($q, $arts_h) = @_;
  my $page='';
  my %labels=();

  foreach $a (keys %$arts_h) {
    $labels{$a} = art2html($arts_h->{$a}, undef);
  }
  $page .= $q->start_form;
  my $oldescape = $q->autoEscape(undef);
  $page .= $q->checkbox_group(-name => 'pmid',
			      -values=> \%labels,
			      -linebreak=>'true',
			      -labels=>\%labels);
  $q->autoEscape($oldescape);

  $page .= $q->submit(-name => 'Keep Selected');
  $page .= $q->submit(-name => 'Keep All');
  $page .= $q->submit(-name => 'Cancel');
  $page .= $q->hidden('allnew', join(',', keys(%labels)));
  $q->param('mode', 'view');
  $page .= $q->hidden(-name =>'mode');
  $page .= $q->end_form;

  return $page;
}


sub do_web_search {
  my ($q, $pmid) = @_;
  my $main = '';

  my @urlpmid = split(/,/, $q->param('id'));
  if (scalar(@urlpmid) > 0) {
    $pmid = \@urlpmid;
  }


  if (! @$pmid) {
    $main .= $q->h3('No articles no compose the search from!');
    $main .= make_simple_view($q);
  } else {
    # First gather words. We would like author names to be preselected.
    my $art_h = pm_fetch_pubmed($pmid);
    my %auth=();
    my %tit=();
    my %words=();
    my $elem;
    foreach $a (keys %$art_h) {
      my $art = $art_h->{$a};
      $elem = $art->{'AU'};
      if (defined $elem) {
	foreach $author (@$elem) {
	  if ($author =~ /(.+)\s+\S+/) {
	    $author = $1;
	  }
	  $auth{$author} = 1;
	}
      }
      $elem = $art->{'TI'};
      if (defined $elem) {
	foreach $str (split(/[^\w\d]+/, $elem)) {
	  $str = lc($str);
	  if (length($str) > 2
	      && !exists $common_words->{$str}) {
	    $tit{$str} = 1;
	  }
	}
      }
      $elem = $art->{'AB'};
      if (defined $elem) {
	foreach $str (split(/[^\w\d]+/, $elem)) {
	  $str = lc($str);
	  if (length($str) > 2
	      && !exists $common_words->{$str}) {
	    $words{$str} = 1;
	  }
	}
      }
    }
    my @authlist = sort(keys %auth);
    my @titlist = sort(keys %tit);
    my @wordlist = sort(keys %words);

    $main .= $q->h1('Compose web search');
    $main .= $q->p("Choose the words you want to submit to the search engine! Google doesn't want too many words, so $Biblio will keep at most $MaxNSearchWords chosen arbitrarily.");
    $main .= $q->start_form();
    $main .= $q->submit(-name => 'mode',
			-value => 'Send to Google Scholar!');
    $main .= $q->submit(-name => 'mode',
			-value => 'Send to Google!');
    $main .= $q->submit(-name => 'mode',
			-value => 'Send to ResearchIndex!');
    $main .= $q->h3('Authors');
    $main .= $q->checkbox_group(-name => 'searchwords',
				-values => \@authlist,
				-default => \@authlist);
    $main .= $q->h3('Title words');
    $main .= $q->checkbox(-name => 'usealltitlewords',
			  -value => join(',', @titlist),
			  -label => 'Use all title words!');
    $main .= $q->p();
    $main .= $q->checkbox_group(-name => 'searchwords',
				-values => \@titlist);
    $main .= $q->h3('Words in abstract');
    $main .= $q->checkbox_group(-name => 'searchwords',
				-values => \@wordlist);
    $main .= $q->end_form();
  }

  my $page = $q->header 
    . $q->start_html(-title => "$Biblio - Web Search",
		     -style => {src => $BiblioStyleSheet});

#  $page .= page_wrapper($q, $main, $pmid);
  $page .= pageheader($q) . $main . footer();
  $page .= cgi_variables($q);
  $page .= $q->end_html;

  print $page;
}


# Redirect a search request to a web search engine
sub send_to_search_engine {
  my ($q, $searchengine) = @_;
  my @words = $q->param('searchwords');
  my $alltitlewords = $q->param('usealltitlewords');
  my @words2 = ();

  if (! @words && !defined $alltitlewords) {
    show_params($q);
  } else {
    if (defined $alltitlewords) {
      @words2 = split(/,/, $alltitlewords);
    }
    @words = (@words, @words2); 
    if (scalar(@words) > $MaxNSearchWords) {
      @words = @words[0..$MaxNSearchWords-1];
    }
    if ($searchengine eq 'Google') {
      my $url = "$Google?q=" . join('+', @words);
      print $q->redirect(-uri => $url);
    } elsif ($searchengine eq 'Google Scholar') {
      my $url = "$Scholar?q=" . join('+', @words);
      print $q->redirect(-uri => $url);
    } elsif ($searchengine eq 'ResearchIndex') {
      my $url = "$ResearchIndex?q=" . join('+', @words);
      print $q->redirect(-uri => $url);
    }
  }
}


# Show bibtex/text/html for the accumulated articles
# In:  A CGI object
# Out: A page
sub present_refs {
  my ($q, $mode, $pmids) = @_;
  my $bib='';

  my @urlpmid = split(/,/, $q->param('id'));
  if (scalar(@urlpmid) > 0) {
    $pmids = \@urlpmid;
  }

  if (! @$pmids) {
    $bib = "No references to convert yet.\n";
  } else {
    my $art_h = pm_fetch_pubmed($pmids);
#    $bib = $q->start_pre();
    foreach $id (keys %$art_h) {
      if ($mode eq 'bibtex') {
	$bib .= make_bibtex_citation($art_h->{$id}) . "\n";
      } elsif ($mode eq 'text') {
	$bib .= make_text_citation($art_h->{$id}) . "\n";
      } elsif ($mode eq 'html') {
	$bib .= make_html_citation($art_h->{$id}) . "<br>\n";
      }
    }
#    $bib .= $q->end_pre();
  }
  my $page = $q->header(-type => 'text/plain')
           . $bib;
  print $page;
}


# In:  A CGI object
# Out: A HTML for composing a query for PubMed based on a present 
#      article template.
sub compose_bib_search {
  my $q = shift @_;
  my $page = $q->header;
  my $template = $q->param('template');
  my $art_h = pm_fetch_pubmed([$template]);

  $page .= $q->start_html(-title => "$Biblio - Compose a search",
			  -style => {src => $BiblioStyleSheet});
  $page .= page_wrapper($q, $q->h1("Compose a search")
  			    . $q->p('The search fields are filled in with values from the article you chose.')
			. make_search_form($q, $art_h->{$template})
			. $q->p()
			. $q->start_form()
			. $q->submit('Cancel search')
			. $q->end_form
		       );


  $page .= cgi_variables($q);
  $page .= $q->end_html;

  print $page;

}


# For debugging purposes etc
sub show_params {
  my $q = shift @_;
  my @pmid = $q->param('pmid');
  my $page = $q->header . $q->start_html;

  $page .= $q->h1('Parameters');
  $page .= cgi_variables($q);
  $page .= $q->end_html;

  print $page;
}

### Helpers ###################################################################

sub make_search_form {
  my ($q, $art) = @_;
  my $page = "\n";
  my ($authors, $title, $journal, $year) = ('','','','');

  if (defined $art) {
    $authors = join(', ', @{$art->{'AU'}});
    $title = $art->{'TI'};
    $journal = $art->{'TA'};
    $year = $art->{'DP'};
  }

  $page .= $q->start_table({-width => '100%',
#			    -border => '1'
			   });
  # First a simple search system
  $page .= $q->start_form();
  $page .= $q->start_Tr();
  $page .= $q->start_th({-colspan => 6, -align => 'left'}) . "Simple search\n";
  $page .= $q->start_Tr();
  $page .= $q->td("Term ") . "\n";
  $page .= $q->td({-colspan => 3},
		  $q->textfield(-name => 'term',
				-default => $authors,
				-size => '60'));
  $page .= $q->td($q->popup_menu(-name => 'narticles',
				 -values => ['10', '20', '40', '60', '80', '100'],
				 -default => '20'));
  $page .= $q->td($q->submit(-name => 'Search'));
  $page .= $q->end_Tr();
  $q->param('mode', 'search');
  $page .= $q->hidden(-name => 'mode');
#   if (defined $q->param('pmid')) {
#     $page .= $q->hidden(-name => 'pmid', $q->param('pmid'));
#   }
  $page .= $q->end_form;

  # Then an advanced form, more simple than PubMed advanced though
  $page .= $q->start_form()
         . $q->start_Tr()
         . $q->th({-colspan => 6, -align => 'left'},
                  'Complex search') . "\n"
         . "\n" . $q->start_Tr()
         . $q->td('Author(s) ') . "\n"
         . $q->td({-colspan => '3'},
                  $q->textfield(-name => 'author',
                                -default => $authors,
                                -size => '70'))
         . $q->td({-align=>'right'}, 'Year ')
         . $q->td($q->textfield(-name => 'year',
                                  -default => $year,
                                  -size=> '4',
                                  -maxlength=> '4'))
 
         . "\n" . $q->start_Tr()
         . $q->td('Title words ') . "\n"
         . $q->start_td({-colspan => '3'}) . $q->textfield(-name => 'title',
                                                           -default => $title,
                                                           -size => '70')
         . $q->td({-align=>'right'}, 'Max # hits')
         . $q->td($q->popup_menu(-name => 'narticles',
                            -values => ['10', '20', '40', '60', '80', '100'],
                            -default => '20'))
         . "\n" . $q->start_Tr()
         . $q->td('Journal ')
         . $q->td({-colspan=>3},
                  $q->textfield(-name => 'journal',
                                -default => $journal,
                                -size => '30')
                  . ' or '
                  . $q->popup_menu(-name => 'journal_menu',
                                  -values => \@journals,
                                  -default => 'Choose...'));
  $page .= $q->td({-colspan=>2,
                   -align=>'right'}, $q->submit(-name => 'Search'));
  $page .= $q->end_table();
#   if (defined $q->param('pmid')) {
#     $page .= $q->hidden(-name => 'pmid', $q->param('pmid'));
#   }
  $q->param('mode', 'search');
  $page .= $q->hidden(-name => 'mode');
  $page .= $q->end_form . "\n";

  return $page;
}


# Out: A simple listing of accumulated articles
sub make_simple_view {
  my ($q, $pmid) = @_;
  my $main = '';

  if (! @$pmid) {
    $main .= $q->p("No references accumulated yet.\n");
  } else {
    my $narts = scalar(@$pmid);
    $main .= $q->h2("&nbsp;Reference list ($narts citations)");
    my $art_h = pm_fetch_pubmed($pmid);
    $main .= $q->start_table();
    foreach $i (@$pmid) {
      $main .= $q->Tr($q->td(art2html($art_h->{$i}, 'true'))) . "\n";
    }
    $main .= $q->end_table();
  }
  return $main;
}


# Out: The standard page header string
#
sub pageheader {
  my $q = shift @_;
  return $q->div({-class => 'logo'},
		 $q->a({-href => $BiblioUrl}, 
		       $q->img({-src => $BiblioLogoURL,
				-alt => 'Biblio',
			        -border => '0'}))) . $q->br();
}

# Out: The standard page foot string
#
sub footer {
  return "
 <address>
   For bug reports, feature requests, wild praise, et.c., please contact
   <a href=\"mailto:$MaintainerEmail\">$Maintainer</a>
 </address>
";
}

# Out: A string containing HTML for the left side tool links
sub make_toolset {
  my ($q, $pmid) = @_;
  my $bibtexlink = '';
  my $websearchlink = '';
  my $settools='';
  my $exporttools = '';
  my $textlink = '';
  my $thispage = '';
  my $gentools = '';

  if (scalar(@$pmid) > 0) {
    my $pmidstr = join(',', @$pmid);

    $q->param('mode', 'clear');
    my $newsetlink =$q->div({-class => 'meny'},
			    $q->a({-href => $q->self_url}, 'Clear list'));
    $q->param('mode', 'sort_by_date');
    my $datesortlink = $q->div({-class => 'meny'},
			       $q->a({-href => $q->self_url}, 'Sort&nbsp;by&nbsp;date'));
    $q->param('mode', 'sort_by_author');
    my $authorsortlink = $q->div({-class => 'meny'},
			       $q->a({-href => $q->self_url}, 'Sort&nbsp;by&nbsp;authors'));
    $q->param('mode', 'sort_by_journal');
    my $journalsortlink = $q->div({-class => 'meny'},
			       $q->a({-href => $q->self_url}, 'Sort&nbsp;by&nbsp;journal'));
    $gentools = $q->div({-class=>'menyname'}, 'Tools') . "
      $newsetlink
$datesortlink
$authorsortlink
$journalsortlink";

    $q->param('mode', 'bibtex');
    $bibtexlink = $q->div({-class => 'meny'},
			  $q->a({-href => $q->self_url}, 'BibTeX'));

    $q->param('mode', 'text');
    $textlink = $q->div({-class => 'meny'},
			$q->a({-href => $q->self_url}, 'Text'));

    $q->param('mode', 'html');
    $htmllink = $q->div({-class => 'meny'},
			$q->a({-href => $q->self_url}, 'HTML'));

    $thispage = $q->div({-class => 'meny'},
			$q->a({-href => "$BiblioUrl?refs=$pmidstr"},
			      "$Biblio link"));

    $settools = $q->div({-class =>'menyname'}, 'Converters') . "
$bibtexlink
$textlink
$htmllink
$thispage";
# <table><tr><td>$bibtexlink
# <tr><td>$textlink
# <tr><td>$htmllink
# <tr><td>$thispage
# </table>";


#    $pubmedlink = $q->a({-href => make_pubmed_url($pmidstr)},
#			 'PubMed');
    $pubmedlink = $q->div({-class => 'meny'},
			  $q->a({-href => $Entrez . "/query.fcgi?cmd=Retrieve&db=pubmed&dopt=Abstract&list_uids="},
			 'PubMed'));
    $q->param('mode', 'websearchcomposer');
    $websearchlink = $q->div({-class => 'meny'},
			     ($q->a({-href => $q->self_url
				             . "&template=$pmidstr"},
				    'WebSearch')));
    $q->param('mode', 'email');
    $emaillink = $q->div({-class => 'meny'}, 
			 $q->a({-href => make_email_url($pmidstr)},
			       'Email'));

    $exporttools = $q->div({-class =>'menyname'}, 'Export to...')
      . "<table>
           <tr><td>$pubmedlink
           <tr><td>$websearchlink
           <tr><td>$emaillink
         </table>";
  }


  return "\n" 
    . pageheader($q)
    . $gentools
    . $settools
    . $exporttools
    . $q->div({-class =>'menyname'}, 'Information')
    . $q->div({-class => 'meny'},
	      $q->a({-class => 'meny',
		     -href => 'http://www.csc.kth.se/~arve/code/refsense/',
		     }, 'Web site'))
    . $q->div({-class => 'meny'},
	      $q->a({-class => 'meny',
		     -href => 'manual/',
		     -target=> '_blank'}, 'Manual'))
    . $q->div({-class => 'meny'},
	      $q->a({-href => 'http://www.ncbi.nlm.nih.gov/entrez/utils/utils_index.html',
		     -target => '_blank'}, 'Entrez Utilities'));
}

# Wrap a simple page into a frame (table-based) of related links et.c.
# In:  The CGI object and a string with the simple page HTML.
# Out: A string with complex HTML.
sub page_wrapper {
  my ($q, $simple, $pmid) = @_;
  my $page = $q->table({-class => 'layout',
#			-border => '1',
			-width=> '100%'},
			$q->Tr([$q->td({-valign => 'top'},
				       [make_toolset($q, $pmid), $simple]),
				$q->td({-colspan => '2'}, footer())])
		       );
  return $page;
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
    my $astr = join(', ', @$elem);
    if (length($astr) > $MaxAuthorStringLength) {
      $astr = $elem->[0] . ' et al';
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
    if ($elem =~ /(\d+)-(\d)/) {
      $from = $1;
      $to = substr($from, 0, -length($2)) . $2;
      $str .= ", $from--$to";
    } else {
      $str .= ", $elem";
    }
  }

  return $str;
}


#
# In:  A ref to a hash with article info, Medline based
# Out: An HTML string
#
# sub make_html_citation {
#   my $art=shift @_;
#   my $str='';

#   my $elem = $art->{'AU'};	# Author
#   if (defined $elem) {
#     my $astr = join(', ', @$elem);
#     if (length($astr) > $MaxAuthorStringLength) {
#       $astr = $elem->[0] . CGI::em(' et al');;
#     }
#     $str .= CGI::strong($astr);
#   }
# #  print STDERR "\n'$str'\n";
#   $elem = $art->{'DP'};		# Date published, typically "1997 Dec"?
#   my ($year, $month);
#   if (defined $elem) {
#     if ($elem =~ /(\d\d\d\d)\s(\w\w\w)/) {
#       $year = $1;
#       $month = $2;
#     } else {
#       $year = $elem;
#     }
#     $str .= " ($year) ";
#   }

#   $elem = $art->{'TI'};		# Title
#   if (defined $elem) {
#     $str .= CGI::em($elem);
#   }

#   $elem = $art->{'TA'};		# Journal
#   if (defined $elem) {
#     $elem =~ s/ /&nbsp;/;
#     $str .= " $elem";
#   }

#   $elem = $art->{'VI'};		# Volume
#   if (defined $elem) {
#     $str .= " $elem";
#   }

#   $elem = $art->{'IP'};		# Issue
#   if (defined $elem) {
#     $str .= "($elem)";
#   }

#   $elem = $art->{'PG'};		# Pages
#   my ($from, $to);
#   if (defined $elem) {
#     if ($elem =~ /(\d+)-(\d)/) {
#       $from = $1;
#       $to = substr($from, 0, -length($2)) . $2;
#       $str .= ", $from&#8212;$to";
#     } else {
#       $str .= ", $elem";
#     }
#   }

#   return $str;
# }


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

  $str = $q->img({-src => $article_logo,
		  -alt => '-',
		  -border => '0'})
    . '&nbsp;';
  $str .= make_html_citation($art);

  my $pmid = $art->{'PMID'};

  my $remove_button = '';
  if (defined $dodrop) {
    $q->param('mode', 'Drop');
    $q->param('victim', $pmid);
    $remove_button = CGI::span({-class => 'articlebutton',
				   -id => 'RemoveButton'},
				  CGI::a({-href => $q->self_url}, 'Drop!'));

    $q->param('mode', 'BringToTop');
    $to_top_button = CGI::span({-class => 'articlebutton',
				-id => 'ToTopButton'},
			       CGI::a({-href => $q->self_url}, 'To top!'));
    $q->delete('victim');
  }

  my $pubmedURL = $Entrez . "/query.fcgi?cmd=Retrieve&db=pubmed&dopt=Abstract&list_uids=" . $pmid;
  my $doi = '';
  $elem = $art->{'AID'};
  if (defined $elem) {
    if ($elem =~ m/\s*(\S+)\s+\[doi\]\s*$/) {
      $doi = '&uri=' . uri_escape($1);
    }
  }
  my $connotealink = article_button('Connotea',
				   $Connotea . '/add?continue=return&title=' . uri_escape($art->{'TI'} . $doiURL),
				   undef);
  my $pubmedlink = article_button('PubMed',
				  $pubmedURL,
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
  my $emaillink = article_button('Email',
				  make_email_url($pmid),
				  undef);
  $q->delete('mode');
  my $links = CGI::div({-class => 'articlelinks'},
                       $to_top_button .
                       $remove_button . "&nbsp;" .
                       $bibtexlink .
                       $connotealink .
                       $pubmedlink .
                       $searchlink .
                       $bibliosearchlink .
                       $emaillink);
 $str .= $links;
#   my $links = CGI::table({-class => 'table.links'},
# 			 CGI::Tr(CGI::td($pubmedlink),
# 				 CGI::td($searchlink),
# 				 CGI::td($bibliosearchlink),
# 				 CGI::td($bibtexlink)));
#   $str = $links . $str;
  return $str;
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
    if ($elem->[0] =~ /(\S+)(\s*\w*)/) {
      $key=$1 . $art->{'PMID'};
    } else {
      $key=$art->{'PMID'};
    }
    @authorl = ();
    foreach $a (@$elem) {
      if ($a =~ /(\S+(\s\S+)*)\s+(\w+)/) { # Test cases: 10366660 and 11301300
	$lname = $1;
	$initials = $3;
      } elsif ($a =~ /\S+/) {
	$lname = $a;
	$initials = undef;
      }
      if (defined $initials) {
	$initials =~ s/(\w)/$1\. /g;
	push @authorl, "$initials$lname";
      } else {
	push @authorl, "$lname";
      }
    }
    $author = join(' and ', @authorl);
  } else {
    $key=$art->{'PMID'};
  }
  push @strl, "\@article{$key";
  if (defined $author) {
    push @strl, "author = {$author}";
  }

  $elem = $art->{'TI'};
  if (defined $elem) {
    $elem =~ s/%/\\%/g;         
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
      my $year = $1;
      my $month = $2;
      push @strl, "year = {$year}";
      push @strl, "month = {$month}";
    } else {
      my $year = $elem;
      push @strl, "year = {$year}";
    }
  }

  $elem = $art->{'PG'};
  if (defined $elem) {
    my ($from, $to);
    if ($elem =~/^(\d+)-(\d)$/) {
      $from = $1;
      $to = substr($from, 0, -length($2)) . $2;
      push @strl, "pages = {$from-$to}";
    } else {
      push @strl, "pages = {$elem}";
    }
  }

  $elem = $art->{'AB'};
  if (defined $elem) {
#    $elem =~ /((\S+\s+){5})\S+/;
#    print STDERR "'$1'\n";
#    $elem =~ s/((\S+\s+){9}\S+\s+)/$1\n/g;
    $elem =~ s/%/\\%/g;		# Percentage signs are comments in TeX
    $elem =~ s/((ftp|http|https):\/\/(\w+\.)+\w+(:\d+)?(\/\S+)*)/\\verb+$1+/g;
    $elem =~ s/((\S|\s){60}\s*\S+)\s+/$1\n/g;
    push @strl, "annote = {$elem}";
  }

  return join(",\n\t", @strl) . "\n}\n";
}


### Sorting ###

#
#
sub sort_by_author {
  my $pmids = shift;

  my $art_h = pm_fetch_pubmed($pmids);
  my %authors = ();
  foreach my $id (@$pmids) {
    my $a = $art_h->{$id}{'AU'};
    $authors{$id} = join(', ', @$a);
  }
  my @sorted_pmids = sort { $authors{$a} cmp $authors{$b}} @$pmids;
  return \@sorted_pmids;
}

#
#
sub sort_by_journal {
  my $pmids = shift;

  my $art_h = pm_fetch_pubmed($pmids);
  my %journals = ();
  foreach my $id (@$pmids) {
    $journals{$id} = $art_h->{$id}{'TA'};
  }
  my @sorted_pmids = sort { $journals{$a} cmp $journals{$b}} @$pmids;
  return \@sorted_pmids;
}

#
#
my %month_lookup = ('jan'=>'00', 'feb'=>'01', 'mar'=>'02', 'apr'=>'03',
		    'may'=>'04', 'jun'=>'05', 'jul'=>'06', 'aug'=>'07',
		    'sep'=>'08', 'oct'=>'09', 'nov'=>'10', 'dec'=>'11');

sub sort_by_date {
  my $pmids = shift;

  my $art_h = pm_fetch_pubmed($pmids);
  my %dates = ();
  foreach my $id (@$pmids) {
    my $datestr = $art_h->{$id}{'DP'};
    if ($datestr =~ m/(\d\d\d\d)\s*(\w\w\w)/) {
      $datestr = $1 . $month_lookup{lc($2)} . '00';
    } elsif ($datestr =~ m/(\d\d\d\d)\s*(\w\w\w)\s*(\d\d)/) {
      $datestr = $1. $month_lookup{lc($2)} . $3;
    } elsif ($datestr =~ m/(\d\d\d\d)\s*(\w\w\w)\s*(\d)/) {
      $datestr = $1. $month_lookup{lc($2)} . "0$3";
    } else {
      $datestr = '99999999';
    }
    $dates{$id} = $datestr;
  }
  my @sorted_pmids = sort { $dates{$a} <=> $dates{$b}} @$pmids;
  return \@sorted_pmids;
}


### Email ###

sub make_email_url {
  my $pmidstr=shift;
  return "mailto:?Body=$BiblioUrl\?suggestion\=$pmidstr";
}

### Dropping ###
#
#
sub drop_one {
  my ($q, $pmid) = @_;
  my $victim = $q->param('victim');

  my @newpmid = ();
  foreach my $i (@$pmid) {
    if ($i != $victim) {
      push @newpmid, $i;
    }
  }
  $pmid = \@newpmid;
  if (scalar(@newpmid) > 0) {
    simple_view($q, $pmid);
  } else {
    entry_view($q, $pmid);
  }
}

#
#
sub bring_to_top {
  my ($q, $pmid) = @_;
  my $victim = $q->param('victim');

  my @newpmid = ($victim);
  foreach my $i (@$pmid) {
    if ($i != $victim) {
      push @newpmid, $i;
    }
  }
  $pmid = \@newpmid;
  simple_view($q, $pmid);
}

##
# For debugging
sub cgi_variables {
  if (defined $debug) {
    my $q = shift @_;
    $q->Dump();
  }
}

