#!/usr/bin/perl -w

# Given the field centre of an omegacam field and the coords of a
# target object tells you which hdu to use in gaia to look at it.
#
# For example:
# ./which_chip.pl 19 3 31.7 1 56 7.6 19 02 15.0 1 48 48.0 
# or
# which_chip.pl 18 35 3.3 -04 39 18.5   18 35 4.3 -4 36 00 gaia
#
use strict;

if ($#ARGV == 0){

    print "Field centre of the Omegacam field?\n";
    my $centre_coords = <STDIN>; 
    chomp $centre_coords; # Get rid of newline character at the end
    exit 0 if ($centre_coords eq ""); # If empty string, exit.
    
    print "Target coords?\n";
    my $target_coords = <STDIN>;
    chomp $target_coords; # Get rid of newline character at the end
    exit 0 if ($target_coords eq ""); # If empty string, exit.
}

#print "Number of arguments is $#ARGV \n";
#use Data::Dumper qw(Dumper);
 
#print Dumper \@ARGV;

if ($#ARGV != 11 and $#ARGV != 12 ){
    print "Usage: \n";
    print "./which_chip.pl centre_ra_h centre_ra_m centre_ra_s target_ra_h target_ra_m target_ra_s\n";
    print "or\n";
    print "./which_chip.pl centre_ra_h centre_ra_m centre_ra_s target_ra_h target_ra_m target_ra_s gaia\n";
    die "Wrong number of input coordinates\n";
}

my $centre_coords = join(' ',$ARGV[0],$ARGV[1],$ARGV[2],$ARGV[3],$ARGV[4],$ARGV[5]);
my $target_coords = join(' ',$ARGV[6],$ARGV[7],$ARGV[8],$ARGV[9],$ARGV[10],$ARGV[11]);

print "Field centre is $centre_coords \n";
print "Target coords are $target_coords \n";

# Convert field centre coordinates from sexagesimal hms to degrees
my @centre_coords_arr = split('\s',$centre_coords);

my $centre_ra_h=$centre_coords_arr[0]; 
my $centre_ra_m=$centre_coords_arr[1];
my $centre_ra_s=$centre_coords_arr[2];

my $centre_dec_d=$centre_coords_arr[3]; 
my $centre_dec_m=$centre_coords_arr[4];
my $centre_dec_s=$centre_coords_arr[5];

# convert sexagesimal to degrees
my $centre_ra_deg = ($centre_ra_h * 15) + ($centre_ra_m/4.0) + ($centre_ra_s/240.0) ;
print "Centre ra in degrees is $centre_ra_deg \n";

#print "centre coords are: \n";
#print "$centre_ra_h $centre_ra_m $centre_ra_s $centre_dec_d $centre_dec_m $centre_dec_s \n";

my $centre_dec_deg = 0.0;

if ($centre_dec_d >= 0){
    $centre_dec_deg = $centre_dec_d + ($centre_dec_m/60.0) + ($centre_dec_s/3600) ;
} else {
    $centre_dec_deg = $centre_dec_d - ($centre_dec_m/60.0) - ($centre_dec_s/3600) ;
}

print "Centre dec in degrees is $centre_dec_deg \n";

# Convert target coordinates from sexagesimal to degrees

my @target_coords_arr = split('\s',$target_coords);
my $target_ra_h=$target_coords_arr[0]; 
my $target_ra_m=$target_coords_arr[1];
my $target_ra_s=$target_coords_arr[2];

my $target_dec_d=$target_coords_arr[3]; 
my $target_dec_m=$target_coords_arr[4];
my $target_dec_s=$target_coords_arr[5];

# convert sexagesimal to degrees
my $target_ra_deg = ($target_ra_h * 15) + ($target_ra_m/4.0) + ($target_ra_s/240.0) ;

#print "target coords are: \n";
#print "$target_ra_h $target_ra_m $target_ra_s $target_dec_d $target_dec_m $target_dec_s \n";
    
print "target ra in degrees is $target_ra_deg \n";

my $target_dec_deg = 0.0;
if ($target_dec_d >= 0){
    $target_dec_deg = $target_dec_d + ($target_dec_m/60.0) + ($target_dec_s/3600) ;
} else {
    $target_dec_deg = $target_dec_d - ($target_dec_m/60.0) - ($target_dec_s/3600) ;
}

print "target dec in degrees is $target_dec_deg \n";

# Calculate limits of image
# From 
# http://www.eso.org/sci/facilities/paranal/instruments/omegacam/doc/VST-MAN-OCM-23100-3110_p96.pdf
# each image is 7.3' x 14.6' which is 0.122 x 0.244 degrees.
# The gap between long sides is 21.5" which is 0.00597 degrees
# The central gap between the short sides is 11.8 which is 0.00328
# The wide gap along the short sides is 80.5 which is 0.0224
my $short_width = 0.122;
my $long_width = 0.244;
my $long_side_gap = 0.00597;
my $central_gap_short_sides = 0.00328;
my $wide_gap_short_sides = 0.0224;

# check whether target is in the image.

# Start with bottom left corner.
my $image_bottom_left_ra =  $centre_ra_deg - (4 * $short_width) - (3.5 * $long_side_gap);
my $image_bottom_left_dec =  $centre_dec_deg - (2 * $long_width) - ($central_gap_short_sides/2) - $wide_gap_short_sides ;

#print "Coordinates of image bottom left are $image_bottom_left_ra $image_bottom_left_dec \n";

if ($target_ra_deg < $image_bottom_left_ra  or $target_dec_deg < $image_bottom_left_dec ){
    die "1 target coords are not within image \n\n";
}

# Top left corner.
my $image_top_left_ra =  $centre_ra_deg - (4 * $short_width) - (3.5 * $long_side_gap);
my $image_top_left_dec =  $centre_dec_deg + (2 * $long_width) + ($central_gap_short_sides/2) + $wide_gap_short_sides ;

#print "Coordinates of image top left are $image_top_left_ra $image_top_left_dec \n";

if ($target_ra_deg < $image_top_left_ra  or $target_dec_deg > $image_top_left_dec ){
    die "2 target coords are not within image \n\n";
}

# Top right corner.
my $image_top_right_ra =  $centre_ra_deg + (4 * $short_width) + (3.5 * $long_side_gap);
my $image_top_right_dec =  $centre_dec_deg + (2 * $long_width) + ($central_gap_short_sides/2) + $wide_gap_short_sides ;

#print "Coordinates of image top right are $image_top_right_ra $image_top_right_dec \n";

if ($target_ra_deg > $image_top_right_ra  or $target_dec_deg > $image_top_right_dec ){
    print "target_ra_deg  image_top_right_ra  target_dec_deg  image_top_right_dec \n";
    print "$target_ra_deg  $image_top_right_ra  $target_dec_deg  $image_top_right_dec \n";
    die "3 target coords are not within image \n\n";
}

# Bottom right corner.
my $image_bottom_right_ra =  $centre_ra_deg + (4 * $short_width) + (3.5 * $long_side_gap);
my $image_bottom_right_dec =  $centre_dec_deg - (2 * $long_width) - ($central_gap_short_sides/2) - $wide_gap_short_sides ;

#print "Coordinates of image bottom right are $image_bottom_right_ra $image_bottom_right_dec \n";

if ($target_ra_deg > $image_bottom_right_ra  or $target_dec_deg < $image_bottom_right_dec ){
    die "4 target coords are not within image \n\n";
}

# Now assign an x and y coordinate to the chip.
# 1,1 is bottom left, 8,4 is top right.
my $xcoord = 0;
my $ycoord = 0;
my $lower_ra = 0.0;
my $higher_ra = 0.0;
my $lower_dec = 0.0;
my $higher_dec = 0.0;

$lower_ra = $image_bottom_left_ra;
$higher_ra = $lower_ra + $short_width;
if ($target_ra_deg > $lower_ra and $target_ra_deg < $higher_ra){
    $xcoord = 1;}
#print "lower_ra is $lower_ra target_ra_deg is $target_ra_deg higher_ra is $higher_ra\n";

$lower_ra = $image_bottom_left_ra + $short_width + $long_side_gap;
$higher_ra = $lower_ra + $short_width;
if ($target_ra_deg > $lower_ra and $target_ra_deg < $higher_ra){
    $xcoord = 2;}
#print "lower_ra is $lower_ra target_ra_deg is $target_ra_deg higher_ra is $higher_ra\n";

$lower_ra = $image_bottom_left_ra + (2 * $short_width) + (2 * $long_side_gap);
$higher_ra = $lower_ra + $short_width;
if ($target_ra_deg > $lower_ra and $target_ra_deg < $higher_ra){
    $xcoord = 3;}
#print "lower_ra is $lower_ra target_ra_deg is $target_ra_deg higher_ra is $higher_ra\n";

$lower_ra = $image_bottom_left_ra + (3 * $short_width) + (3 * $long_side_gap);
$higher_ra = $lower_ra + $short_width;
if ($target_ra_deg > $lower_ra and $target_ra_deg < $higher_ra){
    $xcoord = 4;}
#print "lower_ra is $lower_ra target_ra_deg is $target_ra_deg higher_ra is $higher_ra\n";

$lower_ra = $image_bottom_left_ra + (4 * $short_width) + (4 * $long_side_gap);
$higher_ra = $lower_ra + $short_width;
if ($target_ra_deg > $lower_ra and $target_ra_deg < $higher_ra){
    $xcoord = 5;}
#print "lower_ra is $lower_ra target_ra_deg is $target_ra_deg higher_ra is $higher_ra\n";

$lower_ra = $image_bottom_left_ra + (5 * $short_width) + (5 * $long_side_gap);
$higher_ra = $lower_ra + $short_width;
if ($target_ra_deg > $lower_ra and $target_ra_deg < $higher_ra){
    $xcoord = 6;}
#print "lower_ra is $lower_ra target_ra_deg is $target_ra_deg higher_ra is $higher_ra\n";

$lower_ra = $image_bottom_left_ra + (6 * $short_width) + (6 * $long_side_gap);
$higher_ra = $lower_ra + $short_width;
if ($target_ra_deg > $lower_ra and $target_ra_deg < $higher_ra){
    $xcoord = 7;}
#print "lower_ra is $lower_ra target_ra_deg is $target_ra_deg higher_ra is $higher_ra\n";

$lower_ra = $image_bottom_left_ra + (7 * $short_width) + (7 * $long_side_gap);
$higher_ra = $lower_ra + $short_width;
if ($target_ra_deg > $lower_ra and $target_ra_deg < $higher_ra){
    $xcoord = 8;}
#print "lower_ra is $lower_ra target_ra_deg is $target_ra_deg higher_ra is $higher_ra\n";

# Same for Dec
$lower_dec = $image_bottom_left_dec ;
$higher_dec = $lower_dec + $long_width;
if ($target_dec_deg > $lower_dec and $target_dec_deg < $higher_dec){
    $ycoord  = 1;}
#print "lower_dec is $lower_dec target_dec_deg is $target_dec_deg higher_dec is $higher_dec\n";

$lower_dec = $image_bottom_left_dec + $long_width + $wide_gap_short_sides;
$higher_dec = $lower_dec + $long_width;
if ($target_dec_deg > $lower_dec and $target_dec_deg < $higher_dec){
    $ycoord = 2;}
#print "lower_dec is $lower_dec target_dec_deg is $target_dec_deg higher_dec is $higher_dec\n";

$lower_dec = $image_bottom_left_dec + (2 * $long_width) + $wide_gap_short_sides + $central_gap_short_sides;
$higher_dec = $lower_dec + $long_width;
if ($target_dec_deg > $lower_dec and $target_dec_deg < $higher_dec){
    $ycoord = 3;}
#print "lower_dec is $lower_dec target_dec_deg is $target_dec_deg higher_dec is $higher_dec\n";

$lower_dec = $image_bottom_left_dec + (3 * $long_width) + (2 * $wide_gap_short_sides) + $central_gap_short_sides;
$higher_dec = $lower_dec + $long_width;
if ($target_dec_deg > $lower_dec and $target_dec_deg < $higher_dec){
    $ycoord = 4;}
#print "lower_dec is $lower_dec target_dec_deg is $target_dec_deg higher_dec is $higher_dec\n";

#print "xcoord is $xcoord  ycoord is $ycoord \n";

# If xcoord or ycoord not set, then target is on a gap.
if ($xcoord == 0 or $ycoord == 0){
    die "the object is on a gap, try another image";}


my $hdu_number = 0;
if ( $xcoord <= 4){
    $hdu_number = (($ycoord - 1) * 4) + $xcoord + 1;
    print "Try hdu = $hdu_number \n";
} else {
    $hdu_number = (($ycoord - 1) * 4) + ($xcoord - 4) + 16 + 1;
    print "Try hdu = $hdu_number \n";
}

my $gaia_cmdline = ' ';
my $imcopy_cmdline = ' ';
my $image_number = $hdu_number - 1; # This is $hdu_number -1 for imcopy command

if (/gaia/i ~~ @ARGV){
    print "opening image with gaia \n";
    print "Name of image file?\n";
    my $filename = <STDIN>; 
    chomp $filename; # Get rid of newline character at the end
    exit 0 if ($filename eq ""); # If empty string, exit.
    if (-e $filename ){
	$imcopy_cmdline = 'rm -f temp.fit; /usr/local/bin/imcopy '. $filename . '[' . $image_number .']' . ' temp.fit';
	print "Running $imcopy_cmdline \n";
	system($imcopy_cmdline);
	$gaia_cmdline = "/bin/tcsh << EOF \n source /usr/local/starlink/etc/login ; source /usr/local/starlink/etc/cshrc; gaia temp.fit \nEOF";
        print "Running $gaia_cmdline  \n";
	system("$gaia_cmdline");
}

         
	


# If empty string, exit.
    
}


#$hdu_number = ($ycoord - 1) * 8 + $xcoord;
#print "Try CCD or HDU number $hdu_number \n\n";

    exit;

