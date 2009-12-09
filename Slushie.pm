package Slushie;

use strict;
use warnings;
use Carp;
use CGI;
use CGI::Carp qw< fatalsToBrowser >;
use Digest::MD5 qw< md5_hex >;
use Text::Markdown;

push @INC, '/slushpile/modules/';
require Text::Markdown;

my $q = CGI->new;

sub new {
    ## Modify to accept arguments (possibly as a hashref?).
    my $class = shift;
    my $self = {};
    $self->{_VERSION} = '0.02';
    $self->{_TITLE} = 'Library of Fools';
    $self->{_ENCODING} = 'utf-8';
    $self->{_STYLESHEET} = '/slushpile/css/main.css';
    bless ( $self, $class );
    return $self;
}

sub english_title {
    my ( $self, $title ) = @_;
    my @caps    = split /-|_/, $title;
    my $legible = join( ' ', map { ucfirst $_ } @caps );
    return $legible;
}

sub unix_title {
    my ( $self, $title ) = @_;
    $title =~ s/ /-/g;
    $title =~ s/-{2,}/-/g;
    $title =~ s/[^-\w]//gi;
    return lc $title;
}

sub delicious_url {
    ## This should accept arguments as well, again as a hashref(?).
    my $self = shift;
    my $author = $q->cookie( 1 ) || shift;
    my @elems;
    my %hrefs = (
        '/' => $self->{ _TITLE },
        '/slushpile/index.pl' => 'slushpile',
        "/slushpile/display-codex.pl?author=$author" => $author,
        '/forum' => 'forum',
    );
    my @goodlinks = grep { defined $hrefs{$_} } keys %hrefs;
    push @elems, $q->a({href => $_}, $hrefs{$_}) for sort @goodlinks;
    my $menu = join ' # ', @elems;
    return $menu;
}

sub submit_tome {
    my $self = shift;
    return $q->start_form,
        'title ', $q->br,
            $q->textfield( -name => 'title', -default => '' ), $q->br,
                $q->textarea(
                    -name =>'tome',
                    -default =>'',
                    -rows => 30,
                    -columns => 72,
                ),
                    $q->br, $q->submit(-name => 'publish'),
                        $q->end_form;
}

sub archive_tome {
    my ( $self, $author, $title, $text ) = @_;
    my $m = Text::Markdown->new;
    my $html = $m->markdown($text);
    open my $IO, '>', "/slushpile/$author/codex/$title.txt" or die "Couldn't open $title: $!";
    print $IO $html;
    close $IO or die "Couldn't close $IO: $!";
}

sub transform_tomes {
    my $self  = shift;
    my @tomes = grep !/(^\.|~$)/, @_;
    my $suffix_remover = sub {my $arg = shift; $arg =~ s/\.txt$//gi; return $arg;};
    return reverse sort {-M $a cmp -M $b} map {$suffix_remover->($_)} @tomes;
}

sub author_p {
    my ($self, $author, $passphrase) = @_;
    my $userfile = '/slushpile/data/users.txt';
    open my $IO, '<', $userfile or die $!;
    my @users = <$IO>;
    close $IO;
    return !1 if $author eq $passphrase;
    return !1 unless grep /$author::$passphrase/, @users;
}

sub list_authors {
    my $self = shift;
    my @names;
    my $user_file = '/slushpile/data/users.txt';
    open my $IO, '<', $user_file or die "Couldn't open $user_file: $!";
  LINE: for my $line ( <$IO> ) {
        my @tmp = split /::/, $line;
        next LINE unless $tmp[0] =~ /\w+/;
        my $author = $tmp[0];
        push @names,
         $q->a({href => "/slushpile/display-codex.pl?author=$author"}, $author);
    }
    close $IO or die $!;
    return $q->ul($q->li(\@names));
}

sub cookie_p {
    my $self = shift;
    my $has_cookie = defined $q->cookie( 1 );
    return $has_cookie;
}

sub greeting {
    my $self = shift;
    my ($username, $digest) = $q->cookie(1);
    $self->cookie_p
        ? return $q->p("welcome, $username"),
            $q->p($q->a({-href => '/slushpile/submit-tome.pl'}, 'submit'))
                : return $q->p($q->a({href => '/slushpile/login.pl'}, 'log in')),
                    $q->p($q->a({-href => '/slushpile/submit-tome.pl'}, 'submit'));
}

sub bake_cookie_for {
    my ($self, $username) = @_;
    my @values = ( $username, md5_hex( rand 1 ) );
    return $q->cookie( -name => 1, -value => \@values );
}

sub header {
    # TODO: Pass in a callback that has generated the cookie(?).
    my ($self, $cookie) = @_;
    $cookie
    ? return $q->header(
        -charset => $self->{_CHARSET},
        -cookie  => $cookie,
    ),
        $q->start_html(
            -title => $self->{_TITLE},
            -style => {-src => $self->{_STYLESHEET}},
        )
    : return $q->header(
        -charset => $self->{_CHARSET},
    ),
        $q->start_html(
            -title => $self->{_TITLE},
            -style => {-src => $self->{_STYLESHEET}},
        );
}

1;
