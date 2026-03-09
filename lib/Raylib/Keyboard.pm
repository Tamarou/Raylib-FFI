use 5.36.3;
use Feature::Compat::Class;

class Raylib::Keyboard {
    use Raylib::FFI qw( GetKeyPressed );

    BEGIN {
        *key_down     = &Raylib::FFI::IsKeyDown;
        *key_up       = &Raylib::FFI::IsKeyUp;
        *key_released = &Raylib::FFI::IsKeyReleased;
        *key_pressed  = &Raylib::FFI::GetKeyPressed;
    }

    our @EXPORT_OK( qw( key_down key_up key_released key_pressed ) );
    our %EXPORT_TAGS = (all => \@EXPORT_OK);

    field $key_map :param = {};

    method handle_events() {
        while ( my $key = GetKeyPressed() ) {
            next unless $key_map->{$key};
            $key_map->{$key}->();
        }
    }
}

