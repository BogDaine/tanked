class_name TeamScoreUI

extends Control

@export var score0 = 0
@export var score1 = 0
@export var scores_changed:bool = false

#TODO:
#maybe only share scores, not labels too idk
#make this more elegant ig

@rpc("authority", "call_local", "reliable")
func add_points(pts:int, team:int):
	scores_changed = true
	if team == 0:
		score0 += pts
	else:
		score1 += pts
	update_scorelabels()
	
func update_scorelabels():
	%ScoreLabel1.text = str(score0)
	%ScoreLabel2.text = str(score1)

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if scores_changed:
		scores_changed = false
		
