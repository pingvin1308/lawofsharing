extends Label

func _make_custom_tooltip(for_text: String) -> Tooltip:
	var tooltip := preload("res://scenes/ui/tooltip/tooltip.tscn").instantiate() as Tooltip
	tooltip.text = for_text
	return tooltip
