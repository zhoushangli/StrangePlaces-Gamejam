extends Node
class_name AudioService

@export var _bgmPlayer: AudioStreamPlayer
@export var _sfxPoolSize: int = 5
@export var _sfxContainer: Node

var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_last_play_time: Dictionary = {}

const same_sfx_min_interval_msec: int = 100

func init_service() -> void:
	name = "AudioService"
	if _sfxContainer == null:
		_sfxContainer = self
	for i in range(_sfxPoolSize):
		var player := AudioStreamPlayer.new()
		player.name = "SFXPlayer_%d" % i
		player.bus = "SFX"
		_sfxContainer.add_child(player)
		_sfx_players.append(player)

func shutdown_service() -> void:
	if _bgmPlayer != null:
		_bgmPlayer.stop()
	for player in _sfx_players:
		if is_instance_valid(player):
			player.stop()

func play_bgm(source: Variant, loop: bool = true) -> void:
	if _bgmPlayer == null:
		push_warning("[AudioService] BGM player is not assigned.")
		return
	var stream: AudioStream = null
	if source is String:
		stream = load(source) as AudioStream
	elif source is AudioStream:
		stream = source
	if stream == null:
		push_warning("[AudioService] Failed to load BGM: %s" % str(source))
		return
	if _bgmPlayer.stream == stream:
		return
	_bgmPlayer.stop()

	if stream is AudioStreamWAV:
		var inst := (stream as AudioStreamWAV).duplicate(true) as AudioStreamWAV
		_bgmPlayer.stream = inst
		if loop:
			inst.loop_begin = 0
			inst.loop_end = maxi(1, int(round(inst.get_length() * inst.mix_rate)))
			inst.loop_mode = AudioStreamWAV.LOOP_FORWARD
		else:
			inst.loop_mode = AudioStreamWAV.LOOP_DISABLED

	elif stream is AudioStreamMP3:
		var inst := (stream as AudioStreamMP3).duplicate(true) as AudioStreamMP3
		_bgmPlayer.stream = inst
		inst.loop = loop
		# MP3 只有 loop_offset（秒），没有 loop_end
		inst.loop_offset = 0.0

	else:
		_bgmPlayer.stream = stream

	_bgmPlayer.play()

func stop_bgm() -> void:
	if _bgmPlayer != null:
		_bgmPlayer.stop()

func play_sfx(source: Variant) -> void:
	var stream: AudioStream = null
	if source is String:
		stream = load(source) as AudioStream
	elif source is AudioStream:
		stream = source
	if stream == null:
		push_warning("[AudioService] Failed to load SFX: %s" % str(source))
		return

	var key : Variant = source if source is String else stream.resource_path
	if key == null or str(key).is_empty():
		key = stream
	var now := Time.get_ticks_msec()
	var last := int(_sfx_last_play_time.get(key, -1000000))
	if now - last < same_sfx_min_interval_msec:
		return

	_sfx_last_play_time[key] = now
	for player in _sfx_players:
		if not player.playing:
			player.stream = stream
			player.play()
			return
			
	print("No free SFX player!")
