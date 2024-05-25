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

package Raylib::FFI::Rectangle {
    use FFI::Platypus::Record;
    use overload
      '""'     => sub { shift->as_string },
      fallback => 1;
    record_layout_1(
        $ffi,
        qw(
          float    x
          float    y
          float    width
          float    height
        )
    );

    sub as_string {
        my ($self) = @_;
        sprintf "Rectangle(x:%f y:%f width:%f height:%f)", $self->x, $self->y,
          $self->width, $self->height;
    }
}

package Raylib::FFI::Vector2D {
    use FFI::Platypus::Record;
    use overload
      '""'     => sub { shift->as_string },
      fallback => 1;

    record_layout_1(
        $ffi,
        qw(
          float    x
          float    y
        )
    );

    sub as_string {
        my ($self) = @_;
        sprintf "(x:%f y:%f)", $self->x, $self->y;
    }
}

package Raylib::FFI::Image {
    use FFI::Platypus::Record;
    use overload
      bool => sub { 1 };

    $ffi->load_custom_type( '::PointerSizeBuffer' => 'buffer' );
    record_layout_1(
        $ffi,
        opaque => 'data',
        int    => 'width',
        int    => 'height',
        int    => 'mipmaps',
        int    => 'format',
    );
}

package Raylib::FFI::Texture {
    use FFI::Platypus::Record;
    use overload
      bool => sub { 1 };

    record_layout_1(
        $ffi,
        qw(
          uint     id
          int      width
          int      height
          int      mipmaps
          int      format
        )
    );
}

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

$ffi->type( 'record(Raylib::FFI::Color)'     => 'Color' );
$ffi->type( 'record(Raylib::FFI::Vector2D)'  => 'Vector2D' );
$ffi->type( 'record(Raylib::FFI::Texture)'   => 'Texture' );
$ffi->type( 'record(Raylib::FFI::Image)'     => 'Image' );
$ffi->type( 'record(Raylib::FFI::Rectangle)' => 'Rectangle' );

$ffi->attach( BeginDrawing    => []                             => 'void' );
$ffi->attach( ClearBackground => ['Color']                      => 'void' );
$ffi->attach( CloseWindow     => []                             => 'void' );
$ffi->attach( DrawFPS         => [qw(int int)]                  => 'void' );
$ffi->attach( DrawText        => [qw(string int int int Color)] => 'void' );
$ffi->attach( DrawLine        => [qw(int int int int Color)]    => 'void' );
$ffi->attach(
    DrawRectanglePro => [qw(Rectangle Vector2D int Color)] => 'void' );
$ffi->attach( EndDrawing        => []                   => 'void' );
$ffi->attach( GetScreenHeight   => []                   => 'int' );
$ffi->attach( GetScreenWidth    => []                   => 'int' );
$ffi->attach( GetFPS            => []                   => 'int' );
$ffi->attach( InitAudioDevice   => []                   => 'void' );
$ffi->attach( InitWindow        => [qw(int int string)] => 'void' );
$ffi->attach( SetTargetFPS      => ['int']              => 'void' );
$ffi->attach( WindowShouldClose => []                   => 'bool' );
$ffi->attach( IsWindowReady     => []                   => 'bool' );
$ffi->attach( TakeScreenshot    => [qw(string)]         => 'void' );

# Load Images
$ffi->attach( IsImageReady        => ['Image']                     => 'bool' );
$ffi->attach( LoadImage           => [qw(string)]                  => 'Image' );
$ffi->attach( LoadImageFromMemory => [ 'string', 'buffer', 'int' ] => 'Image' );
$ffi->attach( LoadImageFromTexture => ['Texture']                  => 'Image' );
$ffi->attach( LoadImageSvg         => [qw(string int int)]         => 'Image' );
$ffi->attach( UnloadImage          => ['Image']                    => 'void' );

# Load textures
$ffi->attach( DrawTexture  => [qw(Texture int int Color)]  => 'void' );
$ffi->attach( DrawTextureV => [qw(Texture Vector2D Color)] => 'void' );
$ffi->attach(
    DrawTextureRec => [qw(Texture Rectangle Vector2D Color)] => 'void' );
$ffi->attach(
    DrawTexturePro => [qw(Texture Rectangle Rectangle Vector2D float Color)] =>
      'void' );
$ffi->attach( IsTextureReady       => ['Texture']  => 'bool' );
$ffi->attach( LoadTexture          => [qw(string)] => 'Texture' );
$ffi->attach( LoadTextureFromImage => ['Image']    => 'Texture' );
$ffi->attach( UnloadTexture        => ['Texture']  => 'void' );

# Keyboard
$ffi->attach( GetKeyPressed => []      => 'int' );
$ffi->attach( IsKeyDown     => ['int'] => 'bool' );
$ffi->attach( IsKeyReleased => ['int'] => 'bool' );
$ffi->attach( IsKeyUp       => ['int'] => 'bool' );

sub import {
    export_lexically(
        BeginDrawing         => \&BeginDrawing,
        ClearBackground      => \&ClearBackground,
        CloseWindow          => \&CloseWindow,
        DrawFPS              => \&DrawFPS,
        DrawLine             => \&DrawLine,
        DrawText             => \&DrawText,
        DrawTexture          => \&DrawTexture,
        DrawTextureRec       => \&DrawTextureRec,
        DrawTexturePro       => \&DrawTexturePro,
        DrawRectanglePro     => \&DrawRectanglePro,
        EndDrawing           => \&EndDrawing,
        GetFPS               => \&GetFPS,
        GetKeyPressed        => \&GetKeyPressed,
        GetScreenHeight      => \&GetScreenHeight,
        GetScreenWidth       => \&GetScreenWidth,
        InitAudioDevice      => \&InitAudioDevice,
        InitWindow           => \&InitWindow,
        IsTextureReady       => \&IsTextureReady,
        IsImageReady         => \&IsImageReady,
        IsWindowReady        => \&IsWindowReady,
        LoadImage            => \&LoadImage,
        LoadImageFromMemory  => \&LoadImageFromMemory,
        LoadImageFromTexture => \&LoadImageFromTexture,
        LoadImageSvg         => \&LoadImageSvg,
        LoadTexture          => \&LoadTexture,
        LoadTextureFromImage => \&LoadTextureFromImage,
        SetTargetFPS         => \&SetTargetFPS,
        TakeScreenshot       => \&TakeScreenshot,
        UnloadTexture        => \&UnloadTexture,
        UnloadImage          => \&UnloadImage,
        WindowShouldClose    => \&WindowShouldClose,
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

=head1 SEE ALSO

L<http://www.raylib.com>

L<Graphics::Raylib>

L<Alien::raylib>

=head1 AUTHOR

Chris Prather <chris@prather.org>

Based on the work of:

Ahmad Fatoum C<< <athreef@cpan.org> >>, L<http://a3f.at>


=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2024 by Chris Prather.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 RAYLIB LICENSE

This is an unofficial wrapper of L<http://www.raylib.com>.

raylib is Copyright (c) 2013-2016 Ramon Santamaria and available under the terms of the zlib/libpng license. Refer to C<XS/LICENSE.md> for full terms.

=cut
