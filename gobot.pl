#!/usr/bin/perl
package Bot;
use base qw(Bot::BasicBot);
use feature qw(switch);

my $BOSS = "hvincent";
my $black = "unnamed p1";
my $white = "unnamed p2";

my $bcaps = 0;
my $wcaps = 0;

my $turn =\$black;

my @movelog;

my $B = "O";
my $W = "X";
my $H = "+";
my $X = ".";

my %coords = (
	'A' => 1,
	'B' => 2,
	'C' => 3,
	'D' => 4,
	'E' => 5,
	'F' => 6,
	'G' => 7,
	'H' => 8,
	'J' => 9,
	'K' => 10,
	'L' => 11,
	'M' => 12,
	'N' => 13,
	'O' => 14,
	'P' => 15,
	'Q' => 16,
	'R' => 17,
	'S' => 18,
	'T' => 19,
	'a' => 1,
	'b' => 2,
	'c' => 3,
	'd' => 4,
	'e' => 5,
	'f' => 6,
	'g' => 7,
	'h' => 8,
	'j' => 9,
	'k' => 10,
	'l' => 11,
	'm' => 12,
	'n' => 13,
	'o' => 14,
	'p' => 15,
	'q' => 16,
	'r' => 17,
	's' => 18,
	't' => 19,
	'9' => 1,
	'8' => 2,
	'7' => 3,
	'6' => 4,
	'5' => 5,
	'4' => 6,
	'3' => 7,
	'2' => 8,
	'1' => 9
);

my @board_13 = (
["   A B C D E F G H J K L M N   "],
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
["   A B C D E F G H J K L M N   "]
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

#======= display 

sub printBoard {
	my ($self, $message) = @_;
	&webBoard(\@board_9);

	$self->say(channel => $message->{channel}, body => "http://theta.cfa.cmu.edu/hvincent/gobot-out.html");

	foreach my $row (@board_9) {
		my $line = join(" ", @$row);

		$self->say(channel => $message->{channel}, body => $line);
	}
}

sub webBoard {
	my $outfile = "board.html";
	my $gifs = "gogifs";
	my @board = $_[0];

	open OUT, ">", $outfile;
	select OUT;
	print "<html><head><title>gobot out</title></head><body>\n";
	close OUT;
	open OUT, ">>", $outfile;
	select OUT;
	
	my $j, $i;
	
	print "<p>";

	foreach my $row (@board_9) {
		foreach my $column (@$row) {
			print &gifSelection($j, $i, $board_9[$j][$i]);
			#print "<img src=\"$gifs/".&gifSelection($j, $i, $board[$j][$i])."\">";
			$i++
		}
		print "<br>\n";
		$i = 0;
		$j++;
	}

	print "</p>\n";
	$j = 0;
	$i = 0;	

	print "<p>black: $black (caps: $bcaps) <br>white: $white (caps: $wcaps)</p>";
	print "<p>move history:</p>\n";
	foreach (@movelog) {
		print "$_ ";
	}

	print "\n</body></html>";
	close OUT;
}

sub gifSelection {
	my $row = $_[0];
	my $column = $_[1];
	my $piece = $_[2];

	my $lead = "<img src=\"gogifs/";
	my $tail = ".GIF\">";

	if ($piece =~ /$B/) { return $lead."B".$tail; }
	elsif ($piece =~ /$W/) { return $lead."W".$tail; }
	elsif ($piece =~ /\+/) { return $lead."H".$tail; }

	elsif ($piece =~ /\./) {
	if ($row == 1) {
		if ($column == 1) { return $lead."1".$tail; }
		if (($column > 1) && ($column < 9)) { return $lead."2".$tail; }
		if ($column == 9) { return $lead."3".$tail; }
	} 

	elsif (($row > 1) && ($row < 9)) {
		if ($column == 1) { return $lead."4".$tail; }
		if (($column > 1) && ($column < 9)) { return $lead."5".$tail; }
		if ($column == 9) { return $lead."6".$tail; }
	}

	elsif ($row == 9) {
		if ($column == 1) { return $lead."7".$tail; }
		if (($column > 1) && ($column < 9)) { return $lead."8".$tail; }
		if ($column == 9) { return $lead."9".$tail; }
	}
	}
	else {return;}
}

#======= gameplay

sub play {
	my ($self, $message) = @_;
	
	if ($message->{who} !~ /$$turn/) {
		return "it's not your turn, $message->{who}";
	}

	my $move = &extractMove($self, $message);
	push(@movelog, $move);

	my ($i, $j) = &boardPosition(split("", $move));

	if ($turn == \$black ) {
		$board_9[$j][$i] = $B;
		$turn = \$white;
	} else {
		$board_9[$j][$i] = $W;
		$turn = \$black;
	}

	&webBoard(\@board_9);

	return "your move, $$turn";
}

sub removePiece {
	my ($self, $message) = @_;

	my $move = &extractMove($self, $message);

	my ($i, $j) = &boardPosition(split("", $move));

	if (($move =~/c3/) || ($move =~ /c7/) || ($move =~ /g3/) || ($move =~ /g7/) || ($move =~ /e5/)) {
		$board_9[$j][$i] = $H;
	} else {
		$board_9[$j][$i] = $X;
	}
	if ($board_9[$j][$i] =~ /$B/ ) {
		$bcaps++;
	} else {
		$wcaps++;
	}
	
	&webBoard;
	return "done. http://theta.cfa.cmu.edu/hvincent/gobot-out.html updated";
}

sub extractMove {
	my ($self, $message) = @_;

	my @a = split(' ', $message->{body});
	shift(@a);
	return join(' ', @a);
}

sub boardPosition {
	my $a = shift(@_);
	my $b = join ("", @_);

	my @position;
	push(@position, $coords{$a}, $coords{$b});
	return @position;
}

#======= overrides

sub said {
	my ($self, $message) = @_;

	if ($message->{address}) {
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
		when (/remove/) {
			$self->say(channel => $message->{channel}, body => &removePiece($self, $message));
		}
		when (/board/) { 
			&printBoard($self, $message); 
		}
		when (/who/) {
			$self->say(channel => $message->{channel}, body => "black: $black; white: $white");
		}
		when (/turn/) {
			$self->say(channel => $message->{channel}, body => "it's $$turn\'s turn to play");
		}
	}}
	if ($message->{body} =~ /play/) {
		$self->say(channel => $message->{channel}, body => &play($self, $message));
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
	channels => [ '#kvincent'],
	nick     => 'kvincent-go',
	name     => $BOSS."'s bot",
	quit_message     => "i'm out",
)->run();
