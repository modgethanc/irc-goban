#!/usr/bin/perl
package Bot;
use base qw(Bot::BasicBot);
use feature qw(switch);

my $BOSS = "hvincent";
my $black = "unnamed p1";
my $white = "unnamed p2";

my @board_13 = (
["   A B C D E F G H I J K L M   "],
["13",".",".",".",".",".",".",".",".",".",".",".",".",".","13"],
["12",".",".",".",".",".",".",".",".",".",".",".",".",".","12"],
["11",".",".",".",".",".",".",".",".",".",".",".",".",".","11"],
["10",".",".",".","+",".",".",".",".",".","+",".",".",".","10"],
[" 9",".",".",".",".",".",".",".",".",".",".",".",".","."," 9"],
[" 8",".",".",".",".",".",".",".",".",".",".",".",".","."," 8"],
[" 7",".",".",".",".",".",".","+",".",".",".",".",".","."," 7"],
[" 6",".",".",".",".",".",".",".",".",".",".",".",".","."," 6"],
[" 5",".",".",".",".",".",".",".",".",".",".",".",".","."," 5"],
[" 4",".",".",".","+",".",".",".",".",".","+",".",".","."," 4"],
[" 3",".",".",".",".",".",".",".",".",".",".",".",".","."," 3"],
[" 2",".",".",".",".",".",".",".",".",".",".",".",".","."," 2"],
[" 1",".",".",".",".",".",".",".",".",".",".",".",".","."," 1"],
["   A B C D E F G H I J K L M   "]
);

my @board_9 = (
["  A B C D E F G H J  "],
["9",".",".",".",".",".",".",".",".",".","9"],
["8",".",".",".",".",".",".",".",".",".","8"],
["7",".",".","+",".",".",".","+",".",".","7"],
["6",".",".",".",".",".",".",".",".",".","6"],
["5",".",".",".",".","+",".",".",".",".","5"],
["4",".",".",".",".",".",".",".",".",".","4"],
["3",".",".","+",".",".",".","+",".",".","3"],
["2",".",".",".",".",".",".",".",".",".","2"],
["1",".",".",".",".",".",".",".",".",".","1"],
["  A B C D E F G H J  "]
);

#======= helper functions

sub printBoard {
	my ($self, $message) = @_;
	#&webBoard;

	foreach my $row (@board_9) {
		my $line = join(" ", @$row);

		$self->say(channel => $message->{channel}, body => $line);
	}
}

sub webBoard {
	my $outfile = "board.html";
	my $gifs = "gogifs";
	open OUT, ">", $outfile;
	select OUT;
	print "<html><head><title>gobot out</title></head><body>";
	close OUT;
	open OUT, ">>", $outfile;
	select OUT;

	print "<p><img src=\"$gifs/1.GIF\">";
	for (my $i=0; $i<11; $i++) {
		print "<img src=\"$gifs/2.GIF\">";
	}
	print "<img src=\"$gifs/3.GIF\"><br>";

	for (my $j=0; $j<11; $j++) {
		print "<img src=\"$gifs/4.GIF\">";
		for ($i=0; $i<11; $i++) {
			if ($j==2) {
				if (($i==2) || ($i==8)) {
					print "<img src=\"$gifs/H.GIF\">";
				} else {
					print "<img src=\"$gifs/5.GIF\">";
				}
			} elsif ($j==8) {
				if (($i==2) || ($i==8)) {
					print "<img src=\"$gifs/H.GIF\">";
				} else {
					print "<img src=\"$gifs/5.GIF\">";
				}
			} elsif (($j==5) && ($i==5)) {
				print "<img src=\"$gifs/H.GIF\">";
			} else {
				print "<img src=\"$gifs/5.GIF\">";
			}
		}
		print "<img src=\"$gifs/6.GIF\"><br>";
	}

	print "<img src=\"$gifs/7.GIF\">";
	for ($i=0; $i<11; $i++) {
		print "<img src=\"$gifs/8.GIF\">";
	}
	print "<img src=\"$gifs/9.GIF\"></p>";


	print "<p>black: $black <br>white: $white</p";
	print "</body></html>";
	close OUT;
}

#======= overrides

sub said {
	my ($self, $message) = @_;
	
	given ($message->{body}) {
		#== init
		when (/i'm black/) { 
			$black = $message->{who};
			$self->say(channel => $message->{channel}, body => "okay, you're black");
		}
		when (/i'm white/) { 
			$white = $message->{who};
			$self->say(channel => $message->{channel}, body => "okay, you're white");
		}
		#== commands
		when (/board/) { &printBoard($self, $message); }
		when (/who/) {
			$self->say(channel => $message->{channel}, body => "black: $black; white: $white");
		}
	}
}

#	if ($message->{body} =~ /board/) {
#		&printBoard($self, $message);
#	}

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
