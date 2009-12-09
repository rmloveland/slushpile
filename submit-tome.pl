#!/usr/bin/env perl

use strict;
use warnings;
use CGI;
use CGI::Carp qw< fatalsToBrowser >;

push @INC, '/slushpile/modules';
require LoF::Slushie;

my $slushie = Slushie->new;
my $q = CGI->new;

# These are only defined if you've just submitted something.
my $tome = $q->param( 'tome' );
my $title = $q->param( 'title' );
my $author = $q->cookie( 1 );

print $q->redirect( 'http://libraryoffools.org/slushpile/login.pl' )
    unless $slushie->cookie_p;
print $slushie->header;
print $q->h1($slushie->{_TITLE});
print $slushie->greeting;
print $slushie->delicious_url($author), $q->br;
print $q->p("use ".$q->a({href=>'http://daringfireball.net/markdown/syntax'},
                         'markdown')." to lay out your text");

if (defined $tome && defined $title) {
    my $unix_title = $slushie->unix_title($title);
    $slushie->archive_tome($author, $unix_title, $tome);
    print $q->p('you successfully submitted the following -- it lives '.
                    $q->a({href=>"/slushpile/display-tome.pl?author=$author&tome=$unix_title"}, 'here').' now'),
                        $q->p($title),
                            $q->p($tome);
} else {
    print $slushie->submit_tome;
}
print $q->end_html;
