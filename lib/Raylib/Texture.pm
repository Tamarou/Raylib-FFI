use 5.38.2;
use experimental qw(class);

class Raylib::Image {
    use Raylib::FFI;
    use builtin qw(false);

    field $image : param = undef;

    field $x : param;
    field $y : param;

    sub new_from_file ($file) {
        __PACKAGE__->new( image => LoadImage($file) );
    }

    sub new_from_texture ($texture) {
        __PACKAGE__->new( image => LoadImageFromTexture($texture) );
    }

    sub new_from_svg ( $svg, $w, $h ) {
        __PACKAGE__->new( image => LoadImageSVG( $svg, $w, $h ) );
    }

    sub new_from_scalar ( $fmt, $data, $size ) {
        __PACKAGE__->new( image => LoadImageFromMemory( $fmt, $data, $size ) );
    }

    ADJUST {
        unless ( IsImageReady($image) ) {
            die "Failed to load image";
        }
    }

    method draw() {
        Raylib::Texture->new_from_image($image)->draw();
    }

    method DESTROY {
        UnloadImage($image);
    }
}

class Raylib::Texture {
    use Raylib::FFI;
    use Raylib::Color;

    field $x : param    = 0;
    field $y : param    = 0;
    field $tint : param = WHITE;

    field $texture : param = undef;

    sub new_from_file ( $file, $x = 0, $y = 0, $tint = WHITE ) {
        __PACKGE__->new(
            image => LoadTexture($file),
            x     => $x,
            y     => $y,
            tint  => $tint
        );
    }

    sub new_from_image ( $image, $x = 0, $y = 0, $tint = WHITE ) {
        __PACKAGE__->new(
            image => LoadTextureFromImage($image),
            x     => $x,
            y     => $y,
            tint  => $tint,
        );
    }

    ADJUST {
        unless ( IsTextureReady($texture) ) {
            die "Failed to load texture";
        }
    }

    method draw() {
        DrawTexture( $texture, $x, $y, $tint );
    }

    method DESTROY {
        UnloadTexture($texture);
    }
}
