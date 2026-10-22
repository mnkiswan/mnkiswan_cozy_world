class_name GameData
extends RefCounted

const ITEMS = {
 "berry": {"name":"Cherry berries", "price":2, "color":"b95069", "category":"Forage"},
 "mango": {"name":"Golden mango", "price":5, "color":"edb34f", "category":"Fruit"},
 "banana": {"name":"Banana", "price":4, "color":"ead679", "category":"Fruit"},
 "coconut": {"name":"Coconut", "price":6, "color":"977055", "category":"Fruit"},
 "flower": {"name":"Wildflower", "price":2, "color":"e9a7ad", "category":"Forage"},
 "fish": {"name":"Silver minnow", "price":7, "color":"8ebbc0", "category":"Fish"},
 "carp": {"name":"Honey carp", "price":9, "color":"d9a75a", "category":"Fish"},
 "perch": {"name":"Reed perch", "price":8, "color":"93ad73", "category":"Fish"},
 "trout": {"name":"Rainbow trout", "price":11, "color":"b3a4c9", "category":"Fish"},
 "koi": {"name":"Sunset koi", "price":14, "color":"dc926e", "category":"Fish"},
 "moonfish": {"name":"Moonfin", "price":16, "color":"b2cbdc", "category":"Fish"},
 "egg": {"name":"Fresh egg", "price":3, "color":"f2e5c9", "category":"Farm"},
 "rice": {"name":"Rice bundle", "price":5, "color":"d9c77f", "category":"Crop"},
 "carrot": {"name":"Sweet carrot", "price":5, "color":"df9459", "category":"Crop"},
 "tomato": {"name":"Sun tomato", "price":6, "color":"ce6550", "category":"Crop"},
 "lettuce": {"name":"Leafy greens", "price":4, "color":"96b96c", "category":"Crop"},
 "bloom": {"name":"Garden bloom", "price":6, "color":"d79ac0", "category":"Crop"}
}
const CROPS = {
 "rice":{"name":"Rice", "seconds":110.0, "yield":3, "seed_cost":3},
 "carrot":{"name":"Carrot", "seconds":90.0, "yield":3, "seed_cost":3},
 "tomato":{"name":"Tomato", "seconds":140.0, "yield":4, "seed_cost":4},
 "lettuce":{"name":"Leafy greens", "seconds":75.0, "yield":3, "seed_cost":3},
 "bloom":{"name":"Garden bloom", "seconds":120.0, "yield":3, "seed_cost":4}
}
const DECOR = {
 "rug":{"name":"Woven sunset rug", "cost":12},
 "lamp":{"name":"Firefly lantern", "cost":15},
 "plant":{"name":"Little fern", "cost":10},
 "picture":{"name":"Together portrait", "cost":18},
 "stool":{"name":"Mushroom stool", "cost":12},
 "shelf":{"name":"Treasures shelf", "cost":20},
 "flowers":{"name":"Garden vase", "cost":10},
 "basket":{"name":"Wicker basket", "cost":8},
 "keepsake":{"name":"Guardian keepsake", "cost":25},
 "kettle":{"name":"Morning tea set", "cost":15}
}
const REGIONS = [
 {"id":"forest", "name":"Sunshine Forest", "subtitle":"A little light, a fresh beginning", "p":Vector2(-29,-25), "color":"92aa74"},
 {"id":"pond", "name":"Waterfall & Ponds", "subtitle":"Leave a little room for quiet", "p":Vector2(0,-29), "color":"76b6b5"},
 {"id":"berries", "name":"Cherry Berry Maze", "subtitle":"Good things hide around the bend", "p":Vector2(27,-25), "color":"bd7b86"},
 {"id":"garden", "name":"Village Flower Garden", "subtitle":"Something lovely is always growing", "p":Vector2(29,-4), "color":"d7a3b2"},
 {"id":"paddy", "name":"Paddy Field", "subtitle":"Small seeds, patient hands", "p":Vector2(28,18), "color":"c2b875"},
 {"id":"orchard", "name":"Tropical Fruit Forest", "subtitle":"Sunshine, by the basketful", "p":Vector2(22,39), "color":"d6ac67"},
 {"id":"farm", "name":"Thronn’s Animal Farm", "subtitle":"Our friends with feathers and fur", "p":Vector2(-4,40), "color":"b8aa86"},
 {"id":"gate", "name":"The Three Guardians", "subtitle":"Land. Water. Forest. Together.", "p":Vector2(-30,-4), "color":"a3aaa3"},
 {"id":"park", "name":"Village Park", "subtitle":"A place for everyone", "p":Vector2(0,-4), "color":"abc080"},
 {"id":"home", "name":"Our Treehouse", "subtitle":"Every day ends somewhere warm", "p":Vector2(-14,14), "color":"c8a483"},
 {"id":"colony1", "name":"Willow Colony", "subtitle":"A lantern in every window", "p":Vector2(-34,21), "color":"bca185"},
 {"id":"colony2", "name":"Canopy Colony", "subtitle":"A little closer to the sky", "p":Vector2(-29,42), "color":"92a393"},
 {"id":"market", "name":"Market Square", "subtitle":"Grown with care, shared with love", "p":Vector2(9,15), "color":"cf9478"}
]
const QUESTS = [
 {"id":"welcome", "title":"A welcome basket", "giver":"Elder Willow", "text":"Bring 3 cherry berries to the community board. A small welcome makes a home.", "deliver":{"berry":3}, "metrics":{}, "requires":[], "coins":12, "flag":"basket"},
 {"id":"fruit", "title":"A little sunshine", "giver":"Milo the grocer", "text":"Bring 2 mangoes and 2 bananas from the tropical orchard.", "deliver":{"mango":2,"banana":2}, "metrics":{}, "requires":["welcome"], "coins":24, "flag":"fruit_order"},
 {"id":"fishing", "title":"Pondside picnic", "giver":"Reed the fisher", "text":"Catch a fish and bring 2 berries for a quiet afternoon by the pond.", "deliver":{"berry":2,"fish":1}, "metrics":{"caught":1}, "requires":[], "coins":18, "flag":"picnic"},
 {"id":"care", "title":"Friends with feathers & fur", "giver":"Thronn", "text":"Gently pet, feed, or brush each of the three farm animals.", "deliver":{}, "metrics":{"animal_friends":3}, "requires":[], "coins":20, "flag":"farm_friend"},
 {"id":"planting", "title":"Small beginnings", "giver":"Pippa the farmer", "text":"Plant and water two garden plots. Seeds are already in your bag.", "deliver":{}, "metrics":{"planted":2,"watered":2}, "requires":[], "coins":12, "flag":"planter"},
 {"id":"harvest", "title":"From seed to supper", "giver":"Pippa the farmer", "text":"Harvest 3 crops. Water them, then explore or rest at home.", "deliver":{}, "metrics":{"harvested":3}, "requires":["planting"], "coins":20, "flag":"harvest_table"},
 {"id":"garden", "title":"Colors for the village", "giver":"Flora & Fern", "text":"Bring 5 wildflowers to restore the flower bed in Village Park.", "deliver":{"flower":5}, "metrics":{}, "requires":["welcome"], "coins":18, "flag":"park_flowers"},
 {"id":"trade", "title":"Our first market day", "giver":"Milo the grocer", "text":"Earn 35 coins selling surplus produce at our fruit stall.", "deliver":{}, "metrics":{"earned":35}, "requires":["welcome"], "coins":15, "flag":"market_day"},
 {"id":"stall", "title":"Room for good things", "giver":"Swan", "text":"Buy the first fruit stall improvement at the market.", "deliver":{}, "metrics":{"upgrades":1}, "requires":["trade"], "coins":20, "flag":"shop_pride"},
 {"id":"guardians", "title":"The three guardians", "giver":"Elder Willow", "text":"Read all three guardian plaques. Their symbols open the garden shortcut.", "deliver":{}, "metrics":{"guardians":3}, "requires":[], "coins":20, "flag":"shortcut"},
 {"id":"home", "title":"Make it ours", "giver":"Hazel the maker", "text":"Place 2 different decorations inside the shared treehouse.", "deliver":{}, "metrics":{"decorated":2}, "requires":["welcome"], "coins":20, "flag":"home_warmth"},
 {"id":"together", "title":"A world worth returning to", "giver":"Our village", "text":"Finish the other 11 requests and visit every region. Come back to the board for a gathering.", "deliver":{}, "metrics":{"quests":11,"regions":13}, "requires":["welcome","fruit","fishing","care","planting","harvest","garden","trade","stall","guardians","home"], "coins":60, "flag":"festival"}
]
const NPCS = [
 {"id":"elder", "name":"Elder Willow", "p":Vector2(-3,-5), "color":"a58cb1", "line":"A village grows one small kindness at a time. I’ve left our requests at the board."},
 {"id":"thronn", "name":"Thronn", "p":Vector2(-7,36), "color":"6999a2", "line":"I saved a place for you two. Our animals like a gentle hello, a little food, and a good brushing."},
 {"id":"flora", "name":"Flora", "p":Vector2(25,-6), "color":"ce8e9f", "line":"The park could use five wildflowers. I’d love to see those colors beside the old tree."},
 {"id":"fern", "name":"Fern", "p":Vector2(33,-1), "color":"94aa72", "line":"I grow the practical things. Flora grows the unexpected things. Somehow the garden needs both."},
 {"id":"pippa", "name":"Pippa", "p":Vector2(31,14), "color":"cca45c", "line":"Plant a seed, give it water, and let time do the rest. Nothing here needs you to hurry."},
 {"id":"reed", "name":"Reed", "p":Vector2(-5,-25), "color":"799faf", "line":"Cast from the jetty. When the float bobs and the ring turns gold, press E to reel it in."},
 {"id":"milo", "name":"Milo", "p":Vector2(14,13), "color":"c08462", "line":"Your stall is ready. Choose a quantity before you sell. I’ll keep quest ingredients safe in your bag."},
 {"id":"hazel", "name":"Hazel", "p":Vector2(-31,22), "color":"b091ab", "line":"A room becomes a home a little at a time. Find decorations at the market, then place them at home."}
]
