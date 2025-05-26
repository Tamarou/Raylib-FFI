#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use HTTP::Tiny;

# Skip if we can't download the header
my $raylib_h_content;
eval {
    if ( -f '/tmp/raylib.h' ) {
        open my $fh, '<', '/tmp/raylib.h'
          or die "Cannot open /tmp/raylib.h: $!";
        $raylib_h_content = do { local $/; <$fh> };
        close $fh;
    }
    else {
        my $raylib_h_url =
          'https://raw.githubusercontent.com/raysan5/raylib/5.5/src/raylib.h';
        my $http     = HTTP::Tiny->new( timeout => 10 );
        my $response = $http->get($raylib_h_url);
        die
          "Failed to download raylib.h: $response->{status} $response->{reason}"
          unless $response->{success};
        $raylib_h_content = $response->{content};
    }
};

if ( my $e = $@ ) {
    plan skip_all => "Cannot download raylib.h for comparison: $e";
}

# Extract RLAPI functions from raylib.h
my @raylib_functions;
while ( $raylib_h_content =~ /RLAPI\s+\w+[\s\*]+(\w+)\s*\(/g ) {
    push @raylib_functions, $1;
}

# Read FFI.pm to get implemented functions
my $ffi_file = 'lib/Raylib/FFI.pm';
open my $fh, '<', $ffi_file or die "Cannot open $ffi_file: $!";
my $ffi_content = do { local $/; <$fh> };
close $fh;

# Extract function names from %functions hash
my @ffi_functions;
while ( $ffi_content =~ /^\s*(\w+)\s*=>\s*\[/gm ) {
    push @ffi_functions, $1;
}

# Create lookup hashes
my %raylib_funcs = map { $_ => 1 } @raylib_functions;
my %ffi_funcs    = map { $_ => 1 } @ffi_functions;

# Calculate coverage
my @missing_in_ffi = grep { !exists $ffi_funcs{$_} } @raylib_functions;
my @extra_in_ffi   = grep { !exists $raylib_funcs{$_} } @ffi_functions;

my $coverage =
  ( @raylib_functions > 0 )
  ? ( ( scalar(@ffi_functions) - scalar(@extra_in_ffi) ) /
      scalar(@raylib_functions) ) * 100
  : 0;

# Run tests
plan tests => 4;

ok( scalar(@raylib_functions) > 0, "Found raylib functions in header" );
ok( scalar(@ffi_functions) > 0,    "Found FFI bindings" );

# Coverage threshold
my $threshold = $ENV{RAYLIB_COVERAGE_THRESHOLD} // 80;
ok(
    $coverage >= $threshold,
    sprintf(
        "Coverage %.1f%% meets threshold %d%% (missing %d functions)",
        $coverage, $threshold, scalar(@missing_in_ffi)
    )
);

# Check for critical functions that should definitely be implemented
my @critical_functions = qw(
  InitWindow
  CloseWindow
  BeginDrawing
  EndDrawing
  ClearBackground
  DrawText
  DrawCircle
  DrawRectangle
  LoadTexture
  UnloadTexture
);

my @missing_critical = grep { !exists $ffi_funcs{$_} } @critical_functions;
is( scalar(@missing_critical), 0, "All critical functions are implemented" )
  or diag( "Missing critical functions: " . join( ", ", @missing_critical ) );

# Output diagnostic information
diag("");
diag("Raylib FFI Coverage Report");
diag( "=" x 50 );
diag( sprintf( "Raylib 5.5 functions: %d", scalar(@raylib_functions) ) );
diag( sprintf( "FFI implementations: %d",  scalar(@ffi_functions) ) );
diag( sprintf( "Missing functions: %d",    scalar(@missing_in_ffi) ) );
diag( sprintf( "Extra functions: %d",      scalar(@extra_in_ffi) ) );
diag( sprintf( "Coverage: %.1f%%",         $coverage ) );

if ( $ENV{VERBOSE} || $ENV{TEST_VERBOSE} ) {
    diag("");
    diag("Missing functions:");
    diag("  $_") for sort @missing_in_ffi;

    if (@extra_in_ffi) {
        diag("");
        diag("Extra functions (may be helpers or renamed):");
        diag("  $_") for sort @extra_in_ffi;
    }
}

done_testing();
