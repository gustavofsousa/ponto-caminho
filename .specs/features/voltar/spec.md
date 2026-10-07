# Voltar (v0.4) — Specification

**Escopo:** Complex (domínio novo `leitura`, migração do banco cifrado v1 → v2, primeira tela inicial,
chamada à folha de compartilhamento do sistema) · **Roadmap:** v0.4 "Voltar" ·
**Branch:** `feat/v0.4-voltar` (sobre `feat/v0.3-guardar`)
**Fontes:** [`docs/roadmap.md`](../../../docs/roadmap.md) v0.4 · [`docs/modelo.md`](../../../docs/modelo.md) §1, §3, §4, §6, §7 ·
[`docs/dominios.md`](../../../docs/dominios.md) regras 1, 2, 4, 5, 6 · [`docs/tom-de-voz.md`](../../../docs/tom-de-voz.md) §1, §4 ·
[`docs/backlog.md`](../../../docs/backlog.md) › `leitura`, `selecao`, `colecao` · ADR-002 · AD-005, AD-007, AD-009

## Problem Statement

Até a v0.3, quem abre o app cai numa lista de livros e precisa escolher obra, capítulo e ponto antes
de ler qualquer coisa. Quem não sabe por onde começar desiste; quem lia em sequência precisa lembrar
onde parou. A v0.4 abre o app em duas portas de um toque — continuar a leitura ou receber um ponto
para agora — e começa o domínio `leitura`, que grava o que foi aberto e é a base de todo progresso
futuro. E deixa mandar a alguém a referência de um ponto, nunca o texto (direitos, `modelo.md` §7).

## Goals

- [ ] Da abertura do app até um ponto na tela em **1 toque** (continue ou um ponto para agora).
- [ ] "Continue de onde parou" leva ao último ponto lido em sequência, também depois de fechar e reabrir o app.
- [ ] "Um ponto para agora" nunca devolve um dos 10 últimos pontos lidos enquanto o filtro tiver outro ponto.
- [ ] Nenhuma linha guardada na v0.3 se perde na migração; nenhuma leitura em claro no disco nem no log.
- [ ] O compartilhamento leva só a referência — nunca o texto do ponto nem uma reflexão.

## Out of Scope

| Item | Motivo |
| --- | --- |
| Telas de boas-vindas (`tom-de-voz.md` §2) | Continuam na Incubadora — decisão do usuário ao puxar a v0.4 |
| Ponto do dia, preferências do ponto do dia | v1.1 (`selecao`, `preferencias`) |
| Progresso por capítulo/obra, estado do capítulo, marcar capítulo concluído | v1.3 (`leitura`) |
| Ver ou apagar o histórico de leitura | Não está no roadmap; vai ao backlog (`leitura`). Na v0.4 o histórico só serve ao continue e aos recentes |
| Filtro do aleatório por capítulo ou tema | backlog `selecao` › Novo / Visão |
| Lembrar a obra escolhida no filtro entre aberturas do app | Não pedido; preferências entram com a v1.1 |
| Botão "outro ponto para agora" na página do ponto | Não pedido; voltar e tocar de novo resolve; vai ao backlog |
| Compartilhar o texto do ponto, uma reflexão ou uma coleção | Direitos (`modelo.md` §7) e regra 5; coleção é v3.0 |
| Link ou deep link no texto compartilhado | Não existe deep link (AD-006); o app não está publicado |
| Telemetria da origem | Constituição: sem telemetria; a origem fica só no aparelho |
| Proteção contra toque duplo nos botões de navegação | O app inteiro (v0.2) não protege; empilhar duas páginas não perde nada |
| Origens `ponto-do-dia` e `busca` | Nenhuma tela as produz antes da v1.1/v1.2; entram com elas |
| Configuração e teste no iOS | Mesmo débito da v0.3 (TD-005) |

---

## Assumptions & Open Questions

A1–A6 foram decididas pelo usuário ao puxar a v0.4. As demais são do agente; as marcadas "UAT" são
revistas no aparelho (TD-004).

| # | Decisão | Default escolhido | Motivo | Confirmado? |
| --- | --- | --- | --- | --- |
| A1 | Janela de "recentes" do aleatório (backlog › `selecao`) | Os **10 últimos pontos distintos** lidos, de qualquer origem. Se o filtro não tiver ponto fora deles, a janela encolhe a partir dos mais antigos até sobrar ao menos um | Contagem não depende do relógio; vale igual para quem lê todo dia ou uma vez por mês | sim (usuário) |
| A2 | O que conta como "lido" (backlog › `leitura`) | **Abrir a página do ponto** — inclusive trocar de ponto por Anterior/Próximo | Ponto é curto: abrir é ler. Sem timer nem rolagem | sim (usuário) |
| A3 | Escopo | Um spec para as quatro linhas da v0.4, com slices internas | Mesmo formato da v0.3 | sim (usuário) |
| A4 | Onde ficam continue e aleatório | **Tela inicial nova**, antes da biblioteca | É a "Tela inicial" do `tom-de-voz.md` §4; cumpre "um toque" | sim (usuário) |
| A5 | Onde mora a leitura | Tabela `leituras` no **banco cifrado** do registro; `schemaVersion` 1 → 2 com migração | Histórico de leitura revela a vida interior tanto quanto a reflexão (regra 5) | sim (usuário) |
| A6 | Registro indisponível (chave perdida, AC-04 da v0.3) | Aleatório funciona sem excluir recentes; o continue some; **nenhum aviso** na tela inicial | A leitura nunca depende do registro (ADR-002) | sim (usuário) |
| A7 | Para onde o continue aponta | O último ponto lido **em sequência**: leitura de origem `biblioteca` ou `continuacao`. Pontos abertos por "um ponto para agora", Favoritos ou coleção **não mudam** o lugar | Um desvio não deve perder o fio da leitura. O `modelo.md` §4 diz só "última leitura"; ele é ajustado | não — revisar |
| A8 | Origem de Anterior/Próximo | Sempre `biblioteca`, qualquer que seja a origem da página | Quem toca em Próximo está lendo os livros em ordem; assim um ponto aleatório vira o fio da leitura quando a pessoa segue adiante | não — UAT |
| A9 | Origens na v0.4 | `biblioteca` · `continuacao` · `aleatorio` · `favoritos` · `colecao` (conjunto fechado). O `modelo.md` §4 ganha `continuacao` e `favoritos` | O modelo separa Favorito de coleção; sem `continuacao` não se sabe se o continue é usado | não — revisar |
| A10 | Rótulos da tela inicial | "Continue de onde parou" com a referência do destino abaixo · "Um ponto para agora" · "Biblioteca" (sem ponto final em botão) | `tom-de-voz.md` §4; a pessoa sabe para onde vai antes de tocar | não — UAT |
| A11 | Sem leitura em sequência | O continue **não aparece**; nada no lugar | Estado vazio nunca constata falta; "Comece pelo ponto 1" é das boas-vindas (fora de escopo) | não — UAT |
| A12 | Último ponto em sequência não existe na coleção carregada | O continue usa, dentre os **10 últimos pontos distintos** lidos em sequência, o mais recente que exista; se nenhum, some. A linha fica no banco | Igual à A14 da v0.3: nada do leitor some por mudança de conteúdo. O limite mantém a consulta pequena | sim (agente) |
| A13 | Filtro de obra | Escolha única: "Todas as obras" (padrão) e os títulos das obras com ao menos um ponto disponível, na ordem da coleção. Vale até fechar o app | Opções vindas do dado (regra 1); lembrar entre aberturas está fora de escopo | não — UAT |
| A14 | Sorteio | Uniforme entre os candidatos; a fonte de aleatoriedade é parâmetro (regra 6). Candidatos em ordem estável: obras na ordem da coleção, pontos em ordem de leitura | Torna o resultado determinístico em teste | sim (doc) |
| A15 | O que conta como "recente" | Leitura de **qualquer** origem | A surpresa é o valor (`modelo.md` §3); um ponto relido por uma coleção também é recente | sim (agente) |
| A16 | "Mais recente" | Ordem de **gravação**, não de `lidoEm` | Se o relógio do aparelho voltar, a ordem de gravação continua certa | sim (agente) |
| A17 | Reler um ponto | Cada abertura grava uma leitura nova | Leitura é evento, não estado (regra 4) | sim (doc) |
| A18 | Texto compartilhado | Exatamente `Referencia.texto` — ex.: "Caminho, capítulo Caráter, ponto 1" | `modelo.md` §1 e §7; autor só poderia vir do dado (regra 1) e não existe no código hoje | não — UAT |
| A19 | Onde fica o compartilhar | Ícone na barra da página do ponto, rótulo "Compartilhar referência" | Visível sem competir com o texto | não — UAT |
| A20 | Folha de compartilhamento falha | Mensagem "Não foi possível compartilhar." e erro no log só pelo tipo | O leitor sabe que nada saiu; o log não diz o que ele lia | sim (agente) |
| A21 | Falha ao gravar uma leitura | A página abre normalmente, **sem mensagem**; log só com o tipo do erro (AD-009) | A leitura não é algo que o leitor escreveu: não há o que refazer | sim (agente) |
| A22 | Favoritos e Coleções | Continuam dentro da Biblioteca | Um favorito fica a 3 toques da abertura — a meta da v0.3 se mantém | não — UAT |
| A23 | Migração v1 → v2 | Só cria a tabela de leituras, numa transação. Se falhar: registro indisponível (AC-04 da v0.3), arquivo e linhas intactos, versão continua 1 | Nunca recriar o banco (ADR-002) | sim (ADR-002) |
| A24 | Exemplos dos ACs × dados de teste | Telas usam `colecaoDeTeste` e banco em memória; migração e cifra usam arquivo real | Igual à A17 da v0.3 | sim (agente) |

**Open questions:** nenhuma — todas resolvidas ou registradas acima.

---

## User Stories

### P1: A leitura fica registrada ⭐ MVP

**User Story:** Como leitor, quero que o app saiba o que eu já abri, para poder me devolver ao meu
lugar e não me repetir o que acabei de ler.

**Why P1:** Continue e aleatório dependem disso; é o primeiro dado do domínio `leitura`.

**Acceptance Criteria:**

```
AC-01: Abrir um ponto grava uma leitura
- Scenario:     registro disponível, nenhuma leitura gravada, relógio do teste em 2026-10-07 09:15 UTC
- Action:       o leitor abre um ponto pela biblioteca (obra → capítulo → ponto)
- Expected:     existe exatamente uma leitura, com o PontoId desse ponto, origem `biblioteca`
                e `lidoEm` = 2026-10-07 09:15 UTC
- Must not:     gravar posição (`ordem`, índice) no lugar do PontoId; gravar o texto do ponto
- Verification: teste automatizado (app, banco em memória, relógio falso)
- Priority:     Required

AC-02: Cada entrada grava a própria origem
- Scenario:     registro disponível, um favorito e uma coleção pessoal com um ponto, uma leitura em sequência
- Action:       o leitor abre um ponto por cada entrada: "Continue de onde parou", "Um ponto para agora",
                Favoritos, a coleção pessoal
- Expected:     as leituras gravadas têm origem, respectivamente, `continuacao`, `aleatorio`,
                `favoritos`, `colecao`
- Must not:     uma entrada gravar a origem de outra
- Verification: teste automatizado, um caso por entrada
- Priority:     Required

AC-03: Anterior e Próximo gravam cada ponto mostrado
- Scenario:     o leitor está num ponto aberto por "Um ponto para agora" (1 leitura `aleatorio`)
- Action:       toca Próximo e depois Anterior
- Expected:     duas leituras novas, na ordem dos toques — o ponto seguinte e depois o ponto inicial —,
                ambas com origem `biblioteca`
- Must not:     gravar leitura sem que o ponto mostrado mude
- Verification: teste automatizado
- Priority:     Required

AC-04: Reconstruir a página não grava leitura
- Scenario:     o leitor está na página de um ponto (1 leitura gravada)
- Action:       troca o tema, troca o tamanho do texto e guarda uma reflexão nessa página
- Expected:     continua existindo 1 leitura desse ponto
- Must not:     gravar uma leitura por reconstrução da tela
- Verification: teste automatizado
- Priority:     Required

AC-05: Falha ao gravar a leitura não atrapalha ler
- Scenario:     (a) registro indisponível; (b) a gravação lança uma exceção do banco;
                (c) a gravação lança um erro que não é do banco
- Action:       o leitor abre um ponto
- Expected:     o texto do ponto aparece; nenhuma mensagem nova na página; em (b) e (c) o log recebe
                só o tipo do erro
- Must not:     o log conter o PontoId, o texto do ponto ou a mensagem original do erro; a página travar
- Verification: teste automatizado, um caso por cenário
- Priority:     Required

AC-06: A migração preserva o que a v0.3 guardou
- Scenario:     arquivo de registro cifrado criado com o schema 1, com uma reflexão (editada), um favorito
                e uma coleção pessoal com um ponto
- Action:       o app da v0.4 abre o registro com a mesma chave
- Expected:     reflexão (texto, criadaEm, editadaEm, ponto), favorito (ponto, data) e coleção (nome,
                ponto, data) iguais aos de antes; `user_version` = 2; uma leitura gravada é lida de volta
- Must not:     recriar o arquivo; gerar chave nova; existir em algum momento o arquivo em claro
- Verification: teste automatizado com arquivo real cifrado (infra)
- Priority:     Required

AC-07: Migração que falha não perde nada (rollback)
- Scenario:     arquivo cifrado com o schema 1 e as mesmas linhas do AC-06, onde a criação da tabela
                de leituras vai falhar (já existe um objeto `leituras` incompatível)
- Action:       o app da v0.4 abre o registro
- Expected:     o registro fica indisponível (mensagem do AC-04 da v0.3 onde haveria registro); a leitura
                dos livros funciona; o arquivo continua com `user_version` = 1 e todas as linhas
- Must not:     apagar ou recriar o arquivo; deixar o schema pela metade
- Verification: teste automatizado com arquivo real cifrado (infra)
- Priority:     Required

AC-08: A leitura só existe dentro do banco cifrado
- Scenario:     registro em arquivo real cifrado; preferências com valores falsos em memória
- Action:       o leitor abre `ponto:caminho-sulco-forja/caminho/7` e o banco é fechado
- Expected:     os bytes do arquivo não contêm essa string (UTF-8) nem "SQLite format 3"; nenhum valor
                das preferências contém essa string
- Must not:     existir rastro de leitura fora do banco cifrado
- Verification: teste automatizado (infra para os bytes; app para as preferências)
- Priority:     Required
```

**Independent Test:** abrir três pontos por caminhos diferentes e consultar o banco: três leituras,
cada uma com seu PontoId, origem e hora.

---

### P1: Continue de onde parou ⭐ MVP

**User Story:** Como leitor que lê em sequência, quero voltar ao meu lugar com um toque, para não
precisar lembrar obra, capítulo e número.

**Why P1:** Metade do alvo da fase ("chegar num ponto em um toque").

**Acceptance Criteria:**

```
AC-09: Continue leva ao último ponto lido em sequência
- Scenario:     leituras gravadas, da mais antiga para a mais nova: ponto A (`biblioteca`),
                ponto B (`biblioteca`), ponto C (`aleatorio`), ponto D (`favoritos`), ponto E (`colecao`)
- Action:       o leitor abre o app e toca em "Continue de onde parou"
- Expected:     a tela inicial mostra "Continue de onde parou" e, abaixo, a referência de B; o toque
                abre a página de B
- Must not:     apontar para C, D ou E
- Verification: teste automatizado (motor: função pura; app: tela)
- Priority:     Required

AC-10: O continue acompanha a leitura sem reabrir o app
- Scenario:     o continue aponta para B
- Action:       o leitor toca no continue, toca Próximo e volta à tela inicial
- Expected:     o continue mostra a referência do ponto seguinte a B
- Must not:     exigir fechar e abrir o app para atualizar
- Verification: teste automatizado
- Priority:     Required

AC-11: O continue sobrevive a fechar o app
- Scenario:     o leitor leu B em sequência; o registro é fechado
- Action:       o registro é aberto de novo sobre o mesmo arquivo e a tela inicial é montada
- Expected:     o continue mostra a referência de B
- Must not:     guardar o lugar só em memória
- Verification: teste automatizado com banco em arquivo
- Priority:     Required

AC-12: Sem leitura em sequência, o continue não aparece
- Scenario:     (a) nenhuma leitura; (b) só leituras `aleatorio`, `favoritos` e `colecao`
- Action:       o leitor abre o app
- Expected:     não existe "Continue de onde parou"; "Um ponto para agora" e "Biblioteca" aparecem
- Must not:     texto de falta ou de estado vazio no lugar do continue
- Verification: teste automatizado, um caso por cenário
- Priority:     Required

AC-13: Ponto que sumiu da coleção é pulado, não apagado
- Scenario:     leituras em sequência: B, depois `ponto:<colecao de teste>/<obra>/999` (não existe na coleção)
- Action:       o leitor abre o app
- Expected:     o continue aponta para B; a leitura do ponto 999 continua no banco
- Must not:     travar a tela inicial; apagar a linha
- Verification: teste automatizado
- Priority:     Required

AC-14: Registro indisponível: o continue some sem aviso
- Scenario:     registro indisponível (chave perdida)
- Action:       o leitor abre o app
- Expected:     a tela inicial mostra "Um ponto para agora" e "Biblioteca"; nenhum continue
- Must not:     mostrar "Não foi possível abrir o que você guardou" na tela inicial
- Verification: teste automatizado
- Priority:     Required
```

**Independent Test:** ler dois pontos em sequência, abrir um aleatório, voltar à tela inicial: o
continue aponta para o segundo ponto da sequência.

---

### P1: Um ponto para agora ⭐ MVP

**User Story:** Como leitor que não sabe por onde começar, quero receber um ponto com um toque,
sem repetir o que li há pouco.

**Why P1:** A outra metade do alvo da fase.

**Acceptance Criteria:**

```
AC-15: Um toque abre um ponto
- Scenario:     tela inicial com "Todas as obras"; nenhuma leitura; fonte de aleatoriedade falsa que
                devolve o índice k
- Action:       o leitor toca em "Um ponto para agora"
- Expected:     abre a página do k-ésimo ponto disponível da coleção, contando obras na ordem da coleção
                e pontos em ordem de leitura (k = 0 → primeiro ponto da primeira obra; k = n − 1 → último
                ponto da última obra); a fonte é consultada com n = número de candidatos
- Must not:     usar aleatoriedade ou relógio que não venham por parâmetro (regra 6)
- Verification: teste automatizado (motor e tela)
- Priority:     Required

AC-16: Os 10 últimos pontos lidos ficam de fora
- Scenario:     coleção com ao menos 12 pontos; os 11 últimos pontos distintos lidos são P1 (mais novo) … P11
- Action:       pede-se um ponto para agora para cada valor possível da fonte
- Expected:     nenhum resultado está entre P1 e P10; P11 aparece entre os resultados
- Must not:     excluir mais de 10 pontos
- Verification: teste automatizado (motor), todas as saídas da fonte enumeradas
- Priority:     Required

AC-17: Reler o mesmo ponto conta uma vez
- Scenario:     12 leituras, da mais nova para a mais antiga: P1, P1, P1, P2 … P10 (10 pontos distintos), P11
- Action:       pede-se um ponto para agora para cada valor possível da fonte
- Expected:     P1 a P10 ficam de fora; P11 aparece entre os resultados
- Must not:     contar cada leitura repetida como um recente
- Verification: teste automatizado (motor)
- Priority:     Required

AC-18: A janela encolhe quando a obra tem poucos pontos
- Scenario:     filtro numa obra com 5 pontos (S1…S5); todos estão entre os 10 últimos lidos; da mais nova
                para a mais antiga, a ordem deles é S3, S1, S5, S2, S4
- Action:       pede-se um ponto dessa obra para cada valor possível da fonte
- Expected:     o resultado é sempre S4 (o ponto da obra lido há mais tempo)
- Must not:     não devolver ponto; devolver S3 (o último lido)
- Verification: teste automatizado (motor)
- Priority:     Required

AC-19: O filtro limita o sorteio a uma obra
- Scenario:     coleção de teste com uma obra sem nenhum ponto disponível
- Action:       o leitor abre o app, escolhe uma obra no filtro e toca em "Um ponto para agora"; volta
- Expected:     as opções são "Todas as obras" e depois os títulos das obras com ponto disponível, na
                ordem da coleção; "Todas as obras" vem escolhida; o ponto aberto é da obra escolhida
                (para cada valor da fonte); ao voltar, a obra escolhida continua escolhida
- Must not:     oferecer a obra sem ponto; id de obra escrito no código do app (regra 1)
- Verification: teste automatizado (tela e motor)
- Priority:     Required

AC-20: Sem registro, o sorteio funciona sem recentes
- Scenario:     (a) registro indisponível; (b) a consulta dos recentes lança erro
- Action:       o leitor toca em "Um ponto para agora"
- Expected:     abre um ponto; todos os pontos do filtro são candidatos; em (b) o log recebe só o tipo do erro
- Must not:     mensagem de erro; nenhum ponto aberto
- Verification: teste automatizado, um caso por cenário
- Priority:     Required
```

**Independent Test:** com 10 pontos lidos, tocar "Um ponto para agora" repetidas vezes nunca abre um deles.

---

### P1: Tela inicial ⭐ MVP

**User Story:** Como leitor, quero abrir o app e ver por onde seguir, sem passar por uma lista de livros.

**Why P1:** É onde continue e aleatório moram (A4).

**Acceptance Criteria:**

```
AC-21: O app abre na tela inicial
- Scenario:     livros carregados, registro disponível, uma leitura em sequência
- Action:       o app abre
- Expected:     a primeira tela mostra, de cima para baixo: o continue, "Um ponto para agora" com o filtro,
                "Biblioteca"; tocar em "Biblioteca" abre as obras, com Favoritos e Coleções
- Must not:     mostrar contagem de pontos lidos, data ou tempo desde a última leitura, ou qualquer
                menção à ausência (regra 4, `tom-de-voz.md` §1)
- Verification: teste automatizado
- Priority:     Required

AC-22: Um favorito continua a 3 toques da abertura
- Scenario:     um ponto favoritado
- Action:       o app abre; o leitor toca Biblioteca → Favoritos → o ponto
- Expected:     a página do ponto aparece no terceiro toque
- Must not:     exigir um quarto toque (meta da v0.3)
- Verification: teste automatizado
- Priority:     Required

AC-23: A tela inicial cabe numa tela estreita com texto grande
- Scenario:     largura 320 px, escala do sistema 2,0 e o maior tamanho de texto do app; continue visível
- Action:       a tela inicial é montada
- Expected:     nenhum erro de transbordamento; o continue, o filtro e "Biblioteca" são alcançáveis rolando
- Must not:     cortar a referência do continue
- Verification: teste automatizado
- Priority:     Required
```

**Independent Test:** abrir o app num aparelho estreito com fonte grande e chegar a um ponto em um toque.

---

### P2: Compartilhar a referência

**User Story:** Como leitor, quero mandar a alguém onde está um ponto que me tocou, para que essa
pessoa o encontre no livro dela.

**Why P2:** Está na v0.4, mas não é o alvo da fase ("chegar num ponto em um toque").

**Acceptance Criteria:**

```
AC-24: Compartilhar envia só a referência
- Scenario:     página de um ponto com uma reflexão guardada e o ponto numa coleção pessoal
- Action:       o leitor toca em "Compartilhar referência"
- Expected:     a folha de compartilhamento do sistema recebe exatamente o texto da referência mostrada
                no topo da página (ex.: "Caminho, capítulo Caráter, ponto 1")
- Must not:     conter o texto do ponto, o texto da reflexão, o nome da coleção ou o PontoId cru
- Verification: teste automatizado com porta de compartilhamento falsa
- Priority:     Required

AC-25: Falha ao compartilhar avisa e não derruba nada
- Scenario:     a folha de compartilhamento lança erro
- Action:       o leitor toca em "Compartilhar referência"
- Expected:     aparece "Não foi possível compartilhar."; a página continua; o log recebe só o tipo do erro
- Must not:     o log conter a referência ou a mensagem original do erro
- Verification: teste automatizado
- Priority:     Required

AC-26: O botão é acessível
- Scenario:     página de um ponto
- Action:       o leitor de tela percorre a barra superior
- Expected:     o botão anuncia "Compartilhar referência"; o alvo de toque mede ao menos 48 × 48 dp
- Must not:     botão só com ícone, sem rótulo
- Verification: teste automatizado
- Priority:     Required
```

**Independent Test:** num ponto com reflexão, compartilhar e conferir que só a referência saiu.

---

## Edge Cases

- WHEN o filtro tem um só ponto disponível e ele é o último lido THEN o aleatório SHALL devolvê-lo (a janela encolhe a zero).
- WHEN uma leitura gravada tem PontoId estragado THEN continue e recentes SHALL ignorá-la, sem apagá-la (`lerPontoIdGravado`).
- WHEN o relógio do aparelho volta no tempo THEN "mais recente" SHALL continuar sendo a última gravada (A16).
- WHEN o capítulo do ponto não tem título conferido (TD-002) THEN o texto compartilhado e o continue SHALL usar a referência sem capítulo, igual ao topo da página.
- WHEN o leitor toca Anterior/Próximo várias vezes depressa THEN SHALL existir uma leitura por ponto mostrado, na ordem.
- WHEN os livros não carregam THEN o app SHALL mostrar a mensagem atual de falha, não a tela inicial (comportamento da v0.2, sem mudança).

## Implicit-requirement sweep (Complex → todas as dimensões)

| Dimensão | Resolução |
| --- | --- |
| Input validation & bounds | PontoId lido do banco validado (linha estragada ignorada, Edge Cases); origem é conjunto fechado (A9); filtro só com obras do dado (AC-19) |
| Failure / partial-failure | Gravação falha (AC-05), migração falha com rollback (AC-07), consulta dos recentes falha (AC-20), compartilhar falha (AC-25) |
| Idempotency / duplicates | Reconstrução não grava (AC-04); repetição conta uma vez nos recentes (AC-17); reler grava evento novo (A17) |
| Auth & rate limits | N/A — app local de um usuário, sem servidor |
| Concurrency / ordering | Ordem de gravação, não de relógio (A16, Edge Cases); toques rápidos gravam na ordem (AC-03, Edge Cases) |
| Data lifecycle | Leituras nunca são apagadas na v0.4; ver/apagar histórico vai ao backlog; leitura de ponto sumido fica (AC-13) |
| Observability | Log só com o tipo do erro (AD-009) em AC-05, AC-20, AC-25; nenhuma telemetria |
| External-dependency failure | Folha de compartilhamento (AC-25); registro/Keystore indisponível (AC-14, AC-20) |
| State-transition integrity | Schema 1 → 2 tudo ou nada (AC-06, AC-07); continue: nenhum → ponto → outro ponto (AC-10, AC-12) |

## Requirement Traceability

| Requirement | Story | AC | Status |
| --- | --- | --- | --- |
| LEI-01 | P1 Leitura | AC-01 | Pending |
| LEI-02 | P1 Leitura | AC-02 | Pending |
| LEI-03 | P1 Leitura | AC-03 | Pending |
| LEI-04 | P1 Leitura | AC-04 | Pending |
| LEI-05 | P1 Leitura | AC-05 | Pending |
| LEI-06 | P1 Leitura | AC-06 | Pending |
| LEI-07 | P1 Leitura | AC-07 | Pending |
| LEI-08 | P1 Leitura | AC-08 | Pending |
| CONT-01 | P1 Continue | AC-09 | Pending |
| CONT-02 | P1 Continue | AC-10 | Pending |
| CONT-03 | P1 Continue | AC-11 | Pending |
| CONT-04 | P1 Continue | AC-12 | Pending |
| CONT-05 | P1 Continue | AC-13 | Pending |
| CONT-06 | P1 Continue | AC-14 | Pending |
| AGORA-01 | P1 Agora | AC-15 | Pending |
| AGORA-02 | P1 Agora | AC-16 | Pending |
| AGORA-03 | P1 Agora | AC-17 | Pending |
| AGORA-04 | P1 Agora | AC-18 | Pending |
| AGORA-05 | P1 Agora | AC-19 | Pending |
| AGORA-06 | P1 Agora | AC-20 | Pending |
| INI-01 | P1 Tela inicial | AC-21 | Pending |
| INI-02 | P1 Tela inicial | AC-22 | Pending |
| INI-03 | P1 Tela inicial | AC-23 | Pending |
| COMP-01 | P2 Compartilhar | AC-24 | Pending |
| COMP-02 | P2 Compartilhar | AC-25 | Pending |
| COMP-03 | P2 Compartilhar | AC-26 | Pending |

**Coverage:** 26 requisitos, 0 mapeados para tarefas (Tasks ainda não feito).

## Success Criteria

- [ ] Teste de tela: da abertura do app a uma página de ponto em 1 toque, pelo continue e pelo aleatório.
- [ ] Teste com arquivo real: zero linha da v0.3 perdida ou alterada na migração.
- [ ] UAT no aparelho (TD-004): ler três pontos em sequência, fechar o app, reabrir — o continue aponta para o terceiro.
