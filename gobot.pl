#!/usr/bin/perl
package Bot;
use base qw(Bot::BasicBot);
use feature qw(switch);

my $BOSS = "hvincent";

my $black = "no player";
my $white = "no player";

my $bcaps = 0;
my $wcaps = 0;

my $turn =\$black;
my @activeBoard;
my $boardSize;

my @movelog;

#=== HARDCODE BS

my $B = "O";
my $W = "X";
my $H = "+";
my $X = ".";

my @coordList = ("  ", # first space for board rendering
	"A","B","C","D","E","F","G","H","J", #i wish i didn't have to do this but the convention is to skip 'I'...
	"K","L","M","N","O","P", "Q", "R", "S", "T"); 

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
	't' => 19
);

#=======

sub newBoard { 
	my ($self, $message) = @_;

	my $newSize = &boardSizer($self, $message);
	
	if ($newSize =~ /unsquare/) {
		return "i can only deal with square boards because i'm a square.";
	}

	if ($newSize !~ /\d+/) {
		return "you gotta give me a numerical size!";
	}
	
	if ($newSize > 19) {
		return "maximum board size is 19x19.";
	}

	if ($newSize < 1) {
		return "minimum board size is 1x1 (but like really why would you do that)";
	}
	
	# reset old board shit
	$boardSize = $newSize;
	undef(@activeBoard);
	undef(@moves);
	$black = "no player";
	$white = "no player";
	$bcaps = 0;
	$wcaps = 0;
	$turn =\$black;

	# loop loop loop

	my $xCoord = $boardSize;
	my $arrayMax = $boardSize + 1;
	my $row = 1;
	my $column = 0;
	my $set;
	
	while ($column < $arrayMax) { # make header
		$activeBoard[0][$column] = $coordList[$column];
		$column++;
	}

	while ($row < $arrayMax) { # make body
		$column = 0;
		while ($column <= $arrayMax) {
			if (($column == $arrayMax/2) && ($row == $arrayMax/2)) { # center star
				$set = $H;
			} elsif ($column == 0) { # leading coord
				if ($xCoord < 10) {
					$set = " ".$xCoord;
				} else {
					$set = $xCoord;
				}
			} elsif ($column == $arrayMax) { # trailing coord
				$set = $xCoord;
			} else { # normal point
				$set = $X;
			}

			$activeBoard[$row][$column] = $set;
			$column++;
		}
		$coords{$xCoord} = $row;	
		$xCoord--;
		$row++;
	}
	
	$column = 0;

	while ($column < $arrayMax) { # make footer
		$activeBoard[$arrayMax][$column] = $coordList[$column];
		$column++;
	}

	&printBoard($self, $message); 
	return "new board is ready!";
}

sub boardSizer {
	my ($self, $message) = @_;
	my $newSize;

	my @parse = split(' ',$message->{body});
	my $size = $parse[1];
	@parse = split('x',$size);

	if (($#parse > 0) && ($parse[0] != $parse[1])) {
		return "unsquare";
	}	

	$newSize = $parse[0];

	return $newSize;
}

#======= display 

sub printBoard {
	my ($self, $message) = @_;
	if (!@activeBoard) {
		$self->say(channel => $message->{channel}, body => "there isn't an active board right now. say 'new (9x9, 13x13, 19x19, etc.) if you want to start one.");
		return;
	}
	&webBoard;

	$self->say(channel => $message->{channel}, body => "http://theta.cfa.cmu.edu/hvincent/gobot-out.html");

	foreach my $row (@activeBoard) {
		my $line = join(" ", @$row);

		$self->say(channel => $message->{channel}, body => $line);
	}
}

sub webBoard {
	my $outfile = "board.html";
	my $gifs = "gogifs";

	open OUT, ">", $outfile;
	select OUT;
	print "<html><head><title>gobot out</title></head><body>\n";
	close OUT;
	open OUT, ">>", $outfile;
	select OUT;
	
	my $j, $i;
	
	print "<p>";

	foreach my $row (@activeBoard) {
		foreach my $column (@$row) {
			print &gifSelection($j, $i, $activeBoard[$j][$i]);
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
			if (($column > 1) && ($column < $boardSize)) { return $lead."2".$tail; }
			if ($column == $boardSize) { return $lead."3".$tail; }
		} 

		elsif (($row > 1) && ($row < $boardSize)) {
			if ($column == 1) { return $lead."4".$tail; }
			if (($column > 1) && ($column < $boardSize)) { return $lead."5".$tail; }
			if ($column == $boardSize) { return $lead."6".$tail; }
		}

		elsif ($row == $boardSize) {
			if ($column == 1) { return $lead."7".$tail; }
			if (($column > 1) && ($column < $boardSize)) { return $lead."8".$tail; }
			if ($column == $boardSize) { return $lead."9".$tail; }
		}
	}

	else {return " ";}
}

#======= gameplay

sub play { # this only gets called to deal with input when it's the speaker's turn
	my ($self, $message) = @_;
	
	my @parse = split(' ',$message->{body});
	my $move = shift(@parse);
	@parse = split('',$move);
	
	if ($#parse > 1) {
		$parse[1] = $parse[1].$parse[2];	
	}

	#=== filtering out non-moves

	if (($parse[1] < 1) || ($parse[1] > $boardSize) || (!$coords{$parse[0]})) {	
		return;
	}

	#=== detecting pass

	if ($move =~ /pass/) {
		if ($turn == \$black ) {
			$turn = \$white;
		} else {
			$turn = \$black;
		}
		$self->say(channel => $message->{channel}, body=> "your move, $$turn");
		return;
	}

	#== detecting illegal moves

	my ($i, $j) = &boardPosition(split("", $move));
	my $position = \$activeBoard[$j][$i];

	if ($$position !~ /[\.\+]/) {
		$self->say(channel => $message->{channel}, body => "not a legal move, buddy.");
		return;
	}

	#=== move successful:

	push(@movelog, $move);

	if ($turn == \$black ) {
		$$position = $B;
		$turn = \$white;
	} else {
		$$position = $W;
		$turn = \$black;
	}

	&webBoard(\@activeBoard);

	$self->say(channel => $message->{channel}, body=> "your move, $$turn");
}

sub removePiece {
	my ($self, $message) = @_;

	my $move = &extractMove($self, $message);

	my ($i, $j) = &boardPosition(split("", $move));
	my $position = \$activeBoard[$j][$i];
	
	#== detecting if a piece is there
	if ($$position =~ /[\.\+]/) {
		return "no piece there to remove, pal.";
	}
	
	#== perform remove

	if (($move =~/c3/) || ($move =~ /c7/) || ($move =~ /g3/) || ($move =~ /g7/) || ($move =~ /e5/)) { #HARDCODE BS
		$$position = $H;
	} else {
		$$position = $X;
	}
	
	&webBoard(\@activeBoard);
	return "removed without incrementing captures";
}

sub capturePiece {
	my ($self, $message) = @_;

	my $move = &extractMove($self, $message);

	my ($i, $j) = &boardPosition(split("", $move));
	my $position = \$activeBoard[$j][$i];

	#== detecting if a piece is there
	if ($$position =~ /[\.\+]/) {
		return "no piece there to capture, friend.";
	}
	
	#== perform capture

	if ($$position =~ /$B/ ) {
		if (($move =~/c3/) || ($move =~ /c7/) || ($move =~ /g3/) || ($move =~ /g7/) || ($move =~ /e5/)) { #HARDCODE BS
			$$position = $H;
		} else {
			$$position = $X;
		}

		$bcaps++;
		&webBoard;
		return "black has $bcaps captured pieces";
	} else {
		if (($move =~/c3/) || ($move =~ /c7/) || ($move =~ /g3/) || ($move =~ /g7/) || ($move =~ /e5/)) { #HARDCODE BS
			$$position = $H;
		} else {
			$$position = $X;
		}

		$wcaps++;
		&webBoard;
		return "white has $wcaps captured pieces";
	}
}

sub extractMove { #pulls off a commanded move
	my ($self, $message) = @_;

	my @a = split(' ', $message->{body});
	shift(@a);
	return join(' ', @a);
}

sub boardPosition { #translates a move into real board position
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
			when (/^new/) {
				$self->say(channel => $message->{channel}, body => &newBoard($self, $message));
			}
			when (/i'm black/) { 
				$black = $message->{who};
				$self->say(channel => $message->{channel}, body => "okay, you're black");
			}
			when (/i'm white/) { 
				$white = $message->{who};
				$self->say(channel => $message->{channel}, body => "okay, you're white");
			}
		#== commands
			when (/^remove/) {
				$self->say(channel => $message->{channel}, body => &removePiece($self, $message));
			}
			when (/^capture/) {
				$self->say(channel => $message->{channel}, body => &capturePiece($self, $message));
			}
			when (/^board/) { 
				&printBoard($self, $message); 
			}
			when (/^who/) {
				$self->say(channel => $message->{channel}, body => "black: $black; white: $white");
			}
			when (/^turn/) {
				$self->say(channel => $message->{channel}, body => "it's $$turn\'s turn to play");
			}
			when (/^extra-help/) {
				$self->say(channel => $message->{channel}, body => "commands addressed to me:");
				$self->say(channel => $message->{channel}, body => "'new nxn'; n is some board size between 1 and 19");
				$self->say(channel => $message->{channel}, body => "'i'm black' or 'i'm white' to claim a seat");
				$self->say(channel => $message->{channel}, body => "'board' for an in-channel ascii board printout");
				$self->say(channel => $message->{channel}, body => "'remove (coordinate)' removes a stone from the board without incrementing capture count");
				$self->say(channel => $message->{channel}, body => "'capture (coordinate)' removes a stone and increments captures; yes, you have to do this one at a time (for now)");
				$self->say(channel => $message->{channel}, body => "'who' for current player names; 'turn' to see who's turn it is");
				$self->say(channel => $message->{channel}, body => "passive commands:");
				$self->say(channel => $message->{channel}, body => "when it's your turn, just say the coordinates of the move, or 'pass' to pass. web-rendered board updates every turn.");
			}
		
			default {
				$self->say(channel => $message->{channel}, body => "that's not really something i know how to deal with");
			}
		}
	}

	if ($message->{who} =~ /$$turn/) {
		&play($self, $message);
	}
}

sub chanjoin {
	my ($self, $message) = @_;

	if ($message->{who} =~ $self->{nick}) {
		$self->say(channel => $message->{channel}, body => "hi im awake");
	}
}

sub help {
	return "commands: 'new nxn', 'i'm black', 'i'm white', 'board', 'remove (coord)', 'capture (coord)', 'who', 'turn', '(coord)', 'pass', 'extra-help' for details";
}

#======= INITIALIZATION

Bot->new(
	server   => "irc.freenode.net",
	channels => [ '#kvincent'],
	nick     => 'kvincent-go',
	name     => $BOSS."'s bot",
	quit_message     => "i'm out",
	#flood => 1,
)->run();
