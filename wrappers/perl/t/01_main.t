#!/usr/bin/perl -w

use strict;
use warnings;
use Test::More tests => 33;
use Cwd;

use Xray::FeffPath;

my $here = cwd;
chdir('t') if (cwd !~ m{t\z});

my $epsilon = 1e-4;

my $path = Xray::FeffPath->new();
ok(ref($path) =~ m{FeffPath},								  "object created ".$path);



my $ret = $path->create_path;
ok($ret == $path,									  "called create_path");


my $str = "../../fortran/phase.bin";
$path->phbin($str);
##print $path->phbin, $/;
##(-e $path->phbin) ? print "ok\n" : print "nope\n";
(my $phbin = $path->phbin) =~ s{\s+\z}{};
ok($path->phbin eq $phbin,                                                                "set and read phbin");
ok($path->wrapper->swig_phbin_get eq $phbin ,                                             "low level phbin");

$path->deg(48);
ok($path->deg == 48,									  "set and read degeneracy");
ok($path->wrapper->swig_deg_get == 48,							  "low level deg");



ok($path->Index == 9999,								  "default index");
$path->Index(4);
ok($path->Index == 4,									  "set and read index");
ok($path->wrapper->swig_index_get == 4,							  "low level index");



ok($path->iorder == 2,									  "default iorder");
ok($path->wrapper->swig_iorder_get == 2,						  "low level iorder");



$path->nnnn(1);
ok($path->nnnn,										  "set and read nnnn (boolean)");



$path->evec([0,0,1]);
ok((($path->evec->[0] == 0) and ($path->evec->[1] == 0) and ($path->evec->[2] == 1)),	  "set and read evec");
$path->evec([0,0,0]);
ok((($path->evec->[0] == 0) and ($path->evec->[1] == 0) and ($path->evec->[2] == 0)),	  "unset evec");



$path->xivec([1,1,0]);
ok((($path->xivec->[0] == 1) and ($path->xivec->[1] == 1) and ($path->xivec->[2] == 0)),  "set and read xivec");
$path->xivec([0,0,0]);
ok((($path->xivec->[0] == 0) and ($path->xivec->[1] == 0) and ($path->xivec->[2] == 0)),  "unset xivec");



$path->atom( 0,     0, -3.610, 1);
ok($path->nleg == 2,									  "added first scatterer");



$path->atom(-1.805, 0, -1.805, 1);
ok($path->nleg == 3,									  "added second scatterer");
ok($path->wrapper->swig_nleg_get == 3,							  "low level nleg");


$ret = $path->path;
ok($ret == $path,									  "called path");



ok(( ( abs($path->ri->[0] - 3.61)    < $epsilon) and
     ( abs($path->ri->[1] - 2.55266) < $epsilon) and
     ( abs($path->ri->[2] - 2.55266) < $epsilon) ),					  "ri set correctly");



ok(( ( abs($path->beta->[0] - 135) < $epsilon) and
     ( abs($path->beta->[1] -  90) < $epsilon) and
     ( abs($path->beta->[2] - 135) < $epsilon) ),					  "beta set correctly");



ok(-e 'f3ff0004.dat',									  "feffNNNN.dat file written");
unlink 'f3ff0004.dat';

$path->clear;
ok($path->Index == 9999,								  "path reset");



$path->atom( 0,     0, -3.610, 9);
ok($path->errorcode == 2,                                                                 "error recognized: ipot too big");
$path->clear;



$path->atom( 0,     0, -3.610, -1);
ok($path->errorcode == 1,                                                                 "error recognized: ipot negative");
$path->clear;




$path->atom( 0,     0, -3.610, 1);
$path->atom( 0,     0, -3.710, 1);
ok($path->errorcode == 4,                                                                 "error recognized: atoms too close");
$path->clear;



$path->atom( 0, 0,  0,     1);
$path->atom( 0, 0, -3.61,  1);
$path->path;
ok($path->errorcode == 1,                                                                 "error recognized: begins with absorber");
$path->clear;



$path->atom( 0, 0, -3.61,  1);
$path->atom( 0, 0,  0,     1);
$path->path;
ok($path->errorcode == 2,                                                                 "error recognized: ends with absorber");
$path->clear;



$path->deg(-48);
$path->atom( 0,     0, -3.61,  1);
$path->atom(-1.805, 0, -1.805, 1);
$path->path;
ok($path->errorcode == 4,                                                                 "error recognized: negative degeneracy");
$path->clear;



$path->Index(40000);
$path->atom( 0,     0, -3.61,  1);
$path->atom(-1.805, 0, -1.805, 1);
$path->path;
ok($path->errorcode == 8,                                                                 "error recognized: bad index");
$path->clear;



$path->elpty(-0.5);
$path->atom( 0,     0, -3.61,  1);
$path->atom(-1.805, 0, -1.805, 1);
$path->path;
ok($path->errorcode == 16,                                                                "error recognized: bad elpty");
$path->clear;



$path->iorder(-1);
$path->atom( 0,     0, -3.61,  1);
$path->atom(-1.805, 0, -1.805, 1);
$path->path;
ok($path->errorcode == 32,                                                                "error recognized: bad iorder");
#$path->clear;



$path->clean;
undef $path;
#ok(1, "after destruction");
chdir($here);
## fails here,  SIGSEGV (wait status: 139) or SIGFPE (134)

