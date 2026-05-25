#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;
use File::Basename qw(dirname basename);
use File::Copy qw(copy);
use Cwd qw(abs_path);

$| = 1;
umask(0077);

sub usage {
    print STDERR "Usage: $0 [-he] [-f <prefix>] [-s <simdir>]\n";
    print STDERR "Options:\n";
    print STDERR "  -h           Print this message.\n";
    print STDERR "  -e           Accepted for compatibility; input files are not printed.\n";
    print STDERR "  -f <prefix>  Use <prefix>-pipe-full.hcl and <prefix>-ncopy.ys.\n";
    print STDERR "               If omitted, use <simdir>/pipe/pipe-full.hcl and <simdir>/pipe/ncopy.ys.\n";
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
my ($hcl_file, $ncopy_file, $label);
if ($opts{f}) {
    $hcl_file = "$opts{f}-pipe-full.hcl";
    $ncopy_file = "$opts{f}-ncopy.ys";
    $label = basename($opts{f});
} else {
    $hcl_file = "$simdir/pipe/pipe-full.hcl";
    $ncopy_file = "$simdir/pipe/ncopy.ys";
    $label = "local";
}

my $tmpdir = "/tmp/archlabc-$label.$$";
my @partc_scores = (0);
my $aok = 1;

(-d $simdir) or die "$0: ERROR: Can't access $simdir\n";
(-r $hcl_file) or die "$0: ERROR: could not open file $hcl_file\n";
(-r $ncopy_file) or die "$0: ERROR: could not open file $ncopy_file\n";

my $work = copy_sim_tree($simdir, $tmpdir);

print "\nPart C: Local Test Report for $label\n\n";

print "Part 1: Building simulator\n\n";
copy($hcl_file, "$work/pipe/pipe-full.hcl")
    or die "ERROR: Could not copy HCL file: $!\n";
copy($ncopy_file, "$work/pipe/ncopy.ys")
    or die "ERROR: Could not copy ncopy file: $!\n";
run_or_die("(cd " . shq("$work/misc") . "; make -s clean; make -s all > /dev/null)",
           "ERROR: Could not make misc tools");
run_or_die("(cd " . shq("$work/pipe") . "; make -s clean; make -s VERSION=full GUIMODE= TKLIBS= TKINC= psim)",
           "ERROR: Could not make PIPE simulator");

print "\n**********\n";
print "Part 2: Benchmark regression tests on psim\n";
print "**********\n";
if (system("(cd " . shq("$work/y86-code") . "; make testpsim > outfile 2>&1)") != 0) {
    $aok = 0;
    warn "ERROR: Could not run benchmark regression tests\n";
}
my $outfile = slurp("$work/y86-code/outfile");
print $outfile;
my ($succeed, $total) = (0, 0);
while ($outfile =~ m/Succeed/g) { $succeed++; $total++; }
while ($outfile =~ m/Fails/g) { $total++; }
print "\nPassed $succeed/$total benchmark regression tests\n";
if ($succeed != $total) { $aok = 0; }

print "\n**********\n";
print "Part 3: Extensive regression tests\n";
print "**********\n";
run_or_die("(cd " . shq("$work/ptest") . "; make SIM=../pipe/psim TFLAGS= > outfile 2>&1)",
           "ERROR: Could not run extensive regression tests");
$outfile = slurp("$work/ptest/outfile");
print $outfile;
($succeed, $total) = (0, 0);
while ($outfile =~ m/All (\d+) ISA Checks Succeed/g) { $succeed += $1; $total += $1; }
while ($outfile =~ m/(\d+)\/(\d+) ISA Checks Failed/g) { $succeed += ($2 - $1); $total += $2; }
print "\nPassed $succeed/$total extensive regression tests\n";
if ($succeed != $total) { $aok = 0; }

print "\n**********\n";
print "Part 4: Correctness of ncopy program running on ISA simulator\n";
print "**********\n";
run_or_die("(cd " . shq("$work/pipe") . "; ./correctness.pl -f ncopy.ys > outfile 2>&1)",
           "ERROR: Could not run ncopy correctness tests");
$outfile = slurp("$work/pipe/outfile");
print $outfile;
$outfile =~ m/(\d+)\/(\d+) pass correctness test/;
($succeed, $total) = ($1, $2);
if ($succeed != $total) { $aok = 0; }

print "\n**********\n";
print "Part 5: Correctness of ncopy program running on pipeline simulator\n";
print "**********\n";
run_or_die("(cd " . shq("$work/pipe") . "; ./correctness.pl -p -f ncopy.ys > outfile 2>&1)",
           "ERROR: Could not run ncopy correctness tests on pipeline simulator");
$outfile = slurp("$work/pipe/outfile");
print $outfile;
$outfile =~ m/(\d+)\/(\d+) pass correctness test/;
($succeed, $total) = ($1, $2);
if ($succeed != $total) { $aok = 0; }

print "\n**********\n";
print "Part 6: Performance test\n";
print "**********\n";
run_or_die("(cd " . shq("$work/pipe") . "; ./benchmark.pl -f ncopy.ys > outfile 2>&1)",
           "ERROR: Could not run ncopy performance tests");
$outfile = slurp("$work/pipe/outfile");
print $outfile;
my $score = 0;
if ($outfile =~ m/Score\t(\d+.\d+)\/(\d+.\d+)/) {
    $score = $1;
}
if ($aok) {
    $partc_scores[0] = $score;
} else {
    print "\nNote: Performance score will be zero because of previous correctness issues\n";
}

print "\nPARTC_SCORES = $partc_scores[0]\n";

system("rm -fr " . shq($tmpdir));
exit;
