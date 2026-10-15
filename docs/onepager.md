# Ponto — one-page

> **Um ponto para agora.**
> Leitura espiritual católica a partir de *Caminho*, *Sulco* e *Forja*, de São Josemaría Escrivá.

---

## O problema

Os textos de São Josemaría já estão disponíveis em muitos canais: sites, PDFs, grupos de mensagem,
imagens compartilhadas. O que não existe é **continuidade**.

A pessoa lê um ponto, ele a toca, e ele se perde. Não há onde guardar o que aquele ponto pediu dela,
não há como reencontrá-lo seis meses depois, não há memória do percurso. O conteúdo é abundante; o
que falta é um lugar onde a leitura vire vida interior acompanhada ao longo do tempo.

## A proposta

Um aplicativo mobile-first de leitura, meditação e registro pessoal, construído em torno da unidade
real dessas obras: **o ponto**.

Não um capítulo genérico. Um ponto breve, concreto, que orienta uma vida concreta — e um lugar
sóbrio para guardar o que ele provocou.

O percurso que o produto sustenta:

```
texto → silêncio → reflexão → anotação → releitura → vida prática
```

## Por que "Ponto"

O território não depende de metáfora rebuscada. A palavra carrega três leituras simultâneas:

| Leitura | Significado |
| --- | --- |
| **Ponto textual** | A unidade real de conteúdo em *Caminho*, *Sulco* e *Forja*. |
| **Ponto de atenção** | Algo em que você para para refletir. |
| **Ponto de orientação** | Uma referência que ajuda a se localizar e decidir. |

E os três títulos formam uma unidade simbólica que dá nome às camadas da experiência:

- **Caminho** — percurso, direção, vida em movimento. *O que você percorre.*
- **Sulco** — a marca aberta pela repetição e pelo cultivo. *O que você aprofunda.*
- **Forja** — transformação por fogo e esforço. *O que forma você.*

O ponto de partida simbólico é o ponto 1 de *Caminho*: *"Sê útil. Deixa rasto. Ilumina…"*
O produto existe para ajudar alguém a deixar rastros bons, concretos e pessoais na própria rotina.

## Público

**Principal** — católicos que querem criar ou fortalecer um hábito diário de oração, meditação e
exame pessoal; leitores de São Josemaría; pessoas que valorizam espiritualidade prática aplicada ao
trabalho, à família, ao estudo e às relações.

**Secundário** — quem quer conhecer os textos pela primeira vez; grupos de formação, direção
espiritual e círculos de estudo; leitores que buscam leitura reflexiva sem prática diária consolidada.

## Escopo da v1

A primeira versão faz **poucas coisas, muito bem executadas**:

1. **Biblioteca** dos três livros, com navegação por livro → capítulo → ponto.
2. **Página do ponto** — texto integral, referência clara, ações rápidas, navegação anterior/próximo.
3. **Favoritos e coleções** — listas próprias, um ponto em várias listas.
4. **Reflexões** — anotações pessoais datadas, editáveis, privadas por padrão.
5. **Um ponto para agora** — ponto aleatório.
6. **Retomar a leitura** de onde parou.

Logo depois da v1: **ponto do dia** com notificação opcional (v1.1) e **busca** por palavra-chave
(v1.2). Fora, por decisão: IA de busca semântica, compartilhamento de coleções, sincronização,
exportação, web e desktop — previstos na arquitetura, nenhum na primeira entrega. Ordem completa em
[`roadmap.md`](./roadmap.md).

## Diferencial

O diferencial **não** é ter os textos. É transformar a leitura em um percurso pessoal e organizado.

O app ajuda a construir uma **memória espiritual pessoal** ao longo de meses e anos. Um PDF, um site
de consulta ou um grupo de mensagens não fazem isso e não pretendem fazer.

## Arquitetura: o motor de pontos

O produto nasce desacoplado em três camadas: **conteúdo**, **motor de seleção** e **experiência de leitura**.

O motor recebe qualquer coleção estruturada de textos curtos. Ele devolve um ponto por ID, um ponto
aleatório, o ponto do dia e o próximo de uma sequência. Ele também registra leituras, favoritos,
listas e anotações.

Consequência prática: a coleção *Caminho, Sulco e Forja* pode ser substituída por outras — meditações,
regras de vida, textos clássicos, conteúdo próprio — sem reescrever o aplicativo. O mesmo motor pode
alimentar web, desktop, widget, extensão de navegador, integração com ferramentas de notas e API.

Ver [`modelo.md`](./modelo.md) para o modelo completo.

## Princípios de produto

- **Um ponto por vez.** Tela inicial minimalista, sem cards empilhados nem métricas.
- **Privacidade como princípio, não como configuração.** Anotações são dados pessoais e religiosos
  altamente sensíveis. Não servem a publicidade, nem a treinamento público de IA, nem a
  compartilhamento sem consentimento explícito.
- **Sem mecanismos de culpa.** Nada de streaks, rankings, badges ou notificações agressivas.
  Quem passou uma semana sem abrir o app é recebido do mesmo jeito.
- **Sobriedade católica.** Profundidade sem visual institucional, dourado excessivo ou ornamento.
- **Respeito ao ritmo do usuário.** O app não promete transformação automática, não substitui
  direção espiritual humana e não dá aconselhamento.

## Riscos e o que os endereça

| Risco | Resposta |
| --- | --- |
| **Direitos autorais sobre as três obras** | Bloqueante. Licença formal antes de qualquer distribuição pública — ver Riscos em [`roadmap.md`](./roadmap.md). |
| Sensibilidade das anotações | Criptografia em repouso, sem telemetria de conteúdo, exportação e exclusão desde cedo. |
| Virar "mais um app de citações" | Foco na v1 em releitura e registro, não em volume de features. |
| Gamificação entrando pela porta dos fundos | Princípio explícito no design system e no review de produto. |
| Traduções e edições divergentes | Versionamento da coleção e rastreio de edição/tradução no dado. |

## Sinais de que está funcionando

Métricas escolhidas para medir **profundidade**, não vício:

- Proporção de leitores que escrevem ao menos uma reflexão no primeiro mês.
- Taxa de **releitura**: pontos revisitados 30+ dias depois da primeira leitura.
- Anotações por usuário ativo ao longo de 6 meses (memória acumulada).
- Retenção em 90 dias — sem incentivos artificiais.

Explicitamente **não** são métricas de sucesso: tempo de sessão, número de sessões por dia,
sequência de dias consecutivos.

---

*Documentos relacionados:* [`roadmap.md`](./roadmap.md) · [`modelo.md`](./modelo.md) · [`mensagem-inicial.md`](./mensagem-inicial.md) · [`tom-de-voz.md`](./tom-de-voz.md) · [`livros/`](../livros/)
