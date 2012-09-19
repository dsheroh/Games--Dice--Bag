package Games::Dice::Bag;

use strict;
use warnings;
use 5.010;

our $VERSION  = '1.0.0';

use base 'Exporter';
BEGIN {
  our @EXPORT = ();
  our @EXPORT_OK = qw(
    roll
  );
  our %EXPORT_TAGS = (
    all         => [ @EXPORT, @EXPORT_OK ],
  );
}

sub roll {
  my $raw_spec = shift // '';
  $raw_spec =~ s/\s//g;
  my @spec = split '([-+*/])', $raw_spec;

  my $roll = 0;
  my $op = '+';
  for (@spec) {
    if (m|[-+*/]|) {
      $op = $_;
      next;
    }

    my $num = /d/ ? _process_die($_) : $_;
    given ($op) {
      when ('+') { $roll += $num }
      when ('-') { $roll -= $num }
      when ('*') { $roll *= $num }
      when ('/') { $roll /= $num }
    }
  }

  return $roll;
}

my %mod_map = (
  '%'   => \&_mod_percent,
);

sub _process_die {
  my $die = shift;

  my ($rolls, $size, $mod) = $die =~ /(\d*)d(\d*)([x%]*)/;
  my $total = 0;
  while ($mod =~ s/^(.)//) {
    ($rolls, $size, $mod, $total) = $mod_map{$1}->($rolls, $size, $mod, $total)
      if exists $mod_map{$1};
  }

  $rolls ||= 1;
  $size  ||= 6;

  $total ||= $rolls;
  $total += int rand($size) for 1 .. $rolls;

  return $total;
}

sub _mod_percent {
  my ($rolls, $size, $mod, $total) = @_;

  $size = 100;

  return ($rolls, $size, $mod, $total);
}

1;

