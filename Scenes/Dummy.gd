extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var _sprite = $Sprite

var nextHitFrames = [1, 2]
var lastHitFrame = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	pass

func hurt() -> void:
	var r = randi() % 2
	_sprite.frame = nextHitFrames[r]
	nextHitFrames[r] = lastHitFrame
	lastHitFrame = _sprite.frame
	print("hit")
