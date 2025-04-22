# video_manager.gd
extends Node

var video_player = null
var current_position = 0.0

func _ready():
	# Create a persistent VideoStreamPlayer
	video_player = VideoStreamPlayer.new()
	
	# Configure video player
	video_player.expand = true
	video_player.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Load video
	var video_stream = load("res://bg.ogv")
	video_player.stream = video_stream
	video_player.loop = true
	
	# Add to a new CanvasLayer with very low layer value
	var canvas = CanvasLayer.new()
	canvas.layer = -100  # Ensure it's behind everything
	canvas.add_child(video_player)
	
	# Add the CanvasLayer to the root
	get_tree().root.call_deferred("add_child", canvas)
	
	# Start playback
	call_deferred("start_video")

func start_video():
	video_player.play()

func _process(_delta):
	# Store current position regularly
	if video_player and video_player.is_playing():
		current_position = video_player.stream_position

func pause_video():
	if video_player:
		current_position = video_player.stream_position
		video_player.paused = true

func resume_video():
	if video_player:
		video_player.paused = false
		# If needed, you can seek to the stored position
		# video_player.seek(current_position)

func show_video():
	if video_player:
		video_player.visible = true

func hide_video():
	if video_player:
		video_player.visible = false
