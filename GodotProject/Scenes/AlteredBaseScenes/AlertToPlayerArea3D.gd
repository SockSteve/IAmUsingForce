"""
This Custom Class of the Area3D Node provides the following additions:
	- specified player detection
	- detection if player is in attack range
	- multyplayer support
The Node that uses this class should be a direct child of root or the desired 
detection origin. This class uses the global position of it's parent to determin
if any players are in attack range.
"""
class_name AlertToPlayerArea3D
extends Area3D

#is emitted when a player enters the area
signal player_entered(player:Player)
#is emitted when a player leaves the area
signal player_exited(player:Player)
#is emitted when a player enters the attack range
signal player_entered_attack_range(player:Player)
#is emitted when a player leaves the attack range
signal player_exited_attack_range(player:Player)
#is emitted when multiple players are in range and the closest player to this nodes parent changes
signal closest_player_changed_to(player:Player)

#determines the distance in which the parenct should attack the player
@export var attack_range: float = 2.0

var _closest_player: Player = null
var detected_players: Array = []
var bool_player_in_attack_range: bool = false

"""
function is used for connecting the following signals from area3d to custom signals
connects :
	from area3d - @signal body_entered - to - @signal player_entered
	from area3d - @signal body_exited - to - @signal player_exited
"""
func _ready():
	body_entered.connect(player_entered_area)
	body_exited.connect(player_exited_area)
	return


"""
function is used for detecting if player is in attack range
emits:
	- @signal player_entered_attack_range -  when player gets in attack range
	- @signal player_exited_attack_range - when player left the attack range
"""
func _physics_process(delta):
	if detected_players.is_empty():
		return
	
	_closest_player = get_closest_player()
	
	if not bool_player_in_attack_range:
		if attack_range >= _closest_player.global_position.distance_to(get_parent().global_position):
			bool_player_in_attack_range = true
			emit_signal("player_entered_attack_range", _closest_player)
		
	if bool_player_in_attack_range:
		if attack_range < _closest_player.global_position.distance_to(get_parent().global_position):
			bool_player_in_attack_range = false
			emit_signal("player_exited_attack_range", _closest_player)
	return

# function for getting the closest player to this nodes parent
func get_closest_player()->Player:
	if detected_players.is_empty():
		return null
	
	var closest_player = detected_players.front()
	if detected_players.size() == 1:
		return closest_player
	
	var closest_player_distance = closest_player.global_position.distance_to(get_parent().global_position)
	for player:Player in detected_players:
		if closest_player_distance > player.global_position.distance_to(get_parent().global_position):
			closest_player = player
			emit_signal("closest_player_changed_to", closest_player)
	
	return closest_player

# function for detecting how many players entered this area
func get_detected_player_amount()->int: 
	return detected_players.size()

"""
function for detecting a player that entered this area through the group "player"
emits @signal player_entered - with param @player
adds param @player to @param detected_players
"""
func player_entered_area(player)->void:
	if player.is_in_group("player"):
		detected_players.append(player)
		emit_signal("player_entered", player)

"""
function for detecting a player that exited this area through the group "player"
emits @signal player_exited - with param @player
removes param @player to @param detected_players
"""
func player_exited_area(player)->void:
	if player.is_in_group("player"):
		detected_players.erase(player)
		emit_signal("player_exited", player)
