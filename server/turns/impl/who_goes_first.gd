static func calculate_total_lp(battle_id: int, player_id: int):
	var player_formation = ServerVariables.battlefields[battle_id].formations[player_id]
	
	var player_az_lp = player_formation.az.get('current_lp') if player_formation.az != null else 0
	var player_sz1_lp = player_formation.sz1.get('current_lp') if player_formation.sz1 != null else 0
	var player_sz2_lp = player_formation.sz2.get('current_lp') if player_formation.sz2 != null else 0
	
	return player_az_lp + player_sz1_lp + player_sz2_lp
	
static func who_goes_first(
	player_1: int, 
	player_1_total_lp: int,
	player_2: int, 
	player_2_total_lp: int
):
	if player_1_total_lp < player_2_total_lp:
		return player_1
	if player_2_total_lp < player_1_total_lp:
		return player_2
		
	# Coin flip
	if randf() > 0.5:
		return player_1
	return player_2
