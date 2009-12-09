#!/usr/bin/env perl

use strict;
use warnings;
use CGI::Pretty qw( :all );
use CGI::Carp qw( fatalsToBrowser );

push @INC, '/slushpile/modules/';
require 'LoF/Slushie.pm';

my $s          = Slushie->new();
my $title      = $s->{ _TITLE };
my $charset    = $s->{ _CHARSET };
my $stylesheet = $s->{ _STYLESHEET };

print header( -charset => $charset );
print start_html(
    -title => $title,
    -style => { -src => $stylesheet },
);

print h1( $title );
print $s->greeting;
print $s->delicious_url, br;
print p( 'authors:' ), $s->list_authors;
print end_html;
