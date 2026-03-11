#!/usr/bin/env perl
use 5.36.3;
use lib qw(lib);

use Raylib::FFI ':all';
use Raylib::Color;

Raylib::FFI::attach( rlTranslatef              => [ ( 'float' ) x 3 ] );
Raylib::FFI::attach( [ rlRotatef => 'rotate' ] => [ ( 'float' ) x 4 ] );
Raylib::FFI->import( qw( rlTranslatef rotate ) );

InitWindow( 800, 600, "Testing!" );
SetTargetFPS(60);

my $r = 0;
while ( !WindowShouldClose() ) {
    ClearBackground( Raylib::Color::BLACK );
    BeginDrawing();
    rlTranslatef( 400, 300 );
    rotate( $r += 3, 0, 0, -1 );
    DrawText( "Weeee!", 0, 0, 40, Raylib::Color::WHITE );
    EndDrawing();
}

