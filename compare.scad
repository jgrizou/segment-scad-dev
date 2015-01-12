use <scad-utils/transformations.scad>
use <scad-utils/trajectory_path.scad>
use <scad-utils/trajectory.scad>
use <scad-utils/shapes.scad>

use <skin.scad>
use <sweep.scad>

path_definition = [
trajectory(forward = 10, roll  =  0),
trajectory(forward =  5*3.14159265359, pitch = 180),
trajectory(forward = 10, roll  =  0)
];

// sweep
path = quantize_trajectories(path_definition, steps=100);
sweep(rectangle_profile([2,3]), path);

// skin
trans = [ for (i=[0:len(path)-1]) transform(path[i], rectangle_profile([2,3])) ];

translate([0,10,0])
  skin(trans);
