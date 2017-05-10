#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;
use Mastodon::Client;
use YAML::Tiny;
use IO::Prompt;
use JSON::Tiny qw/encode_json/;

my $inst = prompt("Instance hostname (e.g. mastodon.social): ")->{value};

my $masto = new Mastodon::Client (
  instance => $inst,
  name => "lobstertoot",
  website => "https://git.fuwafuwa.moe/albino/lobstertoot",
  scopes => ["write"],
  coerce_entities => 1,
);

$masto->register();

say STDERR "Authorize your mastodon account at " . $masto->authorization_url . " and enter the access code here.";
my $acode = prompt("Access code: ")->{value};

$masto->authorize(
  access_code => $acode,
);

say encode_json(
  {
    masto => {
      client_id => $masto->client_id,
      client_secret => $masto->client_secret,
      access_token => $masto->access_token,
    },
    lobsters => {
      url => "https://lobste.rs",
    },
  }
);
