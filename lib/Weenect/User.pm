#! perl

use v5.36;
use Object::Pad;
use utf8;

class Weenect::User;

use Weenect::Connect;
use Weenect::Classes;

field $api;
field $acct;
field $debug :mutator;

method login( $user = "", $pass = "" ) {
    $api = Weenect::Connect->new;
    $api->debug = $debug;
    my $acct = $self->get_acct( $user, $pass );
    my $res = $api->request( "user/login",
			     { Content => $acct->json } );
    return unless $res;
    $api->auth = Weenect::Auth->create($res);
}

method get_acct( $user, $pass ) {
    return $acct if $acct;
    if ( $user && $pass ) {
	return $acct =
	  Weenect::Login->new( username => $user, password => $pass );
    }

    require ResInfo;
    my $passwd = { password => 'ddjc8c*@!eqe6' };
    $acct = Weenect::Login->new
      ( username => ResInfo::resinfo( "weenect.username", $passwd ),
	password => ResInfo::resinfo( "weenect.password", $passwd ),
      );
}

use Weenect::Tracker;

method get_trackers {
    my $res = $api->request("mytracker");
    return unless $res;

    my $trackers = Weenect::Trackers->create_with_api( $res, $api );
    $trackers->items;
}

method get_user {
    my $res = $self->request("myuser");
    return $res;
}

method get_animals( $imei ) {
    my $res = $api->request( sprintf("animal?imei=%s", $imei) );
    return unless $res;

    my $animals = Weenect::Animals->create($res);

    return $animals->items;
}

1;
