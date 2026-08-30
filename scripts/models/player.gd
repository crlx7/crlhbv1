class_name CareerPlayer
extends RefCounted

var first_name: String = ""
var last_name: String = ""
var nickname: String = ""
var nationality: String = "Brasil"
var position: String = "Centroavante"
var archetype: String = "Finalizador"
var age: int = 17
var overall: int = 58
var potential: int = 84
var energy: int = 88
var morale: int = 70
var coach_trust: int = 45
var fame: int = 4
var money: int = 1200
var market_value: int = 250000
var club: String = "Aurora FC Sub-20"
var shirt_number: int = 9
var stats: Dictionary = {"matches": 0, "goals": 0, "assists": 0, "minutes": 0, "rating_total": 0.0}
var attributes: Dictionary = {"finalizacao": 64, "passe": 55, "drible": 58, "velocidade": 62, "resistencia": 57, "forca": 54, "visao": 52, "posicionamento": 60, "defesa": 35, "reflexos": 20}

func display_name() -> String:
	var full_name: String = (first_name + " " + last_name).strip_edges()
	return full_name if not full_name.is_empty() else "Sua Promessa"

func average_rating() -> float:
	var matches: int = int(stats.get("matches", 0))
	return 0.0 if matches == 0 else float(stats.get("rating_total", 0.0)) / float(matches)

func to_data() -> Dictionary:
	return {"first_name": first_name, "last_name": last_name, "nickname": nickname, "nationality": nationality, "position": position, "archetype": archetype, "age": age, "overall": overall, "potential": potential, "energy": energy, "morale": morale, "coach_trust": coach_trust, "fame": fame, "money": money, "market_value": market_value, "club": club, "shirt_number": shirt_number, "stats": stats, "attributes": attributes}

static func from_data(data: Dictionary) -> CareerPlayer:
	var p: CareerPlayer = CareerPlayer.new()
	p.first_name = str(data.get("first_name", ""))
	p.last_name = str(data.get("last_name", ""))
	p.nickname = str(data.get("nickname", ""))
	p.nationality = str(data.get("nationality", "Brasil"))
	p.position = str(data.get("position", "Centroavante"))
	p.archetype = str(data.get("archetype", "Finalizador"))
	p.age = int(data.get("age", 17))
	p.overall = int(data.get("overall", 58))
	p.potential = int(data.get("potential", 84))
	p.energy = int(data.get("energy", 88))
	p.morale = int(data.get("morale", 70))
	p.coach_trust = int(data.get("coach_trust", 45))
	p.fame = int(data.get("fame", 4))
	p.money = int(data.get("money", 1200))
	p.market_value = int(data.get("market_value", 250000))
	p.club = str(data.get("club", "Aurora FC Sub-20"))
	p.shirt_number = int(data.get("shirt_number", 9))
	p.stats = data.get("stats", p.stats) as Dictionary
	p.attributes = data.get("attributes", p.attributes) as Dictionary
	return p
