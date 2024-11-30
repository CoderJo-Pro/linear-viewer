extends Node2D

@export var size: Vector2
@export var draw_scale: float = 1
@export var gap: Vector2 = Vector2.ONE
@export var matrix: Transform2D
@export_range(0, 1) var weight: float

@export var vectors: PackedVector2Array
@export var colors: PackedColorArray
@export var antialiased: bool = false

var identity: Transform2D:
	get: return Transform2D.IDENTITY.scaled(Vector2(1, -1) * draw_scale)
var transformer: Transform2D:
	get: return Transform2D.IDENTITY.interpolate_with(matrix, weight).scaled(Vector2(1, -1) * draw_scale)

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	var tween := create_tween()
	tween.set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "weight", 1, 1).set_delay(1)
	tween.tween_property(self, "weight", 0, 1).set_delay(1)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var c := Color.WHEAT
	c.a = .1
	draw_grid(identity, c)
	draw_grid(transformer, Color.WHEAT)
	draw_vectors(transformer)

func draw_grid(tf: Transform2D, color: Color) -> void:
	var lx := fmod(size.x, gap.x) - size.x
	var ly := fmod(size.y, gap.y) - size.y
	
	while lx <= size.x:
		draw_line(tf * Vector2(lx, size.y), tf * Vector2(lx, -size.y), color, -1, antialiased)
		lx += gap.x
	while ly <= size.y:
		draw_line(tf * Vector2(size.x, ly), tf * Vector2(-size.x, ly), color, -1, antialiased)
		ly += gap.y

func draw_vectors(tf: Transform2D) -> void:
	for i in range(vectors.size()):
		var vector := vectors[i]
		var color := colors[i] if i < colors.size() else Color.CRIMSON
		draw_vector(tf * Vector2.ZERO, tf * vector, color)

func draw_vector(from: Vector2, to: Vector2, color: Color) -> void:
	var tri_height := minf(.3 * draw_scale, from.distance_to(to))
	var tri_half := 1 * sqrt(tri_height * tri_height / 3)
	
	var back_dir := to.direction_to(from)
	var perp := back_dir.rotated(PI / 2) * tri_half
	var to_cutter := back_dir * tri_height
	var tri_btm := to + to_cutter
	
	draw_line(from, to + to_cutter / 2, color, -1, antialiased)
	draw_colored_polygon([
		to,
		tri_btm + perp,
		tri_btm - perp
	], color)
