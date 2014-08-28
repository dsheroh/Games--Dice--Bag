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
    roll_die
  );
  our %EXPORT_TAGS = (
    all         => [ @EXPORT, @EXPORT_OK ],
  );
}

sub roll {
  my $raw_spec = shift // '';
  $raw_spec =~ s/\s//g;
  my @spec = split '([-+*/.])', $raw_spec;

  my $roll = 0;
  my $op = '+';
  for (@spec) {
    if (m|[-+*/.]|) {
      $op = $_;
      next;
    }

    my $num = /d/ ? _process_die($_) : $_;
    if    ($op eq '+') { $roll += $num }
    elsif ($op eq '-') { $roll -= $num }
    elsif ($op eq '*') { $roll *= $num }
    elsif ($op eq '/') { $roll /= $num }
    elsif ($op eq '.') { $roll .= $num }
  }

  return $roll;
}

sub roll_die { int rand($_[0]) + 1 }

my %mod_map = (
  '%'   => \&_mod_percent,
  'q'   => \&_mod_quality,
  's'   => \&_mod_stress,
  'x'   => \&_mod_x,
);

sub _process_die {
  my $die = shift;

  my ($rolls, $size, $mod) = $die =~ /(\d*)d(\d*)([qsx%].*)?/;
  $rolls ||= 1;
  my $total = 0;
  if ($mod) {
    for (1 .. $rolls) {
      my $die_total = 0;
      my $tmp_mod = $mod;
      while ($tmp_mod =~ s/^(.)//) {
        ($size, $die_total) = $mod_map{$1}->($size, $die_total)
          if exists $mod_map{$1};
      }
      $total += $die_total;
    }
  }
  return $total if $mod;

  $size  ||= 6;

  $total += roll_die($size) for 1 .. $rolls;

  return $total;
}

sub _mod_percent {
  my ($size, $total) = @_;

  if ($size) {
    $total ||= roll_die($size);
    $total .= roll_die($size);
  } else {
    $total = roll_die($size = 100);
  }

  return ($size, $total);
}

sub _mod_quality {
  my ($size, $total) = @_;
  $size ||= 10;
  
  my $mult = 1;
  my $roll = roll_die($size);
  while ($roll == 1) {
    $mult *= 2;
    $roll = roll_die($size);
  }
  $roll *= $mult;

  return ($size, $total + $roll);
}

sub _mod_stress {
  my ($size, $total) = @_;
  $size ||= 10;

  my $roll = roll_die($size);
  if ($roll == 1) {
    $roll = _mod_quality($size, $total) * 2;
  } elsif ($roll == $size) {
    return ($size, 0);
  }

  return ($size, $total + $roll);
}

sub _mod_x {
  my ($size, $total) = @_;

  $total ||= roll_die($size);
  $total *= roll_die($size);

  return ($size, $total);
}

1;

__END__

# ABSTRACT: Yet another dice roller module

