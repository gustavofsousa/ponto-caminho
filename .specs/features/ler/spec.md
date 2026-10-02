# Ler (v0.2) — Specification

**Escopo:** Large · **Roadmap:** v0.2 "Ler" · **Branch:** `feat/v0.2-ler`
**Fontes:** [`docs/roadmap.md`](../../../docs/roadmap.md) v0.2 · [`docs/modelo.md`](../../../docs/modelo.md) §1, §3, §6 ·
[`docs/tom-de-voz.md`](../../../docs/tom-de-voz.md) · revisão de código da v0.1 (2026-10-02, achados R1–R11)

## Problem Statement

A v0.1 abre num único ponto fixo: não há como chegar a nenhum outro texto. O leitor precisa
navegar pelas três obras como o autor as organizou (obra → capítulo → ponto), ler um ponto
inteiro com conforto e seguir para o próximo sem voltar ao índice. A revisão da v0.1 também
achou que a fronteira de dados aceita silenciosamente livros malformados e mostra erro técnico
ao leitor — isso precisa ser firme antes de mais telas dependerem dela.

## Goals

- [ ] Do app aberto até qualquer ponto disponível em no máximo 3 toques (obra → capítulo → ponto).
- [ ] Ler em sequência um capítulo inteiro, e atravessar para o seguinte, só com "Próximo".
- [ ] Tema e tamanho de texto escolhidos sobrevivem a fechar e reabrir o app.
- [ ] Nenhum livro malformado chega à tela; nenhum erro técnico chega ao leitor.

## Out of Scope

| Item | Motivo |
| --- | --- |
| Favoritar, refletir, coleções | v0.3 (`registro`) |
| Um ponto para agora, continue de onde parou, registro de leitura | v0.4 (`selecao`, `leitura`) |
| Compartilhar referência | v0.4 |
| Telas de boas-vindas (`tom-de-voz.md` §2) | Não estão no roadmap; vão ao backlog |
| Gesto de deslizar para anterior/próximo | Botões resolvem e são acessíveis; gesto vai ao backlog |
| Navegar de uma obra para outra pelo "Próximo" | `modelo.md` §3: a sequência atravessa capítulos, não obras |
| Tipografia e paleta definitivas | v1.0; aqui são provisórias |
| Progresso de leitura por capítulo | v1.3 |

---

## Assumptions & Open Questions

Decisões de área cinzenta tomadas pelo agente: o usuário pediu o fluxo completo sem pausas.
Todas podem ser revistas no UAT.

| # | Decisão | Default escolhido | Motivo | Confirmado? |
| --- | --- | --- | --- | --- |
| A1 | Tela de abertura | **Biblioteca** | Sem "continue de onde parou" (v0.4) nem boas-vindas, a biblioteca é a única entrada honesta | não — UAT |
| A2 | Anterior/próximo entre obras | **Não atravessa obras** | `modelo.md` §3 fala em atravessar capítulos | sim (doc) |
| A3 | Sequência com buracos (mock, ou licença parcial) | Anterior/próximo andam pelos pontos **disponíveis**, em `ordem` | Com o texto integral (v1.0) é a sequência completa; até lá, nunca leva a uma página vazia | não — UAT |
| A4 | O que a contagem do capítulo conta | **Tamanho editorial** (`pontoFinal − pontoInicial + 1`); sem intervalo completo, não mostra contagem | O índice é estrutura do autor, não disponibilidade | não — UAT |
| A5 | Capítulo sem pontos disponíveis | Listado; abre num estado vazio: "Os pontos deste capítulo ainda não estão disponíveis." | Mantém a estrutura real visível; tom sereno, sem prometer data | não — UAT |
| A6 | Capítulo sem título no índice | Mostrado como "Capítulo N"; referência fica "Obra, ponto N" | Títulos de *Caminho* 17–18 ainda não conferidos | sim (v0.1) |
| A7 | Passos de tamanho de texto | Pequeno 0,9 · Médio 1,0 (padrão) · Grande 1,15 · Muito grande 1,3 — **multiplicando** a escala do sistema | Respeita a acessibilidade do sistema e acrescenta ajuste próprio | não — UAT |
| A8 | Tema padrão | **Sistema** | Respeita a escolha do aparelho | sim (roadmap) |
| A9 | Onde guardar preferências | Armazenamento local simples de chave-valor; valor inválido ou ausente → padrão | Preferência não é dado sensível; o banco cifrado chega com `registro` (v0.3) | sim (ADR-001) |
| A10 | Prévia na lista de pontos | Número + início do texto, até 2 linhas | Permite reconhecer o ponto sem abrir | não — UAT |
| A11 | Tipografia provisória | **Literata** (OFL) empacotada para o texto do ponto e títulos; interface no padrão da plataforma | Desenhada para leitura longa; empacotada = idêntica no Android e iOS, sem rede | não — UAT |
| A12 | Falha ao abrir os livros | Tela: "Não foi possível abrir os livros. Feche o app e abra de novo." · detalhe técnico só no log | `tom-de-voz.md`: humano, sem jargão | não — UAT |
| A13 | Exemplos dos ACs × dados dos testes | Os cenários citam o mock atual (ex.: Caminho 5 → 81); os testes **reproduzem cada cenário numa coleção de teste** com a mesma forma (buraco entre capítulos, ponta da obra, capítulo vazio, sem título, intervalo incompleto). Só o teste de contrato e um teste de abertura usam `livros/` real | Trocar mock por texto real não pode quebrar teste de comportamento | sim (agente) |

**Open questions:** nenhuma — todas resolvidas ou registradas acima.

**Revisões:** r1 (2026-10-02) — AC-01 dizia "mensagem nomeando a obra" também para o caso em que o próprio id da obra é o campo inválido; o Verifier apontou que aí não há nome a citar. Agora cita `colecao.json`. Não reduz garantia.

---

## User Stories

### P1: Livros carregados com segurança ⭐ MVP

**User Story:** Como leitor, quero que o app só me mostre texto íntegro, para nunca ler um ponto
no lugar errado ou ver uma mensagem técnica.

**Why P1:** Toda tela da v0.2 depende desta fronteira; a revisão da v0.1 achou cinco brechas nela.

**Acceptance Criteria:**

```
AC-01: Arquivo do livro com campo de tipo errado é recusado  [revised r1]
- Scenario:     um JSON de obra cujo id de obra em colecao.json, slug ou título de capítulo não é texto
- Action:       o motor monta a coleção
- Expected:     FormatException (não TypeError). Slug/título: mensagem nomeando a obra e o campo.
                Id de obra inválido em colecao.json: mensagem citando `colecao.json` (não há nome
                de obra para citar)
- Must not:     devolver uma coleção parcial
- Verification: teste de unidade (motor)
- Priority:     Required

AC-02: Número de ponto repetido numa obra é recusado
- Scenario:     uma obra com dois pontos de mesmo `numero`
- Action:       o motor monta a coleção / validar.py roda
- Expected:     motor: FormatException citando obra e número · validar.py: erro, exit 1
- Must not:     um dos dois sobrescrever o outro em silêncio
- Verification: teste de unidade (motor) + execução do validar.py com arquivo de teste
- Priority:     Required

AC-03: Ponto que aponta para capítulo inexistente é recusado
- Scenario:     ponto com `capituloNumero` que não existe no índice da obra
- Action:       o motor monta a coleção / validar.py roda
- Expected:     motor: FormatException citando ponto e capítulo · validar.py: erro, exit 1
- Must not:     aceitar o ponto com referência sem capítulo
- Verification: teste de unidade (motor) + execução do validar.py
- Priority:     Required

AC-04: Só o motor conhece o formato dos arquivos de livros
- Scenario:     colecao.json lista as obras; cada obra mora em `<id>.json`
- Action:       o app e o teste de contrato carregam a coleção
- Expected:     ambos chamam a mesma função do motor, passando só "como ler um arquivo pelo nome"
- Must not:     o app ler `colecao.json` ou converter campos por conta própria
- Verification: teste de unidade do carregamento (motor) + teste de contrato com livros/ real
- Priority:     Required

AC-05: Falha ao abrir os livros vira mensagem humana
- Scenario:     o carregamento lança qualquer exceção
- Action:       o app inicia
- Expected:     tela única com "Não foi possível abrir os livros. Feche o app e abra de novo."
- Must not:     mostrar texto da exceção na tela
- Verification: teste de widget
- Priority:     Required
```

**Independent Test:** rodar o app com `livros/` íntegro abre a biblioteca; com um arquivo
corrompido abre a mensagem humana.

---

### P1: Biblioteca — obra → capítulo → ponto ⭐ MVP

**User Story:** Como leitor, quero percorrer as obras pela estrutura do autor, para encontrar um
ponto sem saber o número de cor.

**Why P1:** É o único caminho até um ponto qualquer na v0.2.

**Acceptance Criteria:**

```
AC-06: A biblioteca lista as obras na ordem da coleção
- Scenario:     app aberto com a coleção caminho-sulco-forja
- Action:       a tela inicial aparece
- Expected:     três entradas, nesta ordem: "Caminho", "Sulco", "Forja"
- Must not:     ordenar alfabeticamente ou por quantidade
- Verification: teste de widget
- Priority:     Required

AC-07: A obra lista os capítulos com número, título e contagem
- Scenario:     o leitor tocou em "Caminho"
- Action:       a tela da obra aparece
- Expected:     um item por capítulo, em ordem; o capítulo 1 mostra "Caráter" e "55 pontos";
                capítulo sem intervalo completo (17) não mostra contagem; capítulo sem título
                mostra "Capítulo N"
- Must not:     esconder capítulos sem pontos disponíveis
- Verification: teste de unidade (contagem, motor) + teste de widget (tela)
- Priority:     Required

AC-08: O capítulo lista os pontos disponíveis com prévia
- Scenario:     o leitor tocou no capítulo 1 de Caminho (mock: pontos 1–5)
- Action:       a tela do capítulo aparece
- Expected:     cinco itens em `ordem`, cada um com o número e o início do texto (até 2 linhas)
- Must not:     listar pontos de outro capítulo
- Verification: teste de unidade (pontos do capítulo, motor) + teste de widget
- Priority:     Required

AC-09: Capítulo sem pontos disponíveis abre num estado vazio
- Scenario:     capítulo 2 de Caminho (nenhum ponto mock)
- Action:       o leitor toca nele
- Expected:     "Os pontos deste capítulo ainda não estão disponíveis."
- Must not:     tela em branco ou erro
- Verification: teste de widget
- Priority:     Required

AC-10: Tocar num ponto abre a página daquele ponto
- Scenario:     tela do capítulo 3 de Caminho
- Action:       o leitor toca no ponto 82
- Expected:     página com a referência "Caminho, capítulo Oração, ponto 82" e o texto do ponto 82
- Must not:     abrir outro ponto
- Verification: teste de widget
- Priority:     Required
```

**Independent Test:** abrir o app → Caminho → Oração → 82 e ler o ponto 82.

---

### P1: Página do ponto com anterior/próximo ⭐ MVP

**User Story:** Como leitor, quero seguir para o ponto seguinte sem voltar ao índice, para ler
em sequência como no livro.

**Why P1:** Leitura contínua é metade do "Ler" no roadmap.

**Acceptance Criteria:**

```
AC-11: A referência segue o formato único do produto
- Scenario:     qualquer ponto com capítulo titulado
- Action:       a referência é formatada
- Expected:     "<Obra>, capítulo <Capítulo>, ponto <n>" · sem título de capítulo: "<Obra>, ponto <n>"
- Must not:     mostrar o PontoId cru
- Verification: teste de unidade (motor — dono único do formato)
- Priority:     Required

AC-12: Próximo segue a ordem da obra e atravessa capítulos
- Scenario:     página de Caminho 5 (último ponto disponível do capítulo 1)
- Action:       o leitor toca "Próximo"
- Expected:     abre Caminho 81 (próximo disponível em `ordem`, capítulo 3)
- Must not:     pular para outra obra
- Verification: teste de unidade (motor) + teste de widget
- Priority:     Required

AC-13: Anterior é o espelho de Próximo
- Scenario:     página de Caminho 81
- Action:       o leitor toca "Anterior"
- Expected:     abre Caminho 5
- Must not:     —
- Verification: teste de unidade (motor) + teste de widget
- Priority:     Required

AC-14: Nas pontas da obra, o controle que não leva a lugar nenhum não aparece
- Scenario:     primeiro (Caminho 1) e último (Caminho 266) pontos disponíveis da obra
- Action:       a página aparece
- Expected:     em Caminho 1 não há "Anterior"; em Caminho 266 não há "Próximo"
- Must not:     um botão que não faz nada
- Verification: teste de unidade (motor devolve nulo) + teste de widget
- Priority:     Required
```

**Independent Test:** em Caminho 1, tocar "Próximo" até o fim e voltar com "Anterior".

---

### P2: Leitura confortável — tema e tamanho do texto

**User Story:** Como leitor, quero escolher tema e tamanho do texto uma vez, para ler no escuro
ou sem óculos sem reconfigurar a cada abertura.

**Why P2:** O app lê sem isso; a v0.2 só fica boa com isso.

**Acceptance Criteria:**

```
AC-15: Tema claro, escuro ou do sistema
- Scenario:     tela de preferências de leitura
- Action:       o leitor escolhe Claro, Escuro ou Sistema
- Expected:     o app inteiro passa ao tema escolhido; Sistema segue o aparelho; padrão = Sistema
- Must not:     nenhuma tela ficar no tema antigo
- Verification: teste de widget
- Priority:     Required

AC-16: Quatro tamanhos de texto que multiplicam a escala do sistema
- Scenario:     escala de texto do sistema = s
- Action:       o leitor escolhe Pequeno, Médio, Grande ou Muito grande
- Expected:     a escala efetiva do texto é s × 0,9 / 1,0 / 1,15 / 1,3; padrão = Médio
- Must not:     ignorar a escala do sistema
- Verification: teste de widget (escala aplicada) + teste de unidade (fatores)
- Priority:     Required

AC-17: Preferências sobrevivem a reabrir o app
- Scenario:     o leitor escolheu Escuro + Grande
- Action:       o app é fechado e aberto de novo
- Expected:     abre em Escuro + Grande
- Must not:     voltar ao padrão
- Verification: teste de unidade do repositório de preferências (gravar → ler)
- Priority:     Required

AC-18: Preferência gravada inválida volta ao padrão
- Scenario:     valor guardado desconhecido (versão antiga, corrupção)
- Action:       o app lê as preferências
- Expected:     Sistema + Médio, sem erro
- Must not:     travar a abertura
- Verification: teste de unidade
- Priority:     Required
```

**Independent Test:** escolher Escuro + Grande, reiniciar, conferir.

---

### P2: Tipografia e cores provisórias

**User Story:** Como leitor, quero um texto bonito e legível, para que a leitura seja um prazer
e não um esforço.

**Acceptance Criteria:**

```
AC-19: Texto do ponto em fonte de leitura empacotada
- Scenario:     página do ponto, qualquer plataforma
- Action:       o texto aparece
- Expected:     o texto do ponto usa a família "Literata", empacotada no app
- Must not:     baixar fonte da rede em tempo de execução
- Verification: teste de widget (família do estilo) + build (fonte no pacote)
- Priority:     Should

AC-20: Contraste AA nos dois temas
- Scenario:     tokens de cor dos temas claro e escuro
- Action:       contraste calculado (WCAG 2.x) entre texto e fundo
- Expected:     texto principal ≥ 4,5:1 e texto secundário ≥ 4,5:1 nos dois temas
- Must not:     —
- Verification: teste de unidade sobre os tokens
- Priority:     Required
```

---

## Edge Cases

- WHEN a obra não tem nenhum ponto disponível THEN a obra aparece na biblioteca e seus capítulos
  abrem no estado vazio (AC-09).
- WHEN um ponto é o único disponível da obra THEN a página não mostra Anterior nem Próximo (AC-14).
- WHEN o capítulo tem 1 ponto no intervalo THEN a contagem diz "1 ponto", no singular (AC-07).
- WHEN o `PontoId` pedido não existe THEN `proximoPonto`/`pontoAnterior` devolvem nulo.
- WHEN o texto do ponto é longo e o tamanho é "Muito grande" THEN a página rola, sem cortar texto.
- WHEN a escala do sistema já é grande THEN o tamanho do app multiplica, não substitui (AC-16).

---

## Implicit-requirement sweep (Large → todas as dimensões)

| Dimensão | Resolução |
| --- | --- |
| Validação de entrada e limites | Livros: AC-01..03 na fronteira do motor + validar.py. Preferências: AC-18 |
| Falha / falha parcial | Livros: AC-05 (tudo ou nada; nunca coleção parcial). Preferências: AC-18 |
| Idempotência / retry / duplicidade | Duplicidade de ponto: AC-02. Gravar preferência é idempotente (último valor vence) |
| Autorização e rate limit | N/A — sem conta, sem rede |
| Concorrência / ordem | N/A — um isolate, sem escrita concorrente; preferência em memória é a fonte durante a sessão |
| Ciclo de vida do dado | Preferências vivem até desinstalar; não são dado pessoal sensível |
| Observabilidade | Erro de carregamento vai ao log do Flutter (AC-05); **sem telemetria** (regra de privacidade) |
| Dependência externa | N/A — fonte e livros empacotados; nada de rede em tempo de execução (AC-19) |
| Integridade de estado | Tema e tamanho são conjuntos fechados (enum); estados ilegais não compilam |

**Rollback:** N/A — sem migração de dados nem operação destrutiva; reverter = reverter commits.

---

## Requirement Traceability

| ID | Story | AC | Status |
| --- | --- | --- | --- |
| BASE-01 | P1 Livros seguros | AC-01 | Implementing |
| BASE-02 | P1 Livros seguros | AC-02 | Implementing |
| BASE-03 | P1 Livros seguros | AC-03 | Implementing |
| BASE-04 | P1 Livros seguros | AC-04 | Implementing |
| BASE-05 | P1 Livros seguros | AC-05 | Implementing |
| LER-01 | P1 Biblioteca | AC-06 | Implementing |
| LER-02 | P1 Biblioteca | AC-07 | Implementing |
| LER-03 | P1 Biblioteca | AC-08 | Implementing |
| LER-04 | P1 Biblioteca | AC-09 | Implementing |
| LER-05 | P1 Biblioteca | AC-10 | Implementing |
| LER-06 | P1 Página do ponto | AC-11 | Implementing |
| LER-07 | P1 Página do ponto | AC-12 | Implementing |
| LER-08 | P1 Página do ponto | AC-13 | Implementing |
| LER-09 | P1 Página do ponto | AC-14 | Implementing |
| PREF-01 | P2 Conforto | AC-15 | Implementing |
| PREF-02 | P2 Conforto | AC-16 | Implementing |
| PREF-03 | P2 Conforto | AC-17 | Implementing |
| PREF-04 | P2 Conforto | AC-18 | Implementing |
| TIPO-01 | P2 Tipografia | AC-19 | Implementing |
| TIPO-02 | P2 Tipografia | AC-20 | Implementing |

**Coverage:** 20 total, 20 mapped to tasks (ver `tasks.md` › Requirement → Task).

---

## Success Criteria

- [ ] Caminho → Oração → 82 em 3 toques a partir da abertura.
- [ ] Caminho 1 → … → 266 só com "Próximo", e de volta só com "Anterior", sem tela vazia.
- [ ] Escuro + Grande persistem após reiniciar.
- [ ] `flutter test`, `dart test` e `validar.py` verdes; zero issues de análise estática.
