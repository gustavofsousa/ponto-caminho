# Voltar (v0.4) Validation

**Date**: 2026-10-07
**Spec**: `.specs/features/voltar/spec.md`
**Diff range**: `25b2296..6d92a44` (branch `feat/v0.4-voltar`, 12 commits: fa96a9c … 6d92a44) · fixes: `f8a1317..553e766` (rodada 1), `342d5b1..cc8a550` (rodada 2), `aa93d03..79b1630` (rodada 3)
**Verifier**: independent sub-agent (author ≠ verifier)
**Verdict**: ✅ PASS (rodada 3, final). A rodada 3 (`aa93d03..79b1630`, 1 commit só de teste) fechou o último gap: a janela de 10 do continue (A12) agora é provada dos dois lados do limite, e os limites 2, 9 e 11 morrem. Todos os sobreviventes não equivalentes das rodadas 0–2 estão mortos (o M22 é equivalente). O gate passa: motor 64, app 230 no fuso padrão e com `TZ=UTC`, validador 6, APK gerado. Pendente fora do Verifier: UAT no aparelho (TD-004) das decisões marcadas "não — revisar/UAT".

**Verdict da rodada 2**: ❌ FAIL (rodada 2; o pedido de escalar foi resolvido pela rodada 3, sem decisão pendente do usuário). A rodada 2 (`342d5b1..cc8a550`, 2 commits só de teste) matou M45 e M49, e o gate passa (228, também com `TZ=UTC`). Na varredura final, 5 de 6 mutantes novos morreram. Sobrou **um gap Minor**: nenhum teste prova a janela de **10** pontos do continue (A12). Os limites 2, 9 e 11 passam pela suíte inteira (M64, M64b, M64c). O comportamento no HEAD está certo (sonda P9). Correção: 1 teste, ~5 min. Ou o usuário aceita como risco registrado. Ver "Rodada 2" no fim.

**Verdict da rodada 1**: ❌ FAIL. A rodada 1 (`f8a1317..553e766`, 7 commits só de teste) fechou **todos** os gaps da rodada 0: M14, M27, M31 (e `limite: 9`), M36 e M44 morrem, os edge cases 4 e 5 têm teste, o AD-004 está em dia e o gate passa (227). O sensor ampliado achou **2 sobreviventes novos**, ambos Minor e só de teste (~15 min): M45 (gravação em voo descarta toques rápidos, edge case 5) e M49 (o app passa os recentes em ordem invertida, AC-18 na tela). Ver "Rodada 1" no fim.

**Verdict da rodada 0**: ❌ FAIL. O comportamento está certo no HEAD: o gate passa, as 26 ACs têm o resultado do spec afirmado e as 6 sondas passam. Mas **5 mutantes não equivalentes sobreviveram à suíte inteira** (M14, M27, M31, M36, M44). Também ficaram parciais o AC-09 ("abaixo") e os edge cases 4 e 5. Todas as correções são só de teste (~35 min no total). Ver "Fix Plans".

---

## Task Completion

| Task | Status | Notes |
| ---- | ------ | ----- |
| T1–T10 | ✅ Done | Todos os cabeçalhos com ✅ e todas as caixas "Done when" com `[x]` em `tasks.md`. Commits bfecb31…47786eb, mais o plano fa96a9c e o fechamento 6d92a44. `git diff 25b2296..6d92a44 -- apps packages ':!*.g.dart' \| grep -E "^\+.*(SPEC_DEVIATION\|TODO\|FIXME\|ignore:)"` → exit 1 (vazio) |
| T3 (fixture AD-011) | ✅ Done | Conferi por sonda: um `BancoRegistro` novo em memória no commit `25b2296` (worktree de rascunho) despeja um `sqlite_master` **idêntico** a `schemaV1` (`diff` vazio, 6 instruções) |
| T9 / Build gate | ✅ Done | `flutter build apk --debug` → `✓ Built build/app/outputs/flutter-apk/app-debug.apk` (AGP sem mudança) |
| T7, T8, T9 (Done-when de tela) | ⚠️ Partial | Os critérios estão afirmados, mas o sensor achou partes sem discriminação: T7 (AC-09 "abaixo", M27; edge case 4, M44), T8 (o app passa a janela de 10 ao motor, M31), T9 (compartilhar depois de Próximo, M36) |

---

## Spec-Anchored Acceptance Criteria

Caminhos relativos a `apps/ponto_mobile/test/` (app) e `packages/ponto_motor/test/` (motor). "Mxx" = mutante do sensor; "Px" = sonda descartável (seção Probes).

| AC (req) | Spec-defined outcome | `file:line` + assertion | Result |
| --- | --- | --- | --- |
| AC-01 (LEI-01) abrir grava uma leitura | exatamente 1 leitura; PontoId do ponto; origem `biblioteca`; `lidoEm` = 2026-10-07 09:15 UTC; nunca posição nem texto | Pela tela (obra → capítulo → ponto), `leitura/leitura_na_pagina_test.dart:76-86`: `.single` (`:83`), `linha.pontoId == caminho2.toString()` (`:84`), `origem == biblioteca` (`:85`), `lidoEm == DateTime.utc(2026,10,7,9,15)` (`:86`). Repo `leitura/leituras_repositorio_test.dart:39-43` (`'ponto:teste/caminho/2'`, origem, `lidoEm`, `isUtc`). A linha (`LinhaDeLeitura`) só tem `id`, `pontoId`, `lidoEm` e `origem`: não há coluna para o texto | ✅ PASS no resultado do spec. M15 (grava `colecao/obra/numero` em vez do PontoId) foi morto por 15 testes. ⚠️ Sensor: **M14 sobreviveu**. Sem o `toUtc()` (`lib/leitura/leituras_repositorio.dart:23`) tudo passa, porque o relógio de teste já é UTC. A sonda P6, com relógio local, mata M14: grava `isUtc == false` |
| AC-02 (LEI-02) cada entrada grava a própria origem | `continuacao`, `aleatorio`, `favoritos`, `colecao`, uma por entrada | `leitura/continue_de_onde_parou_test.dart:113-114` (`continuacao`). `selecao/um_ponto_para_agora_test.dart:104-105` (`aleatorio`). `leitura/leitura_na_pagina_test.dart:98-100` (`[(sulco1, favoritos)]`), `:122-124` (`[(caminho81, colecao)]`). Conjunto fechado no motor: `leitura/leitura_test.dart:6-12` | ✅ PASS (M19, M26, M32 mortos) |
| AC-03 (LEI-03) Anterior/Próximo gravam cada ponto | 2 leituras novas, na ordem (seguinte, depois inicial), ambas `biblioteca`; nada sem o ponto mudar | `leitura/leitura_na_pagina_test.dart:136-140`: lista exata `[(2, aleatorio), (81, biblioteca), (2, biblioteca)]` | ✅ PASS (M17, M18 mortos). Edge case 5 ("depressa"): ver Edge Cases |
| AC-04 (LEI-04) reconstruir não grava | continua 1 leitura depois de tema, tamanho do texto e reflexão | `leitura/leitura_na_pagina_test.dart:165` (`hasLength(1)` antes). `:178-181`: o tema escuro chegou à página. `:182-184`: exatamente `[(caminho2, biblioteca)]` depois de tema, escala 1,3 e "Guardar" | ✅ PASS (M16, sem a guarda de `didChangeDependencies`, morto) |
| AC-05 (LEI-05) falha ao gravar não atrapalha | texto aparece; nenhuma mensagem; em (b)/(c) log só com o tipo; nunca PontoId, texto ou mensagem original | (a) `leitura/leitura_na_pagina_test.dart:201-203` (texto, sem SnackBar, sem exceção). (b) trigger `RAISE(ABORT, '<PontoId> <texto>')` e (c) `StateError('<PontoId> <texto>')`, `:238-244`: texto `findsOneWidget`, SnackBar `findsNothing`, `isA<FalhaNoRegistro>()`, `toString` sem PontoId e sem "Segundo ponto", nenhuma leitura | ✅ PASS (M20, captura estreita `on Exception`, e M21, relançar, mortos). L-001 aplicada |
| AC-06 (LEI-06) migração preserva a v0.3 | reflexão (texto, criadaEm, editadaEm, ponto), favorito (ponto, data), coleção (nome, ponto, data) iguais; `user_version` = 2; leitura gravada e lida de volta; sem recriar, sem chave nova, sem arquivo em claro | `registro/migracao_test.dart:44`: `lerLinhasV1(...) == antes`, ou seja, todas as colunas de todas as linhas das 5 tabelas. `:45` (2 reflexões, uma editada), `:46` (`lerVersao == 2`), `:47` (`cofre.gravadas, isEmpty`), `:50-51` (sem "SQLite format 3" e sem o texto da reflexão nos bytes). `:73-75` (leitura lida de volta: pontoId, lidoEm, origem). `:95` (schema migrado == schema novo) | ✅ PASS (M23, M24 mortos). L-006 aplicada (linhas irmãs). "Em algum momento em claro" é conferido pelo estado final, a mesma leitura da v0.3 |
| AC-07 (LEI-07) migração que falha não perde nada | registro indisponível; livros funcionam; `user_version` = 1; todas as linhas; schema nunca pela metade; não apagar nem recriar | `registro/migracao_test.dart:104-108` (um índice `leituras` conflitante). `:116` (`isNull`), `:117` (`relatos.single.exception isA<FalhaNoRegistro>`), `:118` (`lerVersao == 1`), `:119` (linhas iguais), `:122` (schema igual ao de antes), `:123` (sem chave nova). A parte da tela vale por composição: `abrirRegistro → null` é a entrada dos testes CIFRA-04 da v0.3 (`app_test.dart:226`, livros abrem; `registro/registro_do_ponto_test.dart`, aviso) | ✅ PASS. M22 (sem `transaction()`) sobrevive, mas é **equivalente** hoje: o `onUpgrade` tem um único passo DDL, então não existe "pela metade" que um teste possa ver (ver Sensor) |
| AC-08 (LEI-08) leitura só no banco cifrado | bytes sem `ponto:caminho-sulco-forja/caminho/7` e sem "SQLite format 3"; nenhuma preferência com essa string | `leitura/leituras_repositorio_test.dart:191-199` (`abrirRegistro` real + `CofreDeTeste`): `contains(lido.toString()) isFalse`, `contains('SQLite format 3') isFalse`. Preferências: `leitura/leitura_na_pagina_test.dart:255-264` (todo valor de toda chave sem o PontoId) | ✅ PASS (M42, que grava o PontoId nas preferências, morto). L-009 respeitada (prova pelos bytes) |
| AC-09 (CONT-01) continue leva ao último em sequência | home mostra "Continue de onde parou" e, **abaixo**, a referência de B; toque abre B; nunca C, D ou E | Motor `leitura/continuar_test.dart:58-66`. Repo `leitura/leituras_repositorio_test.dart:99-110` (`[b, a]`). Tela `leitura/continue_de_onde_parou_test.dart:82-86` (rótulo; referência de B; sem "ponto 81", "ponto 82" ou "Sulco,"), `:91-93` (abre a página de B) | ⚠️ **GAP parcial**. "Abaixo" não é afirmado: M27 (título e subtítulo trocados) sobrevive à suíte inteira. A sonda P4 (`dy` do rótulo < `dy` da referência) passa no HEAD e mata M27. O resto do AC está ✅ (M07, M08, M12 mortos) |
| AC-10 (CONT-02) acompanha sem reabrir | depois de continue → Próximo → voltar, a referência do ponto seguinte a B | `leitura/continue_de_onde_parou_test.dart:130-132` (`InicioPage`; "Caminho, capítulo Oração, ponto 81" `findsOneWidget`; referência de B `findsNothing`). Repo `leitura/leituras_repositorio_test.dart:137-150` (emite `[]` e depois `[a]`) | ✅ PASS (M18 morto) |
| AC-11 (CONT-03) sobrevive a fechar o app | registro reaberto sobre o mesmo arquivo → referência de B | `leitura/continue_de_onde_parou_test.dart:144-158` (arquivo, `close`, banco novo sobre o arquivo, home): rótulo e referência de B. Repo `leitura/leituras_repositorio_test.dart:171-183` | ✅ PASS |
| AC-12 (CONT-04) sem sequência, sem continue | (a) nada lido, (b) só desvios: sem continue; "Um ponto para agora" e "Biblioteca" aparecem; nenhum texto de falta | `leitura/continue_de_onde_parou_test.dart:161-184`, um caso por cenário: `:178` (`findsNothing`), `:179-180` (`findsOneWidget` ×2), `:181` (todo `Text` na tela está na lista permitida, então não há falta, contagem nem data). Motor `leitura/continuar_test.dart:68-70` | ✅ PASS (M07, M12 mortos) |
| AC-13 (CONT-05) ponto sumido é pulado, não apagado | continue aponta para B; a linha do 999 continua no banco | `leitura/continue_de_onde_parou_test.dart:195` (referência de B), `:199-202` (as 2 linhas, na ordem). Motor `leitura/continuar_test.dart:72-89` | ✅ PASS (M09, M28 mortos) |
| AC-14 (CONT-06) sem registro, continue some sem aviso | home com "Um ponto para agora" e "Biblioteca"; sem continue; nunca "Não foi possível abrir o que você guardou" | `leitura/continue_de_onde_parou_test.dart:211-214` (sem continue, "Biblioteca", `textContaining('Não foi possível') findsNothing`, lista permitida). "Um ponto para agora" presente com a mesma montagem: `selecao/um_ponto_para_agora_test.dart:186-191` (home sem registro, toca o botão). Stream em erro: `leitura/continue_de_onde_parou_test.dart:225-229` | ✅ PASS (M25, sem `handleError`, morto) |
| AC-15 (AGORA-01) um toque abre um ponto | índice k → k-ésimo candidato (obras na ordem da coleção, pontos em ordem de leitura); k=0 e k=n−1; fonte consultada com n | Motor `selecao/ponto_aleatorio_test.dart:177` (`limites == [18]`), `:178-182` (todos os k, com obras `b,a,c,d` fora da ordem alfabética e a obra `b` com os pontos fora de ordem). Tela `selecao/um_ponto_para_agora_test.dart:74-89`: k=0 → "Primeiro ponto do caráter.", k=4 → "O único ponto do sulco.", `limites == [5]` | ✅ PASS (M04, M05 mortos). Aleatoriedade só por parâmetro: no motor não há `Random()` nem `DateTime.now` (`grep`) |
| AC-16 (AGORA-02) 10 últimos ficam de fora | P1–P10 fora, P11 dentro, nunca mais de 10 excluídos | Motor `selecao/ponto_aleatorio_test.dart:191` (`hasLength(18 - 10)`, então exatamente 10 excluídos), `:192-194` (P1–P10 ausentes), `:195` (P11 presente) | ✅ PASS no motor, como o spec pede (M01 morto). ⚠️ Sensor: **M31 sobreviveu**. O app passar `limite: 1` em vez de `janelaDeRecentes` ao repositório (`lib/selecao/um_ponto_para_agora.dart:94`) não é detectado: o único teste de tela com recentes tem 1 leitura (`selecao/um_ponto_para_agora_test.dart:108-124`). A sonda P3 (12 pontos, 11 lidos → `limites == [2]`) mata M31 |
| AC-17 (AGORA-03) reler conta uma vez | P1×3, P2…P10, P11 → P1–P10 fora, P11 dentro | Motor `selecao/ponto_aleatorio_test.dart:198-213`. Repo `leitura/leituras_repositorio_test.dart:63` (`[e, a, c, b]`, distintos e do mais novo ao mais antigo, qualquer origem), `:77-80` (limite) | ✅ PASS (M02, M11, M13 mortos) |
| AC-18 (AGORA-04) a janela encolhe | sempre S4 (o lido há mais tempo), nunca S3, nunca nulo | Motor `selecao/ponto_aleatorio_test.dart:228`: `_todosOsSorteios(obra: 'b', …) == [S4]` para todo valor da fonte | ✅ PASS (M03, que encolhe pelo mais novo, morto) |
| AC-19 (AGORA-05) filtro por obra | "Todas as obras" + obras com ponto, na ordem da coleção; "Todas" escolhida; ponto da obra escolhida para cada valor; continua escolhida ao voltar; nunca a obra sem ponto; nenhum id de obra no app | Tela `selecao/um_ponto_para_agora_test.dart:131-140` (ordem por `dx`; Forja ausente; 3 chips; "Todas" escolhida), `:150-161` (Caminho → `limites == [4]`, k=3 → "Segundo ponto da oração."; escolhida ao voltar), `:165-180` (regra 1: nenhum `'caminho'`/`'sulco'`/`'forja'` em `lib/`). Motor `selecao/ponto_aleatorio_test.dart:233-235` (todos os valores dentro da obra), `:239-242` (obra sem ponto → nulo) | ✅ PASS (M06, M29, M30 mortos) |
| AC-20 (AGORA-06) sem registro, sorteia sem recentes | abre um ponto; todos os pontos são candidatos; em (b) log só com o tipo; nenhuma mensagem | (a) `selecao/um_ponto_para_agora_test.dart:190-193` (`limites == [5]`, ponto aberto, sem SnackBar, sem exceção). (b) `:221-232` (`limites == [5]`, ponto aberto, sem SnackBar, todo relato `isA<FalhaNoRegistro>` e sem "leituras", contexto `'ao ler os pontos recentes'`) | ✅ PASS (M33 morto; M34, que ignora os recentes, morto por `:122`) |
| AC-21 (INI-01) o app abre na home | de cima para baixo: continue, "Um ponto para agora" com o filtro, "Biblioteca"; Biblioteca → obras, Favoritos, Coleções; sem contagem, data ou ausência | `app_test.dart:105-107` (a primeira tela é `InicioPage`, não `BibliotecaPage`). `inicio_page_test.dart:76-81` (ordem por `dy`: continue < botão < filtro < Biblioteca), `:85` (lista permitida), `:49-61` (Biblioteca → Caminho, Sulco, Forja, Favoritos, Coleções) | ✅ PASS (M40, M41 mortos). `LER-01` virou `INI-01` por decisão do spec (A4): o teste novo afirma mais, então não é enfraquecimento |
| AC-22 (INI-02) favorito a 3 toques | página do ponto no 3º toque, nunca no 4º | `app_test.dart:118-129`: `PontoPage findsNothing` antes de cada um dos 3 toques e `findsOneWidget` depois | ✅ PASS (M41 morto) |
| AC-23 (INI-03) 320 px, escala 2,0 + maior texto | sem transbordamento; continue, filtro e Biblioteca alcançáveis rolando; referência inteira | `inicio_page_test.dart:92-93` (320 px; 2,6 = 2,0 × 1,3, o fator de "Muito grande" em `lib/preferencias/preferencias.dart:19`). `:103`, `:119` (sem exceção), `:104-109` (`didExceedMaxLines isFalse`), `:110-118` (chips e Biblioteca `hitTestable` depois de rolar) | ✅ PASS (M43, subtítulo com `maxLines: 1`, morto) |
| AC-24 (COMP-01) só a referência | a folha recebe exatamente a referência do topo da página; nunca texto do ponto, reflexão, nome da coleção ou PontoId | `colecao/compartilhar_test.dart:71` (referência no topo), `:72` (`compartilhados == [referência]`), `:74-77` (sem o texto, a reflexão, "Família" e "ponto:") | ✅ PASS no cenário do spec (M35 morto). ⚠️ Sensor: **M36 sobreviveu**. Compartilhar a referência do ponto **inicial** depois de Próximo passa: nenhum teste compartilha depois de trocar de ponto. A sonda P5 mata M36 |
| AC-25 (COMP-02) falha ao compartilhar | "Não foi possível compartilhar."; a página continua; log só com o tipo; nunca a referência nem a mensagem original | `colecao/compartilhar_test.dart:134-135` (`PlatformException(code: 'falhou', message: <referência>)`). `:141` (mensagem), `:142` (texto do ponto ainda na tela), `:144` (`isA<FalhaAoCompartilhar>`), `:145-146` (sem a referência e sem "falhou") | ✅ PASS (M37, M38 mortos) |
| AC-26 (COMP-03) botão acessível | anuncia "Compartilhar referência"; alvo ≥ 48×48 dp; nunca só ícone | `colecao/compartilhar_test.dart:156-159` (`isSemantics(tooltip:, isButton: true, hasTapAction: true)`), `:166-167` (≥ 48), `:168-169` (`androidTapTargetGuideline`, `labeledTapTargetGuideline`) | ✅ PASS (M39, sem tooltip, morto) |

**Status**: ⚠️ 25/26 ACs com o resultado do spec afirmado por inteiro. O AC-09 está parcial ("abaixo"). Os sobreviventes M14 (AC-01), M31 (AC-16) e M36 (AC-24) não deixam o resultado do spec descoberto, mas mostram partes do comportamento que nenhum teste discrimina. **0 spec-precision gaps**: todo Expected/Must-not tem um observável preciso.

### Reverse check (testes sem AC) e AD-004

Todos os testes do diff mapeiam para um AC, um edge case ou um Done-when. Nomes completos extraídos com `flutter test --reporter json` / `dart test --reporter json`. **AD-004**: 3 testes novos não começam com ID. São os testes de edge case, que no spec não têm ID: `leitura/leituras_repositorio_test.dart:84` ("the order is the order of recording…"), `:152` ("a reading with a broken point id…") e o motor `selecao/ponto_aleatorio_test.dart:245` ("a single-point work…"). A busca textual por requisito não os acha. Sugestão: prefixar com o ID do requisito mais próximo (AGORA-03, CONT-05, AGORA-04). ~2 min.

### Probes (descartáveis, só no worktree de rascunho, apagado no fim)

Arquivo único `test/zz_sondas_test.dart`, nunca no repositório real.

| # | Sonda | No HEAD | Mata |
| --- | --- | --- | --- |
| P1 | Página aberta como `aleatorio` no Caminho 2; Próximo, Próximo, Anterior só com `pump()` entre os toques (sem `pumpAndSettle`) → leituras `[(2, aleatorio), (81, bib), (82, bib), (81, bib)]` e o texto do 81 na tela | ✅ passa | — (edge case 5) |
| P2 | Coleção com capítulo sem título; leitura `biblioteca` do ponto 5 → home mostra "Continue de onde parou" e "Longa, ponto 5", sem "capítulo" | ✅ passa | M44 |
| P3 | Obra de 12 pontos; 11 lidos (1…11) → "Um ponto para agora" consulta a fonte com `n = 2` e abre o ponto 1 | ✅ passa | M31 |
| P4 | `dy` de "Continue de onde parou" < `dy` da referência | ✅ passa | M27 |
| P5 | Caminho 2 → Próximo → compartilhar → `['Caminho, capítulo Oração, ponto 81']` | ✅ passa | M36 |
| P6 | Relógio local `DateTime(2026,10,7,6,15)` → `lidoEm.isUtc` e `lidoEm == local.toUtc()` | ✅ passa | M14 |
| Schema | `sqlite_master` de um `BancoRegistro` novo em `25b2296` comparado com `schemaV1` | idêntico | — (fixture do AD-011 é fiel) |

---

## Discrimination Sensor

Worktree de rascunho (`git worktree add … 6d92a44`; `flutter pub get`; o symlink de assets resolve). Uma mutação por vez, por substituição exata de texto: o script aborta se não houver exatamente 1 ocorrência. Primeiro rodei os arquivos de teste do comportamento. Para todo sobrevivente, rodei também a **suíte inteira do app (222)**. Depois de cada mutação: `git checkout -- .` e `git status --porcelain` vazio (asserção do script). No fim, `git worktree remove --force`. O `git status` da árvore real ficou vazio antes e depois.

| # | File:line | Description | Killed? |
| --- | --- | --- | --- |
| M01 | `packages/ponto_motor/lib/src/selecao/ponto_aleatorio.dart:7` | `janelaDeRecentes = 9` | ✅ AGORA-02, AGORA-03 |
| M02 | `ponto_aleatorio.dart:28` | janela sem distinguir antes do corte (`take(10).toSet()`) | ✅ AGORA-03 |
| M03 | `ponto_aleatorio.dart:37` | encolhe a janela pelo **mais novo** | ✅ AGORA-04 |
| M04 | `ponto_aleatorio.dart:23` | obras em ordem reversa | ✅ AGORA-01 |
| M05 | `ponto_aleatorio.dart:30` | `nextInt(universo.length)` em vez de `candidatos.length` | ✅ AGORA-02/03/04 |
| M06 | `ponto_aleatorio.dart:24` | filtro de obra ignorado | ✅ AGORA-04/05 ×2, edge 1 |
| M07 | `packages/ponto_motor/lib/src/leitura/leitura.dart:9` | `aleatorio.emSequencia = true` | ✅ motor CONT-01; app CONT-01 ×3, CONT-04 |
| M08 | `packages/ponto_motor/lib/src/leitura/continuar.dart:11` | `lastOrNull` (o mais antigo) | ✅ CONT-01, CONT-05 |
| M09 | `continuar.dart:11` | não pula ponto inexistente (sem `nonNulls`) | ✅ CONT-05 |
| M10 | `apps/ponto_mobile/lib/leitura/leituras_repositorio.dart:48` | ordena por `MAX(lidoEm)` em vez de `MAX(id)` | ✅ relógio que volta, AGORA-03 ×2 |
| M11 | `leituras_repositorio.dart:47` | sem `GROUP BY pontoId` | ✅ AGORA-03 ×2, CONT-01 ×3 … |
| M12 | `leituras_repositorio.dart:50` | sem o `WHERE origem IN (em sequência)` | ✅ repo CONT-01 ×2; tela CONT-01, CONT-04 |
| M13 | `leituras_repositorio.dart:48` | `ASC` em vez de `DESC` | ✅ AGORA-03 ×2, CONT-01 ×3 |
| M14 | `leituras_repositorio.dart:23` | sem `toUtc()` em `lidoEm` | ❌ **Survived** (suíte inteira: 222 passaram). P6 mata → Fix 4 |
| M15 | `leituras_repositorio.dart:22` | grava `colecao/obra/numero` em vez de `PontoId.toString()` | ✅ 15 testes (LEI-01..04 …) |
| M16 | `apps/ponto_mobile/lib/colecao/ponto_page.dart:44` | sem a guarda "uma vez por abertura" | ✅ LEI-04 |
| M17 | `ponto_page.dart:116` | Próximo/Anterior gravam a origem da página | ✅ LEI-03 |
| M18 | `ponto_page.dart:116` | Próximo/Anterior não gravam | ✅ LEI-03, CONT-02 |
| M19 | `ponto_page.dart:46` | 1ª leitura sempre `biblioteca` | ✅ LEI-02 ×4, LEI-03 |
| M20 | `apps/ponto_mobile/lib/leitura/registrar_leitura.dart:17` | captura estreita `on Exception` | ✅ LEI-05 (erro que não é do banco) |
| M21 | `registrar_leitura.dart:18` | relança em vez de relatar | ✅ LEI-05 ×2 |
| M22 | `apps/ponto_mobile/lib/registro/banco_registro.dart:88-90` | `onUpgrade` sem `transaction()` | ⚪ Survived, **equivalente**: com um único `CREATE TABLE`, que é atômico, nenhum estado intermediário existe. Não conta como fraqueza de teste (ver Riscos) |
| M23 | `banco_registro.dart:89` | `de < 1`: a migração não cria a tabela | ✅ LEI-06 ×2, LEI-07 |
| M24 | `banco_registro.dart:82` | `schemaVersion` fica 1 | ✅ LEI-06 ×3, LEI-07 |
| M25 | `apps/ponto_mobile/lib/leitura/continue_de_onde_parou.dart:38-43` | sem `handleError` (erro do stream não vai ao log) | ✅ CONT-06 (registro que falha) |
| M26 | `continue_de_onde_parou.dart:64` | continue abre com `biblioteca` | ✅ LEI-02 (continue) |
| M27 | `continue_de_onde_parou.dart:56-58` | título e subtítulo trocados (a referência acima do rótulo) | ❌ **Survived** (suíte inteira). P4 mata → Fix 3 |
| M28 | `continue_de_onde_parou.dart:37` | continue lê só 1 ponto em sequência | ✅ CONT-05 |
| M29 | `apps/ponto_mobile/lib/selecao/um_ponto_para_agora.dart:35` | filtro oferece obra sem ponto | ✅ AGORA-05 |
| M30 | `um_ponto_para_agora.dart:73` | sorteio ignora a obra escolhida | ✅ AGORA-05 |
| M31 | `um_ponto_para_agora.dart:94` | `listarRecentes(limite: 1)` em vez de `janelaDeRecentes` | ❌ **Survived** (suíte inteira). P3 mata → Fix 1 |
| M32 | `um_ponto_para_agora.dart:82` | aleatório abre com `biblioteca` | ✅ LEI-02 (aleatório) |
| M33 | `um_ponto_para_agora.dart:93-98` | sem o `try/catch` da consulta dos recentes | ✅ AGORA-06 (b) |
| M34 | `um_ponto_para_agora.dart:74` | recentes ignorados (`const []`) | ✅ AGORA-02 (tela) |
| M35 | `ponto_page.dart:64` | compartilha o texto do ponto | ✅ COMP-01 ×2 |
| M36 | `ponto_page.dart:64` | compartilha a referência do ponto **inicial** (não o mostrado) | ❌ **Survived** (suíte inteira). P5 mata → Fix 2 |
| M37 | `ponto_page.dart:125-127` | falha ao compartilhar sem SnackBar | ✅ COMP-02 |
| M38 | `apps/ponto_mobile/lib/colecao/compartilhar_referencia.dart:29` | log com o erro original | ✅ COMP-02 |
| M39 | `ponto_page.dart:63` | botão sem tooltip (só ícone) | ✅ COMP-01 ×2, COMP-02, COMP-03 |
| M40 | `apps/ponto_mobile/lib/inicio_page.dart:29-30` | aleatório acima do continue | ✅ INI-01 (ordem) |
| M41 | `apps/ponto_mobile/lib/app.dart:42` | o app abre na Biblioteca | ✅ INI-01, INI-02, CIFRA-04 ×2, BASE-04 … (10) |
| M42 | `registrar_leitura.dart:16` | também grava o PontoId nas preferências | ✅ LEI-08 (preferências) |
| M43 | `continue_de_onde_parou.dart:58` | referência do continue com `maxLines: 1` + reticências | ✅ INI-03 |
| M44 | `continue_de_onde_parou.dart:58` | continue monta a referência à mão, sem o ramo "capítulo sem título" | ❌ **Survived** (suíte inteira). P2 mata → Fix 5 |

**Sensor depth**: expandido (dado pessoal sensível + migração do banco cifrado): **44 mutações**, todas de comportamento, cobrindo janela, distinção, encolhimento, ordem, `nextInt(n)`, `emSequencia`, GROUP BY/WHERE/ORDER, origens, guarda de abertura, captura, migração, stream, filtro, compartilhar, log, home e privacidade.
**Result**: 38 killed · 6 survived (5 não equivalentes: M14, M27, M31, M36, M44; 1 equivalente: M22) · 0 travados · 0 erros de compilação. ❌ FAIL. Cada sobrevivente não equivalente tem uma sonda (P2–P6) que passa no HEAD e o mata.

Comando por mutante: `python3 mutar.py` (rascunho), que aplica a troca, roda `dart test` (motor) ou `flutter test <arquivos>` (app) e restaura. Sobreviventes: mesmo script com a suíte inteira (`flutter test`, 222). Sondas × mutantes: `flutter test test/zz_sondas_test.dart --plain-name 'Px '`.

---

## Interactive UAT Results

Não realizado (Verifier sub-agente). Pendentes com o usuário, marcadas "não — revisar/UAT" no spec: A7 (continue só em sequência), A8, A9, A10, A11, A13, A18, A19, A22. Também ficam pendentes o Success Criterion "ler três pontos, fechar, reabrir → continue no terceiro" no aparelho e a migração com Keystore real (TD-004).

---

## Code Quality

| Principle | Status |
| --- | --- |
| Minimum code | ✅. Três funções puras no motor, um repositório, dois widgets e a home como composição. Nenhuma abstração além das seams do design (`Random`, `Compartilhar`, schema congelado) |
| Surgical changes | ✅. Os testes antigos só ganharam `origem:` e `_irParaBiblioteca`. `LER-01` foi substituído por `INI-01`, com mais asserções (A4) |
| No scope creep | ✅. Nada fora dos ACs. Sem botão "outro ponto", sem lembrar o filtro, sem deep link |
| Matches patterns | ✅. AD-007 (stream num `late final` do `State`), AD-009 (`FalhaNoRegistro` / `FalhaAoCompartilhar` só com o tipo), AD-006, AD-010 (`MAX(id)`), AD-011 (fixture conferida por sonda), regra 1 (teste de regex), regra 2 (`PontoId.toString()`) |
| Comments explain why | ✅. `INVARIANT:` (ordem por id, nome do enum gravado, referência existe) e `SECURITY:` (log do compartilhar) |
| Spec-anchored outcome check | ⚠️. AC-09 parcial ("abaixo"); sobreviventes M14/M31/M36 |
| Per-layer Coverage Expectation met | ⚠️. Motor 1:1 com os ACs e todas as saídas da fonte enumeradas ✅. Banco: migração feliz + rollback + schema migrado = novo ✅. Repositório: efeito, ordem, distinção, limite, origem, linha estragada e relógio que volta ✅. Telas: "todas as partes do Expected (L-003)" não vale para o AC-09; a janela do app (M31) e o compartilhar depois de Próximo (M36) não são provados |
| Every test maps to a requirement | ✅, com a nota do AD-004 (3 testes de edge case sem ID) |
| Documented guidelines followed | ⚠️. `AGENTS.md` (análise zero, `validar.py` exit 0, nenhum id de obra em `lib/`) ✅. `.specs/STATE.md` AD-004 parcial |

---

## Edge Cases

- [x] Filtro com um só ponto, que é o último lido → devolvê-lo: motor `selecao/ponto_aleatorio_test.dart:245-247` (`[c/1]` para todo valor da fonte)
- [x] PontoId estragado → continue e recentes o ignoram, sem apagar: `leitura/leituras_repositorio_test.dart:159-163` (as duas consultas `[a]`; banco com 2 linhas). Nas telas, vale pela mesma consulta
- [x] Relógio volta → "mais recente" = última gravada: `leitura/leituras_repositorio_test.dart:84-97` (`[b, a]` nas duas consultas). M10 morto
- [~] Capítulo sem título → compartilhar **e continue** usam a referência sem capítulo. Compartilhar ✅ `colecao/compartilhar_test.dart:123-124` ("Caminho, ponto 390"). **Continue: nenhum teste**. M44 sobrevive à suíte inteira; a sonda P2 confirma o HEAD e mata M44 → Fix 5
- [~] Anterior/Próximo **depressa** → uma leitura por ponto mostrado, na ordem. O único teste (`leitura/leitura_na_pagina_test.dart:133-134`) espera `pumpAndSettle` entre os toques. Isso transforma "depressa" no caso sequencial comum. A sonda P1 (3 toques só com `pump()`) passa no HEAD → Fix 6
- [x] Livros não carregam → mensagem atual de falha, não a home: `app_test.dart:50-98` (BASE-05 ×2, sem mudança desde a v0.2, verdes)

**4/6** cobertos por inteiro; **2/6** parciais (no HEAD, as sondas P1 e P2 mostram o comportamento certo).

---

## Gate Check

- **Gate command** (Build, de `tasks.md`): `python3 livros/validar.py && python3 -m unittest discover -s livros -p 'test_*.py' && (cd packages/ponto_motor && dart format --output=none --set-exit-if-changed . && dart analyze --fatal-infos && dart test) && (cd apps/ponto_mobile && dart format --output=none --set-exit-if-changed lib test && flutter analyze --fatal-infos && flutter test && flutter build apk --debug)`. Rodado na árvore real, etapa por etapa
- **Result**: cada etapa terminou verde
  - `validar.py`: caminho, forja e sulco `ok` (só avisos de mock/intervalo, esperados no modo dev), `EXIT validar=0`. Validador: `Ran 6 tests … OK`
  - Motor: format "26 files (0 changed)", analyze "No issues found!", `00:00 +64: All tests passed!`
  - App: format "78 files (0 changed)", analyze "No issues found! (ran in 5.3s)", `00:42 +222: All tests passed!`
  - APK: `✓ Built build/app/outputs/flutter-apk/app-debug.apk`
- **Test count before feature**: motor **51** · app **171** · validador 6 (reconfirmado rodando `dart test` / `flutter test` em `25b2296` no worktree de rascunho: `+51` e `+171`)
- **Test count after feature**: motor **64** · app **222** · validador 6
- **Delta**: motor +13 · app +51 · validador 0
- **Weakened assertions**: nenhuma. O único teste com outra expectativa é `LER-01` → `INI-01`, por decisão do spec (A4), e afirma mais que antes
- **Skipped tests**: nenhum
- **Failures**: nenhuma
- `git status` da árvore real limpo depois do gate (`build/` é ignorado)

---

## Fix Plans

Todos só de teste. O código do HEAD está certo (P1–P6 passam). Total ≈ 35 min.

### Fix 1: AC-16 na tela: o app passar menos de 10 recentes ao motor não é detectado (M31)

- **Root cause**: o único teste de tela com recentes (`selecao/um_ponto_para_agora_test.dart:108-124`) tem 1 leitura e uma coleção de 5 pontos. Qualquer `limite ≥ 1` passa.
- **Fix task**: em `selecao/um_ponto_para_agora_test.dart`, `'AGORA-02: the app leaves out exactly the ten most recent points'`. Coleção de teste local com uma obra de 12 pontos; gravar 11 leituras distintas (1…11); tocar "Um ponto para agora" com `_FonteFixa(0)`; afirmar `limites == [2]` e o ponto 1 aberto (sonda P3).
- **Verify**: reaplicar M31 (`lib/selecao/um_ponto_para_agora.dart:94`, `limite: 1`) → falha com `[11]`.
- **Priority**: Major (é a promessa do Goal "nunca devolve um dos 10 últimos") · ~10 min

### Fix 2: AC-24: compartilhar depois de Próximo não é testado (M36)

- **Root cause**: todos os testes compartilham o ponto com que a página abriu.
- **Fix task**: em `colecao/compartilhar_test.dart`, `'COMP-01: after Próximo, sharing sends the reference now at the top'`: Caminho 2 → Próximo → compartilhar → `compartilhados == ['Caminho, capítulo Oração, ponto 81']` (sonda P5).
- **Verify**: reaplicar M36 (`lib/colecao/ponto_page.dart:64`, referência de `widget.inicial`) → falha.
- **Priority**: Major (mandaria a alguém o ponto errado) · ~5 min

### Fix 3: AC-09: "abaixo" não é afirmado (M27)

- **Fix task**: em `leitura/continue_de_onde_parou_test.dart` (CONT-01), afirmar `getTopLeft(find.text('Continue de onde parou')).dy < getTopLeft(find.text(referencia2)).dy` (sonda P4).
- **Verify**: reaplicar M27 (`lib/leitura/continue_de_onde_parou.dart:56-58`, título ↔ subtítulo) → falha.
- **Priority**: Minor · ~3 min

### Fix 4: AC-01: a conversão para UTC não é exercitada (M14)

- **Root cause**: todo relógio de teste devolve `DateTime.utc(...)`, então tirar o `toUtc()` não muda nada.
- **Fix task**: em `leitura/leituras_repositorio_test.dart`, `'LEI-01: a local device clock is recorded as the same instant in UTC'`: `Registro(banco, agora: () => DateTime(2026,10,7,6,15))` → `lidoEm.isUtc` e `lidoEm == local.toUtc()` (sonda P6). A asserção `isUtc` não depende do fuso da máquina.
- **Verify**: reaplicar M14 (`lib/leitura/leituras_repositorio.dart:23`) → falha.
- **Priority**: Minor · ~5 min

### Fix 5: edge case 4 no continue (M44)

- **Fix task**: em `leitura/continue_de_onde_parou_test.dart`, `'CONT-01: a chapter with no title yet shows the reference without it'`: coleção local com capítulo `titulo: null`; leitura `biblioteca`; afirmar "Continue de onde parou" e a referência sem "capítulo" (sonda P2).
- **Verify**: reaplicar M44 (`lib/leitura/continue_de_onde_parou.dart:58`, referência montada à mão) → falha.
- **Priority**: Minor · ~5 min

### Fix 6: edge case 5, toques rápidos

- **Fix task**: em `leitura/leitura_na_pagina_test.dart`, `'LEI-03: quick Próximo/Anterior taps record one reading per point shown, in order'`: Próximo, Próximo, Anterior com só `tester.pump()` entre eles; afirmar a lista exata `[(2, aleatorio), (81, bib), (82, bib), (81, bib)]` (sonda P1).
- **Priority**: Minor · ~5 min

### Riscos sem fix nesta rodada

- **M22 equivalente (AD-011)**: o `transaction()` do `onUpgrade` não pode ser provado enquanto a migração tiver um passo só. Na próxima subida de schema com 2+ passos, o teste de rollback precisa fazer o **2º** passo falhar (L-007), senão o `transaction()` volta a ser intestável.
- **Linha estragada ocupa a janela**: `_lerPontos` (`lib/leitura/leituras_repositorio.dart:74-77`) descarta o PontoId estragado **depois** do `LIMIT`. Uma linha estragada entre as 10 mais recentes reduz a janela real para 9. O app nunca grava uma linha assim, então o risco é baixo, e a regra do edge case 2 (ignorar sem apagar) continua valendo. Registrado só como observação.
- **AD-004**: 3 nomes de teste sem ID (ver Reverse check). ~2 min.

---

## Requirement Traceability Update

`spec.md` não foi alterado por este Verifier (escopo: só `validation.md`). Status proposto:

| Requirement | Previous Status | New Status |
| --- | --- | --- |
| LEI-01 | Implemented | ❌ Needs Fix (Fix 4) |
| LEI-02 | Implemented | ✅ Verified |
| LEI-03 | Implemented | ⚠️ Verified (edge case 5 → Fix 6) |
| LEI-04 | Implemented | ✅ Verified |
| LEI-05 | Implemented | ✅ Verified |
| LEI-06 | Implemented | ✅ Verified |
| LEI-07 | Implemented | ✅ Verified (M22 equivalente) |
| LEI-08 | Implemented | ✅ Verified |
| CONT-01 | Implemented | ❌ Needs Fix (Fix 3, Fix 5) |
| CONT-02 | Implemented | ✅ Verified |
| CONT-03 | Implemented | ✅ Verified |
| CONT-04 | Implemented | ✅ Verified |
| CONT-05 | Implemented | ✅ Verified |
| CONT-06 | Implemented | ✅ Verified |
| AGORA-01 | Implemented | ✅ Verified |
| AGORA-02 | Implemented | ❌ Needs Fix (Fix 1) |
| AGORA-03 | Implemented | ✅ Verified |
| AGORA-04 | Implemented | ✅ Verified |
| AGORA-05 | Implemented | ✅ Verified |
| AGORA-06 | Implemented | ✅ Verified |
| INI-01 | Implemented | ✅ Verified |
| INI-02 | Implemented | ✅ Verified |
| INI-03 | Implemented | ✅ Verified |
| COMP-01 | Implemented | ❌ Needs Fix (Fix 2) |
| COMP-02 | Implemented | ✅ Verified |
| COMP-03 | Implemented | ✅ Verified |

---

## Summary

**Overall**: ❌ Not Ready (rodada 0). Só faltam testes; o comportamento está certo.

**Spec-anchored check**: 25/26 ACs com o resultado do spec afirmado por inteiro; AC-09 parcial; 0 spec-precision gaps.
**Sensor**: 38/44 killed. 5 sobreviventes não equivalentes (M14, M27, M31, M36, M44) e 1 equivalente (M22).
**Gate**: motor 64 ✅ · app 222 ✅ · validador 6 ✅ · analyze/format limpos · APK de debug gerado.

**What works**: log de leituras no banco cifrado (nenhum rastro nos bytes nem nas preferências); migração 1 → 2 com rollback provado contra o schema v0.3 real; continue só em sequência, sobrevivendo a fechar o app; sorteio determinístico com janela de 10 distintos que encolhe pelo mais antigo; home na ordem certa, sem culpa nem contagem, cabendo em 320 px; compartilhar só a referência, com falha avisada e log só pelo tipo.

**Issues found**: Fix 1–6 acima (~35 min, só testes).

**Next steps**: aplicar Fix 1–6 → re-verificar (rodada 1: reaplicar M14, M27, M31, M36, M44 e o gate) → UAT no aparelho (TD-004) com as decisões A7–A22 marcadas "não".

---

## Rodada 1 (re-verificação com escopo)

**Date**: 2026-10-07 · **Diff range**: `f8a1317..553e766` (7 commits, só `test/`; `git diff --stat f8a1317..553e766 -- apps/ponto_mobile/lib packages/ponto_motor/lib` vazio)

### Gate

`bash -c 'set -o pipefail; …'` com o Build gate do `tasks.md`, na árvore real: `validar OK` · validador `Ran 6 tests … OK` · motor format "26 files (0 changed)", analyze "No issues found!", `+64: All tests passed!` · app format "78 files (0 changed)", analyze "No issues found!", `00:38 +227: All tests passed!` · `✓ Built build/app/outputs/flutter-apk/app-debug.apk` · `GATE EXIT=0`. A suíte do app também rodou com `TZ=UTC`: `+227: All tests passed!`. O fuso padrão da máquina é UTC−3 (America/Sao_Paulo). Contagem: motor 64 (só renomes) · app 222 → **227** (+5). Árvore real limpa depois.

### Integridade do diff

- `expect(` por arquivo só cresceu: compartilhar 16→18, continue 29→32, página 20→22, repositório 18→20, aleatório 31→33, motor 11→11
- As únicas linhas removidas são os três testes renomeados (F7). Eles voltam com as **mesmas** asserções, só com a quebra de linha do formatador
- Nenhuma mudança em `lib/`

### Gaps da rodada 0 → evidência nova

| Gap | Fix | `file:line` + assertion (em `553e766`) | Spec-anchored? | Mutante reinjetado (worktree novo, suíte inteira) |
| --- | --- | --- | --- | --- |
| 1 · AC-16 na tela | feeea96 | `selecao/um_ponto_para_agora_test.dart:127-181`: 12 pontos, lidos 1…11 → `fonte.limites == [2]` (`:179`) e "Ponto 1." aberto (`:180`) | ✅ P1–P10 = pontos 11…2 de fora, P11 = ponto 1 sorteável; exatamente 10 excluídos de 12 | M31 (`limite: 1`) ✅ morto · M31b (`limite: 9`) ✅ morto |
| 2 · AC-24 depois de Próximo | 0bb9e9c | `colecao/compartilhar_test.dart:81-94`: topo "…Oração, ponto 81" e `compartilhados == ['Caminho, capítulo Oração, ponto 81']` (`:92`) | ✅ "exatamente a referência mostrada no topo" | M36 ✅ morto |
| 3 · AC-09 "abaixo" | a01b505 | `leitura/continue_de_onde_parou_test.dart:84-88`: `dy(referência) > dy(rótulo)` | ✅ | M27 ✅ morto |
| 4 · AC-01 UTC | 44f2801 | `leitura/leituras_repositorio_test.dart:47-56`: relógio local `DateTime(2026,10,7,6,15)` → `isUtc` (`:54`) e `== local.toUtc()` (`:55`) | ✅ mesmo instante, gravado em UTC | M14 ✅ morto no fuso padrão (UTC−3) **e** com `TZ=UTC` |
| 5 · edge case 4 no continue | cbd69f1 | `leitura/continue_de_onde_parou_test.dart:102-147`: capítulo `titulo: null` → "Continue de onde parou" e `'Caminho, ponto 390'` (`:145`) | ✅ igual ao topo da página | M44 ✅ morto |
| 6 · edge case 5 | 5ad7377 | `leitura/leitura_na_pagina_test.dart:144-165`: 3× Próximo com só `pump()` entre os toques (`:151`, `:153`) → 4 leituras em ordem (`:158-164`) | ⚠️ parcial: prova a ordem, mas a gravação em memória termina dentro do quadro, então descartar uma gravação "em voo" passa (M45, abaixo) | — |
| AD-004 | 553e766 | `CONT-01: the order is …` (`leitura/leituras_repositorio_test.dart:96`), `CONT-05: a reading with a broken point id …`, motor `AGORA-04: a single-point work …` | ✅ todos os nomes do diff começam com o ID | — |

### Sensor da rodada 1

Worktree novo em `553e766` (`git worktree add --detach …/verificar-voltar-r1 553e766`; baseline `+227: All tests passed!`). Uma mutação por vez, por substituição exata. Cada mutante rodou contra a **suíte inteira do app**. Depois de cada um: `git checkout -- .` e `git status --porcelain` vazio. No fim, `git worktree remove --force`. Nunca `git stash`.

| # | File:line | Description | Killed? |
| --- | --- | --- | --- |
| M31 | `lib/selecao/um_ponto_para_agora.dart:94` | `limite: 1` | ✅ AGORA-02 (home, 10 recentes) |
| M31b | idem | `limite: 9` | ✅ AGORA-02 (home, 10 recentes) |
| M36 | `lib/colecao/ponto_page.dart:64` | compartilha a referência do ponto inicial | ✅ COMP-01 (depois de Próximo) |
| M27 | `lib/leitura/continue_de_onde_parou.dart:56-58` | título ↔ subtítulo | ✅ CONT-01 (abaixo) |
| M14 | `lib/leitura/leituras_repositorio.dart:23` | sem `toUtc()`, fuso UTC−3 | ✅ LEI-01 (relógio local) |
| M14-UTC | idem | sem `toUtc()`, `TZ=UTC` | ✅ LEI-01 (relógio local) |
| M44 | `lib/leitura/continue_de_onde_parou.dart:58` | referência montada à mão, sem o ramo "sem capítulo" | ✅ CONT-01 (sem título) |
| M45 *(novo)* | `lib/colecao/ponto_page.dart:114-117` | `_ir` ignora a gravação enquanto a anterior está em voo (um "anti-duplicata" de gravação) | ❌ **Survived** (227 passaram). P7 mata → Fix 7 |
| M48 *(novo)* | `lib/selecao/um_ponto_para_agora.dart:94` | o aleatório usa a consulta "em sequência" como recentes | ✅ 7 testes (AGORA-01 ×2, AGORA-02 ×2, AGORA-05 …) |
| M49 *(novo)* | `lib/selecao/um_ponto_para_agora.dart:74` | o app passa os recentes do mais antigo ao mais novo (`recentes.reversed`) | ❌ **Survived** (227 passaram). P8 mata → Fix 8 |

**Result**: 8/10 mortos. Os 5 sobreviventes da rodada 0 (+ M31b, M14-UTC) morrem. Os 2 sobreviventes são novos: M45 e M49.

### Sondas da rodada 1 (descartáveis, só no worktree)

| # | Sonda | No HEAD | Mata |
| --- | --- | --- | --- |
| P7 | Banco em memória com `QueryInterceptor` que atrasa cada `INSERT` em 50 ms (como um arquivo cifrado num aparelho). Página no Caminho 1, 3× Próximo só com `pump()` e depois `pump(1 s)` → leituras `[1, 2, 81, 82]` | ✅ passa | M45 (só `[1, 2]`) |
| P8 | Home; lidos 81, 1, 82, 2 (toda a obra Caminho na janela); filtro "Caminho"; `_FonteFixa(0)` → `limites == [1]` e abre o 81 (o lido há mais tempo) | ✅ passa | M49 (abre o 2, o último lido, que é o Must-not do AC-18) |

### Fix Plans (rodada 1)

#### Fix 7: edge case 5 com gravação lenta (M45)

- **Root cause**: no banco em memória, a gravação termina antes do próximo quadro. O teste de toques rápidos (`leitura/leitura_na_pagina_test.dart:144-165`) não distingue "gravar cada ponto" de "pular a gravação enquanto outra está em voo".
- **Fix task**: no mesmo arquivo, variante do LEI-03 com `BancoRegistro(NativeDatabase.memory().interceptWith(<interceptor que faz await Future.delayed(50 ms) em runInsert>))`. Fazer 3× Próximo com `pump()`, depois `pump(const Duration(seconds: 1))`, e afirmar a lista exata de leituras (sonda P7).
- **Verify**: reaplicar M45 em `lib/colecao/ponto_page.dart:114-117` → falha com `[1, 2]`.
- **Priority**: Minor · ~10 min

#### Fix 8: AC-18 na tela: a ordem dos recentes que o app passa ao motor (M49)

- **Root cause**: F1 provou o **limite** da consulta, mas não a **ordem**. A janela só encolhe pelo lado certo se o app passar os recentes do mais novo ao mais antigo.
- **Fix task**: em `selecao/um_ponto_para_agora_test.dart`, `'AGORA-04: a work fully within the window gives its oldest read point'`. Ler 81, 1, 82, 2; escolher "Caminho"; tocar "Um ponto para agora" com `_FonteFixa(0)`; afirmar `limites == [1]` e "Primeiro ponto da oração." aberto (sonda P8).
- **Verify**: reaplicar M49 (`lib/selecao/um_ponto_para_agora.dart:74`, `recentes.reversed`) → falha.
- **Priority**: Minor · ~5 min

### Requirement Traceability (rodada 1)

LEI-01, CONT-01, AGORA-02 e COMP-01 passam a ✅ Verified. Ficam ⚠️ **LEI-03** (Fix 7) e **AGORA-04** (Fix 8). O resto segue ✅ Verified. M22 continua equivalente.

### Summary (rodada 1)

**Overall**: ❌ Not Ready por 2 testes Minor (~15 min). Comportamento certo no HEAD (P7, P8). Todos os gaps da rodada 0 estão fechados e provados.
**Spec-anchored check**: 26/26 ACs com o resultado do spec afirmado. Edge case 5 parcial (M45). 0 spec-precision gaps.
**Sensor (rodada 1)**: 8/10 mortos. Sobreviventes novos: M45, M49.
**Gate**: motor 64 ✅ · app 227 ✅ (UTC−3 e `TZ=UTC`) · validador 6 ✅ · APK ✅.
**Next steps**: Fix 7 + Fix 8 → rodada 2 (reaplicar M45, M49 e o gate). É a 2ª de no máximo 3 iterações. Se o usuário preferir, os dois podem ser aceitos como risco registrado: nenhum muda o comportamento atual.

---

## Rodada 2 (re-verificação com escopo, a última permitida)

**Date**: 2026-10-07 · **Diff range**: `342d5b1..cc8a550` (2 commits, só `test/`; `git diff --stat 342d5b1..cc8a550 -- apps/ponto_mobile/lib packages/ponto_motor/lib` vazio)

### Gate

`bash -c 'set -o pipefail; …'` com o Build gate do `tasks.md`, na árvore real: `validar OK` · validador `Ran 6 tests … OK` · motor format "26 files (0 changed)", analyze "No issues found!", `+64: All tests passed!` · app format "78 files (0 changed)", analyze "No issues found! (ran in 5.3s)", `00:37 +228: All tests passed!` · `✓ Built build/app/outputs/flutter-apk/app-debug.apk` · `GATE EXIT=0`. Com `TZ=UTC`: `00:37 +228: All tests passed!`. App 227 → **228** (+1). Árvore real limpa depois.

### Integridade do diff

- `expect(`: `leitura/leitura_na_pagina_test.dart` 22→22, `selecao/um_ponto_para_agora_test.dart` 33→36
- Linhas removidas: o `import` do drift (agora com mais nomes), o nome antigo do teste LEI-03 e um comentário. Nenhuma asserção saiu
- O LEI-03 de toques rápidos ganhou o banco lento e um `pump(500 ms)`, e manteve as mesmas asserções de ordem e de texto. Isso fortalece o teste, não o enfraquece

### Gaps da rodada 1 → evidência nova

| Gap | Fix | `file:line` + assertion (em `cc8a550`) | Spec-anchored? | Mutante reinjetado (worktree novo, suíte inteira) |
| --- | --- | --- | --- | --- |
| 7 · edge case 5 com gravação lenta | cc8a550 | `leitura/leitura_na_pagina_test.dart:146-171`: `BancoRegistro(NativeDatabase.memory().interceptWith(_GravacaoLenta()))` (`:149-151`, 50 ms por INSERT, `:300`), 3× Próximo com `pump()`, `pump(500 ms)` (`:161`) → leituras `[1, 2, 81, 82]`, todas `biblioteca` | ✅ "uma leitura por ponto mostrado, na ordem", com a gravação anterior ainda em curso | M45 ✅ morto (fuso padrão e `TZ=UTC`) |
| 8 · AC-18 na tela | e0b59d0 | `selecao/um_ponto_para_agora_test.dart:184-207`: lidos 81, 1, 82, 2; filtro "Caminho" → `limites == [1]` (`:203`), abre "Primeiro ponto da oração." e **não** "Segundo ponto do caráter." (`:205`) | ✅ Expected (o lido há mais tempo) e Must-not (nunca o último lido), os dois afirmados | M49 ✅ morto |

### Sensor da rodada 2

Worktree novo em `cc8a550` (baseline `+228: All tests passed!`). Uma mutação por vez, cada uma contra a **suíte inteira do app**. Depois de cada uma: `git checkout -- .` e `git status --porcelain` vazio. No fim, `git worktree remove --force`. Nunca `git stash`.

| # | File:line | Description | Killed? |
| --- | --- | --- | --- |
| M45 | `lib/colecao/ponto_page.dart:114-117` | `_ir` ignora a gravação enquanto a anterior está em voo | ✅ LEI-03 (gravação lenta) |
| M45-UTC | idem, `TZ=UTC` | idem | ✅ LEI-03 (gravação lenta) |
| M49 | `lib/selecao/um_ponto_para_agora.dart:74` | recentes do mais antigo ao mais novo | ✅ AGORA-04 (tela) |
| M50 *(varredura)* | `lib/colecao/ponto_page.dart:114-117` | grava só o último ponto depois de 300 ms (debounce) | ✅ LEI-03 (gravação lenta) |
| M57 *(varredura)* | `lib/leitura/registrar_leitura.dart:14` | sem a guarda "registro nulo" (`registro!`) | ✅ 16 testes (CIFRA-04 ×2, LEI-05 (a) …) |
| M59 *(varredura)* | `lib/selecao/um_ponto_para_agora.dart:63` | o chip marcado é sempre "Todas as obras" | ✅ AGORA-05 (continua escolhida) |
| M62 *(varredura)* | `lib/inicio_page.dart:30` | a home cria um `Random()` em vez de usar o injetado (regra 6) | ✅ 8 testes (AGORA-01 ×2, AGORA-02 ×2 …) |
| M65 *(varredura)* | `lib/colecao/ponto_page.dart:123` | falha ao compartilhar sem ir ao log | ✅ COMP-02 |
| M64 *(varredura)* | `lib/leitura/continue_de_onde_parou.dart:37` | continue procura só nos **2** últimos pontos em sequência (A12 diz 10) | ❌ **Survived** (228 passaram). P9 mata → Fix 9 |
| M64b | idem | limite **9** | ❌ **Survived** (228). P9 mata |
| M64c | idem | limite **11** | ❌ **Survived** (228). P9 mata |

**Result**: 8/11 mortos. M45 e M49 estão fechados. Sobrevive uma família só: o limite do continue (M64, M64b, M64c). O AC-13 testa **um** ponto ausente, então qualquer limite ≥ 2 passa. O round 0 já tinha morto o limite 1 (M28).

### Sonda da rodada 2 (descartável, só no worktree)

| # | Sonda | No HEAD | Mata |
| --- | --- | --- | --- |
| P9 | (a) leitura `biblioteca` do Caminho 2 e depois de 9 pontos inexistentes (Caminho 901…909) → home mostra "Continue de onde parou" e "Caminho, capítulo Caráter, ponto 2". (b) o mesmo com 10 inexistentes (o B fica em 11º) → continue some | ✅ (a) e (b) passam | limite 2 e 9 (falha a), limite 11 (falha b) |

### Fix Plans (rodada 2)

#### Fix 9: A12: a janela de 10 do continue, nos dois lados do limite (M64, M64b, M64c)

- **Root cause**: o único cenário com ponto ausente (AC-13, `leitura/continue_de_onde_parou_test.dart:238-257`, CONT-05) tem 1 ausente. Qualquer limite ≥ 2 passa.
- **Fix task**: em `leitura/continue_de_onde_parou_test.dart`, dois casos `'CONT-05: …'` (sonda P9). B lido em sequência e depois 9 pontos inexistentes → continue mostra B. Com 10 inexistentes → continue some.
- **Verify**: reaplicar o limite 2, 9 e 11 em `lib/leitura/continue_de_onde_parou.dart:37` → cada um falha num dos dois casos.
- **Priority**: Minor (só aparece com 2+ pontos lidos que somem do conteúdo; o AC-13 está coberto) · ~5 min

### Escalada

Esta é a 3ª iteração (rodadas 0, 1 e 2), o limite do fluxo fix → re-verify. **Decisão do usuário**:

- **(A) Recomendado**: aplicar o Fix 9 (~5 min, só teste, a sonda P9 pronta). Depois, uma checagem curta: reaplicar os limites 2, 9 e 11 e rodar o gate.
- **(B)** Aceitar como risco registrado em `.specs/TECH-DEBT.md`. O comportamento no HEAD está certo (P9 passa), e o requisito AC-13 está coberto.

### Requirement Traceability (rodada 2)

LEI-03 e AGORA-04 passam a ✅ Verified. **CONT-05** fica ⚠️ (A12, Fix 9). Os outros 25 seguem ✅ Verified. M22 continua equivalente.

### Summary (rodada 2)

**Overall**: ❌ Not Ready só pelo Fix 9 (Minor, ~5 min), escalado ao usuário. O comportamento está certo no HEAD em tudo o que foi sondado (P1–P9).
**Spec-anchored check**: 26/26 ACs com o resultado do spec afirmado; edge cases 6/6; 0 spec-precision gaps. Sem prova: só a janela de 10 da A12 no continue.
**Sensor (rodada 2)**: 8/11 mortos. Sobrevivem M64, M64b e M64c (uma família).
**Sensor acumulado**: rodada 0, 38/44 (1 equivalente); rodada 1, 8/10; rodada 2, 8/11. Todos os sobreviventes das rodadas 0 e 1 foram mortos.
**Gate**: motor 64 ✅ · app 228 ✅ (UTC−3 e `TZ=UTC`) · validador 6 ✅ · APK ✅.

---

## Rodada 3 (re-verificação do diff do fix, final)

**Date**: 2026-10-07 · **Diff range**: `aa93d03..79b1630` (1 commit, só `test/leitura/continue_de_onde_parou_test.dart`; `git diff --stat aa93d03..79b1630 -- apps/ponto_mobile/lib packages/ponto_motor/lib` vazio). Escopo: só o diff do fix, sem nova varredura.

### Gate

`bash -c 'set -o pipefail; …'` com o Build gate do `tasks.md`, na árvore real: `validar OK` · validador `Ran 6 tests … OK` · motor format "26 files (0 changed)", analyze "No issues found!", `+64: All tests passed!` · app format "78 files (0 changed)", analyze "No issues found! (ran in 2.6s)", `00:30 +230: All tests passed!` · `✓ Built build/app/outputs/flutter-apk/app-debug.apk` · `GATE EXIT=0`. Com `TZ=UTC`: `00:30 +230: All tests passed!`. App 228 → **230** (+2). Árvore real limpa depois.

### Integridade do diff

`expect(` em `leitura/continue_de_onde_parou_test.dart`: 32 → 34. Nenhuma linha removida no commit (só inserções). Nenhuma mudança em `lib/`.

### Gap da rodada 2 → evidência nova

| Gap | Fix | `file:line` + assertion (em `79b1630`) | Spec-anchored? | Mutante reinjetado (worktree novo em `79b1630`, suíte inteira) |
| --- | --- | --- | --- | --- |
| 9 · janela de 10 do continue (A12, com AC-13) | 79b1630 | `leitura/continue_de_onde_parou_test.dart:258-275`, dois casos `CONT-05`. B (Caminho 2) lido em sequência e depois **9** pontos inexistentes → "Continue de onde parou" e a referência de B `findsOneWidget` (`:271-272`). Depois de **10** inexistentes → os dois `findsNothing` | ✅ A12: "dentre os 10 últimos pontos distintos lidos em sequência, o mais recente que exista; se nenhum, some". Com 9 ausentes, B é o 10º e aparece. Com 10, B é o 11º e o continue some. AC-13: o ausente é pulado e o continue aponta para B | M64 (`limite: 2`) ✅ morto · M64b (`limite: 9`) ✅ morto · M64c (`limite: 11`) ✅ morto |

Antes de rodar, conferi que cada mutante estava aplicado: `git diff --stat -- apps/ponto_mobile/lib` → "1 file changed, 1 insertion(+), 1 deletion(-)". Cada um rodou contra a suíte inteira (230). M64 e M64b falham em "behind 9 points … still finds …". M64c falha em "behind 10 points … no longer looks for …". Depois de cada um, `git checkout -- .` e `git status --porcelain` vazio. No fim, `git worktree remove --force`. Nunca `git stash`.

### Requirement Traceability (final)

| Requirement | Status |
| --- | --- |
| LEI-01 … LEI-08 | ✅ Verified (LEI-07: M22 equivalente, sem efeito observável com um passo de migração) |
| CONT-01 … CONT-06 | ✅ Verified |
| AGORA-01 … AGORA-06 | ✅ Verified |
| INI-01 … INI-03 | ✅ Verified |
| COMP-01 … COMP-03 | ✅ Verified |

### Summary (final)

**Overall**: ✅ Ready (do lado do Verifier).
**Spec-anchored check**: 26/26 ACs com o resultado do spec afirmado; edge cases 6/6; A12 provado nos dois lados; 0 spec-precision gaps.
**Sensor acumulado**: rodada 0, 38/44 (M22 equivalente); rodada 1, 8/10; rodada 2, 8/11; rodada 3, 3/3. **Todos os sobreviventes não equivalentes estão mortos**: M14, M27, M31, M36, M44, M45, M49, M64, M64b, M64c.
**Gate**: motor 64 ✅ · app 230 ✅ (UTC−3 e `TZ=UTC`) · validador 6 ✅ · analyze e format limpos · APK ✅.
**Riscos que ficam (registrados, sem fix)**: (1) o `transaction()` do `onUpgrade` só poderá ser provado quando a migração tiver 2+ passos (AD-011, L-007); (2) uma linha com PontoId estragado entre as 10 mais recentes ocupa um lugar da janela (`lib/leitura/leituras_repositorio.dart:74-77`). O app nunca grava uma linha assim.
**Next steps**: UAT no aparelho (TD-004): A7–A13, A18, A19, A22, e "ler três pontos, fechar, reabrir → continue no terceiro". Depois, a reconciliação de fechamento (`roadmap.md`, `backlog.md`, `dominios.md`, `docs/LESSONS.md`).
