#! perl

use v5.36;
use Object::Pad;

class Weenect::Connect;

use LWP::UserAgent;
use HTTP::Request::Common;
use JSON::PP;

field $json;
field $ua;

field $auth :mutator;
field $debug :mutator;
field $cache :mutator;

ADJUST {
    $json = JSON::PP->new;
    $ua = LWP::UserAgent->new;
    $ua->agent("Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/119.0");
    # $ua->default_header( );
};

method get_endpoint( $u = undef ) {
    my $url = "https://apiv4.weenect.com/v4";
    $url .= "/" . $u if defined $u;
    $url;
}

method request( $path, $keys = {} ) {
    my $u = $self->get_endpoint($path);

    my $req;
    my @common =
      ( Accept => "application/json, text/plain, */*",
	Origin => "https://my.weenect.com",
	Referer => "https://my.weenect.com",
	"x-app-version" => "0.1.0",
	"x-app-user-id" => "",
	"x-app-type" => "userspace",
	DNT => 1,
      );
    push( @common, Authorization => "JWT ".$auth->access_token ) if $auth;

    if ( $keys->{Content} ) {
	my $content = delete $keys->{Content};
	$content = $json->encode($content) if ref($content);
	$req = HTTP::Request::Common::POST
	  ( $u,
	    @common,
	    Content_Type => "application/json",
	    Content => $content,
	    %$keys
	  );
    }
    else {
	$req = HTTP::Request::Common::GET
	  ( $u,
	    @common,
	    %$keys
	  );
    }
    p($req) if $debug;
    my $res = $ua->request($req); # res1.json.raw
    unless ( $res->is_success ) {
	p($res) if $debug;
	return;
    }

    return $json->decode( $res->decoded_content );
}

1;
