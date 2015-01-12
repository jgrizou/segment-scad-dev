use <scad-utils/transformations.scad>
use <scad-utils/lists.scad>
use <scad-utils/shapes.scad>
use <scad-utils/trajectory.scad>
use <scad-utils/trajectory_path.scad>
use <skin.scad>
use <sweep.scad>

tr = translation([0,2,0]);
rr = rotation([0,0,0]);
$fn=100;
translate([-20,0,0])
skin(morph(
  profile1=transform(tr * rr, circle(r=0.5)),
  profile2=transform(translation([0,0,3]), rectangle_profile([5,2])),
  slices=40));


// Path
path_definition = [
  trajectory(forward = 10, roll  =  0),
  trajectory(forward =  5*3.14, pitch = 180),
  trajectory(forward = 10, roll  =  0)
];

echo(path_definition);
path = quantize_trajectories(path_definition, steps=100);
echo(path);

sweep(rectangle_profile([2,3]), path);


belt = [ for (i=[0:len(path)-1])
  transform(path[i], rectangle_profile([2,3])
)
];

translate([0,10,0])
  skin(belt);

/*cube([10,10,10]);*/


function shape() = [
[-10, -1],
[-10,  6],
[ -7,  6],
[ -7,  1],
[  7,  1],
[  7,  6],
[ 10,  6],
[ 10, -1]];
/*
path_transforms = construct_transform_path(path);
echo(path_transforms);
sweep(shape(), path_transforms);*/



function f(t) = [
t*10,
0,
0
];

step = 0.005;
pp = [for (t=[0:step:1-step]) f(t)];
path_transforms = construct_transform_path(pp);
translate([20,0,0]) sweep(shape(), path_transforms);

echo("######");
echo("######");
echo("######");
echo("######");
echo(pp);
echo(path_transforms);

use <sweep.scad>
use <scad-utils/transformations.scad>
use <scad-utils/shapes.scad>

function func0(x)= 1;
function func1(x) = 3 * sin(180 * x);
function func2(x) = -3 * sin(180 * x);
function func3(x) = (sin(270 * (1 - x) - 90) * sqrt(6 * (1 - x)) + 2);
function func4(x) = 180 * x / 2;
function func5(x) = 2 * 180 * x * x * x;
function func6(x) = 3 - 2.5 * x;

pathstep = 1;
height = 10;

shape_points = square(2);
path_transforms1 = [for (i=[0:pathstep:height]) let(t=i/height) translation([func1(t),func1(t),i]) * rotation([0,0,func4(t)])];
path_transforms2 = [for (i=[0:pathstep:height]) let(t=i/height) translation([func2(t),func2(t),i]) * rotation([0,0,func4(t)])];
path_transforms3 = [for (i=[0:pathstep:height]) let(t=i/height) translation([func1(t),func2(t),i]) * rotation([0,0,func4(t)])];
path_transforms4 = [for (i=[0:pathstep:height]) let(t=i/height) translation([func2(t),func1(t),i]) * rotation([0,0,func4(t)])];

translate([0,20,0]) {
sweep(shape_points, path_transforms1);
sweep(shape_points, path_transforms2);
sweep(shape_points, path_transforms3);
sweep(shape_points, path_transforms4);
}
echo("######");
echo("######");
echo("######");
echo("######");

echo(shape_points);
echo(path_transforms1);

function rectangle_profile(size=[1,1]) = [
// The first point is the anchor point, put it on the point corresponding to [cos(0),sin(0)]
[ size[0]/2,  0],
[ size[0]/2,  size[1]/2],
[-size[0]/2,  size[1]/2],
[-size[0]/2, -size[1]/2],
[ size[0]/2, -size[1]/2],
];

function rounded_rectangle_profile(size=[1,1],r=1,fn=32) = [
for (index = [0:fn-1])
let(a = index/fn*360)
r * [cos(a), sin(a)]
+ sign_x(index, fn) * [size[0]/2-r,0]
+ sign_y(index, fn) * [0,size[1]/2-r]
];

function sign_x(i,n) =
i < n/4 || i > n-n/4  ?  1 :
i > n/4 && i < n-n/4  ? -1 :
0;

function sign_y(i,n) =
i > 0 && i < n/2  ?  1 :
i > n/2 ? -1 :
0;

function interpolate_profile(profile1, profile2, t) = (1-t) * profile1 + t * profile2;

// Morph two profile
function morph(profile1, profile2, slices=1, fn=0) = morph0(
  augment_profile(to_3d(profile1),max(len(profile1),len(profile2),fn)),
  augment_profile(to_3d(profile2),max(len(profile1),len(profile2),fn)),
  slices
);

function morph0(profile1, profile2, slices=1) = [
for(index = [0:slices-1])
interpolate_profile(profile1, profile2, index/(slices-1))
];


// The area of a profile
//function area(p, index_=0) = index_ >= len(p) ? 0 :
function pseudo_centroid(p,index_=0) = index_ >= len(p) ? [0,0,0] :
p[index_]/len(p) + pseudo_centroid(p,index_+1);


//// Nongeneric helper functions

function profile_distance(p1,p2) = norm(pseudo_centroid(p1) - pseudo_centroid(p2));

function rate(profiles) = [
for (index = [0:len(profiles)-2]) [
profile_length(profiles[index+1]) - profile_length(profiles[index]),
profile_distance(profiles[index], profiles[index+1])
]
];

function profiles_lengths(profiles) = [ for (p = profiles) profile_length(p) ];

function profile_length(profile,i=0) = i >= len(profile) ? 0 :
profile_segment_length(profile, i) + profile_length(profile, i+1);

function expand_profile_vertices(profile,n=32) = len(profile) >= n ? profile : expand_profile_vertices_0(profile,profile_length(profile),n);
