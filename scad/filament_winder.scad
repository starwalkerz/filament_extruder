/************************************************************************************

filament_winder.scad - various parts for the winder portion of the MOST filament extruder V10000
Copyright 2015 Jerry Anzalone
Author: Jerry Anzalone <gcanzalo@mtu.edu>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

************************************************************************************/

include<bearings.scad>
include<fasteners.scad>
include<threads.scad>
include<gear_calculator.scad>
include<parametric_involute_gear_v5.0.scad>

$fn = 48;

layer_height = 0.25;

pi = 3.14159265359;

// winder motor dims
d_motor_mount_circle = 27.75;
d_motor_mount = 37;
d_shaft_collar = 12;
d_shaft = 6;
d_shaft_flat = 5.3;
l_shaft = 12;
n_mounts = 4;
d_mounts = d_M3_screw;
offset_shaft = 6.81;
t_motor_mount = 4;

// pulleys were originally both 40mm in diameter, changes should be done to both diameters
// to keep belt length the same (unless a different belt is used)
d_pulley_motor = 15;
d_pulley_spool = 65;
d_belt = 4; // belt will be a large o-ring
t_pulley = 6;

id_spool = 52.26;
d_large_cone = id_spool + 2.5;
d_small_cone = id_spool - 2.5;
h_cone = 15;

d_cone_shaft = 8;

d_magnet = 6.3;
h_magnet = 6.3;

d_c_rod = 5; // using carbon fiber rod for the spool holder since it's available
d_frame_mount = d_M3_screw; // screw diameter mounting dpool holder to frame
offset_frame_mount = 10;
h_frame_mount = offset_frame_mount + d_frame_mount + 3;

bearing_idler = bearing_608;

// servo dims
w_servo = 20;
l_servo = 40.2;
l_servo_flange = 55;
cc_w_servo_mounts = 10;
cc_l_servo_mounts = 48;
d_servo_mounts = d_M3_screw;

d_cable = 7;
d_cable_holder = d_cable + 2;

l_strut_slot = 28; // measure 28.32
d_strut_slot = 14; // measured 14.32
cc_strut_slots = 62.4;

d_sensor_threaded_rod = 25.4 / 4 + 0.5; // diameter of threaded rod holding the sensor and laser

// light sensor board dims - origin is corner nearest screw terminal
l_sensor_board = 61.5;
w_sensor_board = 12.95; // 12.95 for TSL1406R

w_sensor_mount = 15; // width of the sensor mount
l_sensor_mount = l_sensor_board + 10;

// following for original Filawinder sensor board:
//hole1 = [2.8, w_sensor_board / 2];
//hole2 = [l_sensor_board - 2.8,w_sensor_board / 2];

// following for prototype sensor/emmitter boards:
hole1 = [0.1 * 25.4, 0.1 * 25.4];
hole2 = [1.3 * 25.4, 0.4 * 25.4];
d_mounts = d_M3_screw - 0.5;
standoff = 2;
t_mount = 11;
l_sensor_mount = cc_strut_slots + 2 * d_sensor_threaded_rod + 3;
l_light_path = l_sensor_mount - 35;
offset_sensors = 4; // distance from back of sensor board to face of sensor

// line laser dims
d_line_laser = 12.5;
offset_line_laser = d_sensor_threaded_rod / 2 + d_line_laser / 2 + 3;
a_line_laser = atan(offset_line_laser / (l_light_path - standoff - offset_sensors));

// point laser dims
d_point_laser = 6.2;
offset_point_laser = d_sensor_threaded_rod / 2 + d_point_laser / 2 + 3;
a_point_laser = atan(offset_point_laser / (l_light_path - standoff - offset_sensors));

h_shroud = 12;
l_slot = 25;
w_slot = 1;
offset_slot = 7;  // offset the slot in the positive y-direction off bottom of board
offset_socket = 37;
l_socket = 20;

// main board dimensions
l_main_board = 71;
w_main_board = 44;
cc_l_mounts = 67 - 3.25;
cc_w_mounts = 39 - 3.25;

d_guide = 4; // ptfe tubing guides

// tensioner loop:
d_loop_tensioner = 135;
d_tensioner = 7;
tensioner_entry_offset = 100;

// quality control device measures diameter and total length of filament
// filament travels through device parallel the x-axis
qc_bearings = bearing_MR105;			// all bearings are the same for simplicity - MR105z keeps the overall sive of the lever down
qc_advantage = 9.65;								// ratio of long:short. Precision increases with increasing advantage.
d_qc_drive_gear = 12.5;						// diamter of the drive gear body
d_qc_drive_gear_hob = 11.3;				// diameter of the hobbed poriton of drive gear
d_qc_encoder_mount = 7; 					// d_M7_screw;
d_qc_pivot = d_M5_screw;
t_qc_lever = 18;									// end thickness of the lever
t_qc_lever_pivot = 8;
qc_pulley_pitch = 2;
qc_pulley_teeth = 16;
qc_pot_mechanical_rotation = 300;	// maximum rotation of potentiometer
qc_max_displacement = 2.5; 				// maximum diameter of the filament to be measured
qc_target_displacement = 1.75; 		// target displacement
a_qc_bearings = 45;								// the idler will be angle about the pivot with respect to the x-axis by this amount

/* it's easier to calculate displacement from angle subtended:
		theta = 1; // angle resulting from displacement
		f = 2 * qc_short * pow(sin(theta / 2), 2); // short leg of triangle
		e = (qc_bearings[0] + d_qc_drive_gear_hob) / 2 + 2 * qc_short * sin(theta / 2) * cos(theta / 2); // long leg of triangle
		D = pow(pow(e, 2) + pow(f, 2), 0.5) - qc_bearings[0]; // displacement happens on the hypotenuse; subtract bearing radii from h to get D

		Doing this in a spreadsheet, plotting a vs D and fitting a line to the area of interest yields
		a good approximation of angle from D, the method used below
*/

// calculation of the total angle subtended can be approximated linearly up to 5 mm diameter by:
d_qc_pulley = qc_pulley_pitch * qc_pulley_teeth / pi / 2;
a_max_qc = (qc_max_displacement - 0.047763) / 0.153332;
a_target_qc = (qc_target_displacement - 0.047763) / 0.153332;
// short side of pivot determined by the diameter of the idler bearing and diameter of pivot
qc_short = (qc_bearings[0] + d_qc_pivot) / 2 + 2;				// add a bit for an M5 nut on the pivot		
qc_long = qc_short * qc_advantage;
max_qc_pot_rotation = 360 * a_max_qc * qc_long * pi / 180 / (qc_pulley_pitch * qc_pulley_teeth);
target_qc_pot_rotation = 360 * a_target_qc * qc_long * pi / 180 / (qc_pulley_pitch * qc_pulley_teeth);

// stationary bearings are offset to keep the filament straight when at target displacement:
x_offset_qc_stationary = qc_short * cos(180 - a_qc_bearings) - qc_bearings[0];
y_offset_qc_stationary = -qc_short * (1 - cos(a_qc_bearings - a_target_qc) + sin(a_qc_bearings));

// length measurement instrument
// encoder will sit between two pieces of PTFE tubing so that the filament must bend over the drive gear
l_filament_path = 30;
deflection = 1.9;
od_tubing = 6.4;		// 3mm id x 6mm od PTFE tubing
id_tubing = 3;
pad_tubing = 2;
l_qc_length_base = l_filament_path + 24;
w_qc_length_base = 30;
t_qc_length_base = 3;
z_offset_tubing = 11; // the bearings on the diameter measurement tool are about 11mm off plate face
offset_encoder = d_qc_drive_gear_hob / 2 + qc_target_displacement / 2 - (id_tubing - qc_target_displacement) / 2 - deflection;
cc_qc_length_mounts = w_qc_length_base - 10;
inset_qc_length_mounts = 6;
d_encoder_mount = 6.8;

// for the qc mounting plate
l_qc_mount = ceil(qc_long - x_offset_qc_stationary + 20);
w_qc_mount = 2 * 25.4;	// 2" x 1/8" Al strip
t_qc_mount = 3;

color_bearing = [0.6, 0.6, 0.6];
color_fastener = [0, 0.7, 0];


// setting outfeed true cuts off eveything but the portion with the mount screws and tubing holder
module qc_length(outfeed = false) {
	difference() {
		union() {
			cube([l_qc_length_base, w_qc_length_base, t_qc_length_base], center = true);
			
			// holders for PTFE tubing - cause friction, but surest way to go
			for (i = [-1, 1])
				translate([i * l_filament_path / 2, 0, z_offset_tubing + t_qc_length_base / 2])
					rotate([0, i * 90, 0])
						hull() {
							cylinder(r = od_tubing / 2 + pad_tubing, h = 12);
						
							translate([i * (z_offset_tubing + 0.01), -od_tubing / 2 - pad_tubing, 0])
								cube([0.1, od_tubing + 2 * pad_tubing, 12]);
						}
			
			// so that it mounts flush to qc device
			translate([l_qc_length_base / 2 - 0.1, -w_qc_length_base / 2, -t_qc_length_base / 2]) {
				cube([14, w_qc_length_base, 2 * t_qc_length_base]);
				
				translate([0, w_qc_length_base / 2, t_qc_length_base])
					rotate([90, 0, 0])
						cylinder(r = t_qc_length_base, h = w_qc_length_base, center = true);
			}
		}
		
		// encoder
		translate([0, offset_encoder, 0]) {
			translate([0, 0, -t_qc_length_base / 2 - 0.1])
				cylinder(r = d_encoder_mount / 2, h = t_qc_length_base + 1);
		}

		// bearings for deflecting filament around drive gear - less friction, but don't work as well
//		for (i = [-1])
//			translate([i * l_filament_path / 2, -qc_bearings[0] / 2 - qc_target_displacement / 2, 0])
//				cylinder(r = d_M5_screw / 2, h = t_qc_length_base + 1, center = true);

		// tube openings
		translate([0, 0, z_offset_tubing + t_qc_length_base / 2]) {
			for (i = [-1, 1])
				translate([i * (l_filament_path / 2 + 2), 0, 0])
					rotate([0, i * 90, 0]) {
						cylinder(r = od_tubing / 2, h = 12);
						
						translate([0, 0, -3])
							cylinder(r1 = id_tubing / 2 + 2, r2 = id_tubing / 2 + 0.2, h = 3);
					}
	
		}
		
		// openings for mount point - centers are 6mm from end of mount plate
		translate([l_qc_length_base / 2 + 8, 0, -0.5]) {
			cube([10.5, w_qc_length_base - 1, t_qc_length_base + 1], center = true);
			
			translate([0, 0, 0.5 + t_qc_length_base + layer_height])
				for (i = [-1, 1])
					translate([0, i * cc_qc_length_mounts / 2, 0])
						hull()
							for (j = [-1, 1])
								translate([j * 2, 0, 0])
									cylinder(r = d_M3_screw / 2 + 0.5, h = t_qc_length_base, center = true);
		}
		
		if (outfeed) {
			// chop off everything but one side
			translate([-l_filament_path / 2, 0, z_offset_tubing])
				cube([2 * l_filament_path, w_qc_length_base + 1, 3 * z_offset_tubing], center = true);
		}
	}
}

// this will generally only be used to render a template for holes to be drilled in 3mm Al plate
// it will not make the stiff mount required for the device to work 
module qc_mount(assembly = false, mount_template = true) {
	a_pulley_mount = -6;   // rotate the pulley mount so shoulders of pulley don't hit lever
//	echo(str("Stationary bearing x offset (mm) = ", x_offset_qc_stationary));
//	echo(str("Stationary bearing y offset (mm) = ", y_offset_qc_stationary));
//	echo(str("QC device mount dimensions (mm): ", l_qc_mount, " x ", w_qc_mount, " x ", t_qc_mount));

	difference() {
		translate([0, -w_qc_mount / 2, 0])
			cube([l_qc_mount, w_qc_mount, (mount_template) ? 1.33 : t_qc_mount]);
		
		translate([qc_bearings[0] / 2 - x_offset_qc_stationary + 5, 0, -1]) {
			// pivot - drill 4.5mm and tap M5 x 0.8
			cylinder(r = (mount_template) ? 1.5 : qc_bearings[1] / 2, h = 5);
			
			// stationary - drill 4.5mm and tap M5 x 0.8
			translate([x_offset_qc_stationary, y_offset_qc_stationary, 0])
				cylinder(r = (mount_template) ? 1.5 : 3.5, h = 5);
			
			// pot - drill 6.5mm and tap M7 x 1
			rotate([0, 0, a_pulley_mount])  // move it out of the way so pulley shoulders don't hit lever
				translate([qc_long + d_qc_pulley, 0, 0])
					cylinder(r = (mount_template) ? 1.5 : 3.5, h = 5);
			
			// mounts for length instrument and outfeed tube - drill 2.5mm and tap M3 x 0.5
			translate([x_offset_qc_stationary + qc_bearings[0] / 2 + qc_target_displacement / 2, 0, -1])
				for (i = [-1, 1])
					translate([i * cc_qc_length_mounts / 2, 0, 0])
						for (j = [-1, 1])
							translate([0, j * (w_qc_mount / 2 - inset_qc_length_mounts), 0])
								cylinder(r = (mount_template) ? 1.5 : 3.5, h = 5);
		}
	}
	
	if (assembly) {
		translate([qc_bearings[0] / 2 - x_offset_qc_stationary + 5, 0, (mount_template) ? 1 : t_qc_mount]) {
			// lever
			translate([0, 0, t_qc_lever / 2])
//				rotate([0, 0, a_target_qc])
					qc_diameter(assembly = true);
		
			// stationary bearings
			translate([x_offset_qc_stationary, y_offset_qc_stationary, t_qc_lever_pivot + layer_height]) {
				color(color_bearing) {
					bearing(type = qc_bearings);
				
					translate([0, 0, qc_bearings[2]])
						bearing(type = qc_bearings);
				}
			}
			
			// pulley
			color([0.7, 0, 0])
			rotate([0, 0, a_pulley_mount])  // move it out of the way so pulley shoulders don't hit lever
				translate([qc_long + d_qc_pulley, 0, 0])
					cylinder(r = 7, h = 19);
			
		}
	}
}

module qc_diameter(assembly = false) {
	echo(str("Length short side (mm) = ", qc_short));
	echo(str("Length long side (mm) = ", qc_long));
	echo(str("Angle at max displacement (deg) = ", a_max_qc));
	echo(str("Pot rotation at max displacement (deg) = ", max_qc_pot_rotation));
	echo(str("Pot rotation at target displacement (deg) = ", target_qc_pot_rotation));
	if (target_qc_pot_rotation > qc_pot_mechanical_rotation)
		echo(str("WARNING: Pot rotation at target displacement exceeds its rotation capacity. Reduce mechanical advantage."));
	else
		echo(str("NOTICE: Maximum precision achieved at an advantage of ", qc_pot_mechanical_rotation / (360 * a_target_qc * pi / 180 / (qc_pulley_pitch * qc_pulley_teeth)) / qc_short, " mm"));
	if (max_qc_pot_rotation > qc_pot_mechanical_rotation)
		echo(str("NOTICE: Pot rotation at max displacement exceeds its rotation capacity. Reduce mechanical advantage or max displacement."));
		
	
	difference() {
		union() {
			difference() {
				hull() {
					intersection() {
						difference() {
							cylinder(r = qc_long, h = t_qc_lever, center = true, $fn = 180);
				
							cylinder(r = qc_long - 2, h = t_qc_lever + 1, center = true);
						}
			
						translate([0, 0, -t_qc_lever / 2])
							difference() {
								cube([qc_long, qc_long, t_qc_lever]);
			
								translate([0, 0, -1])
									rotate([0, 0, a_max_qc])
										cube([qc_long, qc_long, t_qc_lever + 2]);
							}
					}
			
					cylinder(r = qc_short, h = t_qc_lever, center = true);
				}
				
				// shorten the pivot end
				translate([0, 0, -t_qc_lever / 2 + t_qc_lever_pivot])
					cylinder(r = qc_long - 30, h = t_qc_lever);
			}
			
			// idler
			rotate([0, 0, 180 - a_qc_bearings])
				translate([0, 0, (t_qc_lever_pivot - t_qc_lever) / 2]) {
					hull()
						for (i = [0, qc_short])
							translate([0, i, 0])
								cylinder(r = qc_bearings[0] / 2- 1, h = t_qc_lever_pivot, center = true);

					// idler bearing mount
					translate([0, qc_short, t_qc_lever_pivot / 2 - 1]) {
						// add a built-in washer for the bearing inner race to ride on
						cylinder(r = qc_bearings[1] / 2 + 1, h = 1 + layer_height);
					
						cylinder(r = qc_bearings[1] / 2, h = qc_bearings[2] + 1);
				
						translate([0, 0, qc_bearings[2] - 1])
							metric_thread(diameter = 5, pitch = 0.8, length = 7, internal = false, n_starts = 1);
					}
				}

				// keep the belt in the pivot arc
				translate([0, 0, -1])
				intersection() {
					difference() {
						cylinder(r = qc_long, h = t_qc_lever - 2, center = true, $fn = 180);
			
						cylinder(r = qc_long - 6, h = t_qc_lever + 1, center = true);
						
						translate([0, 0, 1])
							cylinder(r = qc_long + 1, h = layer_height, center = true);
					}
		
					translate([0, 0, -t_qc_lever / 2])
						difference() {
								rotate([0, 0, - a_max_qc - 3])
									cube([qc_long, qc_long, t_qc_lever]);

								translate([0, 0, -1])
									cube([qc_long, qc_long, t_qc_lever + 2]);
		
						}
				}
		}
		
		// pivot - use the same bearing as the idler
		translate([0, 0, -t_qc_lever / 2 + qc_bearings[2] + layer_height])
			cylinder(r = qc_bearings[1] / 2 + 1, h = t_qc_lever + 1);
		
		// bearings on both sides
		translate([0, 0, -t_qc_lever / 2 + t_qc_lever_pivot - qc_bearings[2] + 1])
			cylinder(r1 = qc_bearings[0] / 2, r2 =  qc_bearings[0] / 2 + 0.25, h = qc_bearings[2]);

		translate([0, 0, -t_qc_lever / 2 - 1])
			cylinder(r1 =  qc_bearings[0] / 2 + 0.25, r2 = qc_bearings[0] / 2, h = qc_bearings[2] + 1);
		
		// belt anchor - totally fudged this to fit
		rotate([0, 0, a_max_qc - 5.2])
			translate([qc_long - 20, 0, t_qc_lever / 2 - 8])
				rotate([0, 0, 40])
					difference() {
						hull() {
							cylinder(r = 5, h = t_qc_lever);

							translate([20, 0, 0])
								cylinder(r = 1, h = t_qc_lever);

						}
						
						cylinder(r1 = 3.1, r2 = 2.8, h = t_qc_lever);
						
						// the belt with teeth meshed is ~2.4mm thick
						for (i = [-1, 1])
							translate([13, i * 20, 0])
								cylinder(r = 19.1,  h = t_qc_lever);
					}
	}
	
	if (assembly) {
			rotate([0, 0, 180 - a_qc_bearings])
				translate([0, 0, (t_qc_lever_pivot - t_qc_lever) / 2]) {
					// idler bearing mount
					translate([0, qc_short, t_qc_lever_pivot / 2 - 2 + layer_height]) {
							// pivot bearing
							translate([0, 0, 2 + qc_bearings[2] / 2]) {
								color(color_bearing)
									bearing(type = qc_bearings);
									
								// nut
								translate([0, 0, qc_bearings[2] / 2])
									color(color_fastener)
										difference() {
											cylinder(r = d_M5_nut / 2, h = h_M5_nut, $fn = 6);
									
											cylinder(r = d_M5_screw / 2, h = h_M5_nut + 1);
										}
							}
					}
				}
		
		// pivot bearing
		translate([0, 0, -t_qc_lever / 2 + t_qc_lever_pivot - qc_bearings[2] / 2 + 1])
			color(color_bearing)
				bearing(type = qc_bearings);
	
		translate([0, 0, -t_qc_lever / 2 + qc_bearings[2] / 2])
			color(color_bearing)
				bearing(type = qc_bearings);
	}
}

module sensor_shroud(line_laser = false, n_point_lasers = 4) {
	translate([0, 6, 0]) {
		difference() {
			cube([h_shroud, l_sensor_board, w_sensor_board + 4], center = true);

		// laser paths
		if (line_laser) {
			translate([0, offset_slot - (l_sensor_board - l_slot) / 2, h_shroud * sin(a_line_laser) / 2])
				rotate([0, a_line_laser, 0])
					translate([-l_light_path / 2, 0, 0])
						cube([100, l_slot, w_slot], center = true);
		}
		else {
			translate([0, -l_sensor_board / 2 + hole1[0] + 7.5, h_shroud * sin(a_point_laser) / 2])
				rotate([0, 90 + a_point_laser, 0])
					for (i = [0:n_point_lasers -1])
						translate([0, i * 6.5, 0])
							cylinder(r = 2, h = 20, center = true);
		}
		
		// socket relief
		translate([0, offset_socket - (l_sensor_board - l_socket) / 2, 0]) {
			cube([h_shroud + 1, l_socket, w_sensor_board], center = true);
		
			// laser terminal opening
			translate([1, l_socket / 4 - 5, 0])
				cube([h_shroud / 2 + 2, l_socket, w_sensor_board + 5], center = true);
		}
				
		// mounts
		rotate([0, 90, 0])
			translate([-w_sensor_board / 2, -l_sensor_board / 2, 0]) {
				translate([hole1[1], hole1[0], 0]) {
					cylinder(r = d_mounts / 2, h = h_shroud + 1, center = true);
					
					translate([0, 0, -h_shroud / 2 - 1])
						cylinder(r = d_M3_cap / 2, h = h_shroud / 2 + 1);
				}

				translate([hole2[1], hole2[0], 0]) {
					cylinder(r = d_mounts / 2, h =  h_shroud + 1, center = true);
					
					translate([0, 0, -h_shroud / 2 - 1])
						cylinder(r = d_M3_cap / 2, h = h_shroud / 2 + 1);
				}
			}
		
			// sensor relief
			translate([h_shroud / 2, offset_slot - (l_sensor_board - l_slot) / 2, 0])
				cube([6, l_slot, 6], center = true);
		}
	}

	translate([h_shroud / 2 - 3, offset_slot - (l_sensor_board - l_slot) / 2 + 6, 0])
		cube([layer_height, l_slot, 6], center = true);

//	sensor_mount();
}

module mainboard_mount() {
	difference() {
		union() {
			hull()
				for (i = [-1, 1])
					for (j = [-1, 1])
						translate([i * cc_l_mounts / 2, j * cc_w_mounts / 2, 0])
							cylinder(r = d_mounts, h = 3, center = true);

			for (i = [-1, 1])
				for (j = [-1, 1])
					translate([i * cc_l_mounts / 2, j * cc_w_mounts / 2, 1.4])
						cylinder(r = d_mounts, h = standoff);
		}

		for (i = [-1, 1])
			for (j = [-1, 1])
				translate([i * cc_l_mounts / 2, j * cc_w_mounts / 2, -2])
					cylinder(r = d_mounts / 2 - 0.25, h = standoff + 4);

		hull()
			for (i = [-1, 1])
				for (j = [-1, 1])
					translate([i * (cc_l_mounts / 2 - 6), j * (cc_w_mounts / 2 - 6), 0])
						cylinder(r = d_mounts / 2, h = 4, center = true);
	
		for (i = [-1, 1])
			translate([i * (cc_l_mounts / 2 - 1), 0, 1]) {
				cylinder(r1 = d_mounts / 2, r2 = d_M3_cap / 2, h = 3, center = true);
			
				cylinder(r = d_mounts / 2, h = 6, center = true);
			}
	}
}

module sensor_mount(line_laser = false, n_point_lasers = 4) {
	difference() {
		union() {
			translate([standoff + offset_sensors - l_light_path / 2, 0, 0])
				difference() {
					translate([0, 3, 0])
						cube([l_sensor_mount, l_sensor_board + 6, w_sensor_board], center = true);

					translate([0, 7, 0])
						difference() {
							cube([l_light_path, l_sensor_board + 2, w_sensor_board + 1], center = true);
			
							rotate([0, 90, 0])
								translate([-w_sensor_board / 2, -l_sensor_board / 2 - 1, l_light_path / 2]) {
									translate([hole1[1], hole1[0], 0])
										cylinder(r = d_mounts, h = 2 * standoff, center = true);

									translate([hole2[1], hole2[0], 0])
										cylinder(r = d_mounts, h = 2 * standoff, center = true);
										
									// sensor locations -- remark before compiling
//									translate([hole2[1], hole1[0] + 7.75, 0])
//										for (i = [0:n_point_lasers - 1])
//											translate([0, i * 6.5, 0])
//												cylinder(r = d_mounts, h = 2 * standoff, center = true);
							}
						}
	
					for (i = [-1, 1])
						translate([i * cc_strut_slots / 2, 0, 0])
							rotate([90, 0, 0])
								cylinder(r = d_sensor_threaded_rod / 2 + 0.25, h = l_sensor_board + 13, center = true);
	
					rotate([0, 90, 0])
						translate([-w_sensor_board / 2, -l_sensor_board / 2 + 6, l_light_path / 2]) {
							translate([hole1[1], hole1[0], 0])
								cylinder(r = d_mounts / 2, h = 2 * standoff + 1, center = true);

							translate([hole2[1], hole2[0], 0])
								cylinder(r = d_mounts / 2, h =  2 * standoff + 1, center = true);
					}
				}

			if (line_laser) {
				rotate([0, a_line_laser, 0])
					translate([-l_light_path / 2, 0, 0])
						rotate([0, 90, 0])
							translate([0, 0, standoff + offset_sensors - l_light_path / 2 - 9]) {
								cylinder(r = d_line_laser / 2 + 3, h = 15, center = true);
							
								// boss for laser retainer screw
								translate([0, -d_line_laser / 2 - 3, 0])
									rotate([90, 0, 0]) {
										cylinder(r1 = 6, r2 = 3, h = 2 * h_M3_nut, center = true);
									}
							}
			}
			
			if (n_point_lasers > 0) {
				// the sensors are on the bridge side of the mount
				rotate([0, a_point_laser, 0])
					hull()
					for (i = [0,n_point_lasers - 1])
						translate([-l_light_path / 2, -l_sensor_board / 2 - 1 + hole1[0] + 7.75 + 7 + i * 6.5, 0])
							rotate([0, 90, 0])
								translate([0, 0, standoff + offset_sensors - l_light_path / 2 - 9])
									cylinder(r = d_point_laser / 2 + 3, h = 15, center = true);
			}
		}

		if (line_laser) {
			// laser opening
			rotate([0, a_line_laser, 0])
				translate([-l_light_path / 2, 0, 0])
					rotate([0, 90, 0])
						translate([0, 0, standoff + offset_sensors - l_light_path / 2 - 10]) {
							cylinder(r = d_line_laser / 2, h = 25, center = true);

								// laser retainer screw
								translate([0, -d_line_laser / 2 - 3, 1])
									rotate([90, 0, 0]) {
										cylinder(r = d_M3_screw / 2 - 0.2, h = 3 * h_M3_nut, center = true);
									}
						}
		}
		
		if (n_point_lasers > 0) {
			rotate([0, a_point_laser, 0])
				for (i = [0:n_point_lasers - 1])
					translate([-l_light_path / 2, -l_sensor_board / 2 - 1 + hole1[0] + 7.75 + 7 + i * 6.5, 0])
						rotate([0, 90, 0])
							translate([0, 0, standoff + offset_sensors - l_light_path / 2 - 9])
								cylinder(r = d_point_laser / 2, h = 20, center = true);
		}

	}
}

module thread_holder() {
	difference() {
		union() {
			cube([l_strut_slot + 5, d_strut_slot + 5, 12], center = true);
		
			translate([0, 0, 6]) {
				hull()
					for (i = [-1, 1])
						translate([i * (l_strut_slot - d_strut_slot) / 2, 0, 0])
							cylinder(r = d_strut_slot / 2 - 0.01, h = 3);
		
				translate([0, 0, 2])
					english_thread(diameter = 0.48, threads_per_inch = 13, length = 0.5, internal = false, n_starts = 1);
			}
		}
	
		rotate([0, 90, 0])
			cylinder(r = d_sensor_threaded_rod / 2, h = l_strut_slot + 6, center = true);
	}
}

module servo_mount() {
	difference() {
		cube([l_servo_flange + 10, w_servo + 6, 8], center = true);
	
		cube([l_servo + 1, w_servo + 1, 16], center = true);
	
		for (i = [-cc_w_servo_mounts / 2, cc_w_servo_mounts / 2])
			for (j = [-cc_l_servo_mounts / 2, cc_l_servo_mounts / 2])
				translate([j, i, 0])
					cylinder(r = d_servo_mounts / 2 - 0.2, h = 16, center = true);
	
		for (i = [-17.5, 17.5])
			translate([i, 0, 0])
				rotate([90, 0, 0]) {
					cylinder(r = d_M3_screw / 2, h = w_servo + 7, center = true);
			
					translate([0, 0, w_servo / 2 + 0.45])
						cylinder(r1 = d_M3_cap / 2, r2 = d_M3_screw / 2, h = 3);
				}
	}
}

/********** RETIRED **********/


module hall_switch_holder() {
	difference() {
		cylinder(r = d_pulley_spool / 2 + d_belt, h = 6);

		translate([0, 0, 1]) {
			spool_mount_body();
	
			// carbon fiber rod
			translate([bearing_idler[0] / 2 + 8, 0, bearing_idler[2] / 2 + 1])
				rotate([0, 90, 0])
					cylinder(r = d_c_rod / 2, h = d_frame_mount + 6);
		}
	
		translate([0, 0, -t_pulley / 2 - 1])
			cylinder(r = d_cone_shaft / 2 + 5, h = 2 * t_pulley);
	}
}

module tensioner_eccentric() {
	difference() {
		pulley(d_pulley = d_pulley_motor);

		translate([10, 0, 0])
			cylinder(r = d_M3_screw / 2, h = t_pulley + 1, center = true);
	}
}

module idler_tensioner() {
	difference() {
		union() {
			pulley(d_pulley = d_pulley_spool);
			
			translate([0, 0, t_pulley / 2 - 0.1])
				cylinder(r = d_pulley_spool / 2 + d_belt, h = 6);
		}

		translate([0, 0, t_pulley / 2 + 0.5]) {
			spool_mount_body();
	
			// carbon fiber rod
			translate([bearing_idler[0] / 2 + 8, 0, bearing_idler[2] / 2 + 1])
				rotate([0, 90, 0])
					cylinder(r = d_c_rod / 2, h = d_frame_mount + 6);
		}
	
		translate([0, 0, -t_pulley / 2 - 1])
			cylinder(r = d_cone_shaft / 2 + 5, h = 2 * t_pulley);
	}
}

module spool_mount_body() {
	hull() {
		cylinder(r = bearing_idler[0] / 2 + 3, h = bearing_idler[2] + 2);
	
		translate([bearing_idler[0] / 2 + 10, - d_c_rod / 2 - 2, 0])
			cube([0.1, d_c_rod + 4, bearing_idler[2] + 2]);
	}
}

module spool_mount() {
	difference() {
		spool_mount_body();
		
		// bearing pocket
		translate([0, 0, 2])	
			cylinder(r = bearing_idler[0] / 2, h = bearing_idler[2] + 1);
		
		// shaft
		translate([0, 0, -1])
			cylinder(r = d_cone_shaft / 2 + 5, h = 4);
	
		// carbon fiber rod
		translate([bearing_idler[0] / 2 + 1, 0, bearing_idler[2] / 2 + 1])
			rotate([0, 90, 0])
				cylinder(r = d_c_rod / 2, h = d_frame_mount + 6);
	}
}

module idler_cone() {
	difference() {
		union() {
			//cone
			cylinder(r1 = d_small_cone / 2, r2 = d_large_cone / 2, h = h_cone, center = true);
			
			for (i = [0, 180])
				rotate([0, 0, i])
					translate([d_large_cone / 2 - 7, 0, h_cone / 2])
						rotate([90, 0, 0])
							cylinder(r = 6, h = 3, center = true);
		}
	
		// shaft
		translate([0, 0, -h_cone / 2 - 1])
			cylinder(r = d_cone_shaft / 2, h = h_cone + t_pulley + 2);
		
		translate([0, 0, h_cone / 2 - h_M8_nut])
			cylinder(r = d_M8_nut / 2, h = h_M8_nut + 1, $fn = 6);
	}
}

module pulley_spool() {
	union() {
		mirror([0, 0, (d_pulley_spool + d_belt > d_large_cone) ? 1 : 0])
			difference() {
				union() {
					//cone
					cylinder(r1 = d_small_cone / 2, r2 = d_large_cone / 2, h = h_cone, center = true);
		
					// integrated pulley
					translate([0, 0, (h_cone + t_pulley) / 2 - 0.1])
						pulley(d_pulley = d_pulley_spool);
				}
				
				// hollow it out
				translate([0, 0, -2])
					cylinder(r1 = d_small_cone / 2 - 4, r2 = d_large_cone / 2 - 4, h = h_cone, center = true);
	
				// shaft
				translate([0, 0, -h_cone / 2 - 1])
					cylinder(r = d_cone_shaft / 2, h = h_cone + t_pulley + 2);
		
				translate([0, 0, h_cone / 2 + t_pulley - h_M8_nut])
					cylinder(r = d_M8_nut / 2, h = h_M8_nut + 1, $fn = 6);
			
				// magnet pocket
				translate([0, 17, h_cone / 2 + t_pulley])
					cylinder(r = d_magnet / 2, h = 2 * h_magnet, center = true);
			}
		
		if (d_pulley_spool + d_belt > d_large_cone)
			translate([0, 0, -h_cone / 2 - t_pulley + h_M8_nut])
				cylinder(r = d_M8_nut / 2 + 1, h = layer_height);
	}
}

module pulley_motor() {
	difference() {
		union() {
			pulley(d_pulley = d_pulley_motor);
			
			translate([0, 0, t_pulley / 2 - 0.1])
				cylinder(r = 10, h = 6);
		}
		
		// motor shaft
		translate([0, 0, -t_pulley / 2 - 1])
			difference() {
				cylinder(r = d_shaft / 2 + 0.2, h = 2 * t_pulley + 2);
		
				translate([d_shaft_flat / 2, -5, -1])
					cube([10, 10, 2 * t_pulley + 4]);
			}
			
			// set screw
			translate([0, 0, t_pulley / 2 + 3]) {
				translate([6, 0, 0])
					rotate([0, 90, 0]) {
						hull()
							for (i = [0, -6])
								translate([i, 0, 0])
									cylinder(r = d_M3_nut / 2, h = h_M3_nut, center = true, $fn = 6);
						
						cylinder(r = d_M3_screw / 2, h = 12, center = true);
					}
			}
	}
}

module pulley(d_pulley) {
	difference() {
		cylinder(r = d_pulley / 2 + d_belt, h = 6, center = true);
	
		rotate_extrude(convexity = 10)
			translate([d_pulley / 2 + d_belt, 0, 0])
				circle(r = d_belt / 2);
	}
}

module motor_mount() {
	difference() {
		hull() {
			cylinder(r = d_motor_mount / 2, h = 4, center = true);
		
			translate([d_motor_mount / 2 + 30, 0, 0])
				cube([0.1, d_motor_mount, t_motor_mount], center = true);
		}
	
		rotate([0, 0, 30])
			for(i = [0:n_mounts - 1])
				rotate([0, 0, i * 360 / n_mounts])
					translate([d_motor_mount_circle / 2, 0, 0])
						cylinder(r = d_mounts / 2, h = t_motor_mount + 1, center = true);
	
		translate([-offset_shaft, 0, 0])
			cylinder(r = d_shaft_collar / 2 + 1, h = t_motor_mount + 1, center = true);
	
		translate([40, 0, 0])
			for (i = [-12.5, 12.55])
				translate([0, i, 0])
					cylinder(r = d_M3_screw / 2, h = t_motor_mount + 1, center = true);
	}
}


module filament_guides_holder() {
	difference() {
		cube([w_sensor_board + 10, 25, 8], center = true);
		
		translate([0, 0, 2])
			cube([w_sensor_board + 0.25, 26, 5], center = true);
			
		for (i = [-1, 1])
			for (j = [-1, 1])
				translate([j * ((w_sensor_board + d_guide) / 2 + 0.5), i * 5, 0])
					cylinder(r = d_guide / 2, h = 9, center = true);
	}
}


module tensioner_loop_coupling() {
	difference() {
		cube([25, 2 * d_tensioner + 6, 2 * d_tensioner], center = true);
		
		for (i = [-1, 1])
			translate([0, i * (d_tensioner / 2 + 0.5), 0])
				rotate([0, 90, 0])
					cylinder(r = d_tensioner / 2, h = 26, center = true);
	}
}

module tensioner_loop_mount() {
	loop_offset = tensioner_entry_offset - d_loop_tensioner / 2;
	half_chord = pow(pow(d_loop_tensioner / 2, 2) - pow(loop_offset, 2), 0.5);
	
	difference() {
		cube([12, 12, cc_strut_slots + 2 * d_sensor_threaded_rod], center = true);
		
		translate([loop_offset, half_chord, -10])
			rotate_extrude(convexity = 10)
				translate([d_loop_tensioner / 2, 0, 0])
					circle(r = d_tensioner / 2);
		
		for (i = [-1, 1])
			translate([0, 0, i * cc_strut_slots / 2])
				rotate([90, 0, 0]) {
					cylinder(r = d_sensor_threaded_rod / 2 - 0.25, h = 13, center = true);
					
					translate([d_sensor_threaded_rod / 2 + 0.8, 0, 0])
						hull()
							for (j = [0, 10])
								translate([j, 0, 0])
									cylinder(r = d_sensor_threaded_rod / 2, h = 13, center = true);
				}
	}
}

module tensioner_loop_coupling() {
	difference() {
		cube([25, 2 * d_tensioner + 6, 2 * d_tensioner], center = true);
		
		for (i = [-1, 1])
			translate([0, i * (d_tensioner / 2 + 0.5), 0])
				rotate([0, 90, 0])
					cylinder(r = d_tensioner / 2, h = 26, center = true);
	}
}

module cable_mount() {
	difference() {
		hull() {
			cylinder(r = 3, h = d_cable_holder);
		
			translate([10, 0, d_cable_holder / 2])
				rotate([90, 0, 0])
					cylinder(r = d_cable_holder / 2, h = 6, center = true);
		}
	
		translate([0, 0, -1])
			cylinder(r = d_M4_screw / 2, h = d_cable_holder + 2);

		translate([10, 0, d_cable_holder / 2])
			rotate([90, 0, 0])
				cylinder(r = d_cable / 2, h = 7, center = true);
	
		translate([0, 0, d_cable_holder / 2])
			cube([20, d_cable_holder, 2], center = true);
	}
}