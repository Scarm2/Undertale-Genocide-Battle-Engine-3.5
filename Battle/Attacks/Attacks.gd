extends CanvasLayer

var attack: = 0

onready var attacks: Dictionary = {
	"intro" : preload("res://Battle/Attacks/Scripts/intro.gd"),
	"bonegap" : preload("res://Battle/Attacks/Scripts/bonegap.gd"),
	"platformtest" : preload("res://Battle/Attacks/Scripts/platformtest.gd"),
	"randomblaster" : preload("res://Battle/Attacks/Scripts/randomblaster.gd"),
	"bonestabtest" : preload("res://Battle/Attacks/Scripts/bonestabtest.gd"),
	"platformblaster" : preload("res://Battle/Attacks/Scripts/platformblaster.gd"),
}

onready var playerHeart: = $"../HeartLayer/PlayerHeart"
onready var border: = $"../BorderLayer/Border"
onready var camera = $"../Camera"

signal menuEnable
signal startAttack


func _process(delta: float) -> void:
	$BackBufferCopy/Mask/Top.scale = camera.zoom * 200.0
	$BackBufferCopy/Mask/Top.position = border.get_node("CornerTop").global_position
	$BackBufferCopy/Mask/Top.rotation = border.get_node("CornerTop").global_rotation
	
	$BackBufferCopy/Mask/Bottom.scale = camera.zoom * 200.0
	$BackBufferCopy/Mask/Bottom.position = border.get_node("CornerBottom").global_position
	$BackBufferCopy/Mask/Bottom.rotation = border.get_node("CornerBottom").global_rotation


func runAttack():
	for n in get_tree().get_nodes_in_group("MenuBone"): if "terminate" in n: n.terminate = true
	for n in get_tree().get_nodes_in_group("MenuBoneBottomMaker"): n.terminate = true
	
	for n in border.get_node("Collisions").get_children(): if n is CollisionShape2D: n.disabled = false
	
	match attack:
		0,4: heartBorder(Vector2(320, 304), 240, 225, 405, 390)
		1,2,5: heartBorder(Vector2(320, 376), 132, 250, 507, 390)
		3: heartBorder(Vector2(320, 304), 120, 185, 525, 390)
	
	if len(get_tree().get_nodes_in_group("SpeechBubble")) == 0: call_deferred("emit_signal", "startAttack")
	yield(self, "startAttack")
	
	yield(border, "resizeFinished")
	
	match attack:
		0: createAttack(attacks["intro"])
		1: createAttack(attacks["bonegap"])
		2: createAttack(attacks["platformtest"])
		3: createAttack(attacks["randomblaster"])
		4: createAttack(attacks["bonestabtest"])
		5: createAttack(attacks["platformblaster"])


func createAttack(Attack):
	var i = Node.new()
	i.set_script(Attack)
	
	var VarDicts = {
		"border": border,
		"playerHeart": playerHeart,
		"bullets": $Bullets,
	}
	var KeyValues = [VarDicts.keys(), VarDicts.values()]
	
	for n in len(VarDicts): if KeyValues[0][n] in i: i.set(KeyValues[0][n], KeyValues[1][n])
	
	i.connect("endAttack", self, "endAttack")
	
	i.add_to_group("Attack")
	
	add_child(i)


func endAttack():
	for n in get_tree().get_nodes_in_group("Bullet"): n.queue_free()
	for n in get_tree().get_nodes_in_group("Attack"): n.queue_free()
	
	playerHeart.changeMode(0)
	
	for n in border.get_node("Collisions").get_children(): if n is CollisionShape2D: n.disabled = true
	border.changeSize(32, 607, 250, 390, 480)
	yield(border, "resizeFinished")
	emit_signal("menuEnable")


func heartBorder(HeartPos, BorderLeft, BorderTop, BorderRight, BorderBottom):
	playerHeart.position = HeartPos
	border.changeSize(BorderLeft, BorderRight, BorderTop, BorderBottom)
