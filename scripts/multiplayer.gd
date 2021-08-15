#TO DO: Multiplayer with more than 2 players

extends Panel

const SERVER_PORT = 25700
const MAX_PLAYERS = 2
var SERVER_IP = "127.0.0.1"
var player_info = {}
var username
onready var username_text = $username
onready var ip_adress = $ip_adress
onready var waiting_text = $waiting/waiting_text
onready var waiting = $waiting
var mp_type
onready var game = $game
const romp_online = preload("res://levels/romp_online.tscn")
const dummy_scene = preload("res://actors/dummy.tscn")
const player_scene = preload("res://actors/player.tscn")
var game_running = false

func _on_Host_pressed():
	start_multiplayer("server")

func _on_Join_pressed():
	if username_text.text == "":
		#Abort if no username has been entered.
		username_text.get_node("warning").visible = true
		return
	ip_adress.visible = true
	ip_adress.get_node("ip_adress_animation").play("ip")

func _on_BackIP_pressed():
	ip_adress.visible = false

func _on_Connect_pressed():
	if ip_adress.get_node("LineEdit").text == "":
		return
	ip_adress.visible = false
	SERVER_IP = ip_adress.get_node("LineEdit").text
	start_multiplayer("client")

func _on_BackButton_pressed():
	get_tree().network_peer = null
	get_tree().change_scene("res://menus/playmenu.tscn")

func _process(delta):
	if game_running:
		#Update player position
		var character = game.get_node("romp_online/player/Player/KinematicBody")
		rpc_unreliable("position_update", character.global_transform.origin, character.rotation)
		if mp_type != "server":
			return
		#The server tells the clients the ball positions
		var targets = game.get_node("romp_online/Targets")
		var balls_pos_array = []
		for i in targets.get_children():
			balls_pos_array.append(i.global_transform.origin)
		rpc_unreliable("targets_update", balls_pos_array)

remote func targets_update(pos_array):
	var targets = game.get_node("romp_online/Targets")
	for i in targets.get_child_count():
		targets.get_children()[i].global_transform.origin = pos_array[i]

remote func position_update(pos, rot):
	if game.get_node("romp_online/dummies") == null:
		return
	var actor = game.get_node("romp_online/dummies").get_node(str(get_tree().get_rpc_sender_id()))
	if actor != null:
		actor.translation = pos
		actor.rotation = rot

func start_multiplayer(type):
	if username_text.text == "":
		#Abort if no username has been entered.
		username_text.get_node("warning").visible = true
		return
	username = username_text.text
	
	#Show waiting screen
	waiting.visible = true
	mp_type = type
	
	#Create new ENet
	var peer = NetworkedMultiplayerENet.new()
	match type:
		"server":
			peer.create_server(SERVER_PORT, MAX_PLAYERS)
			waiting_text.text = "Waiting for players..."
		"client":
			peer.create_client(SERVER_IP, SERVER_PORT)
			waiting_text.text = "Connecting..."
	get_tree().network_peer = peer
	
	#Connect ENet signals
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _player_connected(id):
	rpc_id(id, "register_player", username)
	if mp_type == "server":
		#A player has connected. Start game.
		start_game()

func _player_disconnected(id):
	player_info.erase(id) # Erase player from info.
	if game_running:
		#Delete dummy
		game.get_node("romp_online/dummies").get_node(str(id)).queue_free()
	#Stop game
	get_tree().network_peer = null
	get_tree().change_scene("res://menus/playmenu.tscn")

remote func register_player(username):
	print("Player " + username + " connected!")
	var id = get_tree().get_rpc_sender_id()
	#Save username in dictionary
	player_info[id] = username

func _connected_ok():
	#Called on clients if connection is successful
	print("Connected")
	start_game()

func _connected_fail():
	print("Connection failed!")
	get_tree().network_peer = null
	get_tree().change_scene("res://menus/playmenu.tscn")

func _server_disconnected():
	print("Disconnected!")
	get_tree().change_scene("res://menus/playmenu.tscn")

func create_dummy(id):
	var dummy = dummy_scene.instance()
	game.get_node("romp_online/dummies").add_child(dummy)
	dummy.name = str(id)

func start_game():
	#Small delay to make sure players are properly registered
	yield(get_tree().create_timer(0.1), "timeout")
	#Instance 3D level as child of $game
	var level_instance = romp_online.instance()
	game.add_child(level_instance)
	GameInfo.ingame = true
	#Create dummy characters
	for id in player_info.keys():
		create_dummy(id)
	game_running = true
	#Connect signals
	game.get_node("romp_online/player/Player/KinematicBody").connect("hit_ball", self, "_on_player_hit_ball")
	#Hide menu
	waiting.visible = false
	ip_adress.visible = false
	$username.visible = false
	$ButtonContainer.visible = false
	$MarginContainer.visible = false
	$ColorRect.visible = false
	GameInfo.switch_gamestate(1)
	yield(get_tree(), "idle_frame")
	#Set client location
	if mp_type == "client":
		GameInfo.p0_respawn_location = game.get_node("romp_online/SpawnLocations").p1_position

func _on_player_hit_ball(target_name, direction):
	rpc("apply_target_force", target_name, direction)

remote func apply_target_force(target_name, direction):
	for i in game.get_node("romp_online/Targets").get_children():
		if i.name == target_name:
			i.apply_impulse(Vector3.ZERO, direction)
			i.update_last_hit(1)
	if target_name == str(get_tree().get_network_unique_id()):
		var player = game.get_node("romp_online/player/Player/KinematicBody")
		player.impact_vec += direction * 1.5
		player.is_hitstunned = true
