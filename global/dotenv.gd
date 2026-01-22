extends Node

static var pattern = RegEx.new()

func _ready() -> void:
	pattern.compile(r"(?<name>\S+) *= *(?<value>\S+)")

func load_env(path: String):
	print('loading data from ', path)
	var data = FileAccess.open(path, FileAccess.READ).get_as_text(true)
	print('reading ', data)
	for line in data.split("\n", false):
		print('line ', line)
		var env = pattern.search(line)
		OS.set_environment(env.get_string("name"), env.get_string("value"))
