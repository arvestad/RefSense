package Globals;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(
$debug

$BiblioStyleSheet
$BiblioLogoURL
$article_logo

$Maintainer
$MaintainerEmail

$Entrez
$Google
$Scholar
$Connotea
$ResearchIndex

$Biblio
$BiblioUrl
$MaxNSearchWords

$BibTeXKeysAsAuthorYear
$IncludeURLInBibTeX
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
$BiblioStyleSheet     = 'http://refsense.sbc.su.se/biblio.css';
$BiblioLogoURL        = 'http://refsense.sbc.su.se/man/refsense.png';
$article_logo         = 'http://refsense.sbc.su.se/man/refsensebutton.png';

# Where to find PubMed etc:
$Entrez               = 'http://www.ncbi.nlm.nih.gov/entrez';
$Connotea             = 'http://www.connotea.org';

# Search engine URLs
$Google = 'http://www.google.com/search';
$Scholar = 'http://scholar.google.com/scholar';
$ResearchIndex = 'http://citeseer.nj.nec.com/cs';

# How to address Biblio page:
$Biblio               = 'RefSense';
$BiblioUrl            = 'http://refsense.sbc.su.se';
$MaxNSearchWords      = 20;


# Set BibTeX keys to, e.g., Arvestad03 instead of Arvestad853289834.
$BibTeXKeysAsAuthorYear = 0;

# Also show the URL field
$IncludeURLInBibTeX = 0;

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
