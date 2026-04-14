extends AnimatedSprite2D # 또는 Node2D 등

func _ready():
	sprite_frames.set_animation_loop("default", false)
	animation_finished.connect(queue_free)
	play("default") # 애니메이션 재생 시작
