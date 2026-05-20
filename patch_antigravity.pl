#!/usr/bin/env perl
use strict;
use warnings;
use File::Copy;

# patch_antigravity.pl
# Perl script to patch Antigravity app.asar to restore native OS window borders
# Author: Ori Kuttner
# License: GPL

print "==========================================\n";
print "   Antigravity Window Borders Patcher     \n";
print "==========================================\n\n";

my $asar_file = shift;

if (!$asar_file) {
    # Try to find the file automatically in common locations
    my @candidates = (
        'Antigravity-x64/resources/app.asar',
        'resources/app.asar',
        'app.asar'
    );
    for my $c (@candidates) {
        if (-e $c) {
            $asar_file = $c;
            last;
        }
    }
}

if (!$asar_file || !-e $asar_file) {
    print "Error: Could not find 'app.asar' automatically.\n";
    print "Usage: $0 [path/to/app.asar]\n";
    exit 1;
}

print "Target file found: $asar_file\n";

# Create backup file
my $backup_file = "$asar_file.bak";
print "Creating a backup copy at: $backup_file...\n";
copy($asar_file, $backup_file) or die "Failed to create backup file: $!\n";

# Open file for binary read/write
open(my $fh, '+<:raw', $asar_file) or die "Error: Cannot open '$asar_file' for writing: $!\n";

# Read the entire file
my $content;
{
    local $/;
    $content = <$fh>;
}

# The target hardcoded string and its exact-length replacement (23 bytes)
my $target =      "titleBarStyle: 'hidden'";
my $replacement = "titleBarStyle:'default'";

# Count occurrences
my $count = 0;
$count++ while $content =~ /$target/g;

if ($count == 0) {
    print "Warning: No matches found for '$target'.\n";
    print "The file might already be patched, or this version does not contain the target string.\n";
    close($fh);
    exit 0;
}

print "Found $count occurrences of the border-hiding setting. Patching...\n";

# Replace occurrences in-place
$content =~ s/\Q$target\E/$replacement/g;

# Write back to file
seek($fh, 0, 0) or die "Error: Seek failed: $!\n";
truncate($fh, 0) or die "Error: Truncate failed: $!\n";
print $fh $content;
close($fh);

print "\nSuccess! Successfully patched '$asar_file'.\n";
print "You can now run Antigravity and it should respect your OS window borders.\n";
print "If anything goes wrong, you can restore from the backup file: $backup_file\n";
