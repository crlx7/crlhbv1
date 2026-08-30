class_name CareerPlayer
extends RefCounted
var first_name := ""
var last_name := ""
var nickname := ""
var nationality := "Brasil"
var position := "Centroavante"
var archetype := "Finalizador"
var age := 17
var overall := 58
var potential := 84
var energy := 88
var morale := 70
var coach_trust := 45
var fame := 4
var money := 1200
var market_value := 250000
var club := "Aurora FC Sub-20"
var shirt_number := 9
var stats := {"matches": 0, "goals": 0, "assists": 0, "minutes": 0, "rating_total": 0.0}
var attributes := {"finalizacao": 64, "passe": 55, "drible": 58, "velocidade": 62, "resistencia": 57, "forca": 54, "visao": 52, "posicionamento": 60, "defesa": 35, "reflexos": 20}
func display_name() -> String: return (first_name + " " + last_name).strip_edges() if not first_name.is_empty() else "Sua Promessa"
func average_rating() -> float: return 0.0 if stats.matches == 0 else stats.rating_total / stats.matches
func to_data() -> Dictionary: return {"first_name": first_name, "last_name": last_name, "nickname": nickname, "nationality": nationality, "position": position, "archetype": archetype, "age": age, "overall": overall, "potential": potential, "energy": energy, "morale": morale, "coach_trust": coach_trust, "fame": fame, "money": money, "market_value": market_value, "club": club, "shirt_number": shirt_number, "stats": stats, "attributes": attributes}
static func from_data(data: Dictionary) -> CareerPlayer:
	var p := CareerPlayer.new()
	for key in data: p.set(key, data[key])
	return p
