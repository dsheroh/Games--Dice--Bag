use strict;
use warnings;
use 5.010;

use Test::More;
use Test::Deep;

use Games::Dice::Bag ':all';

# rolling a constant returns that constant
{
  is(roll, 0, 'rolling a null spec returns 0');
  is(roll(5), 5, 'rolling a constant returns that constant');
}

# roll a single die
{
  my %res;
  $res{roll('d10')}++ for 1 .. 100;
  cmp_deeply([keys %res], bag(1 .. 10), 'd10 returns rolls from 1 to 10');
}

# support Traveller dice notation (3d)
{
  my %res;
  $res{roll('1d')}++ for 1 .. 100;
  cmp_deeply([keys %res], bag(1 .. 6), '1d returns rolls from 1 to 6');
}

# roll multiple identical dice
{
  my %res;
  $res{roll('2d4')}++ for 1 .. 100;
  cmp_deeply([keys %res], bag(2 .. 8), '2d4 returns rolls from 2 to 8');
}

# roll multiple dissimilar dice
{
  my %res;
  $res{roll('d3+d2')}++ for 1 .. 100;
  cmp_deeply([keys %res], bag(2 .. 5), 'd3+d2 returns rolls from 2 to 5');
}

# support basic arithmetic in rolls, WITHOUT order of operations
{
  is(roll('1+1'),  2, 'support addition');
  is(roll('3-5'), -2, 'support subtraction');
  is(roll('5*9'), 45, 'support multiplication');
  is(roll('28/7'), 4, 'support division');
  is(roll('1+3/2-7*5+18'), -7, 'evaluation is strict left-to-right');
}

# ignore spaces
{
  is(roll(' 1 + 3 - 2 '), 2, 'ignore spaces around constants');
  my %res;
  $res{roll(" 2 d 3 \n - d\t\t 4 + 1 d ")}++ for 1 .. 10000;
  cmp_deeply([keys %res], bag(-1 .. 11), 'ignore whitespace around dice');
}

done_testing;

