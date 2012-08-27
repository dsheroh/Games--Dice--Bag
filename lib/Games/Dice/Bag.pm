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

    $_ = _process_die($_) if /d/;

    my $num = $_;
    given ($op) {
      when ('+') { $roll += $num }
      when ('-') { $roll -= $num }
      when ('*') { $roll *= $num }
      when ('/') { $roll /= $num }
    }
  }

  return $roll;
}

sub _process_die {
  my $die = shift;

  my ($rolls, $size, $mod) = $die =~ /(\d*)d(\d*)([x%]*)/;
  if (!$size && $mod =~ /^%(.*)/) {
    $size = 100;
    $mod = $1;
  }
  $rolls ||= 1;
  $size  ||= 6;

  my $total = $rolls;
  $total += int rand($size) for 1 .. $rolls;

  return $total;
}

1;

