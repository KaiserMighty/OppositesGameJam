extends Area2D

export var HurtBoxType = 0
onready var collision = $CollisionShape2D
onready var disableTimer = $DisableTimer

signal hurt(damage, angle, knockback)

var hitOnceArray = []

func _on_HurtBox_area_entered(area):
	if area.is_in_group("Attack"):
		if not area.get("damage") == null:
			match HurtBoxType:
				0: #Cooldown
					collision.call_deferred("set", "disabled", true)
					disableTimer.start()
				1: #HitOnce
					if hitOnceArray.has(area) == false:
						hitOnceArray.append(area)
						if area.has_signal("removeFromArray"):
							if not area.is_connected("removeFromArray", self, "removeFromList"):
								area.connect("removeFromArray", self, "removeFromList")
					else:
						return
				2: #DisableHitBox
					if area.has_method("tempDisable"):
						area.tempDisable()
			var damage = area.damage
			var angle = Vector2.ZERO
			var knockback = 1
			if not area.get("angle") == null:
				angle = area.angle
			if not area.get("knockback") == null:
				knockback = area.knockback
			
			emit_signal("hurt", damage, angle, knockback)
			if area.has_method("enemyHit"):
				area.enemyHit(1)

func removeFromList(object):
	if hitOnceArray.has(object):
		hitOnceArray.erase(object)


func _on_DisableTimer_timeout():
	collision.call_deferred("set", "disabled", false)
