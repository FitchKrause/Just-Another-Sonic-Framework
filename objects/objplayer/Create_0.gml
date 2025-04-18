


var num = audio_get_listener_count();
for( var i = 0; i < num; i++)
{
    var info = audio_get_listener_info(i);
    audio_set_master_gain(info[? "index"], 0.1);
    ds_map_destroy(info);
}

if (!variable_instance_exists(id, "character_builder")) {
	show_error(
		"[CHARACTER INITIALISATION ERROR]\n" +
		$"character_builder not exists.\n" +
		"You need to initialize this variable to create your character.\n",
		true
	)
}

show_debug_info = true;

o_dj = !instance_exists(objDJ) ? 
	instance_create_layer(x, y, layer, objDJ) :
	instance_find(objDJ, 0);
	
camera = !instance_exists(objCameraSonicWorlds) ? 
	instance_create_layer(x, y, layer, objCameraSonicWorlds) :
	instance_find(objCameraSonicWorlds, 0);

// camera = !instance_exists(objCamera) ? 
// 	instance_create_layer(x, y, layer, objCamera) :
// 	instance_find(objCamera, 0);
	
camera.FollowingObject = id;

shield = undefined;

running_on_water = false;

animation_angle = 0;

allow_jump		= true;
allow_movement	= true;

remaining_air = 30;

#macro DELAY_UNDERWATER_EVENT		60
#macro DURATION_SUPER_FAST_SHOES	21*60
#macro DURATION_CONTROL_LOCK		30
#macro DURATION_INVINCIBILITY		120

timer_underwater  = new Timer2(
	DELAY_UNDERWATER_EVENT, 
	true, 
	function() { with self player_underwater_event(); }
);

timer_speed_shoes = new Timer2(
	DURATION_SUPER_FAST_SHOES, 
	false, 
	function() { with self physics.cancel_super_fast_shoes(); }
);

timer_control_lock = new Timer2(
	DURATION_CONTROL_LOCK,
	false,
	function() { with self allow_movement = true; }
);

timer_invincibility = new Timer2(DURATION_INVINCIBILITY, false);

timer_powerup_invincibility = new Timer2(31 * 60, false);

plr = character_builder.build();
plr.state_machine.change_to("normal");


draw_player = function() {
	if (plr.draw_behind != undefined)
		plr.draw_behind(plr);	
	draw_self();	
}


behavior_loop = new PlayerLoop();
behavior_loop
	.add(player_switch_sensor_radius)

	.add(player_behavior_apply_speed)

	// Handle monitors before solid collision
	.add(player_handle_monitors)
	
	// Collisions
	.add(player_behavior_collisions_solid)
	
	// Air 
	.add(player_behavior_apply_gravity)
	.add(player_behavior_air_movement)
	.add(player_behavior_air_drag)
	.add(player_behavior_jump)

	// Ground
	.add(player_behavior_slope_decceleration)
	.add(player_behavior_ground_movement)
	.add(player_behavior_ground_friction)
	.add(player_behavior_fall_off_slopes)
;

handle_loop = new PlayerLoop();
handle_loop
	.add(player_handle_layers)
	.add(player_handle_rings)
	.add(player_handle_springs)
	.add(player_handle_spikes)
	
	.add(player_handle_moving_platforms)
	.add(player_handle_water)
	.add(player_handle_bubbles)
	.add(player_handle_enemy)
	.add(player_handle_corksew)
	.add(player_handle_projectile)
;

visual_loop = new PlayerLoop();
visual_loop
	.add(player_behavior_visual_angle)
	.add(player_behavior_visual_flip)
	.add(player_behavior_visual_create_afterimage)
;

is_key_left				= false;
is_key_right			= false;
is_key_up				= false;
is_key_down				= false;
is_key_action			= false;
is_key_action_pressed	= false;

p_sfx_water_run			= -1;

jump_surface = -1;


