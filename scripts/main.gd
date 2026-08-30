extends Control
const BG := Color("09151d")
const PANEL := Color("102731")
const ACCENT := Color("34d399")
const MUTED := Color("9eb4bd")
var page: VBoxContainer
var content: VBoxContainer
var modal: PanelContainer
var offer: Dictionary = {}

func _ready() -> void:
	seed(Time.get_unix_time_from_system())
	build_shell()
	if SaveGame.has_save() and Career.restore(): show_dashboard()
	else: show_landing()

func build_shell() -> void:
	var background := ColorRect.new(); background.color = BG; background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(background)
	page = VBoxContainer.new(); page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 24); page.add_theme_constant_override("separation", 14); add_child(page)

func clear() -> void:
	for child in page.get_children(): child.queue_free()

func label(text: String, size := 22, color := Color.WHITE) -> Label:
	var node := Label.new(); node.text = text; node.add_theme_font_size_override("font_size", size); node.add_theme_color_override("font_color", color); node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; return node
func button(text: String, action: Callable, tint := ACCENT) -> Button:
	var node := Button.new(); node.text = text; node.custom_minimum_size = Vector2(0, 58); node.add_theme_font_size_override("font_size", 18); node.add_theme_color_override("font_color", Color("062018")); node.add_theme_color_override("font_hover_color", Color.WHITE); var style := StyleBoxFlat.new(); style.bg_color = tint; style.corner_radius_top_left = 12; style.corner_radius_top_right = 12; style.corner_radius_bottom_left = 12; style.corner_radius_bottom_right = 12; node.add_theme_stylebox_override("normal", style); node.pressed.connect(action); return node
func card() -> VBoxContainer:
	var panel := PanelContainer.new(); var style := StyleBoxFlat.new(); style.bg_color = PANEL; style.corner_radius_top_left = 16; style.corner_radius_top_right = 16; style.corner_radius_bottom_left = 16; style.corner_radius_bottom_right = 16; style.content_margin_left = 18; style.content_margin_right = 18; style.content_margin_top = 16; style.content_margin_bottom = 16; panel.add_theme_stylebox_override("panel", style); page.add_child(panel); var box := VBoxContainer.new(); box.add_theme_constant_override("separation", 9); panel.add_child(box); return box
func add_spacer(height := 1) -> void: var space := Control.new(); space.custom_minimum_size.y = height; page.add_child(space)

func show_landing() -> void:
	clear(); add_spacer(120); page.add_child(label("CAREER", 58, ACCENT)); page.add_child(label("XI", 58, Color.WHITE)); page.add_child(label("Todo jogador começa com um sonho.\nQual será o seu?", 24, MUTED)); add_spacer(40)
	page.add_child(button("COMEÇAR CARREIRA", show_creator)); if SaveGame.has_save(): page.add_child(button("CONTINUAR CARREIRA", show_dashboard, Color("b1d8ff")))
	page.add_child(label("Experiência offline • Carreira procedural • Sem marcas reais", 14, MUTED))

func show_creator() -> void:
	clear(); page.add_child(label("Crie sua promessa", 34)); page.add_child(label("Sua origem molda o primeiro capítulo da carreira.", 17, MUTED)); var form := card()
	var first := LineEdit.new(); first.placeholder_text = "Nome"; form.add_child(first)
	var last := LineEdit.new(); last.placeholder_text = "Sobrenome"; form.add_child(last)
	var nation := OptionButton.new(); for item in ["Brasil", "Argentina", "Portugal", "França", "Japão", "Estados Unidos"]: nation.add_item(item); form.add_child(label("Nacionalidade", 16, MUTED)); form.add_child(nation)
	var position := OptionButton.new(); for item in ["Centroavante", "Ponta-direita", "Meia ofensivo", "Volante", "Zagueiro", "Lateral-direito", "Goleiro"]: position.add_item(item); form.add_child(label("Posição", 16, MUTED)); form.add_child(position)
	var archetype := OptionButton.new(); for item in ["Finalizador", "Velocista", "Armador", "Zagueiro físico", "Goleiro-linha"]: archetype.add_item(item); form.add_child(label("Arquétipo", 16, MUTED)); form.add_child(archetype)
	page.add_child(button("INICIAR JORNADA", func(): Career.new_career({"first_name": first.text, "last_name": last.text, "nationality": nation.get_item_text(nation.selected), "position": position.get_item_text(position.selected), "archetype": archetype.get_item_text(archetype.selected)}); show_dashboard()))

func header(title: String) -> void:
	var row := HBoxContainer.new(); page.add_child(row); var back := Button.new(); back.text = "‹"; back.add_theme_font_size_override("font_size", 32); back.pressed.connect(show_dashboard); row.add_child(back); row.add_child(label(title, 30));
func show_dashboard() -> void:
	clear(); var p := Career.player; page.add_child(label("CAREER XI", 25, ACCENT)); page.add_child(label(p.display_name().to_upper(), 31)); page.add_child(label("%s  •  %s  •  Semana %d" % [p.club, Career.season, Career.week], 16, MUTED))
	var hero := card(); hero.add_child(label("OVR %d" % p.overall, 42, ACCENT)); hero.add_child(label("%s  |  #%d  |  Valor €%s" % [p.position, p.shirt_number, str(p.market_value)], 16)); hero.add_child(label("Energia %d%%    Moral %d%%    Confiança %d%%" % [p.energy, p.morale, p.coach_trust], 17, MUTED))
	var match := card(); match.add_child(label("PRÓXIMA PARTIDA", 14, MUTED)); match.add_child(label("%s  ×  %s" % [p.club, Career.fixture.opponent], 22)); match.add_child(button("JOGAR PARTIDA", show_match, Color("b1d8ff")))
	var grid := GridContainer.new(); grid.columns = 2; page.add_child(grid)
	for item in [["Treinamento", show_training], ["Estatísticas", show_stats], ["Transferências", show_transfers], ["Notícias", show_news]]: grid.add_child(button(item[0], item[1], Color("d5edf0")))
	page.add_child(label("ÚLTIMA NOTÍCIA", 14, MUTED)); page.add_child(label(Career.news[0] if not Career.news.is_empty() else "O mundo do futebol está de olho em você.", 16))
func show_training() -> void:
	clear(); header("Treinamento"); page.add_child(label("Escolha sua carga semanal", 18, MUTED)); var box := card(); box.add_child(label("Seu foco: %s" % Career._focus_attribute().capitalize(), 19)); box.add_child(label("Treino intenso acelera a evolução, mas aumenta fadiga.", 15, MUTED))
	for intensity in ["Leve", "Equilibrado", "Intenso"]: page.add_child(button("TREINO " + intensity.to_upper(), func(): show_message(Career.train(intensity).text, show_training), Color("d5edf0")))
	page.add_child(button("DESCANSAR (+20 energia)", func(): Career.rest(); show_training(), Color("b1d8ff")))
func show_match() -> void:
	clear(); header("Dia de jogo"); page.add_child(label("%s" % Career.fixture.competition, 16, MUTED)); page.add_child(label("%s × %s" % [Career.player.club, Career.fixture.opponent], 28)); var box := card(); box.add_child(label("Momento decisivo", 22)); box.add_child(label("Você recebe a bola na entrada da área. Qual é a sua decisão?", 17, MUTED))
	for choice in ["Chutar", "Passar", "Driblar", "Simular"]: page.add_child(button(choice.to_upper(), func(): var result := Career.play_match(choice); show_message("Fim de jogo: %s\nNota %.1f • %d gol(s) • %d assistência(s)" % [result.score, result.rating, result.goals, result.assists], show_dashboard), Color("d5edf0")))
func show_stats() -> void:
	clear(); header("Estatísticas"); var p := Career.player; var box := card(); box.add_child(label("TEMPORADA %s" % Career.season, 16, MUTED)); box.add_child(label("%d jogos  •  %d min" % [p.stats.matches, p.stats.minutes], 22)); box.add_child(label("%d gols  •  %d assistências  •  nota média %.1f" % [p.stats.goals, p.stats.assists, p.average_rating()], 20, ACCENT)); var attrs := card(); attrs.add_child(label("ATRIBUTOS", 16, MUTED)); for key in p.attributes: attrs.add_child(label("%s  %d" % [key.capitalize(), p.attributes[key]], 17))
func show_transfers() -> void:
	clear(); header("Mercado"); page.add_child(label("Seu agente encontrou uma oportunidade.", 18, MUTED)); offer = Career.offer_transfer(); var box := card(); box.add_child(label(offer.club, 28, ACCENT)); box.add_child(label("Contrato de %d anos • €%d por semana" % [offer.length, offer.salary], 19)); box.add_child(label("Papel no elenco: %s" % offer.role, 16, MUTED)); page.add_child(button("ACEITAR PROPOSTA", func(): Career.accept_offer(offer); show_message("Contrato assinado. Um novo capítulo começou!", show_dashboard))); page.add_child(button("RECUSAR E AGUARDAR", show_dashboard, Color("d5edf0")))
func show_news() -> void:
	clear(); header("Notícias"); for item in Career.news: var box := card(); box.add_child(label(item, 17))
func show_message(message: String, next: Callable) -> void:
	if modal: modal.queue_free()
	modal = PanelContainer.new(); modal.set_anchors_and_offsets_preset(Control.PRESET_CENTER); modal.position = Vector2(80, 650); modal.size = Vector2(920, 500); var style := StyleBoxFlat.new(); style.bg_color = Color("163843"); style.corner_radius_top_left = 18; style.corner_radius_top_right = 18; style.corner_radius_bottom_left = 18; style.corner_radius_bottom_right = 18; modal.add_theme_stylebox_override("panel", style); add_child(modal); var box := VBoxContainer.new(); box.add_theme_constant_override("separation", 24); modal.add_child(box); box.add_child(label(message, 24)); box.add_child(button("CONTINUAR", func(): modal.queue_free(); modal = null; next.call()))
