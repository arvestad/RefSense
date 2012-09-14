package Words;
require Exporter;

use Globals;
use Porter;

@ISA = qw(Exporter);
@EXPORT = qw(get_word_freq
	     get_word_counts
	     article_update_word_count
	     update_word_count
	     compute_idf
	     medline_parts_hash
	    );
$VERSION = 1.0;

# Global vars
%stop_words = (
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
);

1;				# This is silly, but necessary for perl.

# In:  Ref to hash and a word w, and a word prefix for word tagging
# Out: 1 if w was added to the hash and 0 otherwise
#
# If w is in the hash, the count is updated, otherwise it is inserted
# and count is set to 1. If the word is a stop word or less than
# 3 characters long it is discarded. Capitalization is removed.
sub update_word_count {
  my ($words, $str, $tag) = @_;

#  print STDERR "'$str' = ";
  $str = lc($str);
  my $len = length($str);
  if ($len > 2 && !exists $stop_words{$str}) {
    if ($UseStemming) {
      $str = porter($str);
    }

    if ($tag ne '') {
      $str = "$tag:$str";
    }
#    print STDERR "'$str'\n";
    if (exists $words->{$str}) {
      $words->{$str} += 1;
    } else {
      $words->{$str} = 1;
    }
  }
}

# In:  . A hash PMID -> MedLine entry,
#        and a hash word -> prob that defines the wordlist and
#        gives prior probabilities. Undef means 'do not use'.
#      . A Dirichlet prior is assumed and a mean posterior
#        estimate is computed.
#      . Third parameter is the minimum number of occurances for the
#        word to be considered as part of the vocabulary.
#      . Hash determining what parts of the entry to use.
# Out: Ref to hash word -> frequency
sub get_word_freq {
  my ($arts, $prior, $minoccurances, $what) = @_;
  my %wh = ();

  foreach $id (keys %$arts) {
    article_update_word_count($arts->{$id}, \%wh, $what);
  }

  if ($minoccurances > 1) {
    foreach my $w (keys %wh) {
      if ($wh{$w} < $minoccurances) {
	delete $wh{$w};
      }
    }
  }

  my $count = 0;		# Total word count
  if (defined $prior) {
    my %probs = ();
    while (my ($w, $pri) = each %$prior) {
      if (exists $wh{$w}) {
	$probs{$w} = $wh{$w} + $pri; # $n_i + \alpha q_i$
	$count += $wh{$w};
      } else {
	$probs{$w} = $pri; # $0 + \alpha q_i$
      }
    }
    while (my ($w, $n) = each %probs) {
      $probs{$w} = $n / ($count +1); # $\over{n_i + \alpha q_i}{n+\alpha}$
    }
    return \%probs;

  } else {
    while (my ($w, $n) = each %wh) {
      $count += $n;		# $n_i$
    }
    while (my ($w, $n) = each %wh) {
      $wh{$w} = $n / $count;	# $n_i / n$
    }
    return \%wh;
  }
}


# In:  A MedLine entry hash, i.e., key -> string, key can be e.g. 'AU';
#      A hash word -> count to update
#      Hash determining what parts of the entry to use.
# Out:
sub article_update_word_count {
  my ($art, $wh, $what) = @_;
  my $words;

  foreach my $part (keys %$what) {
    if (exists $art->{$part}) {
      my $elem = $art->{$part};
      if (defined $elem) {
	if ($part eq 'AB' || $part eq 'TI') { # Might need to extend this to other string elements
	  $words = [$elem];
	} else {
	  $words = $elem;
	}
	foreach my $w (@$words) {
	  foreach my $str (split(/[^\w\d]+/, $w)) {
	    if ($part eq 'AB') {
	      update_word_count($wh, $str, '');
	    } else {
	      update_word_count($wh, $str, $part);
	    }
	  }
	}
      }
    }
  }
}


# In:  A hash PMID -> medline entry hash, and a hash determining what 
#      parts of the entry to use. 
# Out: A hash with word -> count of word in entry
#
# Joachim's SVM setup uses wordcounts rather than word frequencies.
sub get_word_counts {
  my ($arts, $what) = @_;
  my %ah = ();

  foreach $id (keys %$arts) {
    my %words = ();
    my $count = 0;

    my $art = $arts->{$id};

    article_update_word_count($art, \%words, $what);
    $ah{$id} = \%words;
  }
  return \%ah;
}




# In:  Two hash refs with words from positive examples and
#      negative examples, respectively
# Out: A hash word -> Inverse Document frequency
sub compute_idf {
  my ($poswords, $negwords) = @_;
  my $ndocs = scalar(keys %$poswords) + scalar(keys %$negwords);
  my %wh = ();

  # For each word, count how many documents it appears in
  foreach $pmid (keys %$poswords) {
#    print STDERR "+ $pmid\n";
    my $h = $poswords->{$pmid};
    foreach $w (keys %$h) {
#      print STDERR "'$w'\n";
      if (exists $wh{$w}) {
	$wh{$w} += 1;
      } else {
	$wh{$w} = 1;
      }
    }
  }
  foreach $pmid (keys %$negwords) {
#    print STDERR "- $pmid\n";
    my $h = $negwords->{$pmid};
    foreach $w (keys %$h) {
      if (exists $wh{$w}) {
	$wh{$w} += 1;
      } else {
	$wh{$w} = 1;
      }
    }
  }

  # Compute actual IDF, but remove utterly uninformative words

  foreach $w (keys %wh) {
    if ($ndocs == $wh{$w}) {
#      print STDERR "\t$w removed";
      delete $wh{$w};
    } else {
      $wh{$w} = log($ndocs / $wh{$w});
#      print STDERR "\tIDF($w) = ", $wh{$w}, "\n";
    }
  }

  return \%wh;
}


# In:  Array ref of Medline entry elements to use
# Out: A hash ref of same data.
sub medline_parts_hash {
  my $what = shift;
  my $that;

  if (!defined $what) {
    $that = {'TI' => undef, 'AB' => undef, 'MH' => undef};
  } else {
    $that = {};
    foreach $mh (@$what) {
      $that->{$mh} = undef;
    }
  }
  return $that;
}

