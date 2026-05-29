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

use Weenect::Preferences;

method get_preferences {
    my $res = $api->request("myuser");
    return unless $res;

    return Weenect::Preferences->create($res);
}

# E.g.
# langiage => "nl"
#
# mail_pref => { offers => 0, company_news => 0, new_features => 0,
#                surveys_and_tests => 0 },
# optin => 0, preferred_metric_system => "km"

method set_preferences( %prefs ) {
    my $res = $api->request( "myuser",
			     { Content => \%prefs }
			   );
    return unless $res;

    return Weenect::Preferences->create($res);
}

method get_animals( $imei ) {
    my $res = $api->request( sprintf("animal?imei=%s", $imei) );
    return unless $res;

    my $animals = Weenect::Animals->create($res);

    return $animals->items;
}

1;
