extends KinematicBody2D
class_name Hero

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

onready var _sprite = $Sprite
onready var _animationTree = $AnimationTree
onready var _stateMachine = _animationTree["parameters/playback"]

onready var _skillSlash = $Slash

var dir: int = 0
var flipped: int = 1
var noGravity: bool = false

var velocity = Vector2()
var gravity = 200
var jumpStrength = 200
var moveSpeed = 90

onready var kunaiBase_position = $KunaiBase.position
var _scene_kunai = preload("res://Scenes/Kunai.tscn")
onready var superJumpBase_position = $SuperJumpBase.position
var superJumpBase_height = 18
var _scene_superJump = preload("res://Scenes/SuperJump.tscn")

class SkillQueue:
	var skills = ["","",""]
	var size = 0
	func fill(skill1, skill2, skill3):
		skills = [skill1, skill2, skill3]
		size = 3
	func pop() -> String:
		if size > 0:
			var s = skills[size - 1]
			size = size - 1
			return s
		return "Slash"
	func isEmpty() -> bool:
		return size == 0
var skillQueue = SkillQueue.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$KunaiBase.queue_free()
	pass # Replace with function body.	

func useSlash() -> void:
	velocity.x = 0
	_skillSlash.visible = true
	$Slash/CollisionShape2D.disabled = false
	
func finishSlash() -> void:
	_skillSlash.visible = false
	$Slash/CollisionShape2D.disabled = true

func useSuperJump_1() -> void:
	var newSuperJump = _scene_superJump.instance()
	newSuperJump.position = position + superJumpBase_position
	get_tree().get_root().add_child(newSuperJump)
	var offset = Vector2(0, -superJumpBase_height)
	move_and_slide(offset)
	velocity.y -= 800
	#noGravity = true

func useSuperJump_2() -> void:
	noGravity = true
	velocity.y = 0
	
func finishSuperJump() -> void:
	noGravity = false
	changeStateTo("Jump")

func useKunai() -> void:
	velocity.x = 0
	var newKunai = _scene_kunai.instance()
	newKunai.direction = -flipped
	if flipped == 1:
		newKunai.position = position + kunaiBase_position
	else:
		newKunai.rotation_degrees = 180
		newKunai.scale.y = -1
		newKunai.position = position
		newKunai.position.y += kunaiBase_position.y
		newKunai.position.x -= kunaiBase_position.x
	get_tree().get_root().add_child(newKunai)
	
func changeStateTo(state) -> void:
	_stateMachine.travel(state)

func processJumpInput() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_stateMachine.travel("Jump")
		velocity.y -= jumpStrength
		
func processUseInput() -> void:
	if Input.is_action_just_pressed("ui_focus_next"):
		if skillQueue.isEmpty():
			skillQueue.fill("Slash", "SuperJump", "Kunai")
		changeStateTo(skillQueue.pop())

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

func processFixedFaceMovement(mod) -> void:
	if flipped == -1:
		if dir > 0:
			velocity.x = moveSpeed
		elif dir < 0:
			velocity.x = -moveSpeed / mod
	else:
		if dir > 0:
			velocity.x = moveSpeed / mod
		elif dir < 0:
			velocity.x = -moveSpeed

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

func _process(delta: float) -> void:
	if not noGravity:
		velocity.y += gravity * delta
		
	velocity = move_and_slide(velocity)
	
	dir = 0
	if Input.is_action_pressed("ui_left"):
		dir -= 1
	if Input.is_action_pressed("ui_right"):
		dir += 1
	
	var currentState =  _stateMachine.get_current_node()
	match currentState:
		"SuperJump":
			processFixedFaceMovement(4.4)
		"Jump":
			processFixedFaceMovement(2.2)
			
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
