class_name SoundNode
extends Node

func shoot():
	%Shoot_normal.play()
func explosion():
	%Explosion_normal.play()
func bounce():
	%Bounce1.play()
func out_of_bounds():
	%OutOfBounds1.play()
func split():
	%Split.play()
