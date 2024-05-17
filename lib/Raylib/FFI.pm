use 5.38.2;
use experimental 'builtin';

package Raylib::FFI;

our $VERSION = '0.01';

use FFI::CheckLib;
use FFI::Platypus 2.08;
use builtin 'export_lexically';

my $ffi = FFI::Platypus->new(
    api => 2,
    lib => find_lib_or_die( lib => 'raylib', alien => 'Alien::raylib' ),
);

package Raylib::FFI::Color {
    use FFI::Platypus::Record;
    use overload
      '""'     => sub { shift->as_string },
      bool     => sub { 1 },
      fallback => 1;

    record_layout_1(
        $ffi,
        qw(
          char     r
          char     g
          char     b
          char     a
        )
    );

    sub as_string {
        my ($self) = @_;
        sprintf "(red:%02x green:%02x blue:%02x alpha:%02x)", $self->r,
          $self->g, $self->b, $self->a;
    }

}

$ffi->type( 'record(Raylib::FFI::Color)' => 'Color' );

$ffi->attach( BeginDrawing      => []                             => 'void' );
$ffi->attach( ClearBackground   => ['Color']                      => 'void' );
$ffi->attach( CloseWindow       => []                             => 'void' );
$ffi->attach( DrawFPS           => [qw(int int)]                  => 'void' );
$ffi->attach( DrawText          => [qw(string int int int Color)] => 'void' );
$ffi->attach( EndDrawing        => []                             => 'void' );
$ffi->attach( GetScreenHeight   => []                             => 'int' );
$ffi->attach( GetScreenWidth    => []                             => 'int' );
$ffi->attach( GetFPS            => []                             => 'int' );
$ffi->attach( InitAudioDevice   => []                             => 'void' );
$ffi->attach( InitWindow        => [qw(int int string)]           => 'void' );
$ffi->attach( SetTargetFPS      => ['int']                        => 'void' );
$ffi->attach( WindowShouldClose => []                             => 'bool' );
$ffi->attach( IsWindowReady     => []                             => 'bool' );
$ffi->attach( TakeScreenshot    => [qw(string)]                   => 'void' );

sub import {
    export_lexically(
        BeginDrawing      => \&BeginDrawing,
        ClearBackground   => \&ClearBackground,
        CloseWindow       => \&CloseWindow,
        DrawFPS           => \&DrawFPS,
        DrawText          => \&DrawText,
        EndDrawing        => \&EndDrawing,
        GetScreenHeight   => \&GetScreenHeight,
        GetScreenWidth    => \&GetScreenWidth,
        GetFPS            => \&GetFPS,
        InitAudioDevice   => \&InitAudioDevice,
        InitWindow        => \&InitWindow,
        SetTargetFPS      => \&SetTargetFPS,
        WindowShouldClose => \&WindowShouldClose,
        IsWindowReady     => \&IsWindowReady,
        TakeScreenshot    => \&TakeScreenshot,
    );
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Raylib::FFI - Perl FFI bindings for raylib

=head1 SYNOPSIS

    use 5.38.2;
    use lib qw(lib);
    use Raylib::FFI;
    use constant Color => 'Raylib::FFI::Color';

    InitWindow( 800, 600, "Testing!" );
    SetTargetFPS(60);
    while ( !WindowShouldClose() ) {
        my $x = GetScreenWidth() / 2;
        my $y = GetScreenHeight() / 2;
        BeginDrawing();
        ClearBackground( Color->new( r => 0, g => 0, b => 0, a => 0 ) );
        DrawFPS( 0, 0 );
        DrawText( "Hello, world!",
            $x, $y, 20, Color->new( r => 255, g => 255, b => 255, a => 255 ) );
        EndDrawing();
    }
    CloseWindow();

=head1 DESCRIPTION

This module provides Perl bindings for the raylib library using FFI::Platyus.
This is functional but very low level. You probably want to use L<Raylib::App>
instead.

=head1 AUTHOR

Chris Prather <chris@prather.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2024 by Chris Prather.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 RAYLIB LICENSE

This is an unofficial wrapper of L<http://www.raylib.com>.

raylib is Copyright (c) 2013-2016 Ramon Santamaria and available under the terms of the zlib/libpng license. Refer to C<XS/LICENSE.md> for full terms.

=cut
