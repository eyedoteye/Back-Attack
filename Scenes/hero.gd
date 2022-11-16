extends KinematicBody2D
class_name Hero

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

onready var _sprite = $Sprite
onready var _animationTree = $AnimationTree
onready var _stateMachine = _animationTree["parameters/playback"]

onready var _itemSlash = $Slash

var velocity = Vector2()
var gravity = 200
var jumpStrength = 200
var moveSpeed = 90
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func useSlash() -> void:
	_itemSlash.visible = true
	$Slash/CollisionShape2D.disabled = false
	
func finishSlash() -> void:
	_itemSlash.visible = false
	$Slash/CollisionShape2D.disabled = true
	
func changeStateTo(state) -> void:
	_stateMachine.travel(state)

func processJumpInput() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_stateMachine.travel("Jump")
		velocity.y -= jumpStrength
		
func processUseInput() -> void:
	if Input.is_action_just_pressed("ui_focus_next"):
		velocity.x = 0
		_stateMachine.travel("Throw")

func processFalling() -> bool:
	if velocity.y != 0:
		_stateMachine.travel("Jump")
		return true
	return false

func applyMovement(delta) -> void:
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)

func processDirMovement(dir) -> void:
	if dir > 0:
		velocity.x = moveSpeed
	elif dir < 0:
		velocity.x = -moveSpeed
	else:
		velocity.x = 0

func processInAirDirMovement(dir) -> void:
	if _sprite.flip_h:
		if dir > 0:
			velocity.x = moveSpeed
		elif dir < 0:
			velocity.x = -moveSpeed / 2.2
	else:
		if dir > 0:
			velocity.x = moveSpeed / 2.2
		elif dir < 0:
			velocity.x = -moveSpeed

func flipSpriteToDir(dir) -> void:
	if dir == 1:
		_sprite.flip_h = true
	elif dir == -1:
		_sprite.flip_h = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity)
	
	var dir = 0
	if Input.is_action_pressed("ui_left"):
		dir -= 1
	if Input.is_action_pressed("ui_right"):
		dir += 1
	
	var currentState =  _stateMachine.get_current_node()
	match currentState:
		"Jump":
			processInAirDirMovement(dir)
			
			applyMovement(delta)
			if is_on_floor():
				if dir == 0:
					_stateMachine.travel("Idle")
				else:
					_stateMachine.travel("Run")
		"Idle":
			if not processFalling():
				processJumpInput()
				processDirMovement(dir)
				
				processUseInput()
				
				applyMovement(delta)
						
				flipSpriteToDir(dir)
				if dir != 0:
					_stateMachine.travel("Run")
		"Run":
			if not processFalling():
				processJumpInput()
				processDirMovement(dir)
				
				processUseInput()
				
				applyMovement(delta)
				
				flipSpriteToDir(dir)
				if dir == 0:
					_stateMachine.travel("Idle")



func _on_Slash_area_entered(area):
	if area.is_in_group("Enemy"):
		area.get_parent().hurt()
