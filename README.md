# CAREER XI

Um protótipo jogável, **offline e Android-first**, de simulador de carreira de futebol feito em Godot 4. A primeira versão prioriza a jornada central: criar um atleta, treinar com risco de fadiga, decidir momentos da partida, acompanhar estatísticas, receber ofertas e salvar a carreira localmente.

## Executar

1. Instale o Godot 4.3 ou mais recente.
2. Importe `project.godot`.
3. Execute a cena principal (`Main.tscn`).

Para Android, configure o SDK/JDK no Godot e use **Project > Export > Android**. O projeto usa o renderizador Compatibility para celulares intermediários.

## Escopo desta vertical slice

- criação de atleta com nacionalidade, posição e arquétipo;
- overall posicional, atributos, potencial e progressão gradual;
- treino leve/equilibrado/intenso, energia, moral e fadiga;
- partidas simuladas com decisão interativa e nota;
- confiança do treinador, valor de mercado, notícias e transferências fictícias;
- estatísticas de temporada e salvamento automático local;
- interface responsiva para toque, sem ativos ou marcas licenciadas.

A arquitetura separa o modelo do jogador, carreira e persistência em scripts próprios para permitir a expansão posterior de ligas, eventos, seleção, contratos e narrativa procedural.
