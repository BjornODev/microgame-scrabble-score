extends Label

var text_snipbits : Array[String] = []

func add_text(new_text : String) -> void:
	text_snipbits.append(new_text)
	var old_text : String = ""
	for i in text_snipbits:
		old_text += i
	text = old_text

func _on_lose_timer_timeout() -> void:
	if len(text_snipbits) != 0:
		var old_text : String = ""
		text_snipbits.remove_at(0)
		for i in text_snipbits:
			old_text += i
		text = old_text
	else:
		text = ""
