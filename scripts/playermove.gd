extends KinematicBody

signal score_changed
signal stamina_changed

# overview:

# NON-STANDARD FUNCTIONS
# playing impact sounds
# teleporting self
# taking hits
# enabling input

onready var head = $Head
onready var attack_ray = $Head/AttackRay

onready var attack_windup = $AttackWindup
onready var attack_cooldown = $AttackCooldown
onready var respawn_timer = $RespawnTimer

onready var sound_swoosh = $Sounds/Swoosh
onready var sound_clang = $Sounds/Clang
onready var sound_ow = $Sounds/Ow
onready var sound_hitworld = $Sounds/HitWorld
onready var sound_teleport = $Sounds/Teleport

export var player_number: int = 0
export var look_sensitivity = 0.4
var look_device = InputEventMouseMotion # todo: test with Joypads

# combat statistics
var max_stamina = 100
var stamina = 100
var attack_cost_to_stamina = 5
var push_strength = 8
var attack_windup_time = 0.1
var attack_cooldown_time = 0.4


# movement statistics
var speed = 5
var h_acceleration = 10
var gravity = 13
var jump = 6

# character controller vars
var movement = Vector3()
var direction = Vector3()
#var velocity = Vector3()
var h_velocity = Vector3()
var gravity_vec = Vector3()
var impact_vec = Vector3()
var translate_offset = Vector3()
var camera_height = 0.5

# movement checks
var movement_enabled = true
var attacking = false

func _ready():
	init()

func init():
	translate_offset = Vector3(0,camera_height,0)
	attack_windup.wait_time = attack_windup_time
	attack_cooldown.wait_time = attack_cooldown_time
	teleport(GameInfo.get_my_respawn_location(player_number), true)

func _on_AttackWindup_timeout():
	if attack_cooldown.is_stopped():
		attacking = true
		yield(get_tree(),"idle_frame")
		attacking = false
		attack_cooldown.start()


func _on_ItemGrabber_area_entered(area):
	if "coin_quality" in area.get_parent():
		area.get_parent().collect()
		emit_signal("score_changed", area.get_parent().coin_quality)
		return
	
	if area.get_parent().name == "Pits":
		teleport(GameInfo.get_my_respawn_location(player_number), false)
		return

func _input(event):
	if event is look_device: # todo: test with Joypads
		rotate_y(deg2rad(-event.relative.x * look_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * look_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))
	if event.is_action_pressed("aim_%s" % [player_number]):
		impact_vec = Vector3.UP * push_strength
	if attack_cooldown.is_stopped() and attack_windup.is_stopped() and movement_enabled and stamina != 0:
		if event.is_action_pressed("attack_%s" % [player_number]):
			attack_windup.start()
			sound_swoosh.play()
			stamina -= attack_cost_to_stamina
var is_hitstunned: bool = false

func _physics_process(delta):
	direction = Vector3()
	
	# jumping and falling
	if not is_on_floor() and not is_hitstunned:
		gravity_vec += Vector3.DOWN * gravity * delta
	else:
		#gravity_vec = impact_vec
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
				"KinematicBody": # player
					reported_body.is_hitstunned = true
					reported_body.impact_vec += look_direction * 2
			play_impact_sound(impact_type)
	
	# momentum
	h_velocity = h_velocity.linear_interpolate(direction * speed, h_acceleration * delta)
	
	# final calculations
	movement.z = h_velocity.z + impact_vec.z
	movement.x = h_velocity.x + impact_vec.x
	movement.y = gravity_vec.y + (impact_vec.y / 2)
	move_and_slide(movement, Vector3.UP)
	if impact_vec.length() <= 0.5 or is_on_floor():
		impact_vec = Vector3.ZERO
	if impact_vec.length() <= 6:
		is_hitstunned = false
	var impact_decay = 0.96
	impact_vec *= 0.96
	#impact_vec *= Vector3(1,impact_decay,1)


func _process(_delta):
	# update hud
	emit_signal("stamina_changed", stamina)
	pass

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

func knockout():
	speed = 0
	camera_height = -0.55
	translate_offset = Vector3(0,camera_height,0)
	respawn_timer.start()

func recover():
	speed = 5
	camera_height = 0.55
	translate_offset = Vector3(0,camera_height,0)

func take_hit(_stamina:int):
	stamina -= _stamina
	if stamina <= 0:
		knockout()

func enable_input(_true:bool):
	movement_enabled = _true
