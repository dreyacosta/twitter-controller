#!/usr/bin/perl

# Twitter Followers Control
# Version 0.1
#
# by David Rey
# http://dreyacosta.com

use Net::Twitter;

my ($myuser) = @ARGV;

my @ids;
my $flag = 1;

my $descarga_followers = "descarga_followers.txt";
my $misfollowers = "followers_$myuser.txt";
my $historial_followers = "historial_followers_$myuser.txt";

unless($ARGV[0]) {
    print "Usage: perl $0 <user>\n";
    exit 1;
}

print "\nComprobando nuevos followers...\n";

# ESCRIBIR DATOS DE LA API DE TWITTER
my $consumer_key = "XXXXX";
my $consumer_secret = "XXXXX";
my $token = "XXXXX";
my $token_secret = "XXXXX";

my $nt = Net::Twitter->new(
    traits   => [qw/OAuth API::REST/],
    consumer_key        => $consumer_key,
    consumer_secret     => $consumer_secret,
    access_token        => $token,
    access_token_secret => $token_secret,
    );

open (HISTORIAL_FOLLOWERS, ">>", $historial_followers);
open (DESCARGA_FOLLOWERS, ">", $descarga_followers);

my $time = localtime(time);
print HISTORIAL_FOLLOWERS "$time\n";
print HISTORIAL_FOLLOWERS "=====================================================\n\n";
print HISTORIAL_FOLLOWERS "Nuevos followers:\n";

for ( my $cursor = -1, my $r; $cursor; $cursor = $r->{next_cursor} ) {
	$r = $nt->followers({ screen_name =>$myuser,cursor=>$cursor });
	push @ids, @{ $r->{users} };
	
	for my $user (@ids) {
		my $screen_name = $user->{'screen_name'};
                my $full_name = $user->{'name'};

		print DESCARGA_FOLLOWERS "$screen_name\n";
		
		open (FOLLOWERS, $misfollowers);

		while(<FOLLOWERS>) {
			my $follower = $_;
			chomp($follower);
			chomp($screen_name);
			if ($screen_name eq $follower) {
				$flag = 0;
				last;
			}
		}

		close(FOLLOWERS);

		if ($flag == 1) {
			print "\n+ Nuevo follower: $screen_name\n";
			print HISTORIAL_FOLLOWERS "+ $screen_name\n"; 
		}
		$flag = 1;
        }
	splice (@ids);
}

close(DESCARGA_FOLLOWERS);

open(FOLLOWERS, $misfollowers);

print HISTORIAL_FOLLOWERS "\nFollowers perdidos:\n";

print "\nComprobando followers perdidos...\n";

while(<FOLLOWERS>) {
	my $ant_follower = $_;
	
	open(DESCARGA_FOLLOWERS, $descarga_followers);

	while(<DESCARGA_FOLLOWERS>) {
		my $follower = $_;
		chomp($ant_follower);
		chomp($follower);
		
		if($ant_follower eq $follower) {
			$flag = 0;
			last;
		}
	}

	close(DESCARGA_FOLLOWERS);

	if ($flag == 1) {
		print "\n+ Has perdido al follower: $ant_follower\n";

		print HISTORIAL_FOLLOWERS "+ $ant_follower\n";
	}
	$flag = 1;
}

print HISTORIAL_FOLLOWERS "\n\n";

close(FOLLOWERS);
close(HISTORIAL_FOLLOWERS);

system("cp descarga_followers.txt followers_$myuser.txt");
system("rm descarga_followers.txt");