# Guardar (v0.3) — Specification

**Escopo:** Complex (domínio novo `registro`, persistência cifrada, guarda de chave) ·
**Roadmap:** v0.3 "Guardar" · **Branch:** `feat/v0.3-guardar`
**Fontes:** [`docs/roadmap.md`](../../../docs/roadmap.md) v0.3 · [`docs/modelo.md`](../../../docs/modelo.md) §4, §6, §7 ·
[`docs/dominios.md`](../../../docs/dominios.md) regras 2, 3, 5 · [`docs/tom-de-voz.md`](../../../docs/tom-de-voz.md) §4–§7 ·
[`docs/backlog.md`](../../../docs/backlog.md) › `registro`, `infra` · ADR-001

## Problem Statement

Na v0.2 o leitor lê, mas nada do que um ponto provoca fica. O diferencial do produto — a memória
espiritual que se forma relendo o que se escreveu — começa aqui: escrever uma reflexão sobre um
ponto, marcar favoritos, reunir pontos em coleções pessoais e reencontrar tudo isso. Reflexões são
dado pessoal religioso: precisam nascer cifradas, porque cifrar depois exige migração (ADR-001).

## Goals

- [ ] Da página de um ponto, escrever e guardar uma reflexão em no máximo 2 toques mais o texto.
- [ ] Reencontrar um ponto guardado (favorito ou coleção) em no máximo 3 toques a partir da abertura.
- [ ] Nenhum byte de reflexão, favorito ou coleção em claro no disco; nenhum texto de reflexão em log.
- [ ] Nada do que o leitor escreveu se perde por toque acidental (voltar, excluir) ou falha de gravação.

## Out of Scope

| Item | Motivo |
| --- | --- |
| Linha do tempo de todas as reflexões, "você escreveu há um ano", releitura por período | v2.0 (`registro`, Novo / Visão) |
| Exportar reflexões (Markdown/PDF) | v2.0 — formato ainda é decisão pendente |
| Buscar dentro das reflexões | v1.2 (`busca`) |
| Compartilhar coleção | v3.0 — e só `PontoId[]` |
| Sugestão "Se algo aqui ficou, escreva" depois do primeiro ponto (`tom-de-voz.md` §3) | Não está no roadmap da v0.3; vai ao backlog |
| Marcadores na lista de pontos (tem reflexão, é favorito) | Não pedido; vai ao backlog |
| Reordenar coleções ou os pontos dentro delas | Não pedido |
| Tirar um ponto de uma coleção pela tela da coleção | A página do ponto já faz (COL-02); evita dois caminhos |
| Bloqueio por PIN/biometria | A cifra protege o arquivo; o bloqueio do aparelho protege o acesso |
| Backup ou sincronização | v2.0 (`conta`); na v1.0 tudo fica no aparelho |
| Configuração e teste no iOS | Sem Mac nesta máquina; Keychain fica para o pipeline de iOS (backlog `infra`) |

---

## Assumptions & Open Questions

Decisões de área cinzenta tomadas pelo agente: o usuário pediu o fluxo completo do spec-driven sem
pausas (mesmo acordo da v0.2). As marcadas "UAT" são revistas no aparelho.

| # | Decisão | Default escolhido | Motivo | Confirmado? |
| --- | --- | --- | --- | --- |
| A1 | Termo de código: "reflexão" ou "anotação" (backlog › `registro`) | **`Reflexao`** no código e "reflexão" na interface | É o termo do roadmap e do `tom-de-voz.md` §4; "anotação" fica como sinônimo só no `modelo.md` | não — revisar |
| A2 | Onde mora a chave do banco (backlog › `infra`) | Chave aleatória de 256 bits gerada no primeiro uso, guardada no armazenamento seguro do sistema (Keystore/Keychain) | Recomendação já registrada no backlog; transparente ao leitor; sem senha para esquecer. ADR-002 | não — ADR-002 |
| A3 | Backup do Android | **Desligado**, inclusive transferência entre aparelhos | A chave do Keystore não migra: um banco restaurado sem chave é ilegível e quebraria a abertura. Perder ao trocar de aparelho é o acordo da v1.0 (sem conta) | não — ADR-002 |
| A4 | Chave sumiu mas o banco existe | Registro **indisponível**, arquivo intocado, nenhuma chave nova gravada; leitura funciona normalmente | Nunca apagar nem sobrescrever o que o leitor escreveu | sim (regra de privacidade) |
| A5 | Ordem das reflexões de um ponto | **Mais antiga primeiro** | `tom-de-voz.md`: "na ordem em que você escrever"; lê-se como um diário | não — UAT |
| A6 | Ordem dos favoritos e dos pontos numa coleção | **Mais recente primeiro** (ordem em que foram guardados) | Acesso rápido: o que acabou de guardar está no topo | não — UAT |
| A7 | Ordem das coleções | **Ordem de criação** | Estável; as sugeridas aparecem na ordem sugerida | não — UAT |
| A8 | Formato de data e hora | "Escrito em 12 de março de 2026, 6h40." · hora cheia sem minutos: "6h" · editada: "… · editado em 14 de março de 2026, 21h05." · fuso do aparelho | `tom-de-voz.md` §4; "6h" é como se escreve hora cheia em PT-BR | não — UAT |
| A9 | Onde ficam as coleções sugeridas | Uma tela que aparece **no primeiro contato com coleções** (abrir "Coleções" ou "Guardar em uma coleção"), nenhuma marcada | "Primeiro uso" do roadmap lido como primeiro uso de coleções; marcar por padrão seria criar algo não pedido | não — UAT |
| A10 | Sair da tela de sugestões sem escolher | Conta como **recusa**: não aparece de novo | "O app espera, não persegue"; criar coleção à mão continua possível | não — UAT |
| A11 | Nomes das sugeridas | Os sete do `modelo.md` §4, nesta ordem: Pontos para reler · Meditação da semana · Vida profissional · Família · Direção espiritual · Preparação para confissão · Virtudes a trabalhar | Lista já escrita no modelo | sim (doc) |
| A12 | Nome de coleção | Espaços nas pontas removidos; vazio recusado; repetido recusado ignorando maiúsculas/minúsculas; até 60 caracteres | Evita duas "Família"; nome cabe numa linha de lista | não — UAT |
| A13 | Tamanho da reflexão | **Sem limite**; espaços nas pontas removidos; só espaços = vazio | O texto é do leitor e fica no aparelho; a página rola | sim (agente) |
| A14 | Ponto guardado que não existe mais na coleção carregada | Não aparece nas listas; **o dado fica** no banco | `PontoId` é estável entre versões (regra 2); nunca apagar dado do leitor por mudança de conteúdo | sim (agente) |
| A15 | Onde se chega a Favoritos e Coleções | Duas entradas na biblioteca, abaixo das obras | Visível sem ícone escondido; 2 toques até qualquer ponto guardado | não — UAT |
| A16 | Contagem na lista de coleções | "1 ponto" · "N pontos" · "Nenhum ponto" | Mesmo padrão de contagem da v0.2 | não — UAT |
| A17 | Exemplos dos ACs × dados dos testes | Os testes de tela reutilizam a coleção de teste da v0.2 (`colecaoDeTeste`) e um banco em memória; só os testes de cifra usam arquivo real | Igual à A13 da v0.2: trocar mock por texto real não quebra teste de comportamento | sim (agente) |

**Open questions:** nenhuma — todas resolvidas ou registradas acima.

**Revisões:**
- r1 (2026-10-02) — AC-01 dizia "o banco relata uma cifra ativa"; o Verifier mostrou que
  `PRAGMA cipher` responde `chacha20` também num arquivo em claro, então isso não distingue nada.
  Trocado por "outra chave não lê o arquivo".
- r2 (2026-10-03) — a sonda P10 do Verifier mostrou que um arquivo em claro aberto com uma chave
  também não é lido, então "outra chave não lê" também não distingue cifrado de claro. O observável
  do AC-01 fica só nos bytes (sem o texto, sem o cabeçalho), que já eram a prova (mutante M49). O
  teste de "outra chave" continua como checagem de comportamento. Não reduz garantia.

---

## User Stories

### P1: O que o leitor guarda nasce cifrado ⭐ MVP

**User Story:** Como leitor, quero que o que escrevo fique ilegível para qualquer um que copie o
arquivo do app, para escrever com a liberdade de quem escreve só para si.

**Why P1:** "Cifrada desde o primeiro byte" é condição do roadmap; cifrar depois exige migração.

**Acceptance Criteria:**

```
AC-01: O arquivo do registro é cifrado desde a criação  [revised r2]
- Scenario:     nenhum banco no aparelho; o registro é aberto pela primeira vez
- Action:       o leitor guarda uma reflexão com o texto "silêncio-que-ninguém-lê" e o banco é fechado
- Expected:     os bytes do arquivo não contêm esse texto (UTF-8) nem o cabeçalho "SQLite format 3"
- Must not:     existir em algum momento um arquivo de registro em claro
- Verification: teste automatizado com arquivo real (infra)
- Priority:     Required

AC-02: Sem suporte a cifra, o registro não abre
- Scenario:     a biblioteca SQLite carregada não tem cifra
- Action:       o registro é aberto
- Expected:     a abertura falha com erro; nenhuma tabela é criada
- Must not:     cair para um banco em claro
- Verification: teste automatizado (infra)
- Priority:     Required

AC-03: A chave nasce antes do banco e é a mesma nas aberturas seguintes
- Scenario:     armazenamento seguro vazio e nenhum arquivo de banco
- Action:       o registro é aberto, uma reflexão é guardada, o registro é fechado e aberto de novo
- Expected:     uma chave é gravada no armazenamento seguro antes de o arquivo existir; a segunda
                abertura usa a mesma chave e lê a reflexão
- Must not:     gerar uma segunda chave
- Verification: teste automatizado com armazenamento seguro falso (infra)
- Priority:     Required

AC-04: Chave perdida não apaga nada
- Scenario:     o arquivo do banco existe, mas o armazenamento seguro não tem chave (ou falha ao ler)
- Action:       o app abre
- Expected:     a biblioteca e a leitura funcionam; onde haveria registro (página do ponto, Favoritos,
                Coleções) aparece "Não foi possível abrir o que você guardou. Feche o app e abra de novo."
- Must not:     gravar chave nova, apagar, renomear ou sobrescrever o arquivo existente
- Verification: teste automatizado (infra + widget)
- Priority:     Required

AC-05: O registro não sai do aparelho por backup
- Scenario:     o app instalado num Android
- Action:       o sistema faz backup na nuvem ou transfere dados para outro aparelho
- Expected:     o manifesto declara `android:allowBackup="false"` e regras de extração que excluem
                tudo das duas modalidades
- Must not:     —
- Verification: teste automatizado sobre o manifesto + inspeção do Verifier
- Priority:     Required
```

**Independent Test:** abrir o registro num diretório temporário, guardar uma reflexão, ler os bytes
do arquivo: nada legível. Apagar a chave do armazenamento falso e abrir de novo: indisponível, arquivo igual.

---

### P1: Reflexão sobre um ponto ⭐ MVP

**User Story:** Como leitor, quero escrever, num ponto, o que ele provocou em mim — e corrigir ou
apagar depois —, para reler meses depois com a data em que escrevi.

**Why P1:** É o objeto central da v0.3 e do produto (`modelo.md` §4).

**Acceptance Criteria:**

```
AC-06: Escrever e guardar uma reflexão
- Scenario:     página do Caminho 2, sem reflexões
- Action:       tocar "Escrever uma reflexão", digitar "Quero ser útil hoje." e tocar "Guardar"
- Expected:     volta à página do ponto, que mostra "Quero ser útil hoje." e
                "Escrito em <data>, <hora>." com o momento da gravação
- Must not:     criar duas reflexões com um toque duplo em "Guardar"
- Verification: teste de widget com banco em memória e relógio fixo
- Priority:     Required

AC-07: Reflexão vazia não se guarda
- Scenario:     editor de reflexão aberto
- Action:       o campo está vazio ou só tem espaços e quebras de linha
- Expected:     "Guardar" desabilitado; com texto, guarda sem os espaços das pontas
- Must not:     gravar reflexão vazia
- Verification: teste de unidade (motor) + teste de widget
- Priority:     Required

AC-08: Voltar com texto não guardado pede confirmação
- Scenario:     editor cujo texto, sem os espaços das pontas, difere do guardado (reflexão nova:
                guardado = vazio)
- Action:       o leitor volta (botão ou gesto do sistema)
- Expected:     diálogo "Descartar o que você escreveu?" com "Continuar escrevendo" (fica no editor,
                texto intacto) e "Descartar" (sai sem gravar)
- Must not:     perder o texto sem confirmação; pedir confirmação quando não há mudança
- Verification: teste de widget
- Priority:     Required

AC-09: Editar uma reflexão
- Scenario:     reflexão "Quero ser útil hoje." escrita em 12/03/2026 6h40
- Action:       tocar nela, mudar para "Quero ser útil." e guardar em 14/03/2026 21h05
- Expected:     a página mostra o texto novo e "Escrito em 12 de março de 2026, 6h40 · editado em
                14 de março de 2026, 21h05."; guardar sem mudar nada não altera a data de edição
- Must not:     mudar a data de criação; duplicar a reflexão
- Verification: teste de widget com relógio controlado
- Priority:     Required

AC-10: Excluir uma reflexão
- Scenario:     editor de uma reflexão guardada
- Action:       tocar "Excluir"
- Expected:     diálogo "Excluir esta reflexão? Não dá para desfazer." · "Cancelar" mantém tudo ·
                "Excluir" apaga do banco e volta à página do ponto, que não a mostra mais
- Must not:     excluir sem confirmação; excluir outra reflexão
- Verification: teste de widget + consulta ao banco
- Priority:     Required

AC-11: Várias reflexões, só as do ponto, na ordem em que foram escritas
- Scenario:     duas reflexões no Caminho 2 (12/03 e 20/04) e uma no Caminho 81
- Action:       abrir a página do Caminho 2
- Expected:     as duas do Caminho 2, a de 12/03 primeiro; a do Caminho 81 não aparece
- Must not:     misturar reflexões de outro ponto
- Verification: teste de widget
- Priority:     Required

AC-12: Data e hora no formato do produto
- Scenario:     momentos guardados em UTC, mostrados no fuso do aparelho
- Action:       formatar
- Expected:     06:40 → "6h40" · 06:00 → "6h" · 21:05 → "21h05" · 00:00 → "0h";
                mês por extenso e minúsculo: "12 de março de 2026"
- Must not:     mostrar hora UTC
- Verification: teste de unidade
- Priority:     Required

AC-13: Falha ao guardar não perde o texto
- Scenario:     editor com texto; a gravação lança erro
- Action:       tocar "Guardar"
- Expected:     o editor continua aberto com o texto intacto e mostra
                "Não foi possível guardar agora. Tente de novo."; o log registra o tipo do erro
- Must not:     fechar o editor; escrever o texto da reflexão no log
- Verification: teste de widget com falha forçada e captura do log
- Priority:     Required
```

**Independent Test:** página de um ponto → escrever → guardar → a reflexão aparece com data; editar
e excluir pelo editor.

---

### P1: Favorito ⭐ MVP

**User Story:** Como leitor, quero marcar um ponto com um toque e achá-lo depois numa lista, para
voltar a ele sem lembrar o número.

**Why P1:** Acesso rápido é a forma mais simples de "encontrar de novo".

**Acceptance Criteria:**

```
AC-14: Favoritar e desfavoritar na página do ponto
- Scenario:     página do Caminho 2, não favorito
- Action:       tocar o botão "Favoritar"; tocar de novo
- Expected:     após o 1º toque o botão passa a "Remover dos favoritos" (rótulo acessível e ícone
                preenchido) e o ponto está nos favoritos; após o 2º volta a "Favoritar" e sai
- Must not:     duplicar o favorito
- Verification: teste de widget + consulta ao banco
- Priority:     Required

AC-15: Lista de favoritos
- Scenario:     Caminho 2 favoritado antes de Caminho 81
- Action:       na biblioteca, tocar "Favoritos"
- Expected:     Caminho 81 primeiro, depois Caminho 2, cada um com a referência completa e o início
                do texto; tocar abre a página daquele ponto. Sem favoritos:
                "Os pontos que você favoritar ficam aqui."
- Must not:     mostrar o PontoId cru
- Verification: teste de widget
- Priority:     Required
```

**Independent Test:** favoritar dois pontos, abrir Favoritos pela biblioteca, abrir um deles.

---

### P1: Coleção pessoal ⭐ MVP

**User Story:** Como leitor, quero reunir pontos em listas com nomes meus, e um ponto pode estar em
várias, para voltar a eles pelo assunto que estou trabalhando.

**Why P1:** "Um ponto em várias" é a promessa da coleção pessoal no roadmap.

**Acceptance Criteria:**

```
AC-16: Criar uma coleção a partir de um ponto
- Scenario:     página do Caminho 2; sugestões já respondidas; nenhuma coleção
- Action:       tocar "Guardar em uma coleção", tocar "Nova coleção", digitar "Família", confirmar
- Expected:     a coleção "Família" existe e já contém o Caminho 2 (marcada na tela)
- Must not:     criar a coleção sem o ponto (tudo ou nada)
- Verification: teste de widget + consulta ao banco
- Priority:     Required

AC-17: Um ponto em várias coleções
- Scenario:     coleções "Família" e "Pontos para reler"; Caminho 2 em nenhuma
- Action:       em "Guardar em uma coleção", marcar as duas; depois desmarcar "Família"
- Expected:     após marcar, o ponto está nas duas; após desmarcar, só em "Pontos para reler"
- Must not:     afetar outra coleção ou outro ponto
- Verification: teste de widget + consulta ao banco
- Priority:     Required

AC-18: Regras do nome
- Scenario:     existe a coleção "Família"
- Action:       criar (ou renomear para) "  família ", "" ou um nome com 61 caracteres
- Expected:     "  família " → recusado com "Já existe uma coleção com esse nome." ·
                "" ou só espaços → confirmar desabilitado · 61 caracteres → o campo não aceita além de 60 ·
                "  Trabalho " → guardado como "Trabalho"
- Must not:     criar coleção com nome repetido ou vazio
- Verification: teste de unidade (motor) + teste de widget
- Priority:     Required

AC-19: Lista de coleções
- Scenario:     "Pontos para reler" (2 pontos) criada antes de "Família" (1 ponto) e "Trabalho" (0)
- Action:       na biblioteca, tocar "Coleções"
- Expected:     nesta ordem: "Pontos para reler · 2 pontos", "Família · 1 ponto", "Trabalho · Nenhum ponto";
                botão "Nova coleção". Sem coleções:
                "Crie uma coleção para reunir pontos sobre o que você quiser trabalhar."
- Must not:     ordenar por nome ou por tamanho
- Verification: teste de widget
- Priority:     Required

AC-20: Pontos de uma coleção
- Scenario:     "Pontos para reler" com Caminho 2 guardado antes de Sulco 1
- Action:       abrir a coleção
- Expected:     Sulco 1 primeiro, depois Caminho 2, com referência completa e início do texto; tocar
                abre a página do ponto. Vazia: "Nada aqui ainda. O que você salvar aparece nesta lista."
- Must not:     mostrar pontos de outra coleção
- Verification: teste de widget
- Priority:     Required
```

**Independent Test:** criar "Família" a partir de um ponto, guardar outro ponto nela, abrir
Coleções → Família pela biblioteca.

---

### P1: O registro do ponto na própria página ⭐ MVP

**User Story:** Como leitor, quero ver, na página de um ponto, o que já guardei sobre ele, para que
reler o ponto traga junto o que ele me pediu antes.

**Why P1:** Linha explícita do roadmap; é onde reflexão e texto se encontram.

**Acceptance Criteria:**

```
AC-21: A página mostra as coleções do ponto
- Scenario:     Caminho 2 em "Pontos para reler" e "Família"
- Action:       abrir a página do Caminho 2
- Expected:     "Nas coleções: Pontos para reler · Família" (ordem de criação); num ponto sem coleção
                essa linha não aparece
- Must not:     listar coleções que não contêm o ponto
- Verification: teste de widget
- Priority:     Required

AC-22: A página acompanha o que muda e o ponto mostrado
- Scenario:     página do Caminho 2 aberta
- Action:       (a) guardar/editar/excluir reflexão, favoritar, marcar coleção e voltar; (b) tocar "Próximo"
- Expected:     (a) a página já mostra o estado novo, sem reabrir; (b) favorito, coleções e reflexões
                passam a ser os do Caminho 81
- Must not:     mostrar o registro do ponto anterior depois de "Próximo"
- Verification: teste de widget
- Priority:     Required
```

**Independent Test:** abrir um ponto com reflexão e coleções; tocar "Próximo" e ver o registro do seguinte.

---

### P2: Coleções sugeridas, recusáveis

**User Story:** Como leitor que nunca organizou pontos, quero começar com algumas coleções prontas
se eu quiser, para não travar diante de uma lista vazia.

**Why P2:** Ajuda o começo, mas o fluxo de coleção funciona sem ela.

**Acceptance Criteria:**

```
AC-23: Sugestões no primeiro contato com coleções
- Scenario:     sugestões nunca respondidas
- Action:       tocar "Coleções" na biblioteca ou "Guardar em uma coleção" num ponto
- Expected:     tela "Quer começar com algumas coleções?" com os sete nomes da A11, nenhum marcado;
                "Criar" desabilitado até marcar um; "Agora não" sempre disponível
- Must not:     criar qualquer coleção sem escolha explícita
- Verification: teste de widget
- Priority:     Should

AC-24: Criar as escolhidas
- Scenario:     tela de sugestões; marcadas "Família" e "Pontos para reler"
- Action:       tocar "Criar"
- Expected:     as duas existem, na ordem da A11 ("Pontos para reler" antes de "Família"); o leitor
                segue para onde ia; a tela não aparece mais, nem depois de reabrir o app
- Must not:     criar as não marcadas
- Verification: teste de widget + reabrir o banco
- Priority:     Should

AC-25: Recusar
- Scenario:     tela de sugestões
- Action:       tocar "Agora não" (ou voltar)
- Expected:     nenhuma coleção criada; "Agora não" segue para onde o leitor ia, voltar retorna à tela
                anterior; a tela não aparece mais, nem depois de reabrir o app
- Must not:     voltar a sugerir
- Verification: teste de widget + reabrir o banco
- Priority:     Should
```

**Independent Test:** primeiro toque em "Coleções" mostra as sugestões; "Agora não"; segundo toque
vai direto à lista.

---

### P2: Renomear e excluir uma coleção

**User Story:** Como leitor, quero corrigir o nome de uma coleção ou desfazer uma que não uso, para
que a lista continue sendo minha.

**Why P2:** Sem isso, uma sugestão aceita por engano fica para sempre — o leitor de teste pediria.

**Acceptance Criteria:**

```
AC-26: Renomear
- Scenario:     coleção "Familia" aberta
- Action:       "Renomear" → "Família" → confirmar
- Expected:     o novo nome aparece na coleção, na lista e na página dos pontos; mesmas regras da AC-18
- Must not:     mudar os pontos da coleção
- Verification: teste de widget
- Priority:     Should

AC-27: Excluir
- Scenario:     coleção "Trabalho" com o Caminho 2, que tem uma reflexão e é favorito
- Action:       "Excluir coleção" → diálogo "Excluir a coleção Trabalho? Os pontos e as reflexões continuam." →
                "Excluir"
- Expected:     a coleção some da lista e da página do Caminho 2; o favorito e a reflexão continuam;
                "Cancelar" não muda nada
- Must not:     apagar ponto, favorito, reflexão ou outra coleção
- Verification: teste de widget + consulta ao banco
- Priority:     Should
```

---

## Edge Cases

- WHEN a reflexão é longa e o texto está em "Muito grande" THEN editor e página rolam, sem cortar texto.
- WHEN o banco tem uma linha com `pontoId` que não é um PontoId válido THEN a linha é ignorada na leitura, sem travar a tela.
- WHEN um ponto guardado não existe na coleção carregada THEN ele não aparece nas listas e o dado fica (A14).
- WHEN o mesmo ponto é favoritado duas vezes (toque duplo) THEN existe um só favorito.
- WHEN o leitor marca uma coleção em que o ponto já está THEN nada muda (sem duplicata).
- WHEN a tela tem 320 px e texto grande THEN botões da página do ponto e do editor não transbordam (piso de UX da v0.2).
- WHEN o registro está indisponível (AC-04) THEN favoritar, guardar em coleção e escrever não aparecem — só a mensagem.

---

## Implicit-requirement sweep (Complex → todas as dimensões)

| Dimensão | Resolução |
| --- | --- |
| Validação de entrada e limites | Reflexão: AC-07, A13. Nome de coleção: AC-18, A12. `pontoId` lido do banco: edge case (ignorado se inválido) |
| Falha / falha parcial | Banco não abre: AC-04. Sem cifra: AC-02. Gravação falha: AC-13. Coleção criada com ponto e sugestões criadas com a marca de "respondidas": tudo ou nada (AC-16, AC-24) |
| Idempotência / retry / duplicidade | Favorito e ponto-em-coleção são conjuntos (AC-14, edge cases). Toque duplo em "Guardar": AC-06 |
| Autorização e rate limit | N/A — sem conta e sem rede; um único leitor por aparelho, protegido pelo bloqueio do sistema |
| Concorrência / ordem | Escritas serializadas pelo banco; listas ordenadas por momento gravado (A5–A7); empates resolvidos pela ordem de inserção |
| Ciclo de vida do dado | Vive até o leitor excluir ou desinstalar; excluir é definitivo e confirmado (AC-10, AC-27); fora de backup (AC-05, A3) |
| Observabilidade | Falhas vão ao log do Flutter com o tipo do erro, **nunca o texto** (AC-13); sem telemetria |
| Dependência externa | Armazenamento seguro do sistema falha → mesmo caminho da chave perdida (AC-04). Nada de rede |
| Integridade de estado | Reflexão: nova → guardada → editada* → excluída. Sugestões: não respondidas → respondidas (só ida). Favorito: sim/não |

**Rollback (operações destrutivas):** excluir reflexão (AC-10) e coleção (AC-27) sempre pedem
confirmação e não têm desfazer. O esquema nasce na versão 1, sem migração. Reverter a v0.3 =
reverter os commits; o arquivo cifrado fica sem uso e a v0.2 o ignora.

---

## Requirement Traceability

| ID | Story | AC | Status |
| --- | --- | --- | --- |
| CIFRA-01 | P1 Cifrado | AC-01 | Implemented |
| CIFRA-02 | P1 Cifrado | AC-02 | Implemented |
| CIFRA-03 | P1 Cifrado | AC-03 | Implemented |
| CIFRA-04 | P1 Cifrado | AC-04 | Implemented |
| CIFRA-05 | P1 Cifrado | AC-05 | Implemented |
| REF-01 | P1 Reflexão | AC-06 | Implemented |
| REF-02 | P1 Reflexão | AC-07 | Implemented |
| REF-03 | P1 Reflexão | AC-08 | Implemented |
| REF-04 | P1 Reflexão | AC-09 | Implemented |
| REF-05 | P1 Reflexão | AC-10 | Implemented |
| REF-06 | P1 Reflexão | AC-11 | Implemented |
| REF-07 | P1 Reflexão | AC-12 | Implemented |
| REF-08 | P1 Reflexão | AC-13 | Implemented |
| FAV-01 | P1 Favorito | AC-14 | Implemented |
| FAV-02 | P1 Favorito | AC-15 | Implemented |
| COL-01 | P1 Coleção | AC-16 | Implemented |
| COL-02 | P1 Coleção | AC-17 | Implemented |
| COL-03 | P1 Coleção | AC-18 | Implemented |
| COL-04 | P1 Coleção | AC-19 | Implemented |
| COL-05 | P1 Coleção | AC-20 | Implemented |
| PAG-01 | P1 Página | AC-21 | Implemented |
| PAG-02 | P1 Página | AC-22 | Implemented |
| SUG-01 | P2 Sugestões | AC-23 | Implemented |
| SUG-02 | P2 Sugestões | AC-24 | Implemented |
| SUG-03 | P2 Sugestões | AC-25 | Implemented |
| COL-06 | P2 Renomear/excluir | AC-26 | Implemented |
| COL-07 | P2 Renomear/excluir | AC-27 | Implemented |

**ID format:** `CIFRA` (infra), `REF` (reflexão), `FAV` (favorito), `COL` (coleção pessoal),
`PAG` (página do ponto), `SUG` (sugestões).

**Coverage:** 27 total, 27 mapped to tasks (ver `tasks.md` › Requirement → Task).

---

## Success Criteria

- [ ] Caminho 2 → escrever → guardar → a reflexão aparece com data, em 2 toques mais o texto.
- [ ] Biblioteca → Favoritos → ponto, e Biblioteca → Coleções → coleção → ponto, sem tela vazia inesperada.
- [ ] Os bytes do banco não contêm nenhum texto guardado; o log de uma falha não contém o texto.
- [ ] `flutter test`, `dart test` e `validar.py` verdes; zero issues de análise; APK debug gera.
