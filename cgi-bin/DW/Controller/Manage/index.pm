#!/usr/bin/perl
##
## DW::Controller::Manage::Index
##
## /manage/
##
## Authors:
##      Simon Waldman <swaldman@firecloud.org.uk>
##
## Copyright (c) 2012 by Dreamwidth Studios, LLC.
##
## This program is free software; you may redistribute it and/or modify it under
## the same terms as Perl itself. For a copy of the license, please reference
## 'perldoc perlartistic' or 'perldoc perlgpl'.
##
#

package DW::Controller::Manage::Index;

use strict;
use warnings;
use DW::Controller;
use DW::Routing;
use DW::Template;

DW::Routing->register_string( "/manage/index", \&index_handler, app=>1 );

sub index_handler {

    LJ::set_active_crumb('manage');

    my $get_args = DW::Request->get->get_args;

    my $remote = LJ::get_remote();
    return needlogin() unless $remote;
    
    my $authas = $get_args->{authas} || $remote->{user};
    my $u = LJ::get_authas_user($authas);
    return ( error_ml( 'error.invalidauth' ) ) unless $u;

    my $print_authas = LJ::make_authas_select($remote, { authas => $authas });

    # Your Account section
    my %account_vars;
    $account_vars{account_username} = LJ::ljuser( $u );
    $account_vars{account_name} = LJ::ehtml( $u->{name} );

    $account_vars{is_identity_no_email} = $u->is_identity && !$u->email_raw;
    $account_vars{SITEROOT} = LJ::SITEROOT;
    $account_vars{email_validated} = $u->{status} eq 'A' ? 1 : 0;
    $account_vars{email} = $u->email_raw;


    my $template_vars = {
        print_authas => $print_authas,
        %account_vars,
    };

    return DW::Template->render_template( 'manage/index.tt', $template_vars );
}

1;
