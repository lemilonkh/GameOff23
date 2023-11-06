extends Node

const TARGET_RESONANCE = 0.33

func animate_filter(bus_name: StringName, duration: float = 1.0) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_QUAD)
	var bus_id := AudioServer.get_bus_index(bus_name)
	var effect: AudioEffectBandPassFilter = AudioServer.get_bus_effect(bus_id, 0)
	effect.resonance = 0
	tween.tween_property(effect, "resonance", TARGET_RESONANCE, duration / 2)
	tween.tween_property(effect, "resonance", 0, duration / 2)
