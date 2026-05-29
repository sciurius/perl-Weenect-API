#! perl

use v5.36;
use utf8;

use Weenect::User;

package Weenect;

our $VERSION = "1.00";

=head1 NAME

Weenect - API to Weenect tracker server

=head1 SYNOPSIS

    use Weenect::User;
    my $user = Weenect::User->new;
    $user->login( "me@example.com", "mypassword" );
    my $trackers = $user->get_trackers;
    foreach my $tracker ( @$trackers ) {
	printf("Tracker %s [%d%s]\n", $tracker->name, $tracker->id,
	      $tracker->active ? "" : ",inactive" );
    }

=head1 DESCRIPTION

This package facilitates connecting to the Weenect server and fetching
user and tracker data.

See the programs in the scripts directory for examples.

=head1 LICENSE

Copyright (C) 2026, Johan Vromans

This module is free software. You can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

This program is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=cut

1;
