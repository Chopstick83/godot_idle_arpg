extends Control

@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var info_label: Label = $PanelContainer/VBoxContainer/InfoLabel

func ShowPopup(slot: Rect2, level: int):
	# 항상 위에 렌더링
	%PanelContainer.z_index = 999
	
	var mouse_pos = get_viewport().get_mouse_position()
	var correction
	var padding = 4
	
	if mouse_pos.x <= get_viewport_rect().size.x/2:
		correction = Vector2(slot.size.x + padding, 0)
	else:
		correction = -Vector2(%PanelContainer.size.x + padding, 0)
	
	ChangeLevel(level)
	
	%PanelContainer.position = Vector2(slot.position + correction)
	%PanelContainer.show()
	
func HidePopup():
	%PanelContainer.hide()

func ChangeLevel(level: int):
	if level == 0:
		title_label.add_theme_color_override("font_color", Color("#333333"))
		info_label.add_theme_color_override("font_color", Color("#333333"))
	else:
		title_label.add_theme_color_override("font_color", Color("#ffffff"))
		info_label.add_theme_color_override("font_color", Color("#ffffff"))
