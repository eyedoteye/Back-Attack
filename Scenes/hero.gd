extends KinematicBody2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

onready var state_idle = $StateMachine/Idle
onready var state_run = $StateMachine/Run

onready var animationTree = $AnimationTree
onready var state_machine = animationTree["parameters/playback"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
#	state_idle.visible = false
#	state_run.visible = true
	
	if Input.is_action_pressed("ui_left"):
		state_idle.visible = false
		state_run.visible = true
		
		state_idle.flip_h = true
		state_run.flip_h = true
		
		state_machine.travel("Run")
	elif Input.is_action_pressed("ui_right"):
		state_idle.visible = false
		state_run.visible = true
		
		state_idle.flip_h = false
		state_run.flip_h = false
		
		state_machine.travel("Run")
	else:
		state_idle.visible = true
		state_run.visible = false
		state_machine.travel("Idle")
