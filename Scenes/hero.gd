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

func processDirMovement() -> void:
	if dir > 0:
		velocity.x = moveSpeed
	elif dir < 0:
		velocity.x = -moveSpeed
	else:
		velocity.x = 0

func processInAirDirMovement() -> void:
	if flipped == -1:
		if dir > 0:
			velocity.x = moveSpeed
		elif dir < 0:
			velocity.x = -moveSpeed / 2.2
	else:
		if dir > 0:
			velocity.x = moveSpeed / 2.2
		elif dir < 0:
			velocity.x = -moveSpeed

var flipped: int = 1
func _flip() -> void:
	scale.y = -1
	rotation_degrees = 180
	flipped = -1
func _unflip() -> void:
	scale.y = 1
	rotation_degrees = 0
	flipped = 1

func flipSpriteToDir() -> void:
	match dir:
		1:
			_flip()
		-1:
			_unflip()

var dir: int = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity)
	
	dir = 0
	if Input.is_action_pressed("ui_left"):
		dir -= 1
	if Input.is_action_pressed("ui_right"):
		dir += 1
	
	var currentState =  _stateMachine.get_current_node()
	match currentState:
		"Jump":
			processInAirDirMovement()
			
			applyMovement(delta)
			if is_on_floor():
				if dir == 0:
					_stateMachine.travel("Idle")
				else:
					_stateMachine.travel("Run")
		"Idle":
			if not processFalling():
				processJumpInput()
				processDirMovement()
				
				processUseInput()
				
				applyMovement(delta)
				
				flipSpriteToDir()
				if dir != 0:
					_stateMachine.travel("Run")
		"Run":
			if not processFalling():
				processJumpInput()
				processDirMovement()
				
				processUseInput()
				
				applyMovement(delta)
				
				flipSpriteToDir()
				if dir == 0:
					_stateMachine.travel("Idle")


func _on_Slash_area_entered(area):
	if area.is_in_group("Enemy"):
		area.get_parent().hurt()
