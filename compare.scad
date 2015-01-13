use <scad-utils/transformations.scad>
use <scad-utils/lists.scad>
use <scad-utils/shapes.scad>
use <scad-utils/trajectory.scad>
use <scad-utils/trajectory_path.scad>


use <skin.scad>
use <sweep.scad>

$fn = 100;

path_definition = [
trajectory(forward = 10, roll  =  0),
trajectory(forward =  5*3.14159265359, pitch = 180, roll=0, yaw=0),
trajectory(forward = 10, roll  =  0)
];

// sweep
path = quantize_trajectories(path_definition, steps=100, loop=false);
/*sweep(rectangle_profile([2,3]), path);*/

// skin
trans = [ for (i=[0:len(path)-1]) transform(path[i], rectangle_profile([2,3])) ];

/*translate([0,10,0])
  skin(trans);*/


profile_definition = [
circle(5),
rectangle_profile([2,3]),
circle(5)
];
/*
echo(profile_definition);
echo(len(path));
echo(trans);*/

pp = quantize_trajectories([trajectory(forward = 10, pitch=180)], steps=100);
prof1 = transform(translation([0,0,0]), circle(5/4));
prof2 = transform(translation([0,0,0]), rectangle_profile([1,5]));
tt = morph(prof1, prof2, slices=101);

toto = [ for (i=[0:len(pp)-1]) transform(pp[i], tt[i])];

skin(toto);

echo(len(tt));

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
