extends CanvasLayer

var wallet: int = 0

func _ready():
	add_to_group("ui")
	$Control/WalletLabel.text = "0"

func add_money(amount: int):
	wallet += amount
	$Control/WalletLabel.text = str(wallet)
