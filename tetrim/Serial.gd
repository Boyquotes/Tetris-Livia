extends Node
const serial_res = preload("res://bin/gdserial.gdns")

var serial_port = serial_res.new()
var is_port_open = false
var msg =''

signal sinal_EsquerdaGo
signal sinal_DireitaGo
signal sinal_BaixoGo
signal sinal_GiroGo
signal sinal_Normal
signal sinal_Endoidou
signal soltei

func _ready():
	is_port_open = serial_port.open_port('COM3',115200)
	print(is_port_open)	
	
func _process(delta):
	if (is_port_open):
		var message = serial_port.read_text()
		if (message.length()>0):
			for i in message:
				if (i=='\n'):
					_text_interpreter(msg)
					msg=''
				else:
					msg+=i
					
	
func _text_interpreter(msg):	
	if msg == "EsquerdaGo":
		emit_signal("sinal_EsquerdaGo")
	
	elif msg == "DireitaGo":
		emit_signal("sinal_DireitaGo")
		
	elif msg == "BaixoGo":
		emit_signal("sinal_BaixoGo")
		
	elif msg == "GiroGo":
		emit_signal("sinal_GiroGo")
	
	elif msg == "Normal":
		emit_signal("sinal_Normal")
		
	elif msg == "Endoidou":
		emit_signal("sinal_Endoidou")
		
	elif msg == "solteiBaixo":
		emit_signal("soltei")
