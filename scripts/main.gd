extends Control

const BG: Color = Color("09151d")
const PANEL: Color = Color("102731")
const ACCENT: Color = Color("34d399")
const MUTED: Color = Color("9eb4bd")
const SOFT: Color = Color("d5edf0")

var page: VBoxContainer
var modal: PanelContainer
var offer: Dictionary = {}

func _ready() -> void:
	seed(Time.get_unix_time_from_system())
	_build_shell()
	if SaveGame.has_save() and Career.restore():
		show_dashboard()
	else:
		show_landing()

func _build_shell() -> void:
	var background: ColorRect = ColorRect.new()
	background.color = BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 24)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	page = VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 14)
	scroll.add_child(page)

func _clear_page() -> void:
	for child: Node in page.get_children():
		child.queue_free()

func _label(text: String, size: int = 22, color: Color = Color.WHITE) -> Label:
	var node: Label = Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", size)
	node.add_theme_color_override("font_color", color)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return node

func _button(text: String, action: Callable, tint: Color = ACCENT) -> Button:
	var node: Button = Button.new()
	node.text = text
	node.custom_minimum_size = Vector2(0, 58)
	node.add_theme_font_size_override("font_size", 18)
	node.add_theme_color_override("font_color", Color("062018"))
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = tint
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	node.add_theme_stylebox_override("normal", style)
	node.pressed.connect(action)
	return node

func _card() -> VBoxContainer:
	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = PANEL
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", style)
	page.add_child(panel)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 9)
	panel.add_child(box)
	return box

func _header(title: String) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	page.add_child(row)
	var back: Button = Button.new()
	back.text = "‹"
	back.add_theme_font_size_override("font_size", 32)
	back.pressed.connect(show_dashboard)
	row.add_child(back)
	row.add_child(_label(title, 30))

func _add_spacer(height: int) -> void:
	var spacer: Control = Control.new()
	spacer.custom_minimum_size.y = height
	page.add_child(spacer)

func show_landing() -> void:
	_clear_page()
	_add_spacer(120)
	page.add_child(_label("CAREER", 58, ACCENT))
	page.add_child(_label("XI", 58))
	page.add_child(_label("Todo jogador começa com um sonho.\nQual será o seu?", 24, MUTED))
	_add_spacer(40)
	page.add_child(_button("COMEÇAR CARREIRA", show_creator))
	if SaveGame.has_save():
		page.add_child(_button("CONTINUAR CARREIRA", show_dashboard, Color("b1d8ff")))
	page.add_child(_label("Experiência offline • Carreira procedural • Sem marcas reais", 14, MUTED))

func show_creator() -> void:
	_clear_page()
	page.add_child(_label("Crie sua promessa", 34))
	page.add_child(_label("Sua origem molda o primeiro capítulo da carreira.", 17, MUTED))
	var form: VBoxContainer = _card()
	var first: LineEdit = LineEdit.new()
	first.placeholder_text = "Nome"
	form.add_child(first)
	var last: LineEdit = LineEdit.new()
	last.placeholder_text = "Sobrenome"
	form.add_child(last)
	var nation: OptionButton = _select(["Brasil", "Argentina", "Portugal", "França", "Japão", "Estados Unidos"])
	form.add_child(_label("Nacionalidade", 16, MUTED))
	form.add_child(nation)
	var position: OptionButton = _select(["Centroavante", "Ponta-direita", "Meia ofensivo", "Volante", "Zagueiro", "Lateral-direito", "Goleiro"])
	form.add_child(_label("Posição", 16, MUTED))
	form.add_child(position)
	var archetype: OptionButton = _select(["Finalizador", "Velocista", "Armador", "Zagueiro físico", "Goleiro-linha"])
	form.add_child(_label("Arquétipo", 16, MUTED))
	form.add_child(archetype)
	page.add_child(_button("INICIAR JORNADA", func() -> void:
		Career.new_career({"first_name": first.text, "last_name": last.text, "nationality": nation.get_item_text(nation.selected), "position": position.get_item_text(position.selected), "archetype": archetype.get_item_text(archetype.selected)})
		show_dashboard()
	))

func _select(items: Array[String]) -> OptionButton:
	var select: OptionButton = OptionButton.new()
	for item: String in items:
		select.add_item(item)
	return select

func show_dashboard() -> void:
	_clear_page()
	var p: CareerPlayer = Career.player
	page.add_child(_label("CAREER XI", 25, ACCENT))
	page.add_child(_label(p.display_name().to_upper(), 31))
	page.add_child(_label("%s  •  %s  •  Semana %d" % [p.club, Career.season, Career.week], 16, MUTED))
	var hero: VBoxContainer = _card()
	hero.add_child(_label("OVR %d" % p.overall, 42, ACCENT))
	hero.add_child(_label("%s  |  #%d  |  Valor €%d" % [p.position, p.shirt_number, p.market_value], 16))
	hero.add_child(_label("Energia %d%%    Moral %d%%    Confiança %d%%" % [p.energy, p.morale, p.coach_trust], 17, MUTED))
	var match_card: VBoxContainer = _card()
	match_card.add_child(_label("PRÓXIMA PARTIDA", 14, MUTED))
	match_card.add_child(_label("%s  ×  %s" % [p.club, str(Career.fixture.get("opponent", "Adversário"))], 22))
	match_card.add_child(_button("JOGAR PARTIDA", show_match, Color("b1d8ff")))
	page.add_child(_button("TREINAMENTO", show_training, SOFT))
	page.add_child(_button("ESTATÍSTICAS", show_stats, SOFT))
	page.add_child(_button("TRANSFERÊNCIAS", show_transfers, SOFT))
	page.add_child(_button("NOTÍCIAS", show_news, SOFT))
	page.add_child(_label("ÚLTIMA NOTÍCIA", 14, MUTED))
	page.add_child(_label(Career.news[0] if not Career.news.is_empty() else "O mundo do futebol está de olho em você.", 16))

func show_training() -> void:
	_clear_page()
	_header("Treinamento")
	page.add_child(_label("Escolha sua carga semanal", 18, MUTED))
	var box: VBoxContainer = _card()
	box.add_child(_label("Seu foco: %s" % Career._focus_attribute().capitalize(), 19))
	box.add_child(_label("Treino intenso acelera a evolução, mas aumenta fadiga.", 15, MUTED))
	page.add_child(_button("TREINO LEVE", func() -> void: _complete_training("Leve"), SOFT))
	page.add_child(_button("TREINO EQUILIBRADO", func() -> void: _complete_training("Equilibrado"), SOFT))
	page.add_child(_button("TREINO INTENSO", func() -> void: _complete_training("Intenso"), SOFT))
	page.add_child(_button("DESCANSAR (+20 energia)", _rest_training, Color("b1d8ff")))

func _complete_training(intensity: String) -> void:
	var result: Dictionary = Career.train(intensity)
	_show_message(str(result.get("text", "Treino concluído.")), show_training)

func _rest_training() -> void:
	Career.rest()
	show_training()

func show_match() -> void:
	_clear_page()
	_header("Dia de jogo")
	page.add_child(_label(str(Career.fixture.get("competition", "Liga")), 16, MUTED))
	page.add_child(_label("%s × %s" % [Career.player.club, str(Career.fixture.get("opponent", "Adversário"))], 28))
	var box: VBoxContainer = _card()
	box.add_child(_label("Momento decisivo", 22))
	box.add_child(_label("Você recebe a bola na entrada da área. Qual é a sua decisão?", 17, MUTED))
	page.add_child(_button("CHUTAR", func() -> void: _complete_match("Chutar"), SOFT))
	page.add_child(_button("PASSAR", func() -> void: _complete_match("Passar"), SOFT))
	page.add_child(_button("DRIBLAR", func() -> void: _complete_match("Driblar"), SOFT))
	page.add_child(_button("SIMULAR", func() -> void: _complete_match("Simular"), SOFT))

func _complete_match(choice: String) -> void:
	var result: Dictionary = Career.play_match(choice)
	var message: String = "Fim de jogo: %s\nNota %.1f • %d gol(s) • %d assistência(s)" % [str(result.get("score", "0 x 0")), float(result.get("rating", 0.0)), int(result.get("goals", 0)), int(result.get("assists", 0))]
	_show_message(message, show_dashboard)

func show_stats() -> void:
	_clear_page()
	_header("Estatísticas")
	var p: CareerPlayer = Career.player
	var box: VBoxContainer = _card()
	box.add_child(_label("TEMPORADA %s" % Career.season, 16, MUTED))
	box.add_child(_label("%d jogos  •  %d min" % [int(p.stats["matches"]), int(p.stats["minutes"])], 22))
	box.add_child(_label("%d gols  •  %d assistências  •  nota média %.1f" % [int(p.stats["goals"]), int(p.stats["assists"]), p.average_rating()], 20, ACCENT))
	var attrs: VBoxContainer = _card()
	attrs.add_child(_label("ATRIBUTOS", 16, MUTED))
	for key: String in p.attributes:
		attrs.add_child(_label("%s  %d" % [key.capitalize(), int(p.attributes[key])], 17))

func show_transfers() -> void:
	_clear_page()
	_header("Mercado")
	page.add_child(_label("Seu agente encontrou uma oportunidade.", 18, MUTED))
	offer = Career.offer_transfer()
	var box: VBoxContainer = _card()
	box.add_child(_label(str(offer.get("club", "Clube")), 28, ACCENT))
	box.add_child(_label("Contrato de %d anos • €%d por semana" % [int(offer.get("length", 0)), int(offer.get("salary", 0))], 19))
	box.add_child(_label("Papel no elenco: %s" % str(offer.get("role", "Rotação")), 16, MUTED))
	page.add_child(_button("ACEITAR PROPOSTA", _accept_transfer))
	page.add_child(_button("RECUSAR E AGUARDAR", show_dashboard, SOFT))

func _accept_transfer() -> void:
	Career.accept_offer(offer)
	_show_message("Contrato assinado. Um novo capítulo começou!", show_dashboard)

func show_news() -> void:
	_clear_page()
	_header("Notícias")
	for item: String in Career.news:
		var box: VBoxContainer = _card()
		box.add_child(_label(item, 17))

func _show_message(message: String, next: Callable) -> void:
	if is_instance_valid(modal):
		modal.queue_free()
	modal = PanelContainer.new()
	modal.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	modal.position = Vector2(80, 650)
	modal.size = Vector2(920, 500)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("163843")
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	modal.add_theme_stylebox_override("panel", style)
	add_child(modal)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 24)
	modal.add_child(box)
	box.add_child(_label(message, 24))
	box.add_child(_button("CONTINUAR", func() -> void:
		modal.queue_free()
		modal = null
		next.call()
	))
