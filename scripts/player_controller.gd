extends CharacterBody3D

const VELOCIDAD: float = 8.0
const VELOCIDAD_SALTO: float = 5.0
const GRAVEDAD: float = 15.0
const SENSIBILIDAD: float = 0.002

func _ready():
	print("Player cargado. Click para comenzar.")

func _physics_process(delta):
	# Gravedad
	if not is_on_floor():
		velocity.y -= GRAVEDAD * delta
	else:
		velocity.y = 0
	
	# Movimiento
	var input_z = Input.get_axis("ui_up", "ui_down")
	var input_x = Input.get_axis("ui_left", "ui_right")
	
	var direction = Vector3(input_x, 0, input_z)
	
	# Aplicar movimiento
	velocity.x = direction.x * VELOCIDAD
	velocity.z = direction.z * VELOCIDAD
	
	# Saltar
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = VELOCIDAD_SALTO
	
	move_and_slide()

func _input(event):
	# Mouse capturado
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			var camera = get_node_or_null("Camera3D")
			if camera:
				camera.rotation.y -= event.relative.x * SENSIBILIDAD
				camera.rotation.x -= event.relative.y * SENSIBILIDAD
				camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)
	
	# Click para capturar
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# ESC para soltar
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
