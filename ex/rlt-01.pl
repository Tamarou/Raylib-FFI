use 5.38.2;
use lib qw(lib);
use experimental 'class';

use Raylib::App;

class Engine {
    my $WIDTH  = 800;
    my $HEIGHT = 500;

    field $player_x = $WIDTH / 2;
    field $player_y = $HEIGHT / 2;

    field $app = Raylib::App->window( $WIDTH, $HEIGHT, 'Map' );

    ADJUST {
        $app->fps(60);
    }

    field $player = Raylib::Text->new(
        text  => '@',
        color => Raylib::Color::WHITE,
        size  => 10,
    );

    method run() {
        while ( !$app->exiting ) {
            my $key = $app->key_pressed;
            for ($key) {
                use constant KEY_UP    => 265;
                use constant KEY_DOWN  => 264;
                use constant KEY_LEFT  => 263;
                use constant KEY_RIGHT => 262;
                if ( $_ == KEY_UP )    { $player_y -= 10 }
                if ( $_ == KEY_DOWN )  { $player_y += 10 }
                if ( $_ == KEY_LEFT )  { $player_x -= 10 }
                if ( $_ == KEY_RIGHT ) { $player_x += 10 }
            }

            $app->clear();
            $app->draw( sub { $player->draw( $player_x, $player_y ); } );
        }
    }
}

Engine->new->run;
