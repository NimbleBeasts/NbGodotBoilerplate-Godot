extends Node

export(Array, String) var connects

func _ready():
	for c in connects:
		var parts = c.split(";")
		if parts.size() == 3:
			var node = get_node(parts[1])
			connect(parts[0], node, parts[2])
