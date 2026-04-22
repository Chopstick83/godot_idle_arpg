extends TextureButton
class_name SkillNode

@onready var panel: Panel = $Panel
@onready var label: Label = $MarginContainer/Label
@onready var line_2d: Line2D = $Line2D

@export var max_level: int = 4
#@export var title_key: String 다국어?

const default_color = Color("#383838")
const lined_color = Color("ffff3f")

var level: int = 0:
	set(value):
		level = value
		label.text = str(level) + "/" + str(max_level)
		SkillButtonTooltip.ChangeLevel(level)

func _ready() -> void:
	if get_parent() is SkillNode:
		line_2d.add_point(global_position + size/2)
		line_2d.add_point(get_parent().global_position + size/2)

	# 기본 값 인스펙터와 다르게 초기화
	level = 0

func _on_pressed() -> void:
	level = min(level+1, max_level)
	panel.show_behind_parent = true
	
	# 하위 찍었을 때 연결 선 색상 변경
	line_2d.default_color = lined_color
	
	# Child SkillButton은 인스펙터에서 Disabled를 먼저 체크해야 함
	var child_skills = get_children()
	for skill in child_skills:
		# 현재는 부모 레벨 1만 찍혀도 하위 찍기 가능
		if skill is SkillNode and level == 1:
			skill.disabled = false

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# 스킬 할당 취소
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if level > 1:
				level -= 1
			else:
				var all_child_empty = false
				var child_skills = get_children()
				for skill in child_skills:
					if skill is SkillNode:
						if skill.level > 0:
							all_child_empty = true
							break
				if all_child_empty:
					return
					
				level = max(level-1, 0)
				if level == 0:
					panel.show_behind_parent = false
					for skill in child_skills:
						if skill is SkillNode:
							skill.disabled = true
					line_2d.default_color = default_color

func _on_mouse_entered() -> void:
	SkillButtonTooltip.ShowPopup(Rect2(Vector2(global_position), Vector2(size)), level)

func _on_mouse_exited() -> void:
	SkillButtonTooltip.HidePopup()
