package Globals;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(
$debug

$Trawler
$TrawlerStyleSheet

$BiblioStyleSheet
$BiblioLogoURL

$TrawlerBaseUrl
$TrawlerCGIUrl
$TrawlerBinPath
$TrawlerDocPath
$TrawlerImageDir

$TrawlerUserDir
$CookieName
$CookieExpiration
$AttractorURL

$Maintainer
$MaintainerEmail

$SvmLearnExecutable
$SvmClassifyExecutable

$Entrez
$Google
$ResearchIndex

$Biblio
$BiblioUrl
$MaxNSearchWords

$MaxAuthorStringLength
$DefaultInclusionSize
$MaxNSearchHits
$MaxCommentSize
$MaxSetnameSize
$MaxNViewedArticles
$DefaultNArticles
$SmallestAttractorRank
);


### Important Variables Defining the Site ###
# Trawler URLs:
#$TrawlerBaseUrl       = 'http://genelynx.org';
#$TrawlerBinPath       = '/home/httpd/cgi-bin';
#$TrawlerDocPath       = '/home/httpd/trawler';
#$TrawlerImageDir      = "$TrawlerBaseUrl/trawler";

$TrawlerBaseUrl       = 'http://babbage.cgb.ki.se/trawler';
$TrawlerCGIUrl        = 'http://babbage.cgb.ki.se/cgi-bin';
$TrawlerBinPath       = '/usr/local/apache/cgi-bin';
$TrawlerDocPath       = '/usr/local/apache/htdocs/trawler';
$TrawlerImageDir      = "$TrawlerBaseUrl";

# Site independent?
$TrawlerUserDir       = "$TrawlerDocPath/Users";
$CookieName           = 'TrawlerUser';
$CookieExpiration     = '+1M';
$AttractorURL         = "$TrawlerCGIUrl/attractor";

# The default number of articles to show in a display.
$DefaultNArticles     = 20;

# Who to email when things break down:
$Maintainer           = 'Lars Arvestad';
$MaintainerEmail      =  'Lars.Arvestad@cgb.ki.se';

# The SVM executables with full path
$SvmLearnExecutable   = '/usr/bin/svm_learn';
$SvmClassifyExecutable= '/usr/bin/svm_classify';
#$SvmLearnExecutable   = '/home/arve/bin/svm_learn';
#$SvmClassifyExecutable= '/home/arve/bin/svm_classify';


# Debugging? No if 'undef'!
#$debug=undef;
$debug                = 'true';

# The actual name...
$Trawler              = 'Trawler';

# Where to find the style sheet:
#$TrawlerStyleSheet    = '/trawler/trawler.css';
$TrawlerStyleSheet    = 'http://genelynx.org/trawler/trawler.css';
#$BiblioStyleSheet     = 'http://genelynx.org/biblio/biblio.css';
$BiblioStyleSheet     = 'http://babbage.cgb.ki.se/biblio/biblio.css';
$BiblioLogoURL        = 'http://babbage.cgb.ki.se/biblio/manual/bibliologo-150.png';

# Where to find PubMed:
$Entrez               = 'http://www.ncbi.nlm.nih.gov/entrez';

# Search engine URLs
$Google = 'http://www.google.com/search';
$ResearchIndex = 'http://citeseer.nj.nec.com/cs';

# How to address Biblio page:
$Biblio               = 'Biblio';
$BiblioUrl            = 'http://genelynx.org/cgi-bin/biblio';
$MaxNSearchWords      = 20;

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

