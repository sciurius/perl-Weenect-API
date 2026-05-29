#!/usr/bin/perl

# Author          : Johan Vromans
# Created On      : Thu Apr 23 19:20:34 2026
# Last Modified By: Johan Vromans
# Last Modified On: Fri May 29 21:45:51 2026
# Update Count    : 254
# Status          : Unknown, Use with caution!

################ Common stuff ################

use v5.36;
use Object::Pad;
use utf8;
use lib qw( lib );

# Package name.
my $my_package = 'Weenect';
# Program name and version.
my ($my_name, $my_version) = qw( get_status 1.00 );

################ Command line parameters ################

use Getopt::Long 2.13;

# Command line options.
my $verbose = 1;		# verbose processing

# Development options (not shown with -help).
my $debug = 0;			# debugging
my $trace = 0;			# trace (show process)
my $test = 0;			# test mode.

# Process command line options.
app_options();

# Post-processing.
$trace |= ($debug || $test);

################ Presets ################

my $ts = do {
    my @tm = localtime;
    sprintf( "%04d%02d%02d_%02d%02d%02d",
	     1900+$tm[5], 1+$tm[4], @tm[3,2,1,0] );
};

################ The Process ################

main();

################ Subroutines ################

use Weenect::User;
use Weenect::Classes;

sub main() {
    my $home = Weenect::Point->new( latitude => 52.8849946,
				    longitude => 6.8592215 );
    print("== $ts\n");

    my $api = Weenect::User->new;
    $api->debug = $debug;
    $api->login;

    my $trackers = $api->get_trackers;

    foreach my $tracker ( @$trackers ) {

	printf("Tracker %s [%d%s]\n", $tracker->name, $tracker->id,
	      $tracker->active ? "" : ",inactive" );
	next unless $tracker->active;

	my $here = $tracker->position->[0];
	# date_tracker -> timestamp of position
	# date_server  -> timestamp when the server received it
	printf( "  Distance: %dm\n", $home->distance($here) );
	printf( "  %s\n", $here->$_ )
	  for qw( battery_text gsm_text accuracy_text );

	my $zones = $tracker->get_wifizones;
	my $zid = $here->wifi_zone_id;
	foreach my $zone ( @$zones ) {
	    printf( "  %sWiFi zone %s [%d, %dm]%s\n",
			$zid == $zone->id ? ">" : " ",
			$zone->name, $zone->id,
			$zone->radius,
			$zone->is_active ? "" : " INACTIVE",
		      );
	}

	$zid = $tracker->geofence_number;
	$zones = $tracker->get_zones;
	foreach my $zone ( @$zones ) {
	    my $mark = " ";
	    if ( $zone->id == $zid ) {
		$mark = ">";
		$zid = -1;
	    }
	    printf( "  %sZone %s [%d, mode %d, %dm]\n",
		    $mark,
		    $zone->name,
		    $zone->id,
		    $zone->mode, # No, Enter, Exit, Enter+Exit notification
		    $zone->distance,
		  );
	}
	if ( $zid >= 0 ) {
	    my $name = $here->geofence_name // "<unknown>";
	    printf( "  Geofence zone: %s [%d]\n", $name, $zid );
	}

	# $tracker->ring;
    }
}

################ Classes ################


package main;

sub app_options {
    my $help = 0;		# handled locally
    my $ident = 0;		# handled locally

    # Process options, if any.
    # Make sure defaults are set before returning!
    return unless @ARGV > 0;

    if ( !GetOptions(
		     'ident'	=> \$ident,
		     'verbose+'	=> \$verbose,
		     'quiet'	=> sub { $verbose = 0 },
		     'trace'	=> \$trace,
		     'help|?'	=> \$help,
		     'debug'	=> \$debug,
		    ) or $help )
    {
	app_usage(2);
    }
    app_ident() if $ident;
}

sub app_ident {
    print STDERR ("This is $my_package [$my_name $my_version]\n");
}

sub app_usage {
    my ($exit) = @_;
    app_ident();
    print STDERR <<EndOfUsage;
Usage: $0 [options] [file ...]
   --ident		shows identification
   --help		shows a brief help message and exits
   --verbose		provides more verbose information
   --quiet		runs as silently as possible
EndOfUsage
    exit $exit if defined $exit && $exit != 0;
}

__END__

POST /v4/mytracker/711329/vibrate
  {}
POST /v4/mytracker/711329/ring
  {}
POST /v4/mytracker/711329/flash
  {"intermittent_duration_ms_on":100,"intermittent_duration_ms_off":100,"duration_minutes":1}

# super live 1 sec int, 5 min.
POST /v4/mytracker/711329/st-mode
  {"interval":10}

GET /v4/animal?imei=357064570234091
{"items": [{"id": 186922, "created_at": "Sat, 11 Apr 2026 13:11:25 -0000", "updated_at": "Sat, 11 Apr 2026 13:11:25 -0000", "is_activated": true, "tracker_id": 711329, "species": "cat", "breed_id": 22, "sex": "female", "birth_date": "2020-02-10T23:00:00+00:00", "is_sterilized": true, "santevet_optin": false, "identification": "none", "habitual_environment": null, "activity_level": 100, "name": "Joan", "morphology": null, "weight": 10.0, "last_vet_visit_date": "2025-01-10T23:00:00+00:00", "last_vaccination_date": "2025-01-10T23:00:00+00:00", "breed": ""}], "total": 1}

/v4/myuser
  {"language":"nl"}
  ->
  { ... }

  {"mail_pref":{"offers":false,"company_news":false,"new_features":false,"surveys_and_tests":false},"optin":false,"preferred_metric_system":"km"}
  ->
  {"id": 488175, "site": "weenect", "mail": "jvromans@squirrel.nl", "valid": null, "is_admin": false, "is_security": false, "is_premium": false, "role_retailer_id": 0, "role_site": null, "need_subscription": true, "lastname": "Vromans", "firstname": "Johan", "contact_mail": "", "address": "Cederlaan 6", "postal_code": "7875EB", "city": "Exloo", "country": "NL", "phone": "+31591585507", "creation_date": "2026-04-08T09:25:19.997678", "connection_date": "2026-05-19T09:26:06.740389", "last_connection_date": "2026-05-18T22:10:01.753484", "sms": 40, "language": "en", "optin": false, "disable_history": false, "short_code": null, "is_b2b": false, "review_link": "https://uk.trustpilot.com/evaluate-link/e4c6353e0604af605ac8d6075b8aeea4", "preferred_metric_system": "km", "white_label": {"code": "UNKNOWN", "name": "unknown", "logo": null, "logo_header": null, "logo_splashscreen": null, "display_logo": false, "display_header": false, "display_splashscreen": false}, "emailpref": null, "account_options": [{"id": 786320079, "code": "premium_pack", "sms": 0, "amount": 299, "currency": "EUR", "activated": false, "is_running": false, "user_id": 488175, "subscription_id": 0, "created_at": "2026-04-08T09:32:17.326084", "updated_at": "2026-05-04T17:28:16.662876", "next_charge_at": "2026-05-08T09:32:17.341235", "activation_date": "2026-04-08T09:32:17.341293", "cancel_date": "2026-05-04T17:28:16.662265", "cancel_reason": "OTHER"}], "account_option_offers": [{"id": 21, "site": "weenect", "code": "premium_pack", "sms": 40, "created_at": "2022-09-05T20:46:12.810371", "updated_at": "2022-09-05T20:46:12.810371", "price_offer": {"id": 8, "code": "premium_pack", "fr": {"amount": 299, "currency": "EUR"}, "nl": {"amount": 299, "currency": "EUR"}, "de": {"amount": 299, "currency": "EUR"}, "en": {"amount": 290, "currency": "GBP"}, "es": {"amount": 299, "currency": "EUR"}, "it": {"amount": 299, "currency": "EUR"}}}], "user_notation": {"id": 426968, "created_at": "Wed, 08 Apr 2026 09:30:11 -0000", "updated_at": "Thu, 28 May 2026 12:34:01 -0000", "amazon_review_link": "", "trustpilot_product_review_link": "https://products.trustpilot.com/evaluate/d9c7b79e7b8a53438b5a93dd59d47f00", "trustpilot_service_review_link": "https://uk.trustpilot.com/evaluate-link/e4c6353e0604af605ac8d6075b8aeea4", "notation_in_app": null, "user_id": 488175}, "default_payment_mean": {"id": 647618, "created_at": "2026-04-08T09:32:17.260213", "updated_at": "2026-04-08T09:32:17.260218", "is_activated": null, "payment_mean": "stripe", "ipaddress": null, "country": "NL", "payment_id": "pm_1TJsR8LIKqgzIIGYvApBdwWn", "payment_additional_id": null, "bank_account": null, "customer_id": "cus_UITLUJh2bHOEV1", "payment_product": "visa", "card_expiry": "2027-03-31T23:59:59", "card_pan": "XXXXXXXXXXXX7419", "user_id": 488175, "has_card_expired": false, "has_insufficient_funds": false, "count_subscription_payment_error": 0, "count_option_payment_error": 0}, "mail_pref": {"offers": false, "company_news": false, "new_features": false, "surveys_and_tests": false}}
  
