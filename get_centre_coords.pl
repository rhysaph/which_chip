#!/usr/bin/perl -w

# print centre coordinates of fits image
# usage ./get_centre_coords.pl img_name rah ram ras decd decm decs

use warnings;
use strict;

use Astro::WCS::LibWCS qw( :functions ); # export function names
use Astro::WCS::LibWCS qw( :constants ); # export constant names

use Data::Dumper qw(Dumper);


#
if ($#ARGV != 6){
    print "program usage\n";
    print "Number of arguemnts is $#ARGV should be 8 \n";
    print "./get_centre_coords.pl img_name rah ram ras decd decm decs\n";
    exit;
}

print Dumper \@ARGV;


print "Got to here!\n";

exit
