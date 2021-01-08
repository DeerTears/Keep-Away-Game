extends KinematicBody

signal score_changed

onready var head = $Head
onready var attack_ray = $Head/AttackRay

onready var attack_windup = $AttackWindup
onready var attack_cooldown = $AttackCooldown
onready var lob_cooldown = $LobCooldown
onready var lob_windup = $LobWindup

onready var sound_swoosh = $Sounds/Swoosh
onready var sound_clang = $Sounds/Clang
onready var sound_ow = $Sounds/Ow
onready var sound_hitworld = $Sounds/HitWorld
onready var sound_teleport = $Sounds/Teleport

export var player_number: int = 0
export var mouse_look_sensitivity = 0.4
export var joy_look_sensitivity = 0.4
var look_device = InputEventMouseMotion # todo: test with Joypads

# combat statistics
var push_strength = 8
var attack_windup_time = 0.275
var attack_cooldown_time = 0.6
var lob_windup_time = 0.1
var lob_cooldown_time = 0.5

# movement statistics
var speed = 5
var h_acceleration = 10
var gravity = 13
var jump = 6

# character controller vars
var movement = Vector3()
var direction = Vector3()
var h_velocity = Vector3()
var gravity_vec = Vector3()
var impact_vec = Vector3()
var translate_offset = Vector3()
var camera_height = 0
var joy_head_horizontal_movement: float
var joy_head_vertical_movement: float

# movement checks
var movement_enabled = true
var attacking = false
var lobbing = false
var is_hitstunned: bool = false

func _ready():
	init()

func init():
	translate_offset = Vector3(0,camera_height,0)
	attack_windup.wait_time = attack_windup_time
	attack_cooldown.wait_time = attack_cooldown_time
	lob_windup.wait_time = lob_windup_time
	lob_cooldown.wait_time = lob_cooldown_time
	teleport(GameInfo.get_my_respawn_location(player_number), true)
	$Head/Camera/Viewmodel/AnimationPlayer.play("idle")

func _on_AttackWindup_timeout():
	if attack_cooldown.is_stopped():
		attacking = true
		yield(get_tree(),"idle_frame")
		attacking = false
		attack_cooldown.start()

func _on_AttackCooldown_timeout():
	if attack_windup.is_stopped():
		$Head/Camera/Viewmodel/AnimationPlayer.play("idle")

func _on_LobCooldown_timeout():
	pass

func _on_LobWindup_timeout():
	lobbing = true
	yield(get_tree(),"idle_frame")
	lobbing = false
	lob_cooldown.start()

func _on_ItemGrabber_area_entered(area):
	if "coin_quality" in area.get_parent():
		area.get_parent().collect()
		emit_signal("score_changed", area.get_parent().coin_quality)
		return
	if area.get_parent().name == "Pits":
		teleport(GameInfo.get_my_respawn_location(player_number), false)
		return

func _input(event):
	if event is look_device:
		if event is InputEventMouseMotion:
			rotate_y(deg2rad(-event.relative.x * mouse_look_sensitivity))
			head.rotate_x(deg2rad(-event.relative.y * mouse_look_sensitivity))
			head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))
	if attack_cooldown.is_stopped() and attack_windup.is_stopped() and movement_enabled:
		if event.is_action_pressed("attack_%s" % [player_number]):
			attack_windup.start()
			$Head/Camera/Viewmodel/AnimationPlayer.stop()
			$Head/Camera/Viewmodel/AnimationPlayer.play("attack")
			sound_swoosh.play()
	if lob_cooldown.is_stopped() and lob_windup.is_stopped() and movement_enabled:
		if event.is_action_pressed("lob_%s" % [player_number]):
			lob_windup.start()
			sound_swoosh.play()

func _physics_process(delta):
	direction = Vector3()
	if look_device == InputEventJoypadMotion:
		joy_head_vertical_movement = Input.get_action_strength("look_up_%s" % [player_number]) - Input.get_action_strength("look_down_%s" % [player_number]) 
		joy_head_horizontal_movement = Input.get_action_strength("look_left_%s" % [player_number]) - Input.get_action_strength("look_right_%s" % [player_number])
		head.rotate_x(deg2rad(joy_head_vertical_movement * joy_look_sensitivity * 8))
		rotate_y(deg2rad(joy_head_horizontal_movement * joy_look_sensitivity * 8))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))
	# jumping and falling
	if not is_on_floor() and not is_hitstunned:
		gravity_vec += Vector3.DOWN * gravity * delta
	else:
		gravity_vec = Vector3.ZERO
	if Input.is_action_pressed("jump_%s" % [player_number]) and is_on_floor() and movement_enabled:
		gravity_vec = Vector3.UP * jump
	# walking
	if Input.is_action_pressed("fwd_%s" % [player_number]):
		direction -= transform.basis.z
	if Input.is_action_pressed("back_%s" % [player_number]):
		direction += transform.basis.z
	if Input.is_action_pressed("left_%s" % [player_number]):
		direction -= transform.basis.x
	if Input.is_action_pressed("right_%s" % [player_number]):
		direction += transform.basis.x
	if movement_enabled:
		direction = direction.normalized()
	else:
		direction = Vector3.ZERO
	# applying attack force to others
	if attacking:
		var look_direction = Vector3(0,head.rotation.x,0) - transform.basis.z # get all angles
		look_direction.y += 1.15 # hit items off the ground for cartoony effect
		look_direction *= push_strength # apply strength stat
		var reported_body = attack_ray.get_collider()
		if reported_body != null:
			var impact_type = reported_body.get_class()
			match impact_type:
				"RigidBody": # physics object
					reported_body.apply_impulse(Vector3.ZERO,look_direction)
					reported_body.update_last_hit(player_number)
				"KinematicBody": # player
					reported_body.is_hitstunned = true
					reported_body.impact_vec += look_direction * 1.5
			play_impact_sound(impact_type)
	if lobbing:
		var look_direction = Vector3(0,5.5,0)
		var reported_body = attack_ray.get_collider()
		if reported_body != null:
			var impact_type = reported_body.get_class()
			match impact_type:
				"RigidBody": # physics object
					reported_body.apply_impulse(Vector3.ZERO,look_direction)
					reported_body.update_last_hit(player_number)
				"KinematicBody": # player
					reported_body.is_hitstunned = true
					reported_body.impact_vec += look_direction * 1.5
			play_impact_sound(impact_type)
	# momentum
	h_velocity = h_velocity.linear_interpolate(direction * speed, h_acceleration * delta)	
	# final calculations
	movement.z = h_velocity.z + impact_vec.z
	movement.x = h_velocity.x + impact_vec.x
	movement.y = gravity_vec.y + (impact_vec.y / 1.5)
	move_and_slide(movement, Vector3.UP)
	# hacky way of creating a fake curve for knockbacks
	# would love to implement something far more robust, perhaps even showing the endpoint and interpolating as needed
	# fake curve decay
	var impact_decay = 0.98
	impact_vec *= impact_decay # oops this is doubled
	if is_on_floor(): # if we hit the ground
		impact_vec = Vector3.ZERO # don't skid on the ground
		is_hitstunned = false
	else:
		if impact_vec.length() <= 0.5:
			impact_vec *= impact_decay
			return
		if impact_vec.length() <= 26 and is_hitstunned:
			is_hitstunned = false

func play_impact_sound(impact_type:String):
	var random_pitch = rand_range(0.8,1.2)
	match impact_type:
		"KinematicBody":
			sound_clang.pitch_scale = random_pitch
			sound_ow.pitch_scale = random_pitch
			sound_clang.play()
			sound_ow.play()
		"RigidBody":
			sound_clang.pitch_scale = random_pitch
			sound_clang.play()
		"StaticBody":
			sound_hitworld.pitch_scale = random_pitch
			sound_hitworld.play()
		"CSGCombiner":
			sound_hitworld.pitch_scale = random_pitch
			sound_hitworld.play()

func teleport(target:Vector3, silent:bool):
	transform.origin = target
	gravity_vec = Vector3.ZERO # resets previous pushes/gravity
	impact_vec = Vector3.ZERO
	yield(get_tree(),"idle_frame")
	if silent:
		return
	sound_teleport.play()

func enable_input(_true:bool):
	movement_enabled = _true

#func knockout():
#	speed = 0
#	camera_height = -0.55
#	translate_offset = Vector3(0,camera_height,0)
#	respawn_timer.start()
#
#func recover():
#	speed = 5
#	camera_height = 0.55
#	translate_offset = Vector3(0,camera_height,0)
