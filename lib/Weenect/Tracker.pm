#! perl

use v5.36;
use Object::Pad;
use utf8;

use Class::JSON_Object;

class Weenect::Trackers :does(Class::JSON_Object) {

    field $total;
    field @items :Class(Weenect::Tracker);

    # Constructor that connects the items to the api.
    sub create_with_api ( $class, $data, $api ) {
	my $s = $class->create_sparse($data);
	for ( @{$s->items} ) {
	    $_->api = $api;
	}
	return $s;
    }
}

class Weenect::Tracker :does(Class::JSON_Object);

#### Instanciate via Weenect::Trackers only.

field $api :Optional :mutator;
field $id;
field $active;
field $name;
field @position :Class(Weenect::Position);
field $geofence_number :Optional;

method get_zones {
    my $res = $api->request( sprintf( "mytracker/%d/zones", $id ) );
    return unless $res;
    my $zones = Weenect::Zones->create($res);
    return [ $zones->items ];
}

method get_wifizones {
    my $res = $api->request( sprintf( "mytracker/%d/wifi-zones", $id ) );
    return unless $res;
    my $zones = Weenect::WiFiZones->create($res);
    return [ $zones->items ];
}

method get_history( $start, $end ) {
    # https://apiv4.weenect.com/v4/mytracker/135076/activity/v2?metric_system=miles&start=2021-07-17T13:57:43.773Z&end=2021-07-18T13:57:43.773Z
    my $res = $api->request( sprintf( "mytracker/%d/activity/v2?start=%s&end=%s",
				      $id, $start, $end ) );
    return unless $res;
    return $res;
}

method flash {
    my $res = $api->request( sprintf( "mytracker/%d/flash", $id ),
			     { Content => q({"intermittent_duration_ms_on":100,"intermittent_duration_ms_off":100,"duration_minutes":1}) } );
    # return unless $res;
    return $res;
}

method ring {
    my $res = $api->request( sprintf( "mytracker/%d/ring", $id ),
			     { Content => {} } );
    # return unless $res;
    return $res;
}

method vibrate {
    my $res = $api->request( sprintf( "mytracker/%d/vibrate", $id ),
			     { Content => {} } );
    # return unless $res;
    return $res;
}

method super_live {
    my $res = $api->request( sprintf( "mytracker/%d/st-mode", $id ),
			     { Content => {} } );
    # return unless $res;
    return $res;		# {"interval":10}
}

1;
