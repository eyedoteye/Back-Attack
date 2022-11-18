extends Area2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
var direction = -1
var speed = 800

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.connect("timeout", self, "_on_Timer_timeout")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += direction * speed * delta

func _on_Node2D_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		area.get_parent().hurt()
		queue_free()

func _on_Timer_timeout() -> void:
	queue_free()
