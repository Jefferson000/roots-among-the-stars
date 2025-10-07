extends Control

#@onready var health_display = $MarginContainer/VBoxContainer/TopBar/HealthDisplay
@onready var coin_label = $VBoxContainer/ScoreLabel
@onready var score_label = $VBoxContainer/CoinLabel

var max_hearts = 3
var heart_textures = []

func _ready():
	#GameManager.health_changed.connect(update_health)
	GameManager.coins_changed.connect(update_coins)
	GameManager.score_changed.connect(update_score)
	#update_health(3)
	update_coins(0)
	update_score(0)

#func update_health(health: int):
	#for i in range(max_hearts):
		#var heart = health_display.get_child(i) as TextureRect
		#if health >= (i + 1) * 2:  # Full heart (2 health points per heart)
			#heart.texture = heart_textures[0]
		#elif health >= (i * 2) + 1:  # Half heart
			#heart.texture = heart_textures[1]
		#else:  # Empty heart
			#heart.texture = heart_textures[2]

func update_coins(coins: int):
	coin_label.text = "Coins: " + str(coins)

func update_score(score: int):
	score_label.text = "Score: " + str(score)
