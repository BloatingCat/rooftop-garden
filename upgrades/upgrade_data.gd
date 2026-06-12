class_name UpgradeData
extends Resource

enum UpgradeType { STAT, BUILDING }
enum CostCurrency { COINS, AURA, COINS_AND_AURA }

@export_group("Identity")
@export var id: String = ""
@export var title: String = ""
@export var description: String = ""

@export_group("Cost")
@export var cost_currency: CostCurrency = CostCurrency.COINS
@export var cost_coins: int = 0
@export var cost_aura: int = 0
@export var unlock_coins: int = 0
@export var unlock_aura: int = 0

@export_group("Type")
@export var upgrade_type: UpgradeType = UpgradeType.STAT
@export var building_scene: PackedScene = null
