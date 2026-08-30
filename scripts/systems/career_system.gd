extends Node

signal changed

const TRAINING_COST: Dictionary = {"Leve": 4, "Equilibrado": 9, "Intenso": 16}
const TRAINING_GAIN: Dictionary = {"Leve": 1, "Equilibrado": 2, "Intenso": 4}
const CLUBS: Array[String] = ["Aurora FC", "Atlético Verde", "Costa Real", "Vila Norte", "Estrela do Sul"]

var player: CareerPlayer
var week: int = 1
var season: String = "2028/29"
var news: Array[String] = []
var fixture: Dictionary = {"opponent": "Atlético Verde", "competition": "Liga Jovem", "home": true}

func new_career(data: Dictionary) -> void:
	player = CareerPlayer.new()
	player.first_name = str(data.get("first_name", ""))
	player.last_name = str(data.get("last_name", ""))
	player.nickname = str(data.get("nickname", ""))
	player.nationality = str(data.get("nationality", "Brasil"))
	player.position = str(data.get("position", "Centroavante"))
	player.archetype = str(data.get("archetype", "Finalizador"))
	_apply_archetype()
	add_news("Todo jogador começa com um sonho. Sua jornada no %s começou." % player.club)
	_save()
	changed.emit()

func train(intensity: String) -> Dictionary:
	var cost: int = int(TRAINING_COST.get(intensity, 9))
	var gain: int = int(TRAINING_GAIN.get(intensity, 2))
	if player.energy < cost:
		return {"ok": false, "text": "Energia insuficiente. Escolha descanso."}
	var focus: String = _focus_attribute()
	player.energy -= cost
	player.attributes[focus] = mini(100, int(player.attributes[focus]) + gain)
	player.morale = mini(100, player.morale + 1)
	if intensity == "Intenso" and randf() < 0.13:
		player.energy = maxi(0, player.energy - 12)
		add_news("Você sentiu fadiga no treino intenso. A comissão recomendou recuperação.")
	_recalculate_overall()
	add_news("Treino %s: +%d em %s." % [intensity.to_lower(), gain, focus.capitalize()])
	_save()
	changed.emit()
	return {"ok": true, "text": "Treino concluído! %s melhorou." % focus.capitalize()}

func rest() -> void:
	player.energy = mini(100, player.energy + 20)
	player.morale = mini(100, player.morale + 2)
	add_news("Dia de recuperação concluído. Energia restaurada.")
	_save()
	changed.emit()

func play_match(choice: String = "Simular") -> Dictionary:
	var power: float = player.overall + player.morale * 0.12 + player.energy * 0.08 + randf_range(-10.0, 10.0)
	var team_goals: int = clampi(roundi(power / 28.0 + randf_range(-1.0, 2.0)), 0, 5)
	var opposition_goals: int = clampi(roundi(2.2 + randf_range(-1.3, 1.6)), 0, 5)
	var goal_chance: float = (float(player.attributes["finalizacao"]) + float(player.attributes["posicionamento"]) + player.overall) / 300.0
	if choice == "Chutar":
		goal_chance += 0.12
	elif choice == "Passar":
		goal_chance -= 0.08
	var goals: int = 1 if randf() < goal_chance else 0
	if player.position.contains("Meia") or player.position.contains("Ponta"):
		goals = 1 if randf() < goal_chance * 0.7 else 0
	goals = mini(goals, team_goals)
	var assists: int = 1 if choice == "Passar" and randf() < 0.45 else 0
	var result_modifier: float = 1.0 if team_goals > opposition_goals else -0.45
	var rating: float = clampf(5.7 + goals * 1.35 + assists * 0.8 + result_modifier + randf_range(-0.8, 0.8), 3.0, 10.0)
	_update_after_match(goals, assists, rating)
	week += 1
	var opponent: String = str(fixture.get("opponent", "Adversário"))
	var scorer_note: String = "; você marcou!" if goals > 0 else ""
	add_news("%s %d x %d %s — nota %.1f%s" % [player.club, team_goals, opposition_goals, opponent, rating, scorer_note])
	if player.coach_trust >= 60:
		add_news("O treinador elogiou sua evolução e sinalizou mais minutos.")
	_save()
	changed.emit()
	return {"score": "%d x %d" % [team_goals, opposition_goals], "goals": goals, "assists": assists, "rating": rating}

func offer_transfer() -> Dictionary:
	var club_index: int = randi_range(0, CLUBS.size() - 1)
	return {"club": CLUBS[club_index], "salary": 1800 + player.overall * 32 + player.fame * 20, "role": "Rotação" if player.coach_trust < 60 else "Titular em desenvolvimento", "length": 3}

func accept_offer(offer: Dictionary) -> void:
	player.club = str(offer.get("club", player.club))
	player.money += int(offer.get("salary", 0))
	player.coach_trust = 50
	player.fame = mini(100, player.fame + 2)
	add_news("Transferência confirmada: %s assinou com %s." % [player.display_name(), player.club])
	_save()
	changed.emit()

func add_news(text: String) -> void:
	news.push_front("Semana %d — %s" % [week, text])
	if news.size() > 12:
		news.pop_back()

func _apply_archetype() -> void:
	match player.archetype:
		"Velocista": player.attributes["velocidade"] = int(player.attributes["velocidade"]) + 8
		"Armador":
			player.attributes["passe"] = int(player.attributes["passe"]) + 8
			player.attributes["visao"] = int(player.attributes["visao"]) + 7
		"Zagueiro físico":
			player.attributes["defesa"] = int(player.attributes["defesa"]) + 10
			player.attributes["forca"] = int(player.attributes["forca"]) + 8
		"Goleiro-linha":
			player.attributes["reflexos"] = int(player.attributes["reflexos"]) + 20
			player.attributes["passe"] = int(player.attributes["passe"]) + 6
		_:
			player.attributes["finalizacao"] = int(player.attributes["finalizacao"]) + 8
			player.attributes["posicionamento"] = int(player.attributes["posicionamento"]) + 5
	_recalculate_overall()

func _update_after_match(goals: int, assists: int, rating: float) -> void:
	player.stats["matches"] = int(player.stats["matches"]) + 1
	player.stats["minutes"] = int(player.stats["minutes"]) + 90
	player.stats["goals"] = int(player.stats["goals"]) + goals
	player.stats["assists"] = int(player.stats["assists"]) + assists
	player.stats["rating_total"] = float(player.stats["rating_total"]) + rating
	player.energy = maxi(0, player.energy - 18)
	player.morale = clampi(player.morale + (4 if rating >= 7.0 else -3), 0, 100)
	player.coach_trust = clampi(player.coach_trust + (4 if rating >= 7.0 else -2), 0, 100)
	player.fame = mini(100, player.fame + goals * 2 + (1 if rating >= 8.0 else 0))
	player.market_value += goals * 25000 + roundi(rating * 1200.0)

func _focus_attribute() -> String:
	if player.position == "Goleiro":
		return "reflexos"
	if player.position.contains("Zagueiro") or player.position.contains("Lateral"):
		return "defesa"
	if player.position.contains("Meia"):
		return "passe"
	return "finalizacao"

func _recalculate_overall() -> void:
	var keys: Array[String] = ["finalizacao", "velocidade", "posicionamento"]
	if player.position == "Goleiro":
		keys = ["reflexos"]
	elif player.position.contains("Zagueiro"):
		keys = ["defesa", "forca", "posicionamento"]
	elif player.position.contains("Meia"):
		keys = ["passe", "visao", "drible"]
	var total: int = 0
	for key: String in keys:
		total += int(player.attributes[key])
	player.overall = clampi(roundi(float(total) / float(keys.size()) * 0.8 + player.age * 0.5), 40, player.potential)

func _save() -> void:
	SaveGame.save({"player": player.to_data(), "week": week, "season": season, "news": news})

func restore() -> bool:
	var data: Dictionary = SaveGame.load_save()
	if data.is_empty() or not data.has("player"):
		return false
	player = CareerPlayer.from_data(data.get("player", {}) as Dictionary)
	week = int(data.get("week", 1))
	season = str(data.get("season", "2028/29"))
	news.clear()
	for item: Variant in data.get("news", []):
		news.append(str(item))
	changed.emit()
	return true
