extends Control

@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var desc_label: Label = $PanelContainer/VBoxContainer/DescLabel

func ShowPopup(slot: Rect2, level: int, title_key: String, desc_key: String, desc_param: Array):
	# 항상 위에 렌더링
	%PanelContainer.z_index = 999
	
	var mouse_pos = get_viewport().get_mouse_position()
	var correction
	var padding = 4
	
	if mouse_pos.x <= get_viewport_rect().size.x/2:
		correction = Vector2(slot.size.x + padding, 0)
	else:
		correction = -Vector2(%PanelContainer.size.x + padding, 0)
	
	change_level(level, title_key, desc_key, desc_param)
	
	update_text(level, title_key, desc_key, desc_param)
	
	%PanelContainer.position = Vector2(slot.position + correction)
	%PanelContainer.show()
	
func HidePopup():
	%PanelContainer.hide()

func change_level(level: int, title_key: String, desc_key: String, desc_param: Array):
	if level == 0:
		title_label.add_theme_color_override("font_color", Color("#333333"))
		desc_label.add_theme_color_override("font_color", Color("#333333"))
	else:
		title_label.add_theme_color_override("font_color", Color("#ffffff"))
		desc_label.add_theme_color_override("font_color", Color("#ffffff"))
		
	update_text(level, title_key, desc_key, desc_param)

func update_text(level: int, title_key: String, desc_key: String, desc_param: Array):
	title_label.text = tr(title_key)

	if desc_param.size() > 0:
		if level == 0:
			desc_label.text = tr(desc_key).format([desc_param[0]])
		else:
			desc_label.text = tr(desc_key).format([desc_param[level-1]])
	else:
		desc_label.text = tr(desc_key)
