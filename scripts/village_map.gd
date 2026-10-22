class_name VillageMap
extends Control
const D = preload("res://scripts/game_data.gd")
var game: Node
var font = preload("res://assets/fonts/OpenSans-Regular.ttf")

func point(p: Vector2) -> Vector2:
	return Vector2(105+(p.x+40)*7.2,55+(p.y+35)*4.5)

func _ready() -> void:
	custom_minimum_size = Vector2(800,480)
	for r in D.REGIONS:
		var button = Button.new()
		button.text = r.name
		button.position = point(r.p)-Vector2(65,16)
		button.size = Vector2(130,34)
		button.add_theme_font_size_override("font_size",12)
		button.tooltip_text = r.subtitle+" · click to pin on your compass"
		button.pressed.connect(func():
			game.waypoint = r.id
			game.ui.toast("Pinned · "+r.name)
			game.ui.close_modal())
		add_child(button)

func _draw() -> void:
	draw_rect(Rect2(Vector2(15,10),Vector2(785,460)),Color("e7e8d4"),true)
	var edges = [[0,1],[1,2],[0,7],[7,8],[8,3],[3,2],[8,9],[9,12],[12,3],[12,4],[4,5],[5,6],[6,11],[11,10],[10,9],[10,7],[6,9]]
	for edge in edges: draw_line(point(D.REGIONS[edge[0]].p),point(D.REGIONS[edge[1]].p),Color("c3b99a"),4,true)
	for r in D.REGIONS:
		draw_circle(point(r.p),23,Color(r.color))
		if r.id in State.data.visited: draw_arc(point(r.p),26,0,TAU,32,Color("7c8d6b"),2,true)
	var p = Vector2(game.player.position.x,game.player.position.z)
	if State.data.interior: p=D.REGIONS[9].p
	draw_circle(point(p)+Vector2(0,24),6,Color("c4624b"))
	draw_circle(point(p)+Vector2(0,24),8,Color("fff8e8"),false,2)
	draw_string(font,Vector2(31,38),"N ↑   TREE VILLAGE",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("586a52"))
	draw_string(font,Vector2(31,452),"● You     ·     Click a place to pin your compass. No fast travel; enjoy the little paths.",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("586a52"))
