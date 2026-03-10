#!/usr/bin/env perl
use strict;
use Test::More;

# Small selection of raymath functions.

use Raylib::FFI ':all';

# value, min, max
my $clamped = Clamp( 3.14159, 0.0, 1.0 );
ok ( FloatEquals( $clamped, 1.0 ), "Clamped value max" );
$clamped = Clamp( -3.14159, 0.0, 1.0 );
ok ( FloatEquals( $clamped, 0.0 ), "Clamped value max" );

# value, inputStart, inputEnd, outputStart, outputEnd
my $remapped = Remap( 42, 0, 100, 0, 1 );
ok ( FloatEquals( $remapped, 0.42 ), "Remapped value" );
$remapped = Remap( 42, 0, 100, 0, 0.5 );
ok ( FloatEquals( $remapped, 0.21 ), "Remapped value half" );
ok ( ! FloatEquals( $remapped, 0.21001 ), "Remapped not equal" );

my $vec = Vector2One;
ok( FloatEquals( sqrt( 2 ), Vector2Length( $vec ) ), "Vector2One length" );

$vec = Vector3One;
$vec = Vector3Scale( $vec, 3.5 );
ok( FloatEquals( $vec->x, 3.5 ), "Vector3Scale x" );
ok( FloatEquals( $vec->y, 3.5 ), "Vector3Scale y" );
ok( FloatEquals( $vec->z, 3.5 ), "Vector3Scale z" );

$vec = Vector3Min( $vec, Vector3One );
ok( FloatEquals( $vec->x, 1.0 ), "Vector3Min x" );
ok( FloatEquals( $vec->y, 1.0 ), "Vector3Min y" );
ok( FloatEquals( $vec->z, 1.0 ), "Vector3Min z" );

my $vec1 = Vector3One;
# Mostly testing $vec and $vec1 are modified
Vector3OrthoNormalize( $vec, $vec1 );
ok( FloatEquals( $vec->x, 0.57735027 ), "Vector3OrthoNormalize vec x" );
ok( FloatEquals( $vec->y, 0.57735027 ), "Vector3OrthoNormalize vec y" );
ok( FloatEquals( $vec->z, 0.57735027 ), "Vector3OrthoNormalize vec z" );
ok( FloatEquals( $vec1->x, 0 ), "Vector3OrthoNormalize vec1 x" );
ok( FloatEquals( $vec1->y, 0 ), "Vector3OrthoNormalize vec1 y" );
ok( FloatEquals( $vec1->z, 0 ), "Vector3OrthoNormalize vec1 z" );

my $float3 = Vector3ToFloatV( Vector3Scale( Vector3One, 123.456 ) );
ok( FloatEquals( $float3->v->[0], 123.456 ), "float3 0" );
ok( FloatEquals( $float3->v->[1], 123.456 ), "float3 1" );
ok( FloatEquals( $float3->v->[2], 123.456 ), "float3 2" );

done_testing;
