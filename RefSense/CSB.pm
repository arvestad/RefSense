package CSB;
require Exporter;

use EasyGet;
use BibCache;

@ISA = qw(Exporter);
@EXPORT = ('csb_query',
	   'csb_fetch',
);

$VERSION = 1.0;

### URL:s ################################################################################
# Shared URL prefix:
my $csb_base_url   = 'http://liinwww.ira.uka.de';
my $csb_simple_url = "$csb_base_url/searchbib/index?";
my $csb_adv_url    = "$csb_base_url/waisbib?";


### Functions ############################################################################

# Func:  csb_query
#
# In:  A hash containing the building blocks of the search
# Out: A list of ids. Results are also cached!
#
my %def_str = ('ty' => 'Any',	# article,inproceedings,techreport,book,phdthesis,manual
	       'au_i' => 'exact', # phonetic
	       'stemming' => 'on', # off
	       'maxhits' => '40', # 10,40,100,170 Why only these?
	       'directget' => '1', # 0. A '1' means return bibtex items
	       'convert' => 'bibtex', # Important: don't change.
	       'sortmode' => 'date', # score
	       'compress' => undef, # on. I assume we cannot handle compression in general...
	      );
sub csb_query {

}
