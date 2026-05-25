#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;
use File::Basename qw(dirname basename);
use File::Copy qw(copy);
use Cwd qw(abs_path);

$| = 1;
umask(0077);

my @PROGS = ("sum", "rsum", "copy");
my $POINTS_PER_PROBLEM = 10;
my $EXPECTED_RAX = "0x0000000000000cba";

sub usage {
    print STDERR "Usage: $0 [-he] [-f <prefix>] [-s <simdir>]\n";
    print STDERR "Options:\n";
    print STDERR "  -h           Print this message.\n";
    print STDERR "  -e           Accepted for compatibility; source files are not printed.\n";
    print STDERR "  -f <prefix>  Use <prefix>-sum.ys, <prefix>-rsum.ys, and <prefix>-copy.ys.\n";
    print STDERR "               If omitted, use <simdir>/misc/sum.ys, rsum.ys, and copy.ys.\n";
    print STDERR "  -s <simdir>  Directory containing misc/yas and misc/yis.\n";
    die "\n";
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
my $miscdir = "$simdir/misc";
my $yas = "$miscdir/yas";
my $yis = "$miscdir/yis";

(-d $miscdir) or die "$0: ERROR: Can't access directory $miscdir\n";
print "Building yas and yis in $miscdir...\n";
system("make", "-s", "-C", $miscdir, "yas", "yis") == 0
    or die "$0: ERROR: Unable to build yas and yis in $miscdir\n";

(-x $yas) or die "$0: ERROR: Can't access executable $yas\n";
(-x $yis) or die "$0: ERROR: Can't access executable $yis\n";

my $prefix = $opts{f};
my $label = defined($prefix) ? basename($prefix) : "local";
my $tmpdir = "/tmp/archlaba-$label.$$";
my $aok = 1;
my @parta_scores = (0, 0, 0);

mkdir($tmpdir) or die "$0: ERROR: mkdir $tmpdir failed: $!\n";

foreach my $prog (@PROGS) {
    my $src = defined($prefix) ? "$prefix-$prog.ys" : "$simdir/misc/$prog.ys";
    if (!copy($src, "$tmpdir/$prog.ys")) {
        warn "$0: ERROR: could not copy $src to $tmpdir: $!\n";
        $aok = 0;
    }
}

print "\nPart A: Local Test Report for $label\n\n";

my $partnum = 0;
foreach my $prog (@PROGS) {
    print "***************\n";
    print "Problem $partnum: $prog.ys\n";
    print "***************\n";

    if (!-e "$tmpdir/$prog.ys") {
        warn "$0: ERROR: missing $prog.ys\n\n";
        $partnum++;
        next;
    }

    print "Running yas $prog.ys...\n";
    if (system("(cd '$tmpdir'; '$yas' $prog.ys)") != 0) {
        warn "$0: ERROR: Unable to compile $prog.ys. Files are in $tmpdir.\n\n";
        $partnum++;
        $aok = 0;
        next;
    }

    print "Running yis $prog.yo...\n";
    if (system("(cd '$tmpdir'; '$yis' $prog.yo > $prog.out)") != 0) {
        warn "$0: ERROR: Unable to simulate $prog.yo. Files are in $tmpdir.\n\n";
        $partnum++;
        $aok = 0;
        next;
    }

    if (system("(cd '$tmpdir'; cat $prog.out)") != 0) {
        warn "$0: ERROR: Unable to print $prog.out. Files are in $tmpdir.\n\n";
        $partnum++;
        $aok = 0;
        next;
    }

    my $line = `(cd '$tmpdir'; fgrep '%rax' $prog.out)`;
    chomp($line);
    my ($reg, $before, $after) = split(/\s+/, $line);
    if (defined($after) && $after eq $EXPECTED_RAX) {
        $parta_scores[$partnum] = $POINTS_PER_PROBLEM;
    }

    print "\nScore: $parta_scores[$partnum]/$POINTS_PER_PROBLEM\n\n";
    $partnum++;
}

print "PARTA_SCORES = $parta_scores[0]:$parta_scores[1]:$parta_scores[2]\n";


system("rm -fr '$tmpdir'") if $aok;
exit;
