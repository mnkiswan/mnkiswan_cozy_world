class_name CharacterVisual
extends Node3D
## Procedural articulated 3D interpretation; source portraits are retained unmodified.
const S = preload("res://scripts/shapes.gd")
var kind = "mnki"
var tint = "8b9c79"
var body: Node3D
var head: Node3D
var arms: Array[Node3D] = []
var legs: Array[Node3D] = []
var wings: Array[Node3D] = []
var tail: Node3D
var phase = 0.0
var reaction = 0.0

func _ready() -> void:
	body = Node3D.new()
	add_child(body)
	var swan = kind == "swan"
	var mnki = kind == "mnki"
	var skin = "e9b58d"
	var hair = "513128"
	var cloth = "f7f1e2" if swan else ("d9473e" if mnki else tint)
	S.ball(body,Vector3(0,0.94,0),Vector3(0.65,0.72,0.43),cloth)
	S.ball(body,Vector3(0,1.21,-0.12),Vector3(0.65,0.35,0.40),cloth)
	for side in [-1,1]:
		var arm = Node3D.new()
		arm.position = Vector3(side*0.34,1.13,0)
		body.add_child(arm)
		S.ball(arm,Vector3(side*0.075,-0.17,0),Vector3(0.25,0.45,0.28),cloth)
		S.ball(arm,Vector3(side*0.1,-0.39,0.025),Vector3(0.20,0.20,0.19),skin)
		arms.append(arm)
		var leg = Node3D.new()
		leg.position = Vector3(side*0.18,0.64,0)
		body.add_child(leg)
		S.ball(leg,Vector3(0,-0.22,0),Vector3(0.26,0.48,0.28),skin if swan else "302b2a")
		if swan: S.cylinder(leg,Vector3(0,-0.37,0),0.105,0.18,"f7f2e8")
		else: S.box(leg,Vector3(side*0.11,-0.15,0.015),Vector3(0.08,0.18,0.19),"3a302c")
		S.ball(leg,Vector3(0,-0.49,0.09),Vector3(0.30,0.18,0.49),"fff4e4")
		S.ball(leg,Vector3(0,-0.44,0.06),Vector3(0.28,0.20,0.40),"5488ae" if swan else ("c7453b" if mnki else "665544"))
		S.ball(leg,Vector3(0,-0.46,0.23),Vector3(0.28,0.13,0.18),"fff9ef")
		for z in [0.02,0.08,0.14]: S.rod(leg,Vector3(-0.07,-0.336,z),Vector3(0.07,-0.336,z+0.025),0.012,"f7f1e2")
		legs.append(leg)
	if swan:
		S.cylinder(body,Vector3(0,0.63,0),0.43,0.29,"e7a1b4",0.27)
		for i in range(14):
			var a = i*TAU/14
			S.rod(body,Vector3(sin(a)*0.28,0.77,cos(a)*0.28),Vector3(sin(a)*0.43,0.50,cos(a)*0.43),0.015,"f5bac8")
	else:
		S.ball(body,Vector3(0,0.88,0.22),Vector3(0.33,0.22,0.05),"c64037" if mnki else tint)
	for side in [-1,1]:
		S.rod(body,Vector3(side*0.1,1.23,0.2),Vector3(side*0.13,0.97,0.25),0.013,"f3dfbd" if swan else "57382e")
		if swan: S.ball(body,Vector3(side*0.13,0.95,0.25),Vector3.ONE*0.11,"fff8eb")
	if mnki:
		S.ball(body,Vector3(0,1.0,0.231),Vector3(0.25,0.25,0.05),"815039")
		for side in [-1,1]: S.ball(body,Vector3(side*0.12,1.01,0.24),Vector3(0.10,0.11,0.05),"946144")
		S.ball(body,Vector3(0,0.98,0.265),Vector3(0.19,0.16,0.035),"f0ca92")
		for side in [-1,1]: S.ball(body,Vector3(side*0.04,1.015,0.29),Vector3(0.028,0.035,0.018),"47302a")
		tail = Node3D.new()
		tail.name = "CurledMonkeyTail"
		body.add_child(tail)
		var points = [Vector3(0,0.68,-0.17),Vector3(0.1,0.65,-0.5),Vector3(0.42,0.78,-0.68),Vector3(0.7,1.03,-0.63)]
		for i in range(17):
			var a = -0.55+float(i)/16.0*PI*1.7
			points.append(Vector3(0.68+sin(a)*0.23,1.24-cos(a)*0.23,-0.63))
		S.tube(tail,points,0.075,"805139")
	if swan:
		for side in [-1,1]:
			var wing = Node3D.new()
			wing.name = "FeatherWing"
			wing.position = Vector3(side*0.23,1.06,-0.23)
			body.add_child(wing)
			for i in range(5):
				var feather = S.ball(wing,Vector3(side*(0.18+i*0.08),0.09-i*0.075,-0.08-i*0.015),Vector3(0.54,0.19,0.17),"fff8ed")
				feather.rotation.z = side*(0.4+i*0.18)
			wings.append(wing)
		for side in [-1,1]:
			for i in range(6):
				var lock = S.ball(body,Vector3(side*(0.30+sin(i*1.8)*0.05),1.30-i*0.12,-0.12),Vector3(0.30,0.40,0.33),"684231" if i%2==0 else hair)
				lock.rotation.z = side*0.25
		for i in range(5): S.ball(body,Vector3((i-2)*0.14,0.92,-0.31),Vector3(0.26,0.90,0.27),hair)
	head = Node3D.new()
	head.position.y = 1.66
	body.add_child(head)
	S.ball(head,Vector3(0,0.10,-0.02),Vector3(0.94,0.91,0.79),"fcf5e9" if swan else hair)
	S.ball(head,Vector3(0,-0.02,0.13),Vector3(0.75,0.70,0.65),skin)
	for side in [-1,1]:
		S.ball(head,Vector3(side*0.365,-0.03,0.05),Vector3(0.17,0.22,0.16),skin)
		S.ball(head,Vector3(side*0.16,0.005,0.425),Vector3(0.155,0.20,0.043),"533528")
		S.ball(head,Vector3(side*0.15,-0.015,0.451),Vector3(0.085,0.12,0.021),"352b26")
		S.ball(head,Vector3(side*0.15-0.025,0.047,0.465),Vector3(0.042,0.045,0.02),"fff6e8")
		S.ball(head,Vector3(side*0.25,-0.12,0.40),Vector3(0.16,0.07,0.025),"dd9681")
	S.ball(head,Vector3(0,-0.09,0.46),Vector3(0.06,0.07,0.06),"e2a77e")
	var smile = []
	for i in range(9):
		var x = (i-4)*0.022
		smile.append(Vector3(x,-0.18+pow(x/0.09,2)*0.04,0.441))
	S.tube(head,smile,0.012,"864a38")
	if swan:
		for side in [-1,1]:
			S.ball(head,Vector3(side*0.39,0.02,0.05),Vector3(0.22,0.68,0.43),"fff6e7")
			S.ball(head,Vector3(side*0.24,0.36,0.31),Vector3(0.09,0.05,0.04),"50362e")
		S.ball(head,Vector3(0,0.43,0.36),Vector3(0.32,0.13,0.28),"ec983e")
		var crown = Node3D.new()
		crown.name = "SmallGoldCrown"
		crown.position = Vector3(0.17,0.53,-0.06)
		crown.rotation.z = -0.18
		head.add_child(crown)
		S.cylinder(crown,Vector3.ZERO,0.13,0.1,"edbd55")
		for i in range(3):
			var x = (i-1)*0.085
			S.cylinder(crown,Vector3(x,0.11,0),0.055,0.20,"edbd55",0)
			S.ball(crown,Vector3(x,0.22,0),Vector3.ONE*0.045,"f8d176")
		for i in range(5):
			var bang = S.ball(head,Vector3((i-2)*0.13,0.18,0.34),Vector3(0.21,0.35,0.18),hair)
			bang.rotation.z = (i-2)*0.15
	else:
		for i in range(12):
			var a = i*TAU/12
			var tuft = S.ball(head,Vector3(sin(a)*0.35,0.17+cos(a)*0.28,0.03),Vector3(0.37,0.35,0.50),"603d2c" if i%3==0 else hair)
			tuft.rotation.z = -a*0.6
		for i in range(5):
			var tuft = S.ball(head,Vector3((i-2)*0.14,0.22,0.35),Vector3(0.22,0.33,0.22),hair)
			tuft.rotation.z = -0.3+(i-2)*0.1
		# Rounded locks continue around the back so the silhouette stays fluffy.
		for i in range(9):
			var a = i*TAU/9
			var tuft = S.ball(head,Vector3(sin(a)*0.31,0.14+cos(a)*0.25,-0.30),Vector3(0.31,0.31,0.26),hair)
			tuft.rotation.z = -a
		if mnki:
			S.tube(head,[Vector3(-0.38,0.17,0.27),Vector3(-0.26,0.29,0.38),Vector3(0,0.33,0.43),Vector3(0.26,0.29,0.38),Vector3(0.38,0.17,0.27)],0.033,"edb94c")
			for side in [-1,1]:
				var points = []
				for i in range(25):
					var a = float(i)/24*TAU*1.15
					var r = lerpf(0.115,0.019,float(i)/24)
					points.append(Vector3(side*(0.105+cos(a)*r),0.38+sin(a)*r,0.455))
				S.tube(head,points,0.025,"f3c65b")

func animate(delta: float, speed: float) -> void:
	phase += delta*(3.0+speed*2.2)
	reaction = maxf(0,reaction-delta)
	var amount = minf(speed/4.0,1.0)
	body.position.y = absf(sin(phase))*0.045*amount*(0.0 if State.settings.reduced_motion else 1.0)
	head.rotation.z = sin(phase*0.32)*(0.0 if State.settings.reduced_motion else 0.025)
	for i in range(2):
		legs[i].rotation.x = sin(phase+i*PI)*0.55*amount
		arms[i].rotation.x = sin(phase+(i+1)*PI)*0.4*amount
		arms[i].rotation.z = (1 if i==0 else -1)*(0.12+maxf(reaction,0)*0.65)
	if tail: tail.rotation.y = sin(phase*0.35)*0.12
	for i in wings.size(): wings[i].rotation.z = sin(phase*0.4)*0.08*(1 if i==0 else -1)
