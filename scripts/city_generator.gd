extends Node3D
class_name CityGenerator

@export var archivo_zonas: String = "res://data/balvanera_barrio.geojson"

var map_loader: Node
var materials = {}
var modelo_residencial: Variant
var modelo_comercial: Variant
var modelos_adicionales: Array = []

func _ready():
	if has_node("../MapLoader"):
		map_loader = get_node("../MapLoader")
	_cargar_modelos()
	_crear_materiales()
	generar_barrio_5_cuadras()

func _cargar_modelos():
	if ResourceLoader.exists("res://modelos/edificio_residencial.glb"):
		modelo_residencial = load("res://modelos/edificio_residencial.glb")
			
	if ResourceLoader.exists("res://modelos/edificio_comercial.glb"):
		modelo_comercial = load("res://modelos/edificio_comercial.glb")
	
	var modelos = ["building-small-b.glb", "building-small-d.glb", "building-garage.glb"]
	for m in modelos:
		if ResourceLoader.exists("res://modelos/" + m):
			modelos_adicionales.append(load("res://modelos/" + m))

func _crear_materiales():
	materials["residencial"] = StandardMaterial3D.new()
	materials["residencial"].albedo_color = Color(0.85, 0.82, 0.75)
	
	materials["comercial_pared"] = StandardMaterial3D.new()
	materials["comercial_pared"].albedo_color = Color(0.9, 0.85, 0.4)
	
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
	
	_crear_monumento(pos)
	
	for i in range(6):
		var pos_arbol = pos + Vector3(randf_range(-20, 20), 0, randf_range(-20, 20))
		_crear_arbol(pos_arbol)

func _crear_arbol(pos):
	var árbol = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 0.5
	cylinder.bottom_radius = 0.8
	cylinder.height = 4
	árbol.mesh = cylinder
	árbol.position = Vector3(pos.x, 2, pos.z)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.1, 0.4, 0.1)
	árbol.material_override = mat
	add_child(árbol)
	
	var body = StaticBody3D.new()
	body.position = Vector3(pos.x, 2, pos.z)
	var shape = CollisionShape3D.new()
	var cylinder_shape = CylinderShape3D.new()
	cylinder_shape.radius = 0.8
	cylinder_shape.height = 4
	shape.shape = cylinder_shape
	body.add_child(shape)
	add_child(body)

func _crear_monumento(pos):
	var monumento = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(3, 3, 3)
	monumento.mesh = box
	monumento.position = Vector3(pos.x, 1.5, pos.z)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.7, 0.7, 0.7)
	monumento.material_override = mat
	add_child(monumento)
	
	var body = StaticBody3D.new()
	body.position = Vector3(pos.x, 1.5, pos.z)
	var shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(3, 3, 3)
	shape.shape = box_shape
	body.add_child(shape)
	add_child(body)
	
	_crear_rejas(pos)

func _crear_rejas(pos):
	var radio = 5.0
	var num_postes = 8
	
	for i in range(num_postes):
		var angulo = (i * PI * 2) / num_postes
		var x = pos.x + cos(angulo) * radio
		var z = pos.z + sin(angulo) * radio
		
		var poste = MeshInstance3D.new()
		var cylinder = CylinderMesh.new()
		cylinder.top_radius = 0.1
		cylinder.bottom_radius = 0.1
		cylinder.height = 2
		poste.mesh = cylinder
		poste.position = Vector3(x, 1, z)
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.3, 0.3, 0.3)
		poste.material_override = mat
		add_child(poste)

func _crear_manzana(pos, x, z):
	var tamaño_manzana = 50.0
	var num_edificios = 3
	var espacio_entre = tamaño_manzana / num_edificios
	var offset_inicial = -tamaño_manzana / 2.0 + espacio_entre / 2.0
	
	for i in range(num_edificios):
		for j in range(num_edificios):
			var pos_edificio = Vector3(
				pos.x + offset_inicial + i * espacio_entre,
				0,
				pos.z + offset_inicial + j * espacio_entre
			)
			var rotacion = _calcular_rotacion(i, j, num_edificios)
			_crear_edificio_en_posicion(pos_edificio, rotacion)

func _calcular_rotacion(i, j, num_edificios):
	var rot = 0.0
	if i == 0:
		rot = -PI / 2
	elif i == num_edificios - 1:
		rot = PI / 2
	elif j == 0:
		rot = PI
	elif j == num_edificios - 1:
		rot = 0
	else:
		rot = randf_range(0, PI * 2)
	return rot

var colores_edificios = [
	Color(0.9, 0.4, 0.4),
	Color(0.4, 0.6, 0.9),
	Color(0.9, 0.8, 0.4),
	Color(0.5, 0.8, 0.5),
	Color(0.8, 0.5, 0.8),
	Color(0.4, 0.9, 0.9),
	Color(0.9, 0.6, 0.5),
	Color(0.6, 0.5, 0.9)
]

func _crear_edificio_en_posicion(pos, rotacion):
	var es_comercial = randf() < 0.6
	var altura = randf_range(2, 6) * 4
	var color_elegido = colores_edificios.pick_random()
	
	var modelo_a_usar = null
	
	if modelos_adicionales.size() > 0 and randf() < 0.4:
		modelo_a_usar = modelos_adicionales.pick_random()
	elif es_comercial and modelo_comercial:
		modelo_a_usar = modelo_comercial
	elif modelo_residencial:
		modelo_a_usar = modelo_residencial
	
	if modelo_a_usar and modelo_a_usar is PackedScene:
		var edificio = modelo_a_usar.instantiate()
		edificio.position = pos
		edificio.rotation.y = rotacion
		_ajustar_escala(edificio, altura)
		_aplicar_color(edificio, color_elegido)
		_crear_colision_edificio(pos, altura)
		add_child(edificio)
	elif modelo_a_usar and modelo_a_usar is Mesh:
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = modelo_a_usar
		mesh_instance.position = pos
		mesh_instance.rotation.y = rotacion
		_ajustar_escala(mesh_instance, altura)
		_aplicar_color_mesh(mesh_instance, color_elegido)
		_crear_colision_edificio(pos, altura)
		add_child(mesh_instance)
	else:
		_crear_edificio_box(pos, altura, es_comercial, color_elegido, rotacion)

func _crear_colision_edificio(pos, altura):
	var body = StaticBody3D.new()
	body.position = Vector3(pos.x, altura / 2.0, pos.z)
	var shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(50, altura, 50)
	shape.shape = box_shape
	body.add_child(shape)
	add_child(body)

func _aplicar_color(objeto, color):
	for hijo in objeto.find_children("*", "MeshInstance3D"):
		if hijo is MeshInstance3D:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = color
			hijo.material_override = mat

func _aplicar_color_mesh(mesh_instance, color):
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mesh_instance.material_override = mat

func _ajustar_escala(objeto, altura):
	var escala = (altura / 4.0) * 3.0 + 0.5 + 0.4
	objeto.scale = Vector3(escala, escala, escala)

func _crear_edificio_box(pos, altura, es_comercial, color, rotacion):
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(50, altura, 50)
	mesh.mesh = box
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mesh.material_override = mat
	
	mesh.position = pos
	mesh.position.y = altura / 2.0
	mesh.rotation.y = rotacion
	add_child(mesh)
