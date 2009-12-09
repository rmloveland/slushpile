#!/usr/bin/env perl

use strict;
use warnings;
use CGI;
use CGI::Carp qw( fatalsToBrowser );
use File::stat;

push @INC, '/slushpile/modules/';
require LoF::Slushie;

my $slushie = Slushie->new;
my $q = CGI->new;

my $author = $q->param( 'author' );
my $codex = "/slushpile/$author/codex";

chdir $codex or die $!;
opendir my $DIR, $codex or die "couldn't open $author's codex: $!";
my @tomes = readdir $DIR or die $!;

print $slushie->header;
print $q->h1($slushie->{_TITLE});
print $slushie->greeting;
print $slushie->delicious_url($author), $q->br;
my @transformed = $slushie->transform_tomes( @tomes );

for my $tome ( @transformed ) {
    open my $FH, '<', "$tome.txt" or die $!;
    my $stat = stat($FH);
    my $date = localtime($stat->mtime);
    my $title = $slushie->english_title($tome);
    print $q->h2($title);
    print $_ while(<$FH>);
    print $q->p("Posted on $date by $author");
    print $q->p($q->a({href => "/slushpile/display-tome.pl?author=$author&tome=$tome"}, 'permalink'));
    close $FH;
}

print $q->h3('archive:');
for my $tome ( @transformed ) {
    my $url = "/slushpile/display-tome.pl?author=$author&tome=$tome";
    print $q->a({href => $url}, $slushie->english_title($tome)), $q->br;
}

print $q->end_html;
closedir $DIR;
