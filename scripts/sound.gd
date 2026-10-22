extends Node
var music: AudioStreamPlayer
var ambience: AudioStreamPlayer
var effects: Array[AudioStreamPlayer] = []
var cursor = 0

func _ready() -> void:
	music = AudioStreamPlayer.new()
	music.stream = preload("res://assets/audio/meadow.wav")
	add_child(music)
	if music.stream is AudioStreamWAV:
		music.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		music.stream.loop_end = music.stream.get_length()*music.stream.mix_rate
	if DisplayServer.get_name() != "headless": music.play()
	ambience = AudioStreamPlayer.new()
	ambience.stream = preload("res://assets/audio/breeze.wav")
	add_child(ambience)
	if ambience.stream is AudioStreamWAV:
		ambience.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		ambience.stream.loop_end = ambience.stream.get_length()*ambience.stream.mix_rate
	if DisplayServer.get_name() != "headless": ambience.play()
	for i in range(4):
		var p = AudioStreamPlayer.new()
		add_child(p)
		effects.append(p)

func _process(_delta: float) -> void:
	music.volume_db = linear_to_db(maxf(0.0001,State.settings.music*0.65))
	ambience.volume_db = linear_to_db(maxf(0.0001,State.settings.ambience*0.6))

func play(cue: String = "pick") -> void:
	if DisplayServer.get_name() == "headless": return
	var p: AudioStreamPlayer = effects[cursor%effects.size()]
	cursor += 1
	p.stream = load("res://assets/audio/"+cue+".wav")
	p.volume_db = linear_to_db(maxf(0.0001,State.settings.effects*0.7))
	p.play()

func shutdown() -> void:
	for p in [music,ambience]+effects:
		if is_instance_valid(p):
			p.stop()
			p.stream = null

func _exit_tree() -> void:
	shutdown()
