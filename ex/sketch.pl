# Simple test app
print "Hello from test_app.pl\n";

my $app = Raylib::App->window( 800, 600, 'Test App' );
$app->fps(60);

# Persistent counter
my $counter = 3;

# Main loop
while ( !$app->exiting ) {
    my $text = Raylib::Text->new(
        text  => 'Counter: ' . $counter++,
        size  => 20,
        color => Raylib::Color::BLUE
    );

    $app->draw(
        sub {
            $app->clear(Raylib::Color::BLACK);
            $text->draw( 10, 10 );
        }
    );
}
