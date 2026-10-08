#!/usr/bin/env perl
use strict;
use warnings;
use File::Copy;

# patch_antigravity.pl
# Perl script to patch Antigravity app.asar / main.js to restore native OS window borders
# Author: Ori Kuttner & Shira
# License: GPL

print "==========================================\n";
print "   Antigravity Window Borders Patcher     \n";
print "==========================================\n\n";

my $target_file = shift;

if (!$target_file) {
    # Try to find the file automatically in common locations
    my @candidates = (
        '/usr/share/antigravity/resources/app/out/main.js',
        'Antigravity-x64/resources/app.asar',
        'resources/app.asar',
        'app.asar'
    );
    for my $c (@candidates) {
        if (-e $c) {
            $target_file = $c;
            last;
        }
    }
}

if (!$target_file || !-e $target_file) {
    print "Error: Could not find target file automatically.\n";
    print "Usage: $0 [path/to/app.asar or path/to/main.js]\n";
    exit 1;
}

print "Target file found: $target_file\n";

# Create backup file
my $backup_file = "$target_file.bak";
if (!-e $backup_file) {
    print "Creating a backup copy at: $backup_file...\n";
    copy($target_file, $backup_file) or die "Failed to create backup file: $!\n";
} else {
    print "Backup copy already exists at: $backup_file\n";
}

# Open file for binary read/write
open(my $fh, '+<:raw', $target_file) or die "Error: Cannot open '$target_file' for writing: $!\n";

# Read the entire file
my $content;
{
    local $/;
    $content = <$fh>;
}

# Target patterns for legacy and updated Antigravity versions
my @patches = (
    {
        search      => "titleBarStyle: 'hidden'",
        replacement => "titleBarStyle:'default'"
    },
    {
        search      => 'd.titleBarStyle="hidden"',
        replacement => 'd.titleBarStyle=void 0 '
    },
    {
        search      => 'titleBarStyle:"hidden"',
        replacement => 'titleBarStyle:"custom"'
    }
);

my $total_patched = 0;

for my $patch (@patches) {
    my $search = $patch->{search};
    my $replace = $patch->{replacement};

    my $count = 0;
    $count++ while $content =~ /\Q$search\E/g;

    if ($count > 0) {
        print "Found $count occurrences of '$search'. Patching to '$replace'...\n";
        $content =~ s/\Q$search\E/$replace/g;
        $total_patched += $count;
    }
}

if ($total_patched == 0) {
    print "Warning: No matches found for border-hiding settings.\n";
    print "The file might already be patched, or this version uses a different internal structure.\n";
    close($fh);
    exit 0;
}

# Write back to file
seek($fh, 0, 0) or die "Error: Seek failed: $!\n";
truncate($fh, 0) or die "Error: Truncate failed: $!\n";
print $fh $content;
close($fh);

print "\nSuccess! Successfully patched '$target_file' ($total_patched changes applied).\n";
print "You can now run Antigravity and it should respect your OS window borders.\n";
print "If anything goes wrong, you can restore from the backup file: $backup_file\n";
