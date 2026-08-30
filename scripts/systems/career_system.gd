extends Node
signal changed
var player: CareerPlayer
var week := 1
var season := "2028/29"
var news: Array[String] = []
var fixture := {"opponent": "Atlético Verde", "competition": "Liga Jovem", "home": true}
var clubs := ["Aurora FC", "Atlético Verde", "Costa Real", "Vila Norte", "Estrela do Sul"]
func new_career(data: Dictionary) -> void:
	player = CareerPlayer.new(); player.first_name = data.get("first_name", ""); player.last_name = data.get("last_name", ""); player.nickname = data.get("nickname", ""); player.nationality = data.get("nationality", "Brasil"); player.position = data.get("position", "Centroavante"); player.archetype = data.get("archetype", "Finalizador")
	_apply_archetype(); add_news("Todo jogador começa com um sonho. Sua jornada no %s começou." % player.club); _save(); changed.emit()
func _apply_archetype() -> void:
	if player.archetype == "Velocista": player.attributes.velocidade += 8
	elif player.archetype == "Armador": player.attributes.passe += 8; player.attributes.visao += 7
	elif player.archetype == "Zagueiro físico": player.attributes.defesa += 10; player.attributes.forca += 8
	elif player.archetype == "Goleiro-linha": player.attributes.reflexos += 20; player.attributes.passe += 6
	else: player.attributes.finalizacao += 8; player.attributes.posicionamento += 5
	_recalculate_overall()
func train(intensity: String) -> Dictionary:
	var cost := {"Leve": 4, "Equilibrado": 9, "Intenso": 16}[intensity]; var gain := {"Leve": 1, "Equilibrado": 2, "Intenso": 4}[intensity]
	if player.energy < cost: return {"ok": false, "text": "Energia insuficiente. Escolha descanso."}
	player.energy -= cost; var focus := _focus_attribute(); player.attributes[focus] = min(100, player.attributes[focus] + gain); player.morale = min(100, player.morale + 1)
	if intensity == "Intenso" and randf() < 0.13: player.energy = max(0, player.energy - 12); add_news("Você sentiu fadiga no treino intenso. A comissão recomendou recuperação.")
	_recalculate_overall(); add_news("Treino %s: +%d em %s." % [intensity.to_lower(), gain, focus.capitalize()]); _save(); changed.emit(); return {"ok": true, "text": "Treino concluído! %s melhorou." % focus.capitalize()}
func rest() -> void:
	player.energy = min(100, player.energy + 20); player.morale = min(100, player.morale + 2); add_news("Dia de recuperação concluído. Energia restaurada."); _save(); changed.emit()
func play_match(choice: String = "Simular") -> Dictionary:
	var power := player.overall + player.morale * 0.12 + player.energy * 0.08 + randf_range(-10, 10); var team_goals := clampi(roundi(power / 28.0 + randf_range(-1, 2)), 0, 5); var opposition := clampi(roundi(2.2 + randf_range(-1.3, 1.6)), 0, 5)
	var goal_chance := (player.attributes.finalizacao + player.attributes.posicionamento + player.overall) / 300.0
	if choice == "Chutar": goal_chance += 0.12
	elif choice == "Passar": goal_chance -= 0.08
	var goals := 1 if randf() < goal_chance else 0
	if player.position.contains("Meia") or player.position.contains("Ponta"): goals = 1 if randf() < goal_chance * 0.7 else 0
	goals = min(goals, team_goals); var assists := 1 if choice == "Passar" and randf() < 0.45 else 0; var rating: float = clampf(5.7 + goals * 1.35 + assists * 0.8 + (1.0 if team_goals > opposition else -0.45) + randf_range(-0.8, 0.8), 3.0, 10.0)
	player.stats.matches += 1; player.stats.minutes += 90; player.stats.goals += goals; player.stats.assists += assists; player.stats.rating_total += rating; player.energy = max(0, player.energy - 18); player.morale = clampi(player.morale + (4 if rating >= 7 else -3), 0, 100); player.coach_trust = clampi(player.coach_trust + (4 if rating >= 7 else -2), 0, 100); player.fame = min(100, player.fame + goals * 2 + (1 if rating >= 8 else 0)); player.market_value += goals * 25000 + roundi(rating * 1200); week += 1
	add_news("%s %d x %d %s — nota %.1f%s" % [player.club, team_goals, opposition, fixture.opponent, rating, "; você marcou!" if goals > 0 else ""]); if player.coach_trust >= 60: add_news("O treinador elogiou sua evolução e sinalizou mais minutos.")
	_save(); changed.emit(); return {"score": "%d x %d" % [team_goals, opposition], "goals": goals, "assists": assists, "rating": rating}
func offer_transfer() -> Dictionary:
	return {"club": clubs.pick_random(), "salary": 1800 + player.overall * 32 + player.fame * 20, "role": "Rotação" if player.coach_trust < 60 else "Titular em desenvolvimento", "length": 3}
func accept_offer(offer: Dictionary) -> void:
	player.club = offer.club; player.money += offer.salary; player.coach_trust = 50; player.fame += 2; add_news("Transferência confirmada: %s assinou com %s." % [player.display_name(), player.club]); _save(); changed.emit()
func add_news(text: String) -> void:
	news.push_front("Semana %d — %s" % [week, text]); if news.size() > 12: news.pop_back()
func _focus_attribute() -> String:
	if player.position == "Goleiro": return "reflexos"
	if player.position.contains("Zagueiro") or player.position.contains("Lateral"): return "defesa"
	if player.position.contains("Meia"): return "passe"
	return "finalizacao"
func _recalculate_overall() -> void:
	var keys := ["reflexos"] if player.position == "Goleiro" else ["defesa", "forca", "posicionamento"] if player.position.contains("Zagueiro") else ["passe", "visao", "drible"] if player.position.contains("Meia") else ["finalizacao", "velocidade", "posicionamento"]; var total := 0
	for key in keys: total += player.attributes[key]
	player.overall = clampi(roundi(total / keys.size() * 0.8 + player.age * 0.5), 40, player.potential)
func _save() -> void: SaveGame.save({"player": player.to_data(), "week": week, "season": season, "news": news})
func restore() -> bool:
	var data := SaveGame.load_save(); if data.is_empty(): return false
	player = CareerPlayer.from_data(data.player); week = data.week; season = data.season; news.assign(data.news); changed.emit(); return true
