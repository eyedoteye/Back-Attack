extends KinematicBody2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

onready var _sprite = $Sprite
onready var _animationTree = $AnimationTree
onready var state_machine = _animationTree["parameters/playback"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
#	state_idle.visible = false
#	state_run.visible = true
	
	if Input.is_action_pressed("ui_left"):		
		_sprite.flip_h = false
		state_machine.travel("Run")
	elif Input.is_action_pressed("ui_right"):
		_sprite.flip_h = true
		state_machine.travel("Run")
	elif Input.is_action_pressed("ui_accept"):
		state_machine.travel("Jump")
	else:
		state_machine.travel("Idle")
