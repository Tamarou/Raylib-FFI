#!/usr/bin/env perl
use 5.38.2;
use lib qw(lib);
use experimental 'class';

use Raylib::App;

class ECS {
    use Carp qw(confess);
    field $systems : param;

    field @entities   = ();
    field %components = ();

    method entity_count {
        return scalar @entities;
    }

    method add_entity() {
        push @entities, {};
        return $#entities;
    }

    method destroy_entity ($entity) {
        delete $entities[$entity];
    }

    method add_component ( $entity, $component ) {
        $entities[$entity]{ ref $component } = $component;
        push $components{ ref $component }->@*, $entity;
    }

    method entities_with (@components) {
        my @ids = map { $_ && $_->@* } @components{@components};
        return @entities[@ids];
    }

    method update () {
        for my $system ( $systems->@* ) {
            $system->update($self);
        }
    }
}

class System {
    method update ($ecs) { ... }
}

class Position {
    field $x : param  = int rand(800);
    field $y : param  = int rand(600);
    field $vx : param = rand();
    field $vy : param = rand;

    method x { int $x; }
    method y { int $y; }

    method vx ( $dvx = $vx ) { $vx = $dvx }
    method vy ( $dvy = $vy ) { $vy = $dvy }

    method update_location() {
        $x += $vx;
        $y += $vy;
    }

}

class Vision {
    field $range : param = 30;

    method can_see ( $dx, $dy ) {
        return abs($dx) < $range && abs($dy) < $range;
    }
}

class Proximity {
    field $distance : param = 5;

    method is_safe ( $dx, $dy ) {
        my $squared_distance = $dx * $dx + $dy * $dy;
        return $squared_distance > $distance * $distance;
    }
}

class Avoidance : isa(System) {
    field $avoidance_factor : param = 1.5;

    method update ($ecs) {
        for my $entity ( $ecs->entities_with( 'Position', 'Proximity' ) ) {
            my $cdx = 0;
            my $cdy = 0;
            my ( $pos, $prox ) = $entity->@{ 'Position', 'Proximity' };
            for my $other ( $ecs->entities_with('Position') ) {
                next if $entity == $other;
                my $other_pos = $other->{'Position'};

                unless (
                    $prox->is_safe(
                        $pos->x - $other_pos->x,
                        $pos->y - $other_pos->y
                    )
                  )
                {
                    $cdx += $pos->x - $other_pos->x;
                    $cdy += $pos->y - $other_pos->y;
                }
            }
            $pos->vx( $pos->vx + $cdx / $avoidance_factor );
            $pos->vy( $pos->vy + $cdy / $avoidance_factor );
        }
    }
}

class Alignment : isa(System) {
    field $matching_factor : param = 0.08;

    method update ($ecs) {
        for my $entity ( $ecs->entities_with( 'Position', 'Vision' ) ) {
            my $xpos_avg          = 0;
            my $ypos_avg          = 0;
            my $xvel_avg          = 0;
            my $yvel_avg          = 0;
            my $neighboring_boids = 0;

            my ( $pos, $vis ) = $entity->@{ 'Position', 'Vision' };

            for my $other ( $ecs->entities_with('Position') ) {
                next if $entity == $other;
                my $other_pos = $other->{'Position'};

                if (
                    $vis->can_see(
                        $pos->x - $other_pos->x,
                        $pos->y - $other_pos->y
                    )
                  )
                {
                    $xvel_avg          += $other_pos->vx;
                    $yvel_avg          += $other_pos->vy;
                    $neighboring_boids += 1;
                }
            }

            if ($neighboring_boids) {
                $xvel_avg = $xvel_avg / $neighboring_boids;
                $yvel_avg = $yvel_avg / $neighboring_boids;

                $pos->vx(
                    $pos->vx() + ( $xvel_avg - $pos->vx ) * $matching_factor );
                $pos->vy(
                    $pos->vy() + ( $yvel_avg - $pos->vy ) * $matching_factor );

            }
        }
    }
}

class Cohesion : isa(System) {
    field $centering_factor = 0.0002;

    method update ($ecs) {
        for my $entity ( $ecs->entities_with( 'Position', 'Vision' ) ) {
            my $xpos_avg          = 0;
            my $ypos_avg          = 0;
            my $neighboring_boids = 0;

            my ( $pos, $vis ) = $entity->@{ 'Position', 'Vision' };

            for my $other ( $ecs->entities_with('Position') ) {
                next if $entity == $other;

                my $other_pos = $other->{'Position'};

                if (
                    $vis->can_see(
                        $pos->x - $other_pos->x,
                        $pos->y - $other_pos->y
                    )
                  )
                {
                    $xpos_avg          += $other_pos->x;
                    $ypos_avg          += $other_pos->y;
                    $neighboring_boids += 1;
                }
            }
            if ($neighboring_boids) {
                $xpos_avg = $xpos_avg / $neighboring_boids;
                $ypos_avg = $ypos_avg / $neighboring_boids;

                $pos->vx(
                    $pos->vx() + ( $xpos_avg - $pos->x ) * $centering_factor );
                $pos->vy(
                    $pos->vy() + ( $ypos_avg - $pos->y ) * $centering_factor );

            }

        }
    }
}

class ScreenEdge : isa(System) {
    field $turn_factor : param = 0.02;
    field $width : param       = 800;
    field $height : param      = 600;
    field $margin : param      = 10;

    method update ($ecs) {
        for my $entity ( $ecs->entities_with('Position') ) {
            my $pos = $entity->{'Position'};

            # outside top margin
            if ( $pos->y < 0 + $margin ) {
                $pos->vy( $pos->vy() + $turn_factor );
            }

            # outside left margin
            if ( $pos->x < 0 + $margin ) {
                $pos->vx( $pos->vx() + $turn_factor );
            }

            # outside right margin
            if ( $pos->x > $width - $margin ) {
                $pos->vx( $pos->vx() - $turn_factor );
            }

            # outside right margin
            if ( $pos->y > $height - $margin ) {
                $pos->vy( $pos->vy() - $turn_factor );
            }
        }
    }
}

class SpeedLimits : isa(System) {
    field $min_speed = 0.2;
    field $max_speed = 1.5;

    method update ($ecs) {
        for my $entity ( $ecs->entities_with('Position') ) {
            my $pos = $entity->{'Position'};

            my $vx    = $pos->vx;
            my $vy    = $pos->vy;
            my $speed = sqrt( $vx * $vx + $vy * $vy ) || $min_speed;
            if ( $speed < $min_speed ) {
                $pos->vx( ( $vx / $speed ) * $min_speed );
                $pos->vy( ( $vy / $speed ) * $min_speed );
            }

            if ( $speed > $max_speed ) {
                $pos->vx( ( $vx / $speed ) * $max_speed );
                $pos->vy( ( $vy / $speed ) * $max_speed );
            }
        }
    }
}

class Movement : isa(System) {

    method update ($ecs) {
        for my $entity ( $ecs->entities_with('Position') ) {

            my $pos = $entity->{'Position'};
            $pos->update_location();
        }
    }
}

class Renderer : isa(System) {
    field $app : param;
    field $boid = Raylib::Text->new(
        text  => 'x',
        color => Raylib::Color::WHITE,
        size  => 5,
    );
    field $fps = Raylib::Text::FPS->new();

    method update ($ecs) {
        my $boid_count = Raylib::Text->new(
            text  => sprintf( "boids: %s", scalar $ecs->entity_count ),
            color => Raylib::Color::WHITE,
            size  => 5,
        );
        $app->draw(
            sub {
                $app->clear();
                $fps->draw();
                $boid_count->draw( 0, 20 );
                for my $entity ( $ecs->entities_with('Position') ) {
                    my $pos = $entity->{'Position'};
                    $boid->draw( $pos->x, $pos->y );
                }
            }
        );
    }
}

my $app = Raylib::App->window( 800, 600, 'Boids' );
$app->fps(60);

my $ecs = ECS->new(
    systems => [
        Alignment->new(),
        Avoidance->new(),
        Cohesion->new(),
        ScreenEdge->new(
            width  => $app->width,
            height => $app->height,
        ),
        SpeedLimits->new(),
        Movement->new(),
        Renderer->new( app => $app ),
    ]
);

sub add_boid {
    my $entity = $ecs->add_entity();
    $ecs->add_component(
        $entity,
        Position->new(
            x => int rand( $app->width ),
            y => int rand( $app->height ),
        )
    );
    $ecs->add_component( $entity, Vision->new() );
    $ecs->add_component( $entity, Proximity->new() );
}

sub remove_boid() {
    my $entity = int rand( scalar $ecs->entities_with('Position') );
    $ecs->destroy_entity($entity);
}

add_boid() for 1 .. 30;
while ( !$app->exiting ) {
    $ecs->update();
}
