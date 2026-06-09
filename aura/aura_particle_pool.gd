class_name AuraParticlePool
extends Node

const POOL_SIZE := 60
const PARTICLE_SCENE := preload("res://aura/aura_particle.tscn")

var _pool: Array[AuraParticle] = []

func _ready() -> void:
	for i in POOL_SIZE:
		var p := PARTICLE_SCENE.instantiate() as AuraParticle
		p.visible = false
		add_child(p)
		_pool.append(p)

func get_particle() -> AuraParticle:
	for p in _pool:
		if not p._active:
			return p
	# pool exhausted — return null, caller skips gracefully
	return null
