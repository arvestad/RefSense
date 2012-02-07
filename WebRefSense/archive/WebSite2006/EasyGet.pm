package EasyGet;
require Exporter;

use CGI;
use LWP;

@ISA = qw(Exporter);
@EXPORT = qw(easyget);
$VERSION = 1.0;

sub easyget {
  my $url = shift @_;
  my $ua = LWP::UserAgent->new;
  my $req = HTTP::Request->new(GET => $url);
  my $res = $ua->request($req);

#  print STDERR "The URL:\t$url\n";

  if ($res->is_success) {
    return $res->content;
  } else {
    print STDERR "EasyGet error: " . $res->status_line . "\n";
    print STDERR "The URL:\t$url\n";
    print CGI::header()
      . CGI::start_html()
      . "Retrieval error: "
      . $res->status_line
      . "\n"
      . CGI::end_html();
    exit 0;
  }
}
