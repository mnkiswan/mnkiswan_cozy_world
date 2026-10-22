extends Node
## Authoritative, UI-independent transactions. All IDs are stable and serialized.
signal changed(message: String)
signal milestone(id: String)
const D = preload("res://scripts/game_data.gd")
const SAVE_VERSION = 1
const CAPACITY = 120
var save_path = "user://cozy_world.json"
var data: Dictionary
var selected_crop = "rice"
var settings = {"music":0.45,"effects":0.65,"ambience":0.4,"sensitivity":0.003,"invert_y":false,"reduced_motion":false,"text_size":1.0,"easy_fishing":true,"fullscreen":false}
var last_error = ""

func _ready() -> void:
	reset()
	load_settings()

func reset() -> void:
	data = {"version":SAVE_VERSION,"coins":18,"day":1,"clock":120.0,"inventory":{},"storage":{},"seeds":{"rice":4,"carrot":3,"tomato":2,"lettuce":2,"bloom":2},"plots":{},"gathered":{},"animals":{},"completed":[],"flags":[],"metrics":{},"visited":[],"collection":[],"guardians":[],"decor_owned":["basket"],"decor_placed":{},"stall_tier":0,"position":[-29.0,0.15,-21.0],"interior":false}
	changed.emit("")

func notify(message: String) -> bool:
	changed.emit(message)
	return false

func count(id: String) -> int:
	return int(data.inventory.get(id,0))

func metric(id: String) -> int:
	return int(data.metrics.get(id,0))

func record(id: String, amount: int = 1) -> void:
	data.metrics[id] = metric(id)+amount

func used() -> int:
	var total = 0
	for n in data.inventory.values(): total += int(n)
	return total

func add_item(id: String, amount: int) -> bool:
	if not D.ITEMS.has(id) or amount <= 0: return false
	if used()+amount > CAPACITY: return notify("Your bag is full. Make room at home or at the stall.")
	data.inventory[id] = count(id)+amount
	if not id in data.collection: data.collection.append(id)
	return true

func gather(id: String, item: String, amount: int = 2) -> bool:
	if float(data.gathered.get(id,0.0)) > total_time(): return notify("Growing back gently. Try again later, or after a rest.")
	if not add_item(item,amount): return false
	data.gathered[id] = total_time()+150.0
	record("gathered",amount)
	changed.emit("+%d %s · gathered with care" % [amount,D.ITEMS[item].name])
	return true

func total_time() -> float:
	return (int(data.day)-1)*720.0+float(data.clock)

func tick(delta: float) -> void:
	data.clock += delta
	if data.clock >= 720.0:
		data.clock -= 720.0
		data.day += 1
		changed.emit("A new day in Tree Village.")
	for plot in data.plots.values():
		if plot.watered:
			plot.growth = minf(float(plot.growth)+delta,float(D.CROPS[plot.crop].seconds))

func plant(plot_id: String, crop: String) -> bool:
	if not D.CROPS.has(crop) or data.plots.has(plot_id): return false
	if int(data.seeds.get(crop,0)) < 1: return notify("No %s seeds left. Visit the market for more." % D.CROPS[crop].name)
	data.seeds[crop] -= 1
	data.plots[plot_id] = {"crop":crop,"watered":false,"growth":0.0}
	record("planted")
	changed.emit("%s planted. Give it a little water." % D.CROPS[crop].name)
	return true

func water(plot_id: String) -> bool:
	if not data.plots.has(plot_id) or data.plots[plot_id].watered: return false
	data.plots[plot_id].watered = true
	record("watered")
	changed.emit("Watered. It will grow while you explore, or rest at home.")
	return true

func harvest(plot_id: String) -> bool:
	if not data.plots.has(plot_id): return false
	var p: Dictionary = data.plots[plot_id]
	if p.growth < D.CROPS[p.crop].seconds: return false
	var crop: String = p.crop
	if not add_item(crop,D.CROPS[crop]["yield"]): return false
	data.plots.erase(plot_id)
	record("harvested",D.CROPS[crop]["yield"])
	changed.emit("A lovely harvest! +%d %s" % [D.CROPS[crop]["yield"],D.ITEMS[crop].name])
	return true

func care(animal: String, action: String) -> bool:
	if not animal in ["chicken","cow","sheep"] or not action in ["pet","feed","brush","egg"]: return false
	var a: Dictionary = data.animals.get(animal,{})
	if int(a.get(action,0)) == int(data.day): return notify("Already cared for today. Your friend is content.")
	if action == "egg":
		if animal != "chicken" or int(a.get("feed",0)) != int(data.day): return notify("Feed the chicken first. A happy hen has a little gift.")
		if not add_item("egg",1): return false
	if action == "feed":
		if count("berry") == 0 and count("lettuce") == 0: return notify("Bring a berry or leafy green for a little snack.")
		var food = "lettuce" if count("lettuce") > 0 else "berry"
		data.inventory[food] -= 1
	if not data.animals.has(animal): record("animal_friends")
	a[action] = int(data.day)
	data.animals[animal] = a
	changed.emit("A fresh egg, just for you." if action == "egg" else "%s enjoys a gentle %s. ♥" % [animal.capitalize(),action])
	return true

func catch_fish() -> bool:
	var fish_ids = ["fish","carp","perch","trout","koi","moonfish"]
	var index = 0 if metric("caught") == 0 else (int(data.day)+metric("caught")) % fish_ids.size()
	var id: String = fish_ids[index]
	if not add_item(id,1): return false
	record("caught")
	changed.emit("A %s! A little patience goes a long way." % D.ITEMS[id].name)
	milestone.emit("fish")
	return true

func quest_unlocked(q: Dictionary) -> bool:
	for id in q.requires:
		if not id in data.completed: return false
	return true

func quest_ready(q: Dictionary) -> bool:
	if q.id in data.completed or not quest_unlocked(q): return false
	for id in q.deliver:
		if count(id) < int(q.deliver[id]): return false
	for id in q.metrics:
		if metric(id) < int(q.metrics[id]): return false
	return true

func claim_quest(id: String) -> bool:
	for q in D.QUESTS:
		if q.id == id:
			if not quest_ready(q): return false
			for item in q.deliver: data.inventory[item] -= int(q.deliver[item])
			data.completed.append(id)
			data.flags.append(q.flag)
			data.coins += q.coins
			data.metrics.quests = data.completed.size()
			changed.emit("Request complete · %s · +%d coins" % [q.title,q.coins])
			milestone.emit(id)
			return true
	return false

func reserved(id: String) -> int:
	var amount = 0
	for q in D.QUESTS:
		if quest_unlocked(q) and not q.id in data.completed:
			amount += int(q.deliver.get(id,0))
	return mini(amount,count(id))

func sellable(id: String) -> int:
	return maxi(0,count(id)-reserved(id))

func sell(id: String, quantity: int) -> bool:
	if not D.ITEMS.has(id) or quantity <= 0 or quantity > sellable(id): return false
	var value: int = D.ITEMS[id].price*quantity
	data.inventory[id] -= quantity
	data.coins += value
	record("earned",value)
	changed.emit("Sold %d %s · +%d coins" % [quantity,D.ITEMS[id].name,value])
	milestone.emit("sale")
	return true

func buy_seed(crop: String) -> bool:
	if not D.CROPS.has(crop): return false
	var price: int = D.CROPS[crop].seed_cost
	if data.coins < price: return notify("A few more coins first. The stall is always here.")
	data.coins -= price
	data.seeds[crop] = int(data.seeds.get(crop,0))+1
	changed.emit("One %s seed tucked into your bag." % D.CROPS[crop].name)
	return true

func upgrade() -> bool:
	var prices = [45,100,180]
	var tier: int = data.stall_tier
	if tier >= prices.size(): return false
	if data.coins < prices[tier]: return notify("This improvement costs %d coins." % prices[tier])
	data.coins -= prices[tier]
	data.stall_tier += 1
	record("upgrades")
	changed.emit("Our fruit stall has room for more good things!")
	milestone.emit("upgrade")
	return true

func buy_decor(id: String) -> bool:
	if not D.DECOR.has(id) or id in data.decor_owned: return false
	if data.coins < D.DECOR[id].cost: return notify("Save a few more coins for this little treasure.")
	data.coins -= D.DECOR[id].cost
	data.decor_owned.append(id)
	changed.emit("%s · ready to place at home." % D.DECOR[id].name)
	return true

func place_decor(id: String, anchor: int) -> bool:
	if not id in data.decor_owned or anchor < 0 or anchor > 9: return false
	for key in data.decor_placed.keys():
		if data.decor_placed[key] == id: data.decor_placed.erase(key)
	data.decor_placed[str(anchor)] = id
	data.metrics.decorated = data.decor_placed.size()
	changed.emit("A little more like home. ♥")
	return true

func transfer(id: String, amount: int, to_storage: bool) -> bool:
	if not D.ITEMS.has(id) or amount <= 0: return false
	var source: Dictionary = data.inventory if to_storage else data.storage
	var dest: Dictionary = data.storage if to_storage else data.inventory
	if int(source.get(id,0)) < amount: return false
	if not to_storage and used()+amount > CAPACITY: return notify("Your bag is full.")
	source[id] -= amount
	dest[id] = int(dest.get(id,0))+amount
	changed.emit("Safely stored at home." if to_storage else "Back in your bag.")
	return true

func discover(id: String) -> bool:
	if not id in D.REGIONS.map(func(r): return r.id): return false
	if id in data.visited: return false
	data.visited.append(id)
	data.metrics.regions = data.visited.size()
	changed.emit("")
	return true

func guardian(id: String) -> bool:
	if not id in ["land","water","forest"]: return false
	if id in data.guardians: return false
	data.guardians.append(id)
	data.metrics.guardians = data.guardians.size()
	changed.emit("%s guardian remembered · %d / 3" % [id.capitalize(),data.guardians.size()])
	return true

func rest() -> void:
	var remaining = 720.0-float(data.clock)
	tick(remaining)
	data.clock = 120.0
	changed.emit("Day %d · A fresh morning. Nothing is ever lost by resting." % data.day)

func validate(candidate: Variant) -> bool:
	if not candidate is Dictionary: return false
	var c: Dictionary = candidate
	if c.get("version") != SAVE_VERSION: return false
	for key in data:
		if not c.has(key) or typeof(c[key]) != typeof(data[key]):
			# JSON stores all numeric types as float.
			if not c.has(key) or not (typeof(c[key]) in [TYPE_INT,TYPE_FLOAT] and typeof(data[key]) in [TYPE_INT,TYPE_FLOAT]): return false
	if not finite_number(c.coins,0,10000000) or not finite_number(c.day,1,1000000) or not finite_number(c.clock,0,720): return false
	if not finite_number(c.stall_tier,0,3): return false
	if c.position.size() != 3: return false
	for value in c.position:
		if not finite_number(value,-300,300): return false
	var total = 0
	for key in ["inventory","storage"]:
		for id in c[key]:
			if not D.ITEMS.has(id) or not finite_number(c[key][id],0,1000000): return false
			if key == "inventory": total += int(c[key][id])
	if total > CAPACITY: return false
	for id in c.seeds:
		if not D.CROPS.has(id) or not finite_number(c.seeds[id],0,100000): return false
	for id in c.plots:
		var p: Variant = c.plots[id]
		if not p is Dictionary or not D.CROPS.has(p.get("crop","")): return false
		if not p.get("watered") is bool or not finite_number(p.get("growth"),0,10000): return false
	for id in c.gathered:
		if not finite_number(c.gathered[id],0,1000000000): return false
	for id in c.animals:
		if not id in ["cow","sheep","chicken"] or not c.animals[id] is Dictionary: return false
		for action in c.animals[id]:
			if not action in ["pet","feed","brush","egg"] or not finite_number(c.animals[id][action],1,1000000): return false
	for id in c.metrics:
		if not finite_number(c.metrics[id],0,1000000000): return false
	for key in ["completed","flags","visited","collection","guardians","decor_owned"]:
		var seen = []
		for id in c[key]:
			if not id is String or id in seen: return false
			seen.append(id)
	for id in c.completed:
		if not id in D.QUESTS.map(func(q): return q.id): return false
	for id in c.visited:
		if not id in D.REGIONS.map(func(r): return r.id): return false
	for id in c.collection:
		if not D.ITEMS.has(id): return false
	for id in c.guardians:
		if not id in ["land","water","forest"]: return false
	for id in c.decor_owned:
		if not D.DECOR.has(id): return false
	var placed = []
	for anchor in c.decor_placed:
		var id: Variant = c.decor_placed[anchor]
		if not str(anchor).is_valid_int() or int(anchor) < 0 or int(anchor) > 9 or not id in c.decor_owned or id in placed: return false
		placed.append(id)
	return true

func finite_number(value: Variant, low: float, high: float) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) >= low and float(value) <= high

func save_game() -> bool:
	if not validate(data):
		last_error = "Save validation failed; your previous save is safe."
		return notify(last_error)
	var temp = save_path+".tmp"
	var file = FileAccess.open(temp,FileAccess.WRITE)
	if file == null:
		last_error = "Could not write save. Check available disk space."
		return notify(last_error)
	file.store_string(JSON.stringify(data,"\t"))
	file.flush()
	file.close()
	if not validate(JSON.parse_string(FileAccess.get_file_as_string(temp))): return false
	# Only rotate a verified primary; never overwrite a good backup with corruption.
	if FileAccess.file_exists(save_path) and validate(JSON.parse_string(FileAccess.get_file_as_string(save_path))):
		if DirAccess.copy_absolute(save_path,save_path+".bak") != OK: return notify("Could not preserve save backup; previous save unchanged.")
	if DirAccess.rename_absolute(temp,save_path) != OK: return notify("Could not finish saving; previous save remains safe.")
	changed.emit("Saved · your little world is safe.")
	return true

func load_game() -> bool:
	for path in [save_path,save_path+".bak"]:
		if not FileAccess.file_exists(path): continue
		var candidate: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if validate(candidate):
			data = candidate
			changed.emit("Welcome home." if path == save_path else "Recovered your world from its backup.")
			return true
	last_error = "No valid save found. Your existing save files have been kept."
	return notify(last_error)

func save_settings() -> void:
	var config = ConfigFile.new()
	for id in settings: config.set_value("preferences",id,settings[id])
	config.save("user://settings.cfg")

func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") != OK: return
	for id in settings:
		var value: Variant = config.get_value("preferences",id,settings[id])
		if typeof(value) == typeof(settings[id]): settings[id] = value
	settings.music = clampf(settings.music,0,1)
	settings.effects = clampf(settings.effects,0,1)
	settings.ambience = clampf(settings.ambience,0,1)
	settings.sensitivity = clampf(settings.sensitivity,0.001,0.008)
