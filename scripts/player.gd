extends RigidBody3D



@onready var crash_timer: Timer = $timers / crash_timer
@onready var land_timer: Timer = $timers / land_timer
@onready var death_sound: AudioStreamPlayer = $sounds / death_sound
@onready var sucess: AudioStreamPlayer = $sounds / sucess
@onready var rocket_sound: AudioStreamPlayer3D = $sounds / rocket_sound
@onready var main_particles: GPUParticles3D = $main_Particles
@onready var right_particles: GPUParticles3D = $right_Particles
@onready var left_particles: GPUParticles3D = $left_Particles
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles








@export_range(750, 2500) var thrust: float = 1000.0


@export_range(75, 250) var torque: float = 100.0

var is_transitioning: bool = false
var next_level: String
var is_dead: bool = false
var is_level_completed: bool = false

func _process(delta: float) -> void :
	if is_transitioning == false:
		if Input.is_action_pressed("boost"):

			apply_central_force(basis.y * delta * thrust)
			if rocket_sound.playing == false:
				rocket_sound.play()

			main_particles.emitting = true
		else:
			rocket_sound.playing = false
			main_particles.emitting = false
		if Input.is_action_pressed("right"):
			apply_torque(Vector3(0.0, 0.0, - torque * delta))
			right_particles.emitting = true
		else:
			right_particles.emitting = false
		if Input.is_action_pressed("left"):
			apply_torque(Vector3(0.0, 0.0, torque * delta))
			left_particles.emitting = true
		else:
			left_particles.emitting = false

	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
func _on_body_entered(body: Node) -> void :
	if "goal" in body.get_groups() and is_level_completed == false:
		level_complete()
		next_level = body.file_path
	if "death_area" in body.get_groups() and is_dead == false:
		print(body)
		on_crash()

func on_crash() -> void :
	explosion_particles.emitting = true
	set_process(false)
	death_sound.play()
	is_dead = true
	is_transitioning = true
	print("you died lol")
	crash_timer.start()




func level_complete() -> void :
	success_particles.emitting = true
	sucess.play()
	is_level_completed = true
	set_process(false)
	is_transitioning = true
	land_timer.start()






func _on_crash_timer_timeout() -> void :
	get_tree().reload_current_scene()


func _on_land_timer_timeout() -> void :
	get_tree().change_scene_to_file(next_level)
