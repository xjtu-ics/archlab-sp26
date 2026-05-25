#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;
use File::Basename qw(dirname basename);
use File::Copy qw(copy);
use Cwd qw(abs_path);

$| = 1;
umask(0077);

my $REGRESSION_POINTS = 10;
my $IADDQ_POINTS = 15;
my $LEAVE_POINTS = 15;

sub usage {
    print STDERR "Usage: $0 [-he] [-f <seq-full.hcl>] [-s <simdir>]\n";
    print STDERR "Options:\n";
    print STDERR "  -h           Print this message.\n";
    print STDERR "  -e           Accepted for compatibility; input files are not printed.\n";
    print STDERR "  -f <file>    HCL file to test. Defaults to <simdir>/seq/seq-full.hcl.\n";
    print STDERR "  -s <simdir>  Simulator directory. Defaults to this script's parent directory.\n";
    die "\n";
}

sub shq {
    my $s = shift;
    $s =~ s/'/''"'"'/g;
    return "'$s'";
}

sub run_or_die {
    my ($cmd, $msg) = @_;
    system($cmd) == 0 or die "$msg\n";
}

sub slurp {
    my $file = shift;
    open(my $fh, "<", $file) or die "ERROR: could not open $file: $!\n";
    local $/;
    return <$fh>;
}

sub copy_sim_tree {
    my ($simdir, $tmpdir) = @_;
    mkdir($tmpdir) or die "ERROR: mkdir $tmpdir failed: $!\n";
    my $work = "$tmpdir/sim";
    mkdir($work) or die "ERROR: mkdir $work failed: $!\n";
    foreach my $dir ("misc", "seq", "pipe", "ptest", "y86-code") {
        run_or_die("cp -R " . shq("$simdir/$dir") . " " . shq("$work/$dir"),
                   "ERROR: could not copy $dir into $work");
    }
    foreach my $file ("Makefile", "README.md") {
        copy("$simdir/$file", "$work/$file") if -e "$simdir/$file";
    }
    return $work;
}

my %opts;
getopts('hef:s:', \%opts);
usage() if $opts{h};

my $script_dir = dirname(abs_path($0));
sub default_simdir {
    my $parent = abs_path("$script_dir/..");
    return $parent if -d "$parent/misc" && -d "$parent/seq" && -d "$parent/pipe";
    return "$parent/sim" if -d "$parent/sim/misc" && -d "$parent/sim/seq" && -d "$parent/sim/pipe";
    return $parent;
}

my $simdir = $opts{s} ? abs_path($opts{s}) : default_simdir();
my $infile = $opts{f} ? $opts{f} : "$simdir/seq/seq-full.hcl";
my $infile_basename = basename($infile);
my $tmpdir = "/tmp/archlabb-$$";
my @partb_scores = (0, 0, 0);
my $aok = 1;

(-d $simdir) or die "$0: ERROR: Can't access $simdir\n";
(-r $infile) or die "$0: ERROR: Could not open $infile\n";

my $work = copy_sim_tree($simdir, $tmpdir);

print "\nPart B: Local Test Report for $infile_basename\n\n";

print "**********\n";
print "Part 1: Building simulator using $infile...\n";
print "**********\n";
copy($infile, "$work/seq/seq-full.hcl")
    or die "ERROR: Could not copy input file $infile: $!\n";
run_or_die("(cd " . shq("$work/misc") . "; make -s clean; make -s all > /dev/null)",
           "ERROR: Could not make misc tools");
run_or_die("(cd " . shq("$work/seq") . "; make -s clean; make -s VERSION=full GUIMODE= TKLIBS= TKINC= ssim)",
           "ERROR: Could not make SEQ simulator");

print "\n**********\n";
print "Part 2: Benchmark regression tests\n";
print "**********\n";
if (system("(cd " . shq("$work/y86-code") . "; make testssim > outfile 2>&1)") != 0) {
    $aok = 0;
    warn "ERROR: Could not run benchmark regression tests\n";
}
my $outfile = slurp("$work/y86-code/outfile");
print $outfile;
my ($succeed, $total) = (0, 0);
while ($outfile =~ m/Succeed/g) { $succeed++; $total++; }
while ($outfile =~ m/Fails/g) { $total++; }
print "\nPassed $succeed/$total benchmark regression tests\n";
if ($succeed == $total) { $partb_scores[0] = $REGRESSION_POINTS; }
print "Score: $partb_scores[0]/$REGRESSION_POINTS\n";

print "\n**********\n";
print "Part 3: Extensive regression tests for iaddq\n";
print "**********\n";
run_or_die("(cd " . shq("$work/ptest") . "; make SIM=../seq/ssim TFLAGS=-i > outfile 2>&1)",
           "ERROR: Could not run extensive regression tests for iaddq. Files are in $tmpdir.");
$outfile = slurp("$work/ptest/outfile");
print $outfile;
($succeed, $total) = (0, 0);
while ($outfile =~ m/All (\d+) ISA Checks Succeed/g) { $succeed += $1; $total += $1; }
while ($outfile =~ m/(\d+)\/(\d+) ISA Checks Failed/g) { $succeed += ($2 - $1); $total += $2; }
print "\nPassed $succeed/$total tests\n";
if ($succeed == $total) { $partb_scores[1] = $IADDQ_POINTS; }
print "Score: $partb_scores[1]/$IADDQ_POINTS\n";

print "\n**********\n";
print "Part 4: Extensive regression tests for leave\n";
print "**********\n";
run_or_die("(cd " . shq("$work/ptest") . "; rm -f outfile; make SIM=../seq/ssim TFLAGS=-l > outfile 2>&1)",
           "ERROR: Could not run extensive regression tests for leave");
$outfile = slurp("$work/ptest/outfile");
print $outfile;
($succeed, $total) = (0, 0);
while ($outfile =~ m/All (\d+) ISA Checks Succeed/g) { $succeed += $1; $total += $1; }
while ($outfile =~ m/(\d+)\/(\d+) ISA Checks Failed/g) { $succeed += ($2 - $1); $total += $2; }
print "\nPassed $succeed/$total tests\n";
if ($succeed == $total) { $partb_scores[2] = $LEAVE_POINTS; }
print "Score: $partb_scores[2]/$LEAVE_POINTS\n";

print "\nPARTB_SCORES = $partb_scores[0]:$partb_scores[1]:$partb_scores[2]\n";

system("rm -fr " . shq($tmpdir)) if $aok;
exit;
