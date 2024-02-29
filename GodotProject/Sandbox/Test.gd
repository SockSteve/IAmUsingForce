extends StaticBody3D
class_name Test

var number: int = 0
var save = SaveRes.new()

func _ready():
	if ResourceLoader.exists("res://Savegame/save_test.tres"):
		var test = load("res://Savegame/save_test.tres") as SaveRes
		number = test.test
		$subtest.another_number = test.test2
		$Label3D.text = str(number)
		$Label3D2.text = str($subtest.another_number)

func _on_area_3d_body_entered(body):
	number += 1
	$Label3D.text = str(number)
	$subtest.another_number += 1
	$Label3D2.text = str($subtest.another_number)
	save.test = number 
	save.test2 = $subtest.another_number
	
	print(save.test)
	print(save.test2)



func _on_area_3d_body_exited(body):
	print(ResourceSaver.save(save,"res://Savegame/save_test.tres"))
