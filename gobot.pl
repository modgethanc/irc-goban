#!/usr/bin/perl
package Bot;
use base qw(Bot::BasicBot);

my $BOSS = "hvincent";
my @board_13 = (
"   A B C D E F G H I J K L M   ",
"13 . . . . . . . . . . . . . 13",
"12 . . . . . . . . . . . . . 12",
"11 . . . . . . . . . . . . . 11",
"10 . . . + . . . . . + . . . 10",
" 9 . . . . . . . . . . . . . 9 ",
" 8 . . . . . . . . . . . . . 8 ",
" 7 . . . . . . + . . . . . . 7 ",
" 6 . . . . . . . . . . . . . 6 ",
" 5 . . . . . . . . . . . . . 5 ",
" 4 . . . + . . . . . + . . . 4 ",
" 3 . . . . . . . . . . . . . 3 ",
" 2 . . . . . . . . . . . . . 2 ",
" 1 . . . . . . . . . . . . . 1 ",
"   A B C D E F G H I J K L M   "
);

#======= helper functions

sub printBoard {
	my ($self, $message) = @_;

	foreach (@board_13) {
		$self->say(channel => $message->{channel}, body => $_);
	}
}

#======= overrides

sub said {
	my ($self, $message) = @_;

	if ($message->{body} =~ /board/) {
		&printBoard;
	}
}

sub chanjoin {
	my ($self, $message) = @_;

	if ($message->{who} =~ $self->{nick}) {
		$self->say(channel => $message->{channel}, body => "hi im awake");
	}
}

#======= INITIALIZATION

Bot->new(
	server   => "irc.freenode.net",
	channels => [ '#kvincent'],#giantfuckingqueens,#trhq' ],
	nick     => 'kvincent-go',
	name     => $BOSS."'s bot",
	quit_message     => "i'm out",
)->run();
