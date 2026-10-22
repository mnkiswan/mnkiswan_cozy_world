extends CanvasLayer
const D = preload("res://scripts/game_data.gd")
const MAP = preload("res://scripts/village_map.gd")
const FONT = preload("res://assets/fonts/OpenSans-Regular.ttf")
const SERIF = preload("res://assets/fonts/DejaVuSerif.ttf")
const INK = Color("3e503f")
const MUTED = Color("7c826c")
const CREAM = Color("f7f0de")
const SAGE = Color("728868")
var game: Node
var root: Control
var title_screen: Control
var hud: Control
var modal: Control
var modal_body: VBoxContainer
var current_page = ""
var shop_tab = "sell"
var home_tab = "rest"
var region_label: Label
var region_sub: Label
var stats_label: Label
var objective_label: Label
var objective_detail: Label
var compass_label: Label
var prompt_panel: PanelContainer
var prompt_label: Label
var toast_label: Label
var toast_panel: PanelContainer
var toast_time = 0.0
var banner: VBoxContainer
var banner_time = 0.0
var tracked = "welcome"
var animal_id = ""
var pending_binding = ""
var hud_refresh = 0.0
var scroll_y = 0

func _ready() -> void:
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = make_theme()
	add_child(root)
	build_title()
	build_hud()
	build_toast()

func style(bg: Color, radius: int = 14, border: Color = Color.TRANSPARENT, padding: int = 16) -> StyleBoxFlat:
	var s=StyleBoxFlat.new()
	s.bg_color=bg
	s.set_corner_radius_all(radius)
	s.border_color=border
	s.set_border_width_all(1 if border.a>0 else 0)
	s.content_margin_left=padding
	s.content_margin_right=padding
	s.content_margin_top=padding
	s.content_margin_bottom=padding
	return s

func make_theme() -> Theme:
	var theme=Theme.new()
	theme.default_font=FONT
	theme.default_font_size=16
	theme.set_color("font_color","Label",INK)
	theme.set_color("font_color","Button",INK)
	theme.set_color("font_hover_color","Button",INK)
	theme.set_color("font_pressed_color","Button",INK)
	theme.set_stylebox("normal","Button",style(Color("e9e4cf"),9,Color("d4d6be"),12))
	theme.set_stylebox("hover","Button",style(Color("dce3c9"),9,SAGE,12))
	theme.set_stylebox("pressed","Button",style(Color("cbd7b8"),9,SAGE,12))
	theme.set_stylebox("focus","Button",style(Color(0,0,0,0),9,Color("cf9871"),12))
	theme.set_stylebox("disabled","Button",style(Color("e8e5d8"),9,Color.TRANSPARENT,12))
	theme.set_color("font_disabled_color","Button",Color("a2a28f"))
	theme.set_stylebox("panel","PanelContainer",style(CREAM,18,Color("d7d9c1"),24))
	theme.set_color("font_color","CheckButton",INK)
	theme.set_stylebox("normal","LineEdit",style(Color("fff9ea"),8,Color("c6cbb3"),12))
	theme.set_color("font_color","LineEdit",INK)
	return theme

func text(parent: Node, value: String, size: int = 16, color: Color = INK, serif: bool = false) -> Label:
	var l=Label.new()
	l.text=value
	l.set_meta("base_size",size)
	l.add_theme_font_size_override("font_size",int(size*State.settings.text_size))
	l.add_theme_color_override("font_color",color)
	if serif: l.add_theme_font_override("font",SERIF)
	parent.add_child(l)
	return l

func paragraph(parent: Node, value: String, size: int = 16, color: Color = MUTED) -> Label:
	var l=text(parent,value,size,color)
	l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	return l

func button(parent: Node, value: String, action: Callable, primary: bool = false) -> Button:
	var b=Button.new()
	b.text=value
	b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	b.pressed.connect(action)
	if primary:
		b.add_theme_stylebox_override("normal",style(SAGE,10,Color.TRANSPARENT,14))
		b.add_theme_stylebox_override("hover",style(Color("859875"),10,Color.TRANSPARENT,14))
		b.add_theme_color_override("font_color",CREAM)
		b.add_theme_color_override("font_hover_color",CREAM)
	parent.add_child(b)
	return b

func portrait(parent: Node, id: String, size: Vector2) -> TextureRect:
	var p=TextureRect.new()
	p.texture=load("res://assets/portraits/"+id+".webp")
	p.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	p.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	p.custom_minimum_size=size
	parent.add_child(p)
	return p

func spacer(parent: Node, height: float = 12) -> void:
	var c=Control.new()
	c.custom_minimum_size.y=height
	parent.add_child(c)

func vbox(parent: Node, separation: int = 10) -> VBoxContainer:
	var v=VBoxContainer.new()
	v.add_theme_constant_override("separation",separation)
	parent.add_child(v)
	return v

func hbox(parent: Node, separation: int = 12) -> HBoxContainer:
	var h=HBoxContainer.new()
	h.add_theme_constant_override("separation",separation)
	parent.add_child(h)
	return h

func fill(parent: Node) -> void:
	var c=Control.new()
	c.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	parent.add_child(c)

func card(parent: Node, bg: Color = Color("eee9d7")) -> PanelContainer:
	var p=PanelContainer.new()
	p.add_theme_stylebox_override("panel",style(bg,12,Color("dedfca"),16))
	parent.add_child(p)
	return p

func build_title() -> void:
	if is_instance_valid(title_screen): title_screen.queue_free()
	title_screen=Control.new()
	title_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(title_screen)
	var wash=ColorRect.new()
	wash.color=Color(0.95,0.92,0.82,0.86)
	wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wash.mouse_filter=Control.MOUSE_FILTER_IGNORE
	title_screen.add_child(wash)
	var band=ColorRect.new()
	band.color=Color("7e9272")
	band.position=Vector2(0,0)
	band.size=Vector2(1440,8)
	title_screen.add_child(band)
	var left=vbox(title_screen,12)
	left.position=Vector2(88,78)
	left.size=Vector2(610,710)
	text(left,"M N K I S W A N",22,SAGE)
	spacer(left,48)
	text(left,"Cozy World",70,INK,true)
	text(left,"A little world worth\nreturning to — together.",29,Color("68795d"),true)
	spacer(left,15)
	paragraph(left,"Wander the woodland paths with Mnki and Swan.\nGrow a garden, share a harvest, and turn a tiny\nvillage into a place that feels like home.",18,Color("70755f"))
	spacer(left,30)
	var actions=vbox(left,10)
	actions.custom_minimum_size.x=310
	var start=button(actions,"Begin our story   →",func():
		if FileAccess.file_exists(State.save_path) or FileAccess.file_exists(State.save_path+".bak"): confirm_new()
		else: game.begin(false),true)
	start.custom_minimum_size=Vector2(310,54)
	if FileAccess.file_exists(State.save_path) or FileAccess.file_exists(State.save_path+".bak"):
		button(actions,"Continue our world",func(): game.begin(true))
	button(actions,"Settings & controls",func(): open_menu("settings"))
	spacer(left,20)
	text(left,"NO RUSH. NO WRONG TURNS. JUST US.",12,MUTED)
	var art=portrait(title_screen,"couple",Vector2(615,690))
	art.position=Vector2(760,88)
	art.size=Vector2(615,690)
	var foot=text(title_screen,"A WOODLAND LIFE SIMULATION                         ORIGINAL CHARACTER REFERENCES · MNKISWAN",12,Color("727e64"))
	foot.position=Vector2(88,848)
	var version=text(title_screen,"GODOT 4.7.2  /  PLAYABLE FOUNDATION",11,MUTED)
	version.position=Vector2(1015,848)
	start.grab_focus()

func confirm_new() -> void:
	modal_shell("A fresh beginning", "Your existing world stays safe until you save the new one.")
	paragraph(modal_body,"Starting again replaces your active world when you next save. You can continue your current world instead.",18)
	button(modal_body,"Start a new world",func():
		close_modal()
		game.begin(false),true)
	button(modal_body,"Keep our current world",func(): close_modal())

func build_hud() -> void:
	hud=Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter=Control.MOUSE_FILTER_IGNORE
	hud.visible=false
	root.add_child(hud)
	var loc=PanelContainer.new()
	loc.position=Vector2(28,26)
	loc.size=Vector2(340,98)
	loc.add_theme_stylebox_override("panel",style(Color(0.96,0.94,0.85,0.94),14,Color("d7d9c1"),18))
	loc.mouse_filter=Control.MOUSE_FILTER_IGNORE
	hud.add_child(loc)
	var lv=vbox(loc,3)
	region_sub=text(lv,"TREE VILLAGE · 01 / 13",11,MUTED)
	region_label=text(lv,"Sunshine Forest",22,INK,true)
	compass_label=text(lv,"A little light, a fresh beginning",12,MUTED)
	var stat=PanelContainer.new()
	stat.position=Vector2(1112,26)
	stat.size=Vector2(300,62)
	stat.add_theme_stylebox_override("panel",style(Color(0.96,0.94,0.85,0.94),14,Color("d7d9c1"),16))
	hud.add_child(stat)
	stats_label=text(stat,"DAY 1    08:00     ◉ 18",17,INK)
	var quest=PanelContainer.new()
	quest.position=Vector2(1092,105)
	quest.size=Vector2(320,145)
	quest.add_theme_stylebox_override("panel",style(Color(0.96,0.94,0.85,0.91),14,Color("d7d9c1"),18))
	hud.add_child(quest)
	var qv=vbox(quest,7)
	text(qv,"A LITTLE SOMETHING TO DO",10,MUTED)
	objective_label=text(qv,"A welcome basket",18,INK,true)
	objective_detail=paragraph(qv,"Gather 3 cherry berries\nVillage board · J for requests",13,MUTED)
	var bottom=PanelContainer.new()
	bottom.position=Vector2(28,770)
	bottom.size=Vector2(398,100)
	bottom.add_theme_stylebox_override("panel",style(Color(0.96,0.94,0.85,0.93),14,Color("d7d9c1"),10))
	hud.add_child(bottom)
	var br=hbox(bottom,6)
	portrait(br,"mnki",Vector2(59,76))
	portrait(br,"swan",Vector2(59,76))
	var bv=vbox(br,5)
	text(bv,"MNKI & SWAN",13,INK)
	text(bv,"WASD  move · Mouse  look",11,MUTED)
	text(bv,"Shift  run · Space  jump",11,MUTED)
	var actions=hbox(hud,8)
	actions.position=Vector2(1080,816)
	for info in [["Bag [I]","inventory"],["Journal [J]","journal"],["Map [M]","map"]]:
		button(actions,info[0],func(): open_menu(info[1]))
	prompt_panel=PanelContainer.new()
	prompt_panel.position=Vector2(450,774)
	prompt_panel.size=Vector2(540,70)
	prompt_panel.add_theme_stylebox_override("panel",style(Color("f7f0de"),14,Color("d2c59d"),18))
	hud.add_child(prompt_panel)
	prompt_label=text(prompt_panel,"[E] Gather berries",17,INK)
	prompt_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	banner=vbox(hud,8)
	banner.position=Vector2(400,160)
	banner.size=Vector2(640,100)
	banner.visible=false

func show_hud() -> void:
	title_screen.visible=false
	hud.visible=true
	if is_instance_valid(modal): modal.queue_free()

func build_toast() -> void:
	toast_panel=PanelContainer.new()
	toast_panel.position=Vector2(370,676)
	toast_panel.size=Vector2(700,64)
	toast_panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
	toast_panel.add_theme_stylebox_override("panel",style(Color(0.19,0.27,0.20,0.94),13,Color.TRANSPARENT,16))
	root.add_child(toast_panel)
	toast_label=text(toast_panel,"",15,CREAM)
	toast_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	toast_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	toast_panel.visible=false

func toast(value: String) -> void:
	if not is_instance_valid(toast_label): return
	toast_label.text=value
	toast_time=5.5
	toast_panel.visible=not value.is_empty()
	root.move_child(toast_panel,-1)

func region_banner(title: String, subtitle: String) -> void:
	for n in banner.get_children(): n.queue_free()
	var l=text(banner,title,34,CREAM,true)
	l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_color_override("font_shadow_color",Color("455841"))
	l.add_theme_constant_override("shadow_offset_x",2)
	l.add_theme_constant_override("shadow_offset_y",2)
	var sub=text(banner,subtitle,15,CREAM)
	sub.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	banner_time=4
	banner.visible=true

func update_hud() -> void:
	if not hud.visible: return
	region_label.text=game.region.name
	region_sub.text="TREE VILLAGE · %02d / 13 PLACES" % State.data.visited.size()
	var hours = int(6+float(State.data.clock)/720*24)%24
	var minutes = int(fmod(float(State.data.clock)/720*24,1)*60)
	stats_label.text="DAY %d    %02d:%02d     ◉ %d" % [State.data.day,hours,minutes,State.data.coins]
	compass_label.text=game.region.subtitle
	if not game.waypoint.is_empty():
		for r in D.REGIONS:
			if r.id==game.waypoint:
				var distance=Vector2(game.player.position.x,game.player.position.z).distance_to(r.p)
				compass_label.text="◇ %s · %dm" % [r.name,int(distance)]
	var selected: Dictionary = D.QUESTS[0]
	for q in D.QUESTS:
		if q.id==tracked: selected=q
	objective_label.text=selected.title
	objective_detail.text=("Complete · choose another request [J]" if selected.id in State.data.completed else progress(selected))+"\nVillage board · J for requests"
	if game.fishing:
		prompt_panel.visible=true
		prompt_label.text="[E] REEL IT IN!   ·   a bite!" if game.bite_played else "Waiting for a little nibble…   ·   Right-click to cancel"
		prompt_panel.modulate=Color("f5d99a") if game.bite_played else Color.WHITE
	elif is_instance_valid(game.target) and not game.menu_open:
		prompt_panel.visible=true
		prompt_panel.modulate=Color.WHITE
		prompt_label.text="[%s] %s" % [binding("interact"),game.target.prompt()]
	else: prompt_panel.visible=false

func progress(q: Dictionary) -> String:
	var lines: Array[String]=[]
	for id in q.deliver: lines.append("%s %d/%d" % [D.ITEMS[id].name,mini(State.count(id),int(q.deliver[id])),q.deliver[id]])
	var names={"caught":"Fish caught","animal_friends":"Animal friends","planted":"Planted","watered":"Watered","harvested":"Harvested","earned":"Coins earned","upgrades":"Stall improvements","guardians":"Guardian plaques","decorated":"Decorations placed","quests":"Requests completed","regions":"Places visited"}
	for id in q.metrics: lines.append("%s %d/%d" % [names.get(id,id),mini(State.metric(id),int(q.metrics[id])),q.metrics[id]])
	return " · ".join(lines)

func modal_shell(title: String, subtitle: String = "") -> void:
	if is_instance_valid(modal): modal.free()
	game.set_menu(true)
	modal=Control.new()
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(modal)
	var dim=ColorRect.new()
	dim.color=Color(0.12,0.19,0.14,0.64)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal.add_child(dim)
	var panel=PanelContainer.new()
	panel.position=Vector2(230,64)
	panel.size=Vector2(980,772)
	modal.add_child(panel)
	var outer=vbox(panel,12)
	var head=hbox(outer)
	var names=vbox(head,3)
	names.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	text(names,title,29,INK,true)
	if not subtitle.is_empty(): text(names,subtitle,13,MUTED)
	button(head,"Close  ×",func(): close_modal())
	var sep=HSeparator.new()
	outer.add_child(sep)
	var sc=ScrollContainer.new()
	sc.size_flags_vertical=Control.SIZE_EXPAND_FILL
	sc.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	sc.custom_minimum_size=Vector2(900,600)
	outer.add_child(sc)
	modal_body=vbox(sc,12)
	modal_body.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	text(outer,"YOUR TIME IS YOURS. MENUS PAUSE THE WORLD.                                    Esc · return",11,MUTED)

func open_menu(page: String) -> void:
	current_page=page
	match page:
		"pause": pause_page()
		"inventory": inventory_page()
		"journal","board": journal_page(page=="board")
		"map": map_page()
		"shop": shop_page()
		"home": home_page()
		"settings": settings_page()
		"animal": animal_menu(animal_id)

func refresh() -> void:
	call_deferred("open_menu",current_page)

func close_modal() -> void:
	pending_binding=""
	if is_instance_valid(modal): modal.queue_free()
	modal=null
	current_page=""
	game.set_menu(not game.playing)
	if not game.playing: title_screen.visible=true

func pause_page() -> void:
	modal_shell("A little breather", "Day %d · %d requests complete · %d / 13 places discovered" % [State.data.day,State.data.completed.size(),State.data.visited.size()])
	portrait(modal_body,"couple",Vector2(320,230))
	button(modal_body,"Return to our world",func(): close_modal(),true)
	button(modal_body,"Save our world",func(): game.save_world())
	button(modal_body,"Settings & controls",func(): open_menu("settings"))
	button(modal_body,"Save & return to title",func():
		if not game.save_world(): return
		game.playing=false
		game.player.active=false
		game.swan.enabled=false
		game.title_camera.current=true
		hud.visible=false
		close_modal()
		build_title())
	button(modal_body,"Save & quit",func():
		if game.save_world(): game.quit_cleanly())

func inventory_page() -> void:
	modal_shell("Our little satchel", "%d / %d items · ◉ %d coins · seeds have their own pocket" % [State.used(),State.CAPACITY,State.data.coins])
	paragraph(modal_body,"Ingredients for available village requests are reserved when trading. Store or retrieve items at home.")
	var any=false
	for id in D.ITEMS:
		var count=State.count(id)
		if count<=0: continue
		any=true
		var row=hbox(card(modal_body))
		var dot=text(row,"●",24,Color(D.ITEMS[id].color))
		dot.custom_minimum_size.x=35
		var v=vbox(row,3)
		v.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		text(v,D.ITEMS[id].name,18)
		text(v,"%s · %d coins each · %d reserved for requests" % [D.ITEMS[id].category,D.ITEMS[id].price,State.reserved(id)],12,MUTED)
		text(row,"× %d" % count,22,SAGE)
	if not any: paragraph(modal_body,"An empty bag is the beginning of a good walk. Look for ripe berries beside the forest path.",19)
	spacer(modal_body)
	text(modal_body,"THE SEED POCKET",13,SAGE)
	for crop in D.CROPS:
		var row=hbox(modal_body)
		text(row,D.CROPS[crop].name+" seeds",16)
		fill(row)
		text(row,"× %d" % State.data.seeds.get(crop,0))
		button(row,"Select" if State.selected_crop!=crop else "Selected ✓",func():
			State.selected_crop=crop
			refresh())

func journal_page(at_board: bool) -> void:
	modal_shell("Village requests" if at_board else "Our story so far", "%d / 12 requests complete · no deadlines, just little acts of care" % State.data.completed.size())
	if not at_board: paragraph(modal_body,"Track a request here. Deliver ingredients and collect rewards at the community board in Village Park.")
	for q in D.QUESTS:
		var done=q.id in State.data.completed
		var unlocked=State.quest_unlocked(q)
		var ready=State.quest_ready(q)
		var v=vbox(card(modal_body,Color("e4e9d5") if done else Color("eee9d7")),7)
		var row=hbox(v)
		text(row,("✓ " if done else "◇ ")+q.title,19,INK,true)
		fill(row)
		text(row,"◉ %d" % q.coins,15,SAGE)
		paragraph(v,q.giver+" · "+q.text,14)
		if done: text(v,"A kindness remembered.",13,SAGE)
		elif not unlocked:
			text(v,"Unlocks after: "+", ".join(q.requires),12,MUTED)
		else:
			paragraph(v,progress(q),14,INK)
			var actions=hbox(v)
			button(actions,"Tracking ✓" if tracked==q.id else "Track request",func(): tracked=q.id; refresh())
			if at_board:
				var claim=button(actions,"Deliver & receive reward" if ready else "Still a little to do",func():
					if State.claim_quest(q.id): game.save_world()
					refresh(),ready)
				claim.disabled=not ready
	spacer(modal_body)
	text(modal_body,"OUR NATURE JOURNAL",17,INK,true)
	paragraph(modal_body,"Discovered: "+(", ".join(State.data.collection.map(func(id): return D.ITEMS[id].name)) if not State.data.collection.is_empty() else "The first page is waiting for a discovery."))

func map_page() -> void:
	modal_shell("A map of our little world", "%d / 13 places discovered · warm paths always lead home" % State.data.visited.size())
	var map=MAP.new()
	map.game=game
	modal_body.add_child(map)
	for r in D.REGIONS:
		var row=hbox(modal_body)
		text(row,("✓ " if r.id in State.data.visited else "○ ")+r.name,15)
		fill(row)
		button(row,"Pin on compass",func(): game.waypoint=r.id; close_modal())

func shop_page() -> void:
	modal_shell("Mnki & Swan’s fruit stall", "◉ %d coins · stall tier %d / 4 · grown with care, shared with love" % [State.data.coins,State.data.stall_tier+1])
	var tabs=hbox(modal_body)
	for tab in ["sell","seeds","decor","improvements"]:
		button(tabs,tab.capitalize(),func(): shop_tab=tab; refresh(),shop_tab==tab)
	match shop_tab:
		"sell":
			paragraph(modal_body,"Choose a quantity and check its price before selling. Ingredients for available requests stay safe in your bag.")
			var any=false
			for id in D.ITEMS:
				if State.count(id)<=0: continue
				any=true
				var row=hbox(card(modal_body))
				var v=vbox(row,4)
				v.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				text(v,D.ITEMS[id].name,18)
				text(v,"%d in bag · %d reserved · %d coins each" % [State.count(id),State.reserved(id),D.ITEMS[id].price],12,MUTED)
				var qty=SpinBox.new()
				qty.min_value=1 if State.sellable(id)>0 else 0
				qty.max_value=State.sellable(id)
				qty.step=1
				qty.value=State.sellable(id)
				qty.custom_minimum_size.x=100
				row.add_child(qty)
				var sell_button=button(row,"Sell · +%d coins" % (int(qty.value)*D.ITEMS[id].price),func():
					State.sell(id,int(qty.value))
					refresh(),true)
				sell_button.disabled=State.sellable(id)==0
				qty.value_changed.connect(func(value): sell_button.text="Sell · +%d coins" % (int(value)*D.ITEMS[id].price))
			if not any: paragraph(modal_body,"Your baskets are empty. The berry maze, orchard and fishing pond are waiting.",20)
		"seeds":
			paragraph(modal_body,"All crops are gentle. Plant, water, explore or rest, then harvest. Nothing withers.")
			for crop in D.CROPS:
				var row=hbox(card(modal_body))
				var v=vbox(row,4)
				v.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				text(v,D.CROPS[crop].name+" seed",18)
				text(v,"%d owned · grows in %ds when watered · yield %d" % [State.data.seeds.get(crop,0),D.CROPS[crop].seconds,D.CROPS[crop]["yield"]],12,MUTED)
				button(row,"Buy · %d coins" % D.CROPS[crop].seed_cost,func(): State.buy_seed(crop); refresh(),true)
		"decor":
			paragraph(modal_body,"Choose a little treasure. Place it at one of ten anchors inside your shared treehouse.")
			for id in D.DECOR:
				var row=hbox(card(modal_body))
				text(row,D.DECOR[id].name,18)
				fill(row)
				var owned=id in State.data.decor_owned
				var b=button(row,"Owned ✓" if owned else "Buy · %d coins" % D.DECOR[id].cost,func(): State.buy_decor(id); refresh(),not owned)
				b.disabled=owned
		"improvements":
			var names=["A little extra shelf","A colorful fruit display","A proud village stall"]
			var prices=[45,100,180]
			for i in range(3):
				var row=hbox(card(modal_body))
				text(row,names[i],18)
				fill(row)
				var b=button(row,"Built ✓" if State.data.stall_tier>i else "Improve · %d coins" % prices[i],func(): State.upgrade(); refresh(),State.data.stall_tier==i)
				b.disabled=State.data.stall_tier!=i

func home_page() -> void:
	modal_shell("Our treehouse", "A place for quiet mornings and small treasures · ◉ %d" % State.data.coins)
	var tabs=hbox(modal_body)
	for tab in ["rest","storage","decorate"]:
		button(tabs,tab.capitalize(),func(): home_tab=tab; refresh(),tab==home_tab)
	match home_tab:
		"rest":
			portrait(modal_body,"couple",Vector2(300,270))
			paragraph(modal_body,"A new morning brings ripe fruit and a fresh start. Watered crops keep growing. Nothing is lost by resting.",18)
			button(modal_body,"Rest until morning & save",func():
				State.rest()
				game.save_world()
				refresh(),true)
			button(modal_body,"Save our world",func(): game.save_world())
		"storage":
			paragraph(modal_body,"Home storage is separate from your satchel. Move one item at a time; everything stays accounted for.")
			for id in D.ITEMS:
				if State.count(id)+int(State.data.storage.get(id,0))<=0: continue
				var row=hbox(card(modal_body))
				var v=vbox(row,3)
				v.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				text(v,D.ITEMS[id].name)
				text(v,"Bag %d · Home %d" % [State.count(id),State.data.storage.get(id,0)],13,MUTED)
				var store=button(row,"Store 1 →",func(): State.transfer(id,1,true); refresh())
				store.disabled=State.count(id)==0
				var take=button(row,"← Take 1",func(): State.transfer(id,1,false); refresh())
				take.disabled=int(State.data.storage.get(id,0))==0
		"decorate":
			paragraph(modal_body,"Place a treasure at an anchor. Replacing an anchor returns its previous decoration to your collection. Each owned item can appear once.")
			for anchor in range(10):
				var row=hbox(card(modal_body))
				var v=vbox(row,3)
				v.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				text(v,("Living room" if anchor<5 else "Upstairs")+" · anchor %d" % (anchor%5+1),17)
				var placed: String=State.data.decor_placed.get(str(anchor),"")
				text(v,"An empty space" if placed=="" else D.DECOR[placed].name,12,MUTED)
				var choice=OptionButton.new()
				choice.custom_minimum_size.x=220
				for id in State.data.decor_owned: choice.add_item(D.DECOR[id].name)
				row.add_child(choice)
				button(row,"Place here",func():
					State.place_decor(State.data.decor_owned[choice.selected],anchor)
					game.save_world()
					refresh(),true)

func dialogue(name: String, line: String, art: String = "") -> void:
	current_page="dialogue"
	modal_shell(name,"A moment together")
	if not art.is_empty(): portrait(modal_body,art,Vector2(260,260))
	paragraph(modal_body,"“"+line+"”",22,INK)
	spacer(modal_body,24)
	button(modal_body,"Let’s keep exploring",func(): close_modal(),true)
	button(modal_body,"Read our journal",func(): open_menu("journal"))

func animal_menu(id: String) -> void:
	animal_id=id
	current_page="animal"
	modal_shell("A gentle hello, "+id, "Little friends, never a chore")
	paragraph(modal_body,"Offer a berry or leafy green, brush gently, or simply say hello. There are no penalties for missing a day. Each care action is remembered for today.",19)
	for action in ["pet","feed","brush","egg"]:
		if action=="egg" and id!="chicken": continue
		var done=int(State.data.animals.get(id,{}).get(action,0))==int(State.data.day)
		var b=button(modal_body,{"pet":"Gently pet","feed":"Offer food · 1 berry or leafy green","brush":"Brush their coat","egg":"Collect today’s egg"}[action]+(" · done for today ✓" if done else ""),func():
			if State.care(id,action): Sound.play("pick"); game.player.visual.reaction=0.6
			refresh(),not done)
		b.disabled=done

func slider(parent: Node, name: String, id: String, low: float, high: float, step: float) -> void:
	var row=hbox(parent)
	var l=text(row,name,16)
	l.custom_minimum_size.x=270
	var s=HSlider.new()
	s.min_value=low
	s.max_value=high
	s.step=step
	s.value=State.settings[id]
	s.custom_minimum_size=Vector2(400,36)
	row.add_child(s)
	var value=text(row,str(snappedf(s.value,0.01)),13,MUTED)
	s.value_changed.connect(func(v):
		State.settings[id]=v
		State.save_settings()
		value.text=str(snappedf(v,0.01)))

func toggle(parent: Node, name: String, id: String) -> void:
	var t=CheckButton.new()
	t.text=name
	t.button_pressed=State.settings[id]
	parent.add_child(t)
	t.toggled.connect(func(on):
		State.settings[id]=on
		State.save_settings()
		if id=="fullscreen": DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED))

func settings_page() -> void:
	modal_shell("Make yourself comfortable", "Saved locally · audio, camera, readability and controls")
	text(modal_body,"SOUND & CAMERA",13,SAGE)
	slider(modal_body,"Music","music",0,1,0.05)
	slider(modal_body,"Woodland ambience","ambience",0,1,0.05)
	slider(modal_body,"Action sounds","effects",0,1,0.05)
	slider(modal_body,"Mouse sensitivity","sensitivity",0.001,0.008,0.0005)
	toggle(modal_body,"Invert vertical camera","invert_y")
	toggle(modal_body,"Reduce decorative character motion","reduced_motion")
	toggle(modal_body,"Relaxed fishing · generous bite window","easy_fishing")
	toggle(modal_body,"Fullscreen","fullscreen")
	var row=hbox(modal_body)
	text(row,"Text size",16)
	button(row,"Standard",func(): set_text_size(1.0))
	button(row,"Large",func(): set_text_size(1.15))
	spacer(modal_body)
	text(modal_body,"CONTROLS · CLICK TO REBIND",13,SAGE)
	for action in ["move_forward","move_back","move_left","move_right","interact","jump","run","inventory","journal","map","save","photo"]:
		var key_row=hbox(modal_body)
		var l=text(key_row,action.replace("_"," ").capitalize(),15)
		l.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		button(key_row,"Press a key…" if pending_binding==action else binding(action),func():
			pending_binding=action
			refresh())
	paragraph(modal_body,"Esc closes menus and pauses. 1–5 selects a crop seed. Mouse wheel adjusts camera distance. F2 hides the interface. No stamina, hunger, crop death or deadlines.",13)

func binding(action: String) -> String:
	var events=InputMap.action_get_events(action)
	return OS.get_keycode_string(events[0].physical_keycode) if not events.is_empty() else "—"

func _input(event: InputEvent) -> void:
	if pending_binding.is_empty() or not event is InputEventKey or not event.pressed or event.echo: return
	if event.physical_keycode==KEY_ESCAPE:
		pending_binding=""
		refresh()
		get_viewport().set_input_as_handled()
		return
	for action in InputMap.get_actions():
		if action==pending_binding or action.begins_with("ui_"): continue
		for existing in InputMap.action_get_events(action):
			if existing is InputEventKey and existing.physical_keycode==event.physical_keycode:
				toast("That key already belongs to "+action.replace("_"," ")+". Choose a different key.")
				get_viewport().set_input_as_handled()
				return
	var key=InputEventKey.new()
	key.physical_keycode=event.physical_keycode
	InputMap.action_erase_events(pending_binding)
	InputMap.action_add_event(pending_binding,key)
	var config=ConfigFile.new()
	config.load("user://bindings.cfg")
	config.set_value("keys",pending_binding,int(key.physical_keycode))
	config.save("user://bindings.cfg")
	pending_binding=""
	refresh()
	get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	toast_time=maxf(0,toast_time-delta)
	toast_panel.visible=toast_time>0 and not toast_label.text.is_empty()
	banner_time=maxf(0,banner_time-delta)
	if is_instance_valid(banner): banner.visible=banner_time>0 and not game.menu_open

func set_text_size(value: float) -> void:
	State.settings.text_size=value
	State.save_settings()
	root.theme.default_font_size=int(16*value)
	resize_labels(root)
	refresh()

func resize_labels(parent: Node) -> void:
	for node in parent.get_children():
		if node is Label and node.has_meta("base_size"):
			node.add_theme_font_size_override("font_size",int(node.get_meta("base_size")*State.settings.text_size))
		resize_labels(node)
