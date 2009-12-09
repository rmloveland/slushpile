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

my $author = $q->param('author');
my $tome   = $q->param('tome');
my $codex  = "/slushpile/$author/codex";

chdir $codex or die $!;
my $stat = stat("$tome.txt");
my $date = localtime($stat->mtime);
open my $IO, '<', "$codex/$tome.txt" or die $!;

print $slushie->header;
print $q->h1($slushie->{_TITLE});
print $slushie->greeting;
print $slushie->delicious_url($author), $q->br;

my $title = $slushie->english_title($tome);
print $q->h3($title);
print $_ while(<$IO>);
print $q->p("Posted on $date by $author");
print $q->end_html;
close $IO;
