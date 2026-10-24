extends Node
class_name BattlingComponent

func notify_ending_turn() -> void:
	ServerRPCs.end_turn.rpc_id(
		Networking.SERVER_PEER_ID,
		Networking.battle_id
	)

func notify_skill_used(initiator_zone: PlayerZone.Zone, skill_id: String, target_player_id: int, target_zone: PlayerZone.Zone = PlayerZone.Zone.EZ) -> void:
	ServerRPCs.use_skill.rpc_id(
		Networking.SERVER_PEER_ID,
		Networking.battle_id,
		initiator_zone,
		skill_id,
		target_player_id,
		target_zone,
	)

func notify_swap_to_ez(target_zone: PlayerZone.Zone) -> void:
	ServerRPCs.swap_to_ez.rpc_id(
		Networking.SERVER_PEER_ID,
		Networking.battle_id,
		target_zone
	)
