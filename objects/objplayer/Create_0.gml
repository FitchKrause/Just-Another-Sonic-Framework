/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

#macro ROLL_DEC 0.125
#macro DEC		0.5

#macro SHIELD_NONE			0
#macro SHIELD_CLASSIC		1
#macro SHIELD_BUBBLE		2
#macro SHIELD_FIRE			3
#macro SHIELD_ELECTRIC		4

shield = SHIELD_NONE;

show_debug_info = true;

acc = 0.046875;
airacc = acc * 2;
dec = 0.5;
frc = acc;
top = 6;

animation_angle = 0;

slp = 0.125;
slp_rollup = 0.078125;
slp_rolldown = 0.3125;

grv = 0.21875;
jmp = 6.5;

control_lock_timer = 0;

idle_anim_timer = 0;



ground = false;

xsp = 0;
ysp = 0;
gsp = 0;

camera = instance_create_layer(x, y, layer, objCamera);

#macro ACT_NORMAL		0
#macro ACT_JUMP			1
#macro ACT_ROLL			2
#macro ACT_SKID			3
#macro ACT_CROUCH		4
#macro ACT_LOOK_UP		5
#macro ACT_PUSH			6
#macro ACT_SPINDASH		7
#macro ACT_BALANCING	8
#macro ACT_PEELOUT		9
#macro ACT_SPRING		10
#macro ACT_DIE			-1
#macro ACT_HURT			-2

action = ACT_NORMAL;

peelout_timer = 0;

inv_timer = 0;

spinrev = 0;

is_drop_dashing = false;
drop_dash_timer = 0;
drpspd		= 8; //the base speed for a drop dash
drpmax		= 12; //the top speed for a drop dash
drpspdsup	= 12; //the base speed for a drop dash while super
drpmaxsup	= 13; //the top speed for a drop dash while super

sensor = new Sensor();

is_key_left = 0;
is_key_right = 0;
is_key_up = 0;
is_key_down = 0;
is_key_action = 0;

sprite_index_prev = 0;