extends Node


@onready var player_az_start: Control = $BattleWindow/PlayerVivosaurPositions/AZStart
@onready var player_sz1_start: Control = $BattleWindow/PlayerVivosaurPositions/SZ1Start
@onready var player_sz2_start: Control = $BattleWindow/PlayerVivosaurPositions/SZ2Start

@onready var player_az: Control = $BattleWindow/PlayerVivosaurPositions/AZ
@onready var player_sz1: Control = $BattleWindow/PlayerVivosaurPositions/SZ1
@onready var player_sz2: Control = $BattleWindow/PlayerVivosaurPositions/SZ2
@onready var player_ez: Control = $BattleWindow/PlayerVivosaurPositions/EZ

@onready var opponent_az: Control = $BattleWindow/OpponentVivosaurPositions/AZ
@onready var opponent_sz1: Control = $BattleWindow/OpponentVivosaurPositions/SZ1
@onready var opponent_sz2: Control = $BattleWindow/OpponentVivosaurPositions/SZ2
@onready var opponent_ez: Control = $BattleWindow/OpponentVivosaurPositions/EZ

@onready var player_vivosaur1_sprite_btn: TextureButton = $BattleWindow/PlayerVivosaurPositions/VivosaurSpriteAZ
@onready var player_vivosaur2_sprite_btn: TextureButton = $BattleWindow/PlayerVivosaurPositions/VivosaurSpriteSZ1
@onready var player_vivosaur3_sprite_btn: TextureButton = $BattleWindow/PlayerVivosaurPositions/VivosaurSpriteSZ2

@onready var opponent_vivosaur1_sprite_btn: TextureButton = $BattleWindow/OpponentVivosaurPositions/VivosaurSpriteAZ
@onready var opponent_vivosaur2_sprite_btn: TextureButton = $BattleWindow/OpponentVivosaurPositions/VivosaurSpriteSZ1
@onready var opponent_vivosaur3_sprite_btn: TextureButton = $BattleWindow/OpponentVivosaurPositions/VivosaurSpriteSZ2

@onready var player_support_effects_img: TextureRect = $BattleWindow/PlayerSupportEffects
@onready var player_atk_modifier: Label = $BattleWindow/PlayerSupportEffects/Atk
@onready var player_def_modifier: Label = $BattleWindow/PlayerSupportEffects/Def
@onready var player_acc_modifier: Label = $BattleWindow/PlayerSupportEffects/Acc
@onready var player_eva_modifier: Label = $BattleWindow/PlayerSupportEffects/Eva

@onready var opponent_support_effects_img: TextureRect = $BattleWindow/OpponentSupportEffects
@onready var opponent_atk_modifier: Label = $BattleWindow/OpponentSupportEffects/Atk
@onready var opponent_def_modifier: Label = $BattleWindow/OpponentSupportEffects/Def
@onready var opponent_acc_modifier: Label = $BattleWindow/OpponentSupportEffects/Acc
@onready var opponent_eva_modifier: Label = $BattleWindow/OpponentSupportEffects/Eva

@onready var player_total_lp: TextureRect = $BattleWindow/PlayerTotalLp
@onready var player_total_lp_finish: Control = $BattleWindow/PlayerTotalLpFinish
@onready var opponent_total_lp: TextureRect = $BattleWindow/OpponentTotalLp
@onready var opponent_total_lp_finish: Control = $BattleWindow/OpponentTotalLpFinish

@onready var player_turn: Control = $BattleWindow/PlayerTurn
@onready var player_turn_start: Control = $BattleWindow/PlayerTurnStart
@onready var player_icon: TextureRect = $BattleWindow/PlayerTurn/Icon
@onready var player_name: Label = $BattleWindow/PlayerTurn/Name

@onready var opponent_turn: Control = $BattleWindow/OpponentTurn
@onready var opponent_turn_start: Control = $BattleWindow/OpponentTurnStart
@onready var opponent_icon: TextureRect = $BattleWindow/OpponentTurn/Icon
@onready var opponent_name: Label = $BattleWindow/OpponentTurn/Name

@onready var player_fp_bg: TextureRect = $BattleWindow/PlayerFPBg
@onready var player_fp: Label = $BattleWindow/PlayerFP
@onready var player_fp_delta: Label = $BattleWindow/PlayerFPDelta

@onready var opponent_fp_bg: TextureRect = $BattleWindow/OpponentFPBg
@onready var opponent_fp: Label = $BattleWindow/OpponentFP
@onready var opponent_fp_delta: Label = $BattleWindow/OpponentFPDelta

@onready var vivosaur_summary = $ColorRect/VivosaurSummary
@onready var skills_container: VBoxContainer = $SkillScreen/ScrollContainer/SkillsContainer

@onready var skill_back: TextureButton = $BattleWindow/Back
@onready var skill_ok: TextureButton = $BattleWindow/Ok
