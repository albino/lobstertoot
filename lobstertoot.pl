#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;
use Mastodon::Client;
use JSON::Tiny qw/encode_json decode_json/;
use File::Slurp;
use LWP::UserAgent;

my $s = decode_json read_file("state.json");

my $ua = new LWP::UserAgent;
$ua->agent("lobstertoot (".$ua->_agent.") - for info contact albino\@autistici.org");
my $resp = $ua->get("$s->{lobsters}->{url}/hottest.json");
die unless $resp->is_success;
my $stories = decode_json $resp->decoded_content;

my $masto = new Mastodon::Client (
  name => "lobstertoot",
  coerce_entities => 1,
  %{ $s->{masto} },
);

for my $story (@{$stories}) {
  next if grep {$_ eq $story->{short_id}} @{ $s->{lobsters}->{storiesdone} };

  my $toot = "$story->{title} $story->{url} | $s->{lobsters}->{url}/s/$story->{short_id}";
  for (@{ $story->{tags} }) {
    $toot .= " #$_";
  }

  $masto->post_status($toot);

  push @{ $s->{lobsters}->{storiesdone} }, $story->{short_id};
  shift @{ $s->{lobsters}->{storiesdone} } if scalar(@{ $s->{lobsters}->{storiesdone} }) > 500;
}

open my $fh, ">state.json" or die $!;
print $fh encode_json($s);
close $fh;
