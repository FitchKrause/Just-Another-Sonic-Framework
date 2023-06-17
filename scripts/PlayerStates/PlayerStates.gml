// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function is_player_sphere() {
	return array_contains([
		"jump",
		"roll",
		"dropdash",
	], state.current());
}

function PlayerStates() {

state.add("normal", {
	on_start: function() {
		
	},
	
	on_step: function(player) {with (player) {
		// Look Up and Down
		if (ground && is_key_up && gsp == 0)
			state.change_to("look_up");
		if (ground && is_key_down && gsp == 0)
			state.change_to("look_down");
			
		// To Roll
		if (ground && is_key_down && abs(gsp) >= 1) {
			state.change_to("roll");
			audio_play_sound(sndPlrRoll, 0, false);
		}
		
		// Skid
		if (ground && abs(gsp) >= 4 && 
			((gsp < 0 && is_key_right) || (gsp > 0 && is_key_left))
		) {
			state.change_to("skid");
			audio_play_sound(sndPlrBraking, 0, false);
		}
		
		// Balancing
		if (ground && gsp == 0 && 
			(!sensor.is_collision_ground_left_edge() || !sensor.is_collision_ground_right_edge())
		) {
			state.change_to("balancing");
		}
		
		
	}},
	
	on_exit: function() {
		
	},
});


state.add("jump", {
	on_start: function() {
		
	},
	
	on_step: function(player) { with (player) {
		if (!is_key_action && ysp < -4)
			ysp = -4;
			
		if (is_key_action_pressed && 
			(shield == SHIELD_NONE || shield == SHIELD_CLASSIC)
		) {
			audio_play_sound(sndPlrDropDash, 0, false);
			state.change_to("dropdash");
		}
	}},
	
	on_exit: function() {
		
	},
});


state.add("look_up", {
	on_start: function(player) { with player {
		allow_jump = false;	
		allow_movement = false;	
	}},
	
	on_exit: function(player) { with player {
		allow_jump = true;	
		allow_movement = true;	
	}},
	
	on_step: function(player) { with (player) {
		if (!is_key_up || !ground || gsp != 0)
			state.change_to("normal");
			
		if (ground && is_key_action) 
			state.change_to("peelout");
	}},
});


state.add("look_down", {
	on_start: function(player) { with player {
		allow_jump = false;	
		allow_movement = false;	
	}},
	
	on_exit: function(player) { with player {
		allow_jump = true;	
		allow_movement = true;	
	}},
	
	on_step: function(player) { with player {
		if (!is_key_down || !ground)
			state.change_to("normal");
		else if (abs(gsp) >= 1.0)
			state.change_to("roll");
			
		if (ground && is_key_action_pressed)
			state.change_to("spindash");	
	}},
});


state.add("push", {
	on_step: function(player) { with player {
		xsp = 0;
		gsp = 0;
	
		if ((image_xscale == 1 && !is_key_right) || (image_xscale == -1 && !is_key_left))
			state.change_to("normal");
	}},
});


state.add("roll", {
	on_step: function(player) { with player {
		var _agsp = abs(gsp);
		
		if (_agsp < 0.5)
			state.change_to("normal");
	}},
});


state.add("skid", {
	on_step: function(player) { with player {
		if (abs(gsp) <= 0.5 || !ground || 
		    ((gsp < 0 && is_key_left) || (gsp > 0 && is_key_right))
		) {
			state.change_to("normal");	
		}
	}},
});


state.add("balancing", {
	on_step: function(player) { with player {
		if (gsp != 0 || !ground)
			state.change_to("normal");
	}},
});


state.add("peelout", {
	__timer: 0,
	
	on_start: function(player) { with player {
		audio_play_sound(sndPlrPeelCharge, 0, false);
		other.__timer = 0;
		allow_jump = false;	
		player.allow_movement = false;	
		
		player.peelout_animation_spd = 0;
	}},
	
	on_exit: function(player) { with player {
		allow_jump = true;	
		allow_movement = true;	
	}},
	
	on_step: function(player) { 
		with player {
			if (!is_key_up) {
				if (other.__timer >= 30) {
					gsp = 12 * image_xscale;
			
					audio_stop_sound(sndPlrPeelCharge);
					audio_play_sound(sndPlrPeelRelease, 0, false);
			
					camera.lagTimer = 15;
				} else {
					other.__timer = 0;		
				}
		
				state.change_to("normal");
			}
			
		}
		
		__timer++;
		if __timer > 30
			__timer = 30;
			
		player.peelout_animation_spd = __timer;
	},
});

state.add("spindash", {
	__spinrev: 0,
	
	on_start: function(player) {
		audio_sound_pitch(sndPlrSpindashCharge, 1);
		audio_play_sound(sndPlrSpindashCharge, 0, false);
		__spinrev = 0;
		player.allow_jump = false;	
		player.allow_movement = false;	
	},
	
	on_exit: function(player) { with player {
		allow_jump = true;	
		allow_movement = true;	
	}},
	
	on_step: function(player) {
		with player {
			if (!is_key_down) {
				gsp = (8 + (floor(other.__spinrev) / 2)) * sign(image_xscale);
		
				audio_stop_sound(sndPlrSpindashCharge);
				audio_play_sound(sndPlrSpindashRelease, 0, false);
			
				state.change_to("roll");
		
				camera.lagTimer = 15;
			}
		}
	
		if (player.is_key_action_pressed) {
			__spinrev += (__spinrev < 8) ? 2 : 0;
		
			audio_stop_sound(sndPlrSpindashCharge);
		
			audio_sound_pitch(sndPlrSpindashCharge, 1 + __spinrev / 10);
			audio_play_sound(sndPlrSpindashCharge, 0, false);
		
		}
	
		__spinrev -= (((__spinrev * 1000) div 125) / 256000);
		
	},
});


state.add("dropdash", {
	__drop_timer: 0,
	
	on_start: function(player) {
		__drop_timer = 0;
		audio_play_sound(sndPlrDropDash, 0, false);
	},
	
	
	on_landing: function(player) {with player {
		if (other.__drop_timer < 20) {
			state.change_to("normal");
			return;
		}
		
		state.change_to("roll");
		audio_play_sound(sndPlrSpindashRelease, 0, false);
		
		if (sign(image_xscale) == sign(xsp))
			gsp = (gsp / 4) + (drpspd * sign(image_xscale));
		else 
			gsp = ((sensor.get_angle() == 0) ? 0 : (gsp / 2)) + (drpspd * sign(image_xscale));
				
		camera.lagTimer = 15;
	}},
	
	on_step: function(player) {with player {
		if (!is_key_action)
			state.change_to("jump");
			
		other.__drop_timer++;
	}},
});

state.add("hurt", {
	on_start: function(player) {with (player) {
		allow_movement = false;			
	}},
	
	on_exit: function(player) {with (player) {
		allow_movement = true;			
	}},
	
	on_landing: function(player) {with (player) {
		inv_timer = 120;
		
		state.change_to("normal");
		
		gsp = 0;
		xsp = 0;
	}},
});




}