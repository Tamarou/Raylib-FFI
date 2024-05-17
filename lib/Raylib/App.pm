use 5.38.2;
use experimental 'class';

use Raylib::Text;

class Raylib::App {
    use Raylib::FFI;
    use Raylib::Color qw();

    field $title : param = $0;
    field $width : param;
    field $height : param;
    field $fps : param        = 60;
    field $background : param = Raylib::Color::BLACK;

    ADJUST {
        InitWindow( $width, $height, $title );
        if ( IsWindowReady() ) {
            SetTargetFPS($fps);
            ClearBackground($background);
        }
    }

    sub window ( $, $width, $height, $title = $0 ) {
        return __PACKAGE__->new(
            width  => $width,
            height => $height,
            title  => $title
        );
    }

    method fps ( $new_fps = undef ) {
        if ( defined $new_fps ) {
            $fps = $new_fps;
            SetTargetFPS($fps);

        }
        return $fps = GetFPS();
    }

    method clear ( $new_color = undef ) {
        if ( defined $new_color ) {
            $background = $new_color;
        }
        ClearBackground($background);
    }

    method exiting { WindowShouldClose() }

    method draw ($code) {
        BeginDrawing();
        $code->();
        EndDrawing();
    }

    method draws (@drawables) {
        BeginDrawing();
        $_->draw for @drawables;
        EndDrawing();
    }

    method draw3d ($code) {
        BeginDrawing();
        $code->();
        EndDrawing();
    }

    my sub timestamp {
        return strftime( '%Y-%m-%dT%H.%M.%S', gmtime(time) );
    }

    method screenshot ( $file = ( 'ScreenShot-' . timestamp() . '.png' ) ) {
        TakeScreenshot($file);
    }

    method draw_fps ( $x, $y ) { DrawFPS( $x, $y ) }

    method draw_text ( $text, $x, $y, $size, $color ) {
        DrawText( $text, $x, $y, $size, $color );
    }

    method height { $height = GetScreenHeight() }
    method width  { $width  = GetScreenWidth() }

    method DESTROY { CloseWindow() }
}

__END__

=pod

=encoding utf-8

=head1 NAME

Raylib::App - Perlish wrapper for Raylib videogame library

=head1 SYNOPSIS

    use Raylib::App
    use Raylib::Text;
    use Raylib::Color;

    my $g = Graphics::Raylib->window(120,20);
    $g->fps(5);

    my $text = Raylib::Text->new(
        text => 'Hello World!',
        color => DARKGRAY,
        size => 20,
    );

    while (!$g->exiting) {
        $app->draw(sub {
            $g->clear;

            $text->draw;
        });
    }

=head1 raylib

raylib is highly inspired by Borland BGI graphics lib and by XNA framework.
Allegro and SDL have also been analyzed for reference.

NOTE for ADVENTURERS: raylib is a programming library to learn videogames
programming; no fancy interface, no visual helpers, no auto-debugging... just
coding in the most pure spartan-programmers way. Are you ready to learn? Jump
to L<code examples|http://www.raylib.com/examples.html> or
L<games|http://www.raylib.com/games.html>!

=head1 DESCRIPTION

This module is a port of the L<Graphics::Raylib> module to use Raylib::FFI
instead of Graphics::Raylib::XS. It should be a drop-in replacement for
Graphics::Raylib, but it is a work in progress.

=head1 METHODS

=over 4

=item new((%args)

Create a new Raylib::App object. The following arguments are accepted:

=over 4

=item title (defaults to $0)

The tile of the application and the window. Defaults to the name of the script.

=item width

The width of the window.

=item height

The height of the window.

=item fps (defaults to 60)

The frames per second to target. Defaults to 60.

=item background (defaults to Raylib::Color::BLACK)

The background color of the window, defaults to Raylib::Color::Black.

=back

=item window($width, $height, [$title = $0])


=back

=head1 AUTHOR

Chris Prather <chris@prather.org>

Based on the work of:

Ahmad Fatoum C<< <athreef@cpan.org> >>, L<http://a3f.at>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2024 by Chris Prather.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


