shader_type particles;
uniform vec3 direction;
uniform float spread;
uniform float flatness;
uniform float initial_linear_velocity_min;
uniform float initial_angle_min;
uniform float angular_velocity_min;
uniform float orbit_velocity_min;
uniform float linear_accel_min;
uniform float radial_accel_min;
uniform float tangent_accel_min;
uniform float damping_min;
uniform float scale_min;
uniform float hue_variation_min;
uniform float anim_speed_min;
uniform float anim_offset_min;
uniform float initial_linear_velocity_max;
uniform float initial_angle_max;
uniform float angular_velocity_max;
uniform float orbit_velocity_max;
uniform float linear_accel_max;
uniform float radial_accel_max;
uniform float tangent_accel_max;
uniform float damping_max;
uniform float scale_max;
uniform float hue_variation_max;
uniform float anim_speed_max;
uniform float anim_offset_max;
uniform float lifetime_randomness;
uniform vec3 emission_box_extents;
uniform vec4 color_value : source_color;
uniform vec3 gravity;
uniform sampler2D sprite;


float rand_from_seed(inout uint seed) {
	int k;
	int s = int(seed);
	if (s == 0)
	s = 305420679;
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0)
		s += 2147483647;
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}

float rand_from_seed_m1_p1(inout uint seed) {
	return rand_from_seed(seed) * 2.0 - 1.0;
}

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

void start() {
	uint base_number = NUMBER;
	uint alt_seed = hash(base_number + uint(1) + RANDOM_SEED);
	float angle_rand = rand_from_seed(alt_seed);
	float scale_rand = rand_from_seed(alt_seed);
	float hue_rot_rand = rand_from_seed(alt_seed);
	float anim_offset_rand = rand_from_seed(alt_seed);
	float pi = 3.14159;
	float degree_to_rad = pi / 180.0;

	float tex_angle = 1.0;
	float tex_anim_offset = 1.0;
	float spread_rad = spread * degree_to_rad;
	if (RESTART_VELOCITY) {
		float tex_linear_velocity = 1.0;
		{
			float angle1_rad = rand_from_seed_m1_p1(alt_seed) * spread_rad;
			angle1_rad += direction.x != 0.0 ? atan(direction.y, direction.x) : sign(direction.y) * (pi / 2.0);
			vec3 rot = vec3(cos(angle1_rad), sin(angle1_rad), 0.0);
			VELOCITY = rot * mix(initial_linear_velocity_min,initial_linear_velocity_max, rand_from_seed(alt_seed));
		}
	}
	float base_angle = (tex_angle) * mix(initial_angle_min, initial_angle_max, angle_rand);
	CUSTOM.x = base_angle * degree_to_rad;
	CUSTOM.y = 0.0;
	CUSTOM.w = (1.0 - lifetime_randomness * rand_from_seed(alt_seed));
	CUSTOM.z = (tex_anim_offset) * mix(anim_offset_min, anim_offset_max, anim_offset_rand);

	if (RESTART_ROT_SCALE) {
		TRANSFORM[0].xyz = vec3(1.0, 0.0, 0.0);
		TRANSFORM[1].xyz = vec3(0.0, 1.0, 0.0);
		TRANSFORM[2].xyz = vec3(0.0, 0.0, 1.0);
	}

	if (RESTART_POSITION) {
		TRANSFORM[3].xyz = vec3(rand_from_seed(alt_seed) * 2.0 - 1.0, rand_from_seed(alt_seed) * 2.0 - 1.0, rand_from_seed(alt_seed) * 2.0 - 1.0) * emission_box_extents;
		
		vec2 particle_pos = TRANSFORM[3].xy;
		vec2 texture_size = vec2(textureSize(sprite, 0));
		vec4 sprite_color = texture(sprite, particle_pos/texture_size + vec2(0.25, 0.5));
		COLOR = sprite_color;
		VELOCITY.xy = particle_pos * initial_linear_velocity_min;

		if (sprite_color.a == 0.0) {
			ACTIVE = false;
		}
		
	if (RESTART_VELOCITY) VELOCITY = (EMISSION_TRANSFORM * vec4(VELOCITY, 0.0)).xyz;
	TRANSFORM = EMISSION_TRANSFORM * TRANSFORM;
	VELOCITY.z = 0.0;
	TRANSFORM[3].z = 0.0;
	}
}

void process() {
	uint base_number = NUMBER;
	uint alt_seed = hash(base_number + uint(1) + RANDOM_SEED);
	float angle_rand = rand_from_seed(alt_seed);
	float scale_rand = rand_from_seed(alt_seed);
	float hue_rot_rand = rand_from_seed(alt_seed);
	float anim_offset_rand = rand_from_seed(alt_seed);
	float pi = 3.14159;
	float degree_to_rad = pi / 180.0;

	CUSTOM.y += DELTA / LIFETIME;
	float tv = CUSTOM.y / CUSTOM.w;
	float tex_linear_velocity = 1.0;
	float tex_orbit_velocity = 1.0;
	float tex_angular_velocity = 1.0;
	float tex_linear_accel = 1.0;
	float tex_radial_accel = 1.0;
	float tex_tangent_accel = 1.0;
	float tex_damping = 1.0;
	float tex_angle = 1.0;
	float tex_anim_speed = 1.0;
	float tex_anim_offset = 1.0;
	vec3 force = gravity;
	vec3 pos = TRANSFORM[3].xyz;
	pos.z = 0.0;
	// apply linear acceleration
	force += length(VELOCITY) > 0.0 ? normalize(VELOCITY) * tex_linear_accel * mix(linear_accel_min, linear_accel_max, rand_from_seed(alt_seed)) : vec3(0.0);
	// apply radial acceleration
	vec3 org = EMISSION_TRANSFORM[3].xyz;
	vec3 diff = pos - org;
	force += length(diff) > 0.0 ? normalize(diff) * tex_radial_accel * mix(radial_accel_min, radial_accel_max, rand_from_seed(alt_seed)) : vec3(0.0);
	// apply tangential acceleration;
	float tangent_accel_val = tex_tangent_accel * mix(tangent_accel_min, tangent_accel_max, rand_from_seed(alt_seed));
	force += length(diff.yx) > 0.0 ? vec3(normalize(diff.yx * vec2(-1.0, 1.0)), 0.0) * tangent_accel_val : vec3(0.0);
	force += ATTRACTOR_FORCE;

	// apply attractor forces
	VELOCITY += force * DELTA;
	
	// orbit velocity
	float orbit_amount = tex_orbit_velocity * mix(orbit_velocity_min, orbit_velocity_max, rand_from_seed(alt_seed));
	if (orbit_amount != 0.0) {
	     float ang = orbit_amount * DELTA * pi * 2.0;
	     mat2 rot = mat2(vec2(cos(ang), -sin(ang)), vec2(sin(ang), cos(ang)));
	     TRANSFORM[3].xy -= diff.xy;
	     TRANSFORM[3].xy += rot * diff.xy;
	}
	float dmp = mix(damping_min, damping_max, rand_from_seed(alt_seed));
	if (dmp * tex_damping > 0.0) {
		float v = length(VELOCITY);
		float damp = tex_damping * dmp;
		v -= damp * DELTA;
		if (v < 0.0) {
			VELOCITY = vec3(0.0);
		} else {
			VELOCITY = normalize(VELOCITY) * v;
		}
	}
	float base_angle = (tex_angle) * mix(initial_angle_min, initial_angle_max, angle_rand);
	base_angle += CUSTOM.y * LIFETIME * (tex_angular_velocity) * mix(angular_velocity_min,angular_velocity_max, rand_from_seed(alt_seed));
	CUSTOM.x = base_angle * degree_to_rad;
	CUSTOM.z = (tex_anim_offset) * mix(anim_offset_min, anim_offset_max, rand_from_seed(alt_seed)) + tv * tex_anim_speed * mix(anim_speed_min, anim_speed_max, rand_from_seed(alt_seed));
	vec3 tex_scale = vec3(1.0);

	TRANSFORM[0] = vec4(cos(CUSTOM.x), -sin(CUSTOM.x), 0.0, 0.0);
	TRANSFORM[1] = vec4(sin(CUSTOM.x), cos(CUSTOM.x), 0.0, 0.0);
	TRANSFORM[2] = vec4(0.0, 0.0, 1.0, 0.0);
	TRANSFORM[3].z = 0.0;
	float base_scale = mix(scale_min, scale_max, scale_rand);
	base_scale = sign(base_scale) * max(abs(base_scale), 0.001);
	TRANSFORM[0].xyz *= base_scale * sign(tex_scale.r) * max(abs(tex_scale.r), 0.001);
	TRANSFORM[1].xyz *= base_scale * sign(tex_scale.g) * max(abs(tex_scale.g), 0.001);
	TRANSFORM[2].xyz *= base_scale * sign(tex_scale.b) * max(abs(tex_scale.b), 0.001);
	if (CUSTOM.y > CUSTOM.w) {
		ACTIVE = false;
	}
}

