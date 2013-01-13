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

    my ( $ok, $rv ) = controller( anon => 0, authas => 1 );
    return $rv unless $ok;

    my $u = $rv->{u};
    my $remote = $rv->{remote};

    return ( error_ml( 'error.invalidauth' ) ) unless $u;

    my $print_authas = LJ::make_authas_select($remote, { authas => $u->user });

    # Things just for Your Account section
    my %account_vars = (
        account_username => LJ::ljuser( $u ),
        account_name => $u->{name},
        is_identity_no_email => $u->is_identity && !$u->email_raw,
        email_validated => $u->{status} eq 'A' ? 1 : 0,
        email => $u->email_raw,
    );

    # Things just for Settings & Prefs section
    my %settings_prefs = (
        can_use_esn => $u->can_use_esn,
        is_deleted => $u->is_deleted,
    );

    #Vars to pass to the template
    my $template_vars = {
        print_authas_dropdown => $print_authas,
        is_identity => $u->is_identity,
        is_comm => $u->is_community,
        dotcomm => $u->is_community ? '.comm' : '',
        authas => $u->equals( $remote ) ? '' : "?authas=$u->{user}",
        #authas2: same as authas, but for use where it's not 1st variable
        authas2 => $u->equals( $remote ) ? '' : "&authas=$u->{user}",
        %account_vars,
        %settings_prefs,
    };
warn LJ::D($template_vars);
    return DW::Template->render_template( 'manage/index.tt', $template_vars );
}

1;
