package Globals;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(
$debug

$BiblioStyleSheet
$BiblioLogoURL

$Maintainer
$MaintainerEmail

$Entrez
$Google
$Scholar
$ResearchIndex
$Connotea
$ConnoteaAddDOI

$Biblio
$BiblioUrl
$MaxNSearchWords

$BibTeXKeysAsAuthorYear
$IncludeURLInBibTeX
$RemoveTitlePeriod
$MaxNAuthors
$MaxAuthorStringLength
$DefaultInclusionSize
$MaxNSearchHits
$MaxCommentSize
$MaxSetnameSize
$MaxNViewedArticles
$DefaultNArticles
$SmallestAttractorRank
$UseStemming
);

1;

### Important Variables Defining the Site ###

# The default number of articles to show in a display.
$DefaultNArticles     = 100;

# Who to email when things break down:
$Maintainer           = 'Lars Arvestad';
$MaintainerEmail      =  'arve@csc.kth.se';


# Debugging? No if 'undef'!
#$debug=undef;
$debug                = 'true';

#$BiblioStyleSheet     = 'http://genelynx.org/biblio/biblio.css';
$BiblioStyleSheet     = 'http://www.sbc.su.se/~arve/refsense/biblio.css';
$BiblioLogoURL        = 'http://www.sbc.su.se/~arve/refsense/manual/refsense.png';

# Where to find PubMed:
$Entrez               = 'http://www.ncbi.nlm.nih.gov/entrez';

# Search engine URLs
$Google = 'http://www.google.com/search';
$Scholar = 'http://scholar.google.com/scholar';
$ResearchIndex = 'http://citeseer.nj.nec.com/cs';

# Connotea related
$Connotea = 'http://www.connotea.org/';
$ConnoteaAddDOI = 'add?continue=return\&uri=http://dx.doi.org/';
# Not used:
#$ConnoteaAddURL = 'add?continue=return\&uri=';

# How to address Biblio page:
$Biblio               = 'RefSense';
$BiblioUrl            = 'http://www.sbc.su.se/~arve/refsense/';
$MaxNSearchWords      = 20;


# Set BibTeX keys to, e.g., Arvestad03 instead of Arvestad853289834.
# Styles:
#   0      Arvestad853289834
#   1      Arvestad2003
#   2      Arvestad-03       a.k.a. "Ali mode"
$BibTeXKeysAsAuthorYear = 0;

# Also show the URL field
$IncludeURLInBibTeX = 0;

#
$RemoveTitlePeriod = 1;

# How many authors to display without using "et al",
# supercedes "MaxAuthorStringLength" below.
$MaxNAuthors = 3;

# This determines how long the author string is before it is truncated to
# first author followed by "et al".
$MaxAuthorStringLength= 70;

# The number of articles to include when using PubMed's related articles.
$DefaultInclusionSize = 20;

# The maximum number of returned hits in PubMed searches:
$MaxNSearchHits       = 100;

# How many characters do we allow for set names and set comments?
$MaxCommentSize       = 1024;
$MaxSetnameSize       = 32;

# We put a limit on the number of articles shown at one time
$MaxNViewedArticles   = 100;

# To be sure to put an article last in an attractor ranking,
# use this rank value.
$SmallestAttractorRank = -536870912;

# Decide whether word stemming should be used or not.
$UseStemming = 0;



1;
