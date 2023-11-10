extends BaseDialogueTestScene

@onready var balloon: CanvasLayer = $ExampleBalloon

func _ready() -> void:
	balloon.start(resource, title)
