extends Node3D
class_name CityGenerator

@export var archivo_zonas: String = "res://data/balvanera_barrio.geojson"

var map_loader: Node
var materials = {}

func _ready():
	map_loader = get_node("../MapLoader")
	_crear_materiales()
	generar_barrio_5_cuadras()

func _crear_materiales():
	materials["residencial"] = StandardMaterial3D.new()
	materials["residencial"].albedo_color = Color(0.85, 0.82, 0.75)
	
	materials["comercial"] = StandardMaterial3D.new()
	materials["comercial"].albedo_color = Color(0.9, 0.85, 0.4)
	
	materials["plaza"] = StandardMaterial3D.new()
	materials["plaza"].albedo_color = Color(0.2, 0.6, 0.2)
	
	materials["calle"] = StandardMaterial3D.new()
	materials["calle"].albedo_color = Color(0.25, 0.25, 0.25)

func generar_barrio_5_cuadras():
	var tamaño_cuadra = 80.0
	var ancho_calle = 10.0
	var num_cuadras = 5
	
	for x in range(-num_cuadras/2, num_cuadras/2 + 1):
		for z in range(-num_cuadras/2, num_cuadras/2 + 1):
			var pos_cuadra = Vector3(x * tamaño_cuadra, 0, z * tamaño_cuadra)
			
			if x != 0:
				_crear_calle(Vector3(x * tamaño_cuadra - tamaño_cuadra/2 + ancho_calle/2, 0.01, z * tamaño_cuadra), Vector3(ancho_calle, 0.1, tamaño_cuadra))
			
			if z != 0:
				_crear_calle(Vector3(x * tamaño_cuadra, 0.01, z * tamaño_cuadra - tamaño_cuadra/2 + ancho_calle/2), Vector3(tamaño_cuadra, 0.1, ancho_calle))
			
			if x == 0 and z == 0:
				_crear_plaza(pos_cuadra)
			else:
				_crear_manzana(pos_cuadra, x, z)

func _crear_calle(pos, tamano):
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = tamano
	mesh.mesh = box
	mesh.position = pos
	mesh.material_override = materials["calle"]
	add_child(mesh)
	
	var body = StaticBody3D.new()
	body.position = pos
	var shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = tamano
	shape.shape = box_shape
	body.add_child(shape)
	add_child(body)

func _crear_plaza(pos):
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(60, 0.2, 60)
	mesh.mesh = box
	mesh.position = pos
	mesh.position.y = 0.1
	mesh.material_override = materials["plaza"]
	add_child(mesh)
	
	for i in range(6):
		var árbol = MeshInstance3D.new()
		var cylinder = CylinderMesh.new()
		cylinder.top_radius = 0.5
		cylinder.bottom_radius = 0.8
		cylinder.height = 4
		árbol.mesh = cylinder
		árbol.position = pos + Vector3(randf_range(-20, 20), 2, randf_range(-20, 20))
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.1, 0.4, 0.1)
		árbol.material_override = mat
		add_child(árbol)

func _crear_manzana(pos, x, z):
	var es_comercial = randf() < 0.6
	var altura = randf_range(3, 8) * 4
	
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(50, altura, 50)
	mesh.mesh = box
	
	if es_comercial:
		mesh.material_override = materials["comercial"]
	else:
		mesh.material_override = materials["residencial"]
	
	mesh.position = pos
	mesh.position.y = altura / 2.0
	add_child(mesh)
	
	var body = StaticBody3D.new()
	body.position = Vector3(pos.x, altura / 2.0, pos.z)
	var shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(50, altura, 50)
	shape.shape = box_shape
	body.add_child(shape)
	add_child(body)
