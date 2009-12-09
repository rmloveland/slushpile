#!/usr/bin/env perl

use strict;
use warnings;
use CGI::Pretty qw( :all );
use CGI::Carp qw( fatalsToBrowser );

push @INC, '/slushpile/modules';
require LoF::Slushie;

my $slushie  = Slushie->new();
my $title    = $slushie->{_TITLE};

my $username = param('username');
my $password = param('password');
my $params_p = $username && $password;

print redirect( 'http://libraryoffools.org/slushpile/index.pl' )
    if $slushie->cookie_p;

if ($params_p && $slushie->author_p($username, $password)) {
    my $cookie = $slushie->bake_cookie_for($username);
    print $slushie->header($cookie);
    print p( "you're logged in -- happy browsing, $username!" );
    print $slushie->delicious_url;
} else {
    print header( -charset => $slushie->{ _CHARSET } ),
        start_html(
            -title => $title,
            -style => {-src => $slushie->{ _STYLESHEET } },
        );
    print p('wrong username or password')
        if ($params_p && !$slushie->author_p($username, $password));
    print start_form,
        'username ', br, textfield( -name => 'username' ), br,
            'password ', br, password_field( -name => 'password' ), br,
                p submit( -name => 'log in' ),
                    end_form;
}
