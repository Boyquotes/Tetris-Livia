extends Node2D


signal update_score
signal update_next_block
signal gameover

var velocity_endoidou
enum States { STOP, PLAY, PAUSE }

const FAST_DOWN_SPEED = 20
const FAST_DOWN_POINT = 5

var block_list = [
	preload("res://blocks/S.tscn"),
	preload("res://blocks/L.tscn"),
	preload("res://blocks/J.tscn"),
	preload("res://blocks/T.tscn"),
	preload("res://blocks/Z.tscn"),
	preload("res://blocks/O.tscn"),
	preload("res://blocks/I.tscn"),
]
var position_cursor = {}

const START_POSITION = StoreSettings.TILE_SIZE / 2
const FINAL_POSITION = START_POSITION + StoreSettings.TILE_SIZE * 20

var tile_scene = preload("res://blocks/Tile.tscn")
var _state = States.STOP
var _fast_down = false
var player_block
var next_block
var velocity_down
var _score = 0
var _completed_lines = 0
var velocity=0
var flag_esq = false
var flag_dir = false
var flag_bax = false
var flag_giro = false
var flag_normal = false
var flag_endoidou = false
var flag_soltei = false

func _ready():

	randomize()
	_game_start()
	Serial.connect("sinal_EsquerdaGo",self,"esquerda")
	Serial.connect("sinal_DireitaGo",self,"direita")
	Serial.connect("sinal_BaixoGo",self,"baixo")
	Serial.connect("sinal_GiroGo",self,"giro")
	Serial.connect("soltei",self,"_soltei")
	Serial.connect("sinal_Normal",self,"normal")
	Serial.connect("sinal_Endoidou",self,"endoidou")
	
func _soltei():
	
	flag_soltei = true
	
func esquerda():
	flag_esq = true
	
func direita():
	flag_dir = true
	
func baixo():
	flag_bax = true
	
func giro():
	flag_giro = true
	
func normal():
	flag_normal = true
	
func endoidou():
	
	flag_endoidou = true

func _game_start():

	position_cursor = {}

	for i in range(START_POSITION, FINAL_POSITION, StoreSettings.TILE_SIZE):
		position_cursor[i] = []


	_update_score(0, 0)
	_fast_down = false
	print(StoreSettings.TILE_SIZE)
	velocity_down = Vector2(0, 1).normalized() * StoreSettings.TILE_SIZE
	velocity_endoidou = Vector2(0, 500).normalized() * StoreSettings.TILE_SIZE

	$FallingTimer.start()

	_get_player_block()

	_state = States.PLAY
	

func _process(delta):

	if _state != States.PLAY:
		return

	var velocity = Vector2()

	if Input.is_action_just_pressed("ui_left") or flag_esq:
		velocity.x -= 32
		flag_esq=false
		

	elif Input.is_action_just_pressed("ui_right") or flag_dir:
		velocity.x += 32
		flag_dir = false

	if Input.is_action_pressed("ui_down") or flag_bax:
		velocity.y = 16
	
		#_fast_down = true

	if Input.is_action_just_released("ui_down") or flag_soltei:
		#print("aaaaaaaaaaaaa")
		flag_soltei = false
		_fast_down = false
		flag_bax = false
		
	
	if flag_endoidou:
		
		velocity.y = 4
		flag_endoidou=false
		#flag_normal = false


	if _fast_down and velocity.y > 0:
	
		player_block.move_and_collide(velocity_down)

	if velocity.length() > 0:
		
		#velocity = velocity.normalized() * StoreSettings.TILE_SIZE
		print(velocity)
		#print("asjkhdkjashdkjah")
		player_block.move_and_collide(velocity)

	if Input.is_action_just_pressed("ui_up") or flag_giro:
		player_block.rotate_block() 
		flag_giro=false

func _get_player_block():

	if player_block:
		remove_child(player_block)
		player_block.add_to_group('Junk')


	if next_block:
		player_block = next_block
	else:
		player_block = get_next_block()


	next_block = get_next_block()
	emit_signal("update_next_block", next_block)


	add_child(player_block)
	player_block.position = $StartPosition.position

	if player_block.get_name() == 'I' or player_block.get_name() == 'O':
		player_block.adjust_position()

func get_next_block():
	return block_list[randi() % block_list.size()].instance()

func _clear_line():

	var completed_line_index_list = []

	for i in position_cursor:


		if position_cursor[i].size() == 10:

	
			for tile in position_cursor[i]:
				remove_child(tile)
				tile.remove_from_group("StuckBlocks")
				tile.add_to_group("Junk")


			position_cursor[i].clear()


			completed_line_index_list.append(i)


	for idx in completed_line_index_list:

		for pos in range(idx, START_POSITION, -StoreSettings.TILE_SIZE):

			for tile in position_cursor[pos]:
				tile.position += velocity_down

		
				position_cursor[int(tile.position.y)].append(tile)

	
			position_cursor[pos].clear()

	if completed_line_index_list.size():
		var score_value = _score + 100 * pow(2, completed_line_index_list.size() - 1)
		var line_count = _completed_lines + completed_line_index_list.size()
		_update_score(score_value, line_count)

		if StoreSettings.audio_sfx:
			$CleanLineSFX.play()

func _update_score(score_value, lines_count):
	
	_score = score_value
	_completed_lines = lines_count
	emit_signal("update_score", _score, _completed_lines)

func _on_FallingTimer_timeout():

	if _state != States.PLAY:
		return

	var collision_info

	if not _fast_down:
		#print(velocity_down)
		collision_info = player_block.move_and_collide(velocity_down)
	else:
		collision_info = false

	if collision_info:

		if _fast_down:
			_fast_down = false
			_update_score(_score + FAST_DOWN_POINT, _completed_lines)

	
		for tile in player_block.get_children():


			var tile_body = tile_scene.instance()

			tile_body.get_node("Sprite").modulate = tile.get_node("Sprite").modulate
			tile_body.position = tile.position + player_block.position
			add_child(tile_body)

			if position_cursor.has(int(tile_body.position.y)):
				position_cursor[int(tile_body.position.y)].append(tile_body)
				
		_get_player_block()

	
		_clear_line()

func _on_Roof_body_entered(body):
	_state = States.STOP
	emit_signal("gameover")

	if StoreSettings.audio_music:
		pass
	#	$BackgroundMusic.stop()

	if StoreSettings.audio_sfx:
		pass
	#	$GameOverSFX.play()


func _on_GUI_change_game_state():

	if _state == States.PLAY:
		_state = States.PAUSE
		$FallingTimer.stop()

	elif _state == States.PAUSE:
		_state = States.PLAY
		$FallingTimer.start()


func _on_GUI_restart_game():

	for pos in $PositionCursor.get_children():
		pos.clear_tile_list()

	get_tree().call_group("StuckBlocks", "queue_free")
	get_tree().call_group("Junk", "queue_free")

	if player_block:
		remove_child(player_block)
		player_block.queue_free()

	_game_start()

