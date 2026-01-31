extends Control

const MAX_TIME = 30

signal timeout


func _ready() -> void:
	visibility_changed.connect(func(): if not visible: $Timer.stop())
	$Timer.timeout.connect(func():
		$Label.text = "0"
		timeout.emit()
	)
	$Timer.one_shot = true


func _draw():
	var arc = TAU - (TAU * ($Timer.time_left / MAX_TIME))
	var color = Color.YELLOW_GREEN
	
	match $Timer.time_left:
		var t when t > 15: color = Color.YELLOW_GREEN
		var t when t > 5: color = Color.YELLOW
		_: color = Color.RED
	
	draw_arc(size / 2, min(size.x, size.y) / 2, TAU, arc, 100, color, 6.0, true)


func _process(_delta: float) -> void:
	if not $Timer.is_stopped():
		$Label.text = str(ceili($Timer.time_left))
		queue_redraw()


func start():
	$Timer.start(MAX_TIME)
