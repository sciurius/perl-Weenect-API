#! perl

# Weenect API data classes.

use v5.36;
use Object::Pad;
use Class::JSON_Object;
use utf8;

class Weenect::Login :does(Class::JSON_Object) {
    field $username :param;
    field $password :param;
}

class Weenect::Auth :does(Class::JSON_Object) {
    field $access_token;
    field $expires_in;
    field $refresh_token;
    field $token_type;
}

class Weenect::Zone :does(Class::JSON_Object) {
    field $id;
    field $number;
    field $name;
    field $address;
    field $active;
    field $tracker_id;
    field $latitude;
    field $longitude;
    field $mode;
    field $distance;
    field $is_outside;
}

class Weenect::Zones :does(Class::JSON_Object) {
    field $total;
    field @items :Class(Weenect::Zone);
}

class Weenect::WiFiZone :does(Class::JSON_Object) {
    field $id;
    field $name;
    field $mac_address;
    field $created_at;
    field $updated_at;
    field $tracker_id;
    field $latitude;
    field $longitude;
    field $radius;
    field $is_active;
    field $enable_notifications;
}

class Weenect::WiFiZones :does(Class::JSON_Object) {
    field $total;
    field @items :Class(Weenect::WiFiZone);
}

class Weenect::Position :does(Class::JSON_Object) {
    field $latitude;
    field $longitude;
    field $battery_text;
    field $gsm_text;
    field $accuracy_text;
    field $geofence_name;
    field $wifi_zone_id;
    field $date_tracker;

    method distance($other) {
	$other = Weenect::Point->new( longitude => $other->longitude,
				      latitude  => $other->latitude )
	  unless $other isa Weenect::Point;
	Weenect::Point->new( longitude => $longitude,
			     latitude  => $latitude )->distance($other);
    }
}

class Weenect::Point {
    field $latitude  :param;
    field $longitude :param;

    use constant PI_D => atan2(1,1) / 45;
    sub d2r($d) { $d * PI_D } # degrees to radians

    method distance($other) {
	my $longitude1 = d2r($longitude);
	my $latitude1 = d2r($latitude);
	my $longitude2 = d2r($other->longitude);
	my $latitude2 = d2r($other->latitude);
	my $dlon = $longitude2 - $longitude1;
	my $dlat = $latitude2 - $latitude1;
	my $a = (sin($dlat/2))**2 + cos($latitude1) * cos($latitude2) * (sin($dlon/2))**2;
	my $c = 2 * atan2( sqrt($a), sqrt(1-$a) );
	return 6371640 * $c;	# meters
    }
}

1;
