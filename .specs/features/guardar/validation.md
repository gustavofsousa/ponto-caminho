# Guardar (v0.3) Validation

**Date**: 2026-10-02
**Spec**: `.specs/features/guardar/spec.md`
**Diff range**: `main..feat/v0.3-guardar` = `5077422..2e9b930` (22 commits, 5077422 … 2e9b930)
**Verifier**: independent sub-agent (author ≠ verifier)
**Verdict**: ✅ PASS (rodada 1). A rodada 0 deu ❌ FAIL: 6 mutantes sobreviveram (M22, M29, M30b, M32, M38, M47), 4 ACs estavam parciais (AC-06, AC-16, AC-17, AC-27) e o AC-01 tinha um spec-precision gap. A rodada 1 (`19bf448..a37523f`) fechou tudo só com testes e uma revisão do spec. Os 6 sobreviventes morreram, mais 6 checagens focadas, e o gate passa. Ver "Round 1".

---

## Task Completion

| Task | Status | Notes |
| ---- | ------ | ----- |
| T1–T21 | ✅ Done | Todos os cabeçalhos com ✅ em `tasks.md`. Commits d3ffd9b…2e9b930. As caixas "Done when" estão como `[ ]`, mas é só formatação: conferi cada critério por evidência, abaixo. `git diff main..HEAD -- apps packages ':!*.g.dart' \| grep -E "^\+.*(SPEC_DEVIATION\|TODO\|FIXME\|ignore:)"` → exit 1 (vazio). |
| T9 / Build gate | ✅ Done | `flutter build apk --debug` (cópia de rascunho) → `✓ Built build/app/outputs/flutter-apk/app-debug.apk`. O manifesto mesclado tem `allowBackup=false` e `dataExtractionRules`, e `libsqlite3mc.so` está no APK nos 3 ABIs (ver Gate Check). |

---

## Spec-Anchored Acceptance Criteria

Caminhos relativos a `apps/ponto_mobile/test/` (app) e `packages/ponto_motor/test/` (motor). "Mxx" = mutante do sensor; "Px" = sonda descartável (seção Probes).

| AC (req) | Spec-defined outcome | `file:line` + assertion | Result |
| --- | --- | --- | --- |
| AC-01 (CIFRA-01) arquivo cifrado desde a criação | bytes sem "silêncio-que-ninguém-lê" (UTF-8) e sem "SQLite format 3"; o banco relata cifra ativa; nunca um arquivo em claro | `infra/banco_cifrado_test.dart:63-65`: `expect(bytes, isNotEmpty)`, `_contem(bytes, _segredo), isFalse`, `_contem(bytes, 'SQLite format 3'), isFalse`. `:66-69`: `cifra.data.values.single` não vazio. Pela abertura real (cenário "primeira vez"): `registro/abrir_registro_test.dart:54-55`, mesmo par de asserções | ✅ PASS (M49, abrir sem o `setup` da cifra, morto por 3 testes CIFRA-01). ⚠️ **Spec-precision gap**: "relata uma cifra ativa" não tem um observável definido. A asserção `:66-69` não discrimina nada: a sonda P9 mostra que `PRAGMA cipher` responde `chacha20` também num arquivo **em claro** (com cabeçalho e texto legíveis). Quem prova o AC são as asserções sobre os bytes |
| AC-02 (CIFRA-02) sem cifra não abre | a abertura falha com erro; nenhuma tabela criada; nunca cai para banco em claro | `infra/banco_cifrado_test.dart:90`: `prepararCifra(semCifra, _chave)` → `throwsStateError`. `:102`: `banco.select(...).get()` → `throwsStateError`. `:108-113`: `sqlite_master` com `type='table'` → `isEmpty` | ✅ PASS (M01 morto) |
| AC-03 (CIFRA-03) chave antes do arquivo, a mesma depois | chave gravada antes de o arquivo existir; a 2ª abertura usa a mesma chave e lê a reflexão; nunca uma 2ª chave | `registro/abrir_registro_test.dart:68`: `arquivoExistiaAoGravar, [false]`. `:83`: `reflexoes.map(texto), [_segredo]`. `:84`: `cofre.gravadas, hasLength(1)`. `infra/guarda_da_chave_test.dart:13-14`: 64 hex, `gravadas, [chave]`. `:21-23`: guardada reutilizada, nada gravado | ✅ PASS (M06, M07 mortos) |
| AC-04 (CIFRA-04) chave perdida não apaga nada | leitura funciona; página do ponto, Favoritos e Coleções mostram "Não foi possível abrir o que você guardou. Feche o app e abra de novo."; nunca chave nova, apagar, renomear ou sobrescrever | `registro/abrir_registro_test.dart:95-97` (cofre vazio), `:110-112` (cofre que lança), `:121-123` (chave errada): `isNull`, bytes e `lastModified` iguais (`:46-47`), `gravadas, isEmpty`. `infra/guarda_da_chave_test.dart:36-40`, `:51-55` (dois tipos de erro). Telas: `registro/registro_do_ponto_test.dart:129-133` (texto do ponto + aviso; sem Favoritar/Guardar/Escrever), `:143-144` (Favoritos e Coleções: aviso, sem sugestões). App: `app_test.dart` CIFRA-04 ×2 (registro nulo e que lança → referência e texto do Caminho 2) | ✅ PASS (M04, M05, M08, M09, M10, M14, M46 mortos) |
| AC-05 (CIFRA-05) fora de backup | `allowBackup="false"` + regras de extração excluindo tudo em nuvem e transferência | `infra/backup_test.dart:18`, `:22-25`, `:30-40` (5 domínios × 2 modalidades, sem `<include`). APK: `aapt2 dump xmltree` → `allowBackup=false`, `dataExtractionRules=@0x7f100000`; `res/xml/regras_de_extracao.xml` compilado com as 10 exclusões | ✅ PASS (M40, M41 mortos; inspeção do APK feita) |
| AC-06 (REF-01) escrever e guardar | volta à página; mostra o texto e "Escrito em <data>, <hora>."; **nunca** duas reflexões num toque duplo | `registro/reflexao_na_pagina_test.dart:65-71`: editor `findsNothing`, referência, texto e `'Escrito em 12 de março de 2026, 6h40.'` `findsOneWidget`. O toque duplo é `:83-87`: dois `tester.tap` e depois `textosGuardados == ['Quero ser útil hoje.']` | ❌ **GAP (Must not)**. O teste de toque duplo não entrega o 2º toque. Com o handler instrumentado, `_escreverESair` roda **uma vez só**. Sem a guarda (M38), o teste passa. Sem a guarda e com o botão sempre habilitado (M38c), passa também. A sonda P8 chama `onPressed` duas vezes antes da reconstrução: passa no HEAD e mata M38. A parte positiva do AC está ✅ |
| AC-07 (REF-02) vazia não se guarda | "Guardar" desabilitado com vazio/só espaços; guarda sem as pontas | motor `registro/reflexao_test.dart:6-22` (`''`, `'  \n\t \n '` → `isNull`; pontas removidas; quebras internas mantidas). App `registro/reflexao_na_pagina_test.dart:96`, `:100` (`podeGuardar, isFalse`), `:104` (`isTrue`), `:108` (`['Com espaços.']`). Repo `registro/reflexoes_repositorio_test.dart:40-45` | ✅ PASS (M15, M16 mortos) |
| AC-08 (REF-03) voltar com texto pede confirmação | diálogo "Descartar o que você escreveu?". "Continuar escrevendo" fica com o texto intacto; "Descartar" sai sem gravar; não pergunta sem mudança | `registro/editor_de_reflexao_test.dart:82-91` (diálogo; continua com o texto), `:100-106` (descarta, 0 linhas), `:113-117` (voltar do sistema), `:126-134` (vazio e só espaços: sem diálogo), `:184-194` (edição sem mudança: sem diálogo), `:196-206` (com mudança: diálogo) | ✅ PASS (M36, M37 mortos) |
| AC-09 (REF-04) editar | texto novo + "Escrito em 12 de março de 2026, 6h40 · editado em 14 de março de 2026, 21h05."; guardar sem mudar não altera a edição; nunca muda a criação nem duplica | `registro/editor_de_reflexao_test.dart:153-163` (texto novo, antigo ausente, linha completa, `hasLength(1)`), `:176-181` (sem mudança: `editadaEm, isNull`). Repo `registro/reflexoes_repositorio_test.dart:58-61`, `:73-74`, `:84-85` | ✅ PASS no resultado do spec (M21 morto). ⚠️ Sensor: **M22 sobreviveu**. O `WHERE` da edição sem o filtro de `id` reescreve todas as outras reflexões do leitor, e nenhum teste semeia uma 2ª reflexão. A sonda P3 mata M22 |
| AC-10 (REF-05) excluir | diálogo "Excluir esta reflexão? Não dá para desfazer."; "Cancelar" mantém tudo; "Excluir" apaga só ela e volta | `registro/editor_de_reflexao_test.dart:215-228` (diálogo; Cancelar mantém as 2), `:240-243` (só "Segunda." fica, na tela e no banco), `:251` (reflexão nova sem Excluir). Repo `registro/reflexoes_repositorio_test.dart:96` | ✅ PASS (M24 morto) |
| AC-11 (REF-06) só as do ponto, a mais antiga primeiro | as duas do Caminho 2 com a de 12/03 primeiro; a do 81 ausente | `registro/reflexao_na_pagina_test.dart:135-143` (`marco < abril`, as duas datas, `'De outro ponto.'` `findsNothing`). Repo `registro/reflexoes_repositorio_test.dart:107`, `:117-121` (empate → inserção) | ✅ PASS (M23 morto) |
| AC-12 (REF-07) formato da data | 6h40 · 6h · 21h05 · 0h; mês por extenso e minúsculo; fuso do aparelho, nunca UTC | `registro/data_da_reflexao_test.dart:20-27`, `:31-32`, `:51-54` (12 meses), `:61-62` (UTC → local) | ✅ PASS (M42, M43 mortos). Risco: M42 (`toLocal` removido) só morre porque o fuso desta máquina é UTC−3. Num runner em UTC, ele sobreviveria |
| AC-13 (REF-08) falha ao guardar não perde o texto | editor aberto, texto intacto, "Não foi possível guardar agora. Tente de novo."; log com o tipo do erro, nunca com o texto | `registro/reflexao_na_pagina_test.dart:168-176` com **dois** tipos de falha (tabela apagada e banco fechado): editor `findsOneWidget`, `controller.text == texto`, mensagem `findsOneWidget`, `takeException() isA<FalhaNoRegistro>`, `toString` sem o texto. Tipo no log: `registro/abrir_registro_test.dart:134` (`contains('StateError')`, mesmo `relatarFalhaNoRegistro`) | ✅ PASS (M11, M12, M13 e M39 mortos; a captura estreita `on Exception` morre pelo caso "banco fechado"). L-001 foi aplicada |
| AC-14 (FAV-01) favoritar e desfavoritar | 1º toque: "Remover dos favoritos" + ícone preenchido + no banco; 2º: "Favoritar" e sai; sem duplicata | `registro/favoritos_test.dart:55-67` (tooltips, `Icons.star`/`star_border`, banco `[caminho2]` → vazio). Repo `registro/favoritos_repositorio_test.dart:25` (favoritar 2× → 1) | ✅ PASS (M26 morto) |
| AC-15 (FAV-02) lista de favoritos | 81 antes do 2; referência completa + início do texto; toque abre; vazio "Os pontos que você favoritar ficam aqui."; sem PontoId cru | `registro/favoritos_test.dart:101-109` (ordem, referências, textos, `textContaining('ponto:'), findsNothing`), `:119-120` (abre o 81), `:128-131` (vazio) | ✅ PASS (M25 morto) |
| AC-16 (COL-01) criar a partir de um ponto | "Família" existe e já contém o Caminho 2 (marcada); **tudo ou nada** | `registro/guardar_em_colecao_test.dart:89-93` (diálogo fechado, `marcada('Família')`, banco `{'Família': [caminho2]}`). Repo `registro/colecoes_repositorio_test.dart:45-46`; `:55-61` (nome recusado → nem coleção nem vínculo) | ❌ **GAP (Must not)**. O único caso de "tudo ou nada" testado falha na validação, **antes** de qualquer escrita. Tirar a transação (M29) não é detectado. A sonda P1 usa um trigger que aborta o insert do vínculo: passa no HEAD e mata M29 |
| AC-17 (COL-02) um ponto em várias | marcar as duas → nas duas; desmarcar "Família" → só em "Pontos para reler"; nunca afetar outra coleção **ou outro ponto** | `registro/guardar_em_colecao_test.dart:101-121` (marcas e banco nos dois passos). Repo `registro/colecoes_repositorio_test.dart:88-93` | ❌ **GAP parcial (Must not "outro ponto")**. Toda coleção tem só um ponto quando se desmarca. M32 (`tirar` sem o filtro de ponto, que esvazia a coleção) sobrevive. A sonda P4 mata M32. "Outra coleção" está coberto |
| AC-18 (COL-03) regras do nome | "  família " → "Já existe uma coleção com esse nome."; vazio → confirmar desabilitado; o campo para em 60; "  Trabalho " → "Trabalho" | motor `registro/colecao_pessoal_test.dart:14-15`, `:20`, `:24`, `:29-32`, `:37-40`, `:44`. App `registro/guardar_em_colecao_test.dart:135-136` (mensagem + desabilitado), `:145-147`, `:166` (`'a' * 60`), `:179-181`, `:194`. Repo `registro/colecoes_repositorio_test.dart:68`, `:72-75` | ✅ PASS (M17, M18, M20, M48 mortos) |
| AC-19 (COL-04) lista de coleções | ordem de criação com "2 pontos"/"1 ponto"/"Nenhum ponto"; "Nova coleção"; vazio "Crie uma coleção para reunir pontos sobre o que você quiser trabalhar." | `registro/colecoes_test.dart:68-88`, `:110-114`, `:124-130` | ✅ PASS (M27 morto). Ver o edge case A14 (M47) |
| AC-20 (COL-05) pontos de uma coleção | Sulco 1 antes do Caminho 2; referência + texto; toque abre; vazia "Nada aqui ainda. O que você salvar aparece nesta lista."; nunca pontos de outra coleção | `registro/colecoes_test.dart:151-154`, `:170-171`, `:179-182` | ✅ PASS (M28 morto) |
| AC-21 (PAG-01) coleções na página | "Nas coleções: Pontos para reler · Família" (ordem de criação, com "Trabalho" no meio sem o ponto); sem coleção → sem linha | `registro/guardar_em_colecao_test.dart:212-215`, `:232` | ✅ PASS (M45, M27 mortos) |
| AC-22 (PAG-02) a página acompanha | (a) estado novo sem reabrir; (b) depois de "Próximo", o registro do 81 | `registro/registro_do_ponto_test.dart:73-86` (reflexão, favorito, coleção, exclusão); a edição aparece em `registro/editor_de_reflexao_test.dart:153-163`. `registro/registro_do_ponto_test.dart:113-119` (81: favorito, coleção e reflexão dele; nada do 2) | ✅ PASS (M44 morto) |
| AC-23 (SUG-01) sugestões no 1º contato | "Quer começar com algumas coleções?" com os 7 nomes da A11, em ordem e desmarcados; "Criar" desabilitado; "Agora não" habilitado; pela biblioteca e pelo ponto | `registro/sugestoes_test.dart:82-93`, `:99-100`, `:111` | ✅ PASS |
| AC-24 (SUG-02) criar as escolhidas | as duas, na ordem da A11; segue para onde ia; não aparece mais, nem depois de reabrir | `registro/sugestoes_test.dart:127-145`, `:158-159`. Reabrir: `registro/colecoes_repositorio_test.dart:253-257` | ✅ PASS no resultado do AC (M35 morto). ⚠️ Sensor: **M30b sobreviveu**. O "tudo ou nada" da varredura implícita (sugestões + marca numa transação) não é provado; a sonda P2 o mata |
| AC-25 (SUG-03) recusar | nada criado; "Agora não" segue; voltar retorna; não sugere de novo, nem depois de reabrir | `registro/sugestoes_test.dart:174-183`, `:194-204`. Repo `registro/colecoes_repositorio_test.dart:235-236` | ✅ PASS (M33, M34 mortos). "Reabrir" vale por composição: a recusa grava a mesma linha de marco que `:253` lê de volta depois de reabrir |
| AC-26 (COL-06) renomear | novo nome na coleção, na lista e na página dos pontos; pontos mantidos; regras da AC-18 | `registro/colecoes_test.dart:217-232`, `:245-247`. Motor `registro/colecao_pessoal_test.dart:48-58`. Repo `registro/colecoes_repositorio_test.dart:173-175`, `:183-188` | ✅ PASS (M19 morto) |
| AC-27 (COL-07) excluir coleção | diálogo "Excluir a coleção Trabalho? Os pontos e as reflexões continuam."; some **da lista e da página do Caminho 2**; favorito e reflexão ficam; "Cancelar" não muda nada | `registro/colecoes_test.dart:277-286` (diálogo; Cancelar), `:299-313` (lista; banco: Família, favorito, reflexão). Repo `registro/colecoes_repositorio_test.dart:202-209` | ⚠️ **GAP parcial**. Nenhum teste afirma que a página do Caminho 2 perde "Trabalho". A sonda P6 confirma que perde, no HEAD (M31 morto) |

**Status**: ❌ Gaps present. 23/27 ACs têm o resultado do spec afirmado por inteiro. 4 estão parciais: AC-06, AC-16 e AC-17 (um Must not sem evidência) e AC-27 (uma parte do Expected). Há 1 spec-precision gap (AC-01, "cifra ativa").

### Reverse check (testes sem AC)

Todos os testes do diff mapeiam para um requisito, um edge case ou um Done-when: os de 320 px → edge case/T12/T20; os de alvo de toque → UX de T15/T16. Nota sobre o AD-004: o nome completo de 24 testes começa pelo nome do `group`, não pelo ID. São 16 em `registro/colecoes_repositorio_test.dart` (`criar COL-01: …`, `sugestões SUG-02: …`) e 8 no motor `registro/colecao_pessoal_test.dart` (`validarNomeDeColecao COL-03: …`). Também há um caso REF-03 dentro de `group('REF-04: …')`. O rastreio por busca textual funciona; só a regra "começa com o ID" não é seguida. Achei isso extraindo os nomes com `flutter test --reporter json`.

### Probes (descartáveis, só na cópia de rascunho `verify-guardar-apk`)

| # | Sonda | No HEAD | Mata |
| --- | --- | --- | --- |
| P1 | trigger `RAISE(ABORT)` no insert de `pontos_da_colecao`; `criar('Família', comPonto:)` lança e nenhuma coleção existe | ✅ passa | M29 |
| P2 | trigger no insert de `marcos`; `responderSugestoes([...])` lança e nenhuma coleção existe | ✅ passa | M30b |
| P3 | duas reflexões (Caminho 2 e 81); editar a do 2; a do 81 fica igual e sem `editadaEm` | ✅ passa | M22 |
| P4 | coleção com Caminho 2 e 81; tirar o 2; o 81 fica | ✅ passa | M32 |
| P5 | coleção com um ponto ausente dos livros (Caminho 3) + Caminho 2 → lista mostra "1 ponto" | ✅ passa | M47 |
| P6 | página do Caminho 2 aberta; excluir "Trabalho" → "Nas coleções: Família" | ✅ passa | — (AC-27, parte da página) |
| P7 | editor em 320 px a 2,6×: texto longo, rola (`maxScrollExtent > 0`), sem exceção; guardado aparece inteiro (`maxLines` nulo) | ✅ passa | — (edge case 1) |
| P8 | `onPressed` de "Guardar" chamado 2× antes da reconstrução → 1 linha e volta à página | ✅ passa | M38 |
| P9 | `sqlite3.open` **sem** chave, cria tabela com texto: `PRAGMA cipher` = `[[chacha20]]`, cabeçalho `SQLite format 3` e texto em claro | — | mostra que `banco_cifrado_test.dart:66-69` não discrimina |
| Diag. | `_escreverESair` instrumentado com `debugPrint`, rodando o teste de toque duplo (HEAD, M38, M38c) | 1 chamada | explica por que M38 sobrevive |

---

## Discrimination Sensor

Cópia descartável da árvore inteira (`cp -a`, sem `build/`). Uma mutação por vez, por substituição exata de texto (falha se não houver exatamente 1 ocorrência). Primeiro rodei os arquivos de teste do comportamento, com `timeout`; para todo sobrevivente, rodei também a **suíte inteira**. O arquivo foi restaurado e conferido byte a byte depois de cada mutação. Árvore real intocada: `git status --porcelain` igual antes e depois, e `diff -rq` entre a cópia e a árvore real vazio no fim.

| # | File:line | Description | Killed? |
| --- | --- | --- | --- |
| M01 | `apps/ponto_mobile/lib/infra/banco_cifrado.dart:28` | guarda da cifra desligada (`PRAGMA cipher` vazio não lança) | ✅ CIFRA-02 ×2 |
| M02 | `banco_cifrado.dart:22` | sem conferir o formato da chave | ✅ CIFRA-02 key shape |
| M03 | `banco_cifrado.dart:8` | formato aceita maiúsculas (`[0-9a-fA-F]`) | ✅ CIFRA-02 key shape |
| M49 | `banco_cifrado.dart:15` | `createInBackground` sem `setup` (sem `PRAGMA key`) | ✅ CIFRA-01 ×3, CIFRA-04 wrong key |
| M04 | `apps/ponto_mobile/lib/infra/guarda_da_chave.dart:42` | gera chave mesmo com banco existente | ✅ CIFRA-04 ×2 |
| M05 | `apps/ponto_mobile/lib/registro/abrir_registro.dart:18` | `bancoExiste: false` sempre | ✅ CIFRA-04 lost key |
| M06 | `guarda_da_chave.dart:45` | chave nova não é gravada no cofre | ✅ CIFRA-03 ×3 |
| M07 | `abrir_registro.dart:18` | cria o arquivo antes de obter/gravar a chave | ✅ CIFRA-03 before file |
| M08 | `abrir_registro.dart:22` | sem o `SELECT 1` (abertura preguiçosa) | ✅ CIFRA-03, CIFRA-04 wrong key |
| M09 | `abrir_registro.dart:24` | captura estreita (`on ChaveIndisponivel`) | ✅ CIFRA-04 ×3 |
| M10 | `abrir_registro.dart:26-27` | na falha, apaga o arquivo | ✅ CIFRA-04 ×3 |
| M11 | `apps/ponto_mobile/lib/registro/falha_no_registro.dart:19` | relata o erro original (AD-009) | ✅ CIFRA-04 ×2, REF-08 ×2 |
| M12 | `falha_no_registro.dart:22` | erro original no `context` do relato | ✅ CIFRA-04 logged by type |
| M13 | `falha_no_registro.dart:19` | relato sem o tipo (`FalhaNoRegistro(Object)`) | ✅ CIFRA-04 logged by type |
| M14 | `apps/ponto_mobile/lib/app.dart:66-71` | falha ao preparar o registro derruba a abertura | ✅ CIFRA-04 failing registro |
| M15 | `packages/ponto_motor/lib/src/registro/reflexao.dart:25` | sem `trim` | ✅ REF-02 ×3 |
| M16 | `reflexao.dart:26` | vazio vira reflexão | ✅ REF-02 ×2 |
| M17 | `packages/ponto_motor/lib/src/registro/colecao_pessoal.dart:61` | repetido compara com maiúsculas | ✅ COL-03, COL-06 |
| M18 | `colecao_pessoal.dart:57` | limite `>` → `>=` (60 recusado) | ✅ COL-03 ×2 |
| M19 | `colecao_pessoal.dart:61` | renomear não pode manter o próprio nome | ✅ COL-06 |
| M20 | `colecao_pessoal.dart:57` | conta unidades UTF-16, não caracteres | ✅ COL-03 |
| M21 | `apps/ponto_mobile/lib/registro/reflexoes_repositorio.dart:55` | edita mesmo sem mudança (registra `editadaEm`) | ✅ REF-04 ×2 |
| M22 | `reflexoes_repositorio.dart:55` | `WHERE` da edição sem `id`: reescreve todas as reflexões com texto diferente | ❌ **Survived** (suíte inteira: 164 passaram) → Fix 2 |
| M23 | `reflexoes_repositorio.dart:21` | reflexões da mais nova para a mais antiga | ✅ REF-06 ×2 |
| M24 | `reflexoes_repositorio.dart:65` | excluir apaga todas | ✅ REF-05 ×2 |
| M25 | `apps/ponto_mobile/lib/registro/favoritos_repositorio.dart:19` | favoritos do mais antigo ao mais novo | ✅ FAV-02 ×2 |
| M26 | `favoritos_repositorio.dart:37` | favoritar sem `insertOrIgnore` | ✅ FAV-01 twice |
| M27 | `apps/ponto_mobile/lib/registro/colecoes_repositorio.dart:124` | coleções da mais nova para a mais antiga | ✅ COL-04 ×2, PAG-01 |
| M28 | `colecoes_repositorio.dart:126` | pontos da coleção do mais antigo ao mais novo | ✅ COL-05 ×2 |
| M29 | `colecoes_repositorio.dart:32-37` | `criar(…, comPonto:)` sem transação | ❌ **Survived** (suíte inteira) → Fix 4 |
| M30 | `colecoes_repositorio.dart:85-86` | (inválida: a closure não era chamada → erro de compilação) | ⛔ descartada; substituída por M30b |
| M30b | `colecoes_repositorio.dart:85-99` | `responderSugestoes` sem transação | ❌ **Survived** (suíte inteira) → Fix 4 |
| M31 | `apps/ponto_mobile/lib/registro/banco_registro.dart:76` | `foreign_keys = OFF` (sem cascata) | ✅ COL-07 |
| M32 | `colecoes_repositorio.dart:68-72` | `tirar` sem o filtro de ponto (esvazia a coleção) | ❌ **Survived** (suíte inteira) → Fix 3 |
| M33 | `apps/ponto_mobile/lib/registro/sugestoes_page.dart:52` | voltar não conta como recusa | ✅ SUG-03 going back |
| M34 | `sugestoes_page.dart:89` | "Agora não" segue sem responder | ✅ SUG-03 Agora não |
| M35 | `sugestoes_page.dart:95-98` | cria na ordem dos toques, não na da A11 | ✅ SUG-02 order |
| M36 | `apps/ponto_mobile/lib/registro/editor_de_reflexao_page.dart:48` | `PopScope(canPop: true)` | ✅ REF-03 ×4 |
| M37 | `editor_de_reflexao_page.dart:43` | "mudou" compara o texto cru (sem as pontas) | ✅ REF-03 only spaces |
| M38 | `editor_de_reflexao_page.dart:171` | sem a guarda de toque duplo (`if (_guardando) return;`) | ❌ **Survived** (suíte inteira) → Fix 1 |
| M39 | `editor_de_reflexao_page.dart:179` | captura estreita `on Exception` | ✅ REF-08 closed database |
| M40 | `apps/ponto_mobile/android/app/src/main/AndroidManifest.xml:7` | `allowBackup="true"` | ✅ CIFRA-05 backup off |
| M41 | `apps/ponto_mobile/android/app/src/main/res/xml/regras_de_extracao.xml:16` | transferência entre aparelhos deixa de excluir `database` | ✅ CIFRA-05 device-transfer |
| M42 | `apps/ponto_mobile/lib/registro/data_da_reflexao.dart:21` | sem `toLocal()` | ✅ REF-07 ×5, REF-04 (só fora de UTC) |
| M43 | `data_da_reflexao.dart:22` | hora cheia com ":00" ("6h00") | ✅ REF-07 whole hour |
| M44 | `apps/ponto_mobile/lib/colecao/ponto_page.dart:34` | sem `ValueKey(_ponto.id)` (o registro do ponto anterior fica) | ✅ PAG-02 Próximo |
| M45 | `apps/ponto_mobile/lib/registro/registro_do_ponto.dart:85` | lista todas as coleções na página | ✅ PAG-01 ×2 |
| M46 | `registro_do_ponto.dart:26` | registro indisponível sem aviso | ✅ CIFRA-04 page |
| M47 | `apps/ponto_mobile/lib/registro/colecoes_page.dart:87` | contagem inclui pontos que não existem nos livros | ❌ **Survived** (suíte inteira) → Fix 6 |
| M48 | `apps/ponto_mobile/lib/registro/nome_de_colecao_dialog.dart:69` | campo sem `maxLength` | ✅ COL-03 60 chars |
| M38c (diag.) | `editor_de_reflexao_page.dart:62` + `:171` | sem a guarda **e** com o botão sempre habilitado | ❌ Survived (só o teste de toque duplo, na cópia `-apk`). Não entra na contagem: é diagnóstico |

**Sensor depth**: expandido (dado pessoal religioso cifrado): 49 mutações válidas, cobrindo cifra, chave, abertura, log (AD-009), motor, os três repositórios, ordem, transação, cascata, sugestões, editor (PopScope, toque duplo, falha), backup, data e página.
**Result**: 43/49 killed, 6 survived (M22, M29, M30b, M32, M38, M47), 0 hung. ❌ FAIL. Cada sobrevivente tem uma sonda (P1–P5, P8) que passa no HEAD e o mata.

---

## Interactive UAT Results

Não realizado (Verifier sub-agente). Pendentes com o usuário: A1, A2, A3, A5–A10, A12, A15 e A16, marcadas "não — revisar/UAT" no spec. Também falta abrir o registro num aparelho real (TD-004): Keystore, `resetOnError`, tempo do KDF.

---

## Code Quality

| Principle | Status |
| --- | --- |
| Minimum code | ✅. Três repositórios num agregado `Registro`; `pontosDisponiveis` tem 3 usos; nenhuma abstração de uso único além das seams declaradas no design |
| Surgical changes | ✅. Os testes da v0.2 não mudaram (`git diff --stat` vazio em `test/colecao`, `test/preferencias` e nos testes antigos do motor). `montar_tela.dart` e `app_test.dart` só ganharam o parâmetro de registro |
| No scope creep | ✅. Nada fora dos ACs/Done-when. Os testes de alvo de toque são do piso de UX (T15/T16) |
| Matches patterns | ✅. AD-007 (streams no `initState` via `RegistroEscopo`), AD-008, AD-009, AD-006 (Navigator), regra 3 (`colecoes_pessoais` ≠ `Colecao`), `PontoId.toString()` como âncora |
| Comments explain why | ✅. Prefixos `SECURITY:`, `INVARIANT:`, `COMPAT:` com motivo. `.g.dart` excluído do analyzer, com comentário |
| Constitution rules | ✅. Nenhum id de obra em `lib/` (a lista de sugeridas é copy de UI, não id). Reflexão nunca vai ao log (M11/M12/M13 mortos). Chave nova só para banco novo (M04/M05 mortos). Backup desligado (M40/M41 mortos + APK) |
| Spec-anchored outcome check | ⚠️. AC-06, AC-16, AC-17 e AC-27 parciais; AC-01 com spec-precision gap |
| Per-layer Coverage Expectation met | ⚠️. Motor 1:1 com os ACs. A matriz do `tasks.md` pede "transação" e "efeito no banco" nos repositórios: a transação não é provada (M29, M30b) e o isolamento de linha também não (M22, M32) |
| Every test maps to a requirement | ✅, com a nota do AD-004 (24 nomes com prefixo de `group`) |
| Documented guidelines followed | ⚠️. `AGENTS.md` (análise zero, `validar.py` exit 0) ✅. `.specs/STATE.md` AD-004 parcial (ver Reverse check) |

---

## Edge Cases

- [~] Reflexão longa em "Muito grande": editor e página rolam sem cortar. A página rola com reflexão longa a 2,6× (`registro/reflexao_na_pagina_test.dart:181-210`). O editor só é aberto ali, nunca com texto longo. A sonda P7 confirma no HEAD: o editor rola, o texto guardado aparece inteiro e `maxLines` é nulo. Gap menor
- [x] Linha com `pontoId` inválido é ignorada: `registro/favoritos_repositorio_test.dart:55-69`, `registro/colecoes_repositorio_test.dart:148-162`. Nas reflexões, a consulta filtra por igualdade com um `PontoId` válido, então a linha nunca aparece
- [~] Ponto guardado que não existe nos livros: some das listas e o dado fica. Favoritos: ✅ `registro/favoritos_test.dart:143-145` (1 item na tela, 2 no banco). Coleções: nenhum teste; M47 (a contagem inclui o ponto ausente) sobrevive. A sonda P5 confirma o HEAD
- [x] Favoritar duas vezes deixa um só favorito: `registro/favoritos_repositorio_test.dart:21-26` (M26 morto)
- [x] Marcar uma coleção que já tem o ponto não duplica: `registro/colecoes_repositorio_test.dart:96-106`
- [x] 320 px + texto grande, sem transbordar: `registro/reflexao_na_pagina_test.dart:181-210`, `registro/registro_do_ponto_test.dart:149-174`
- [x] Registro indisponível: só a mensagem, sem ações: `registro/registro_do_ponto_test.dart:123-144` (M46 morto)

**5/7** cobertos por inteiro; **2/7** parciais (no HEAD, as sondas P5 e P7 mostram o comportamento certo).

---

## Gate Check

- **Gate command** (do orquestrador, com `set -o pipefail`): `python3 livros/validar.py && python3 -m unittest discover -s livros -p 'test_*.py'`; `(cd packages/ponto_motor && dart format --output=none --set-exit-if-changed . && dart analyze --fatal-infos && dart test)`; `(cd apps/ponto_mobile && dart format --output=none --set-exit-if-changed lib test && flutter analyze --fatal-infos && flutter test)`. Mais o `flutter build apk --debug` do Build gate do `tasks.md`, numa cópia de rascunho
- **Result**: cada etapa saiu com 0 na árvore real
  - `validar.py`: caminho, forja e sulco ok (só avisos de mock/intervalo, esperados no modo dev). Validador: **6** OK
  - Motor: format 20 arquivos, 0 mudados; analyze "No issues found!"; **51 passed**
  - App: format 63 arquivos, 0 mudados; analyze "No issues found! (ran in 2.7s)"; **164 passed**
  - APK: `✓ Built build/app/outputs/flutter-apk/app-debug.apk`. `aapt2 dump xmltree` mostra `allowBackup=false` e `dataExtractionRules`; `libsqlite3mc.so` presente em arm64-v8a, armeabi-v7a e x86_64
- **Test count before feature**: motor 38 · app 46 · validador 6 (reconfirmado rodando os testes num `git archive main`)
- **Test count after feature**: motor 51 · app 164 · validador 6
- **Delta**: motor +13 · app +118 · validador 0
- **Weakened assertions**: nenhuma. Nenhum teste anterior foi alterado; só os helpers ganharam o parâmetro de registro
- **Skipped tests**: nenhum
- **Failures**: nenhuma. O aviso "multiple databases" do drift em `infra/banco_cifrado_test.dart:57` é benigno: são dois bancos de propósito sobre o mesmo arquivo

---

## Fix Plans

### Fix 1: AC-06: o teste de toque duplo não entrega o 2º toque (M38)

- **Root cause**: em `registro/reflexao_na_pagina_test.dart:83-84`, dois `tester.tap` seguidos chamam o handler uma vez só (instrumentado). O teste passa com ou sem a guarda, e até com o botão sempre habilitado (M38c).
- **Fix task**: trocar os dois `tap` por duas chamadas ao `onPressed` antes de qualquer `pump`: `final b = tester.widget<TextButton>(guardar()); b.onPressed!(); b.onPressed!(); await tester.pumpAndSettle();`. Depois, afirmar 1 linha no banco e a página do ponto visível (sonda P8).
- **Verify**: reaplicar M38 (`editor_de_reflexao_page.dart:171`) → o teste falha.
- **Priority**: Major · ~5 min

### Fix 2: REF-04: editar uma reflexão pode reescrever as outras sem ninguém ver (M22)

- **Root cause**: todo teste de edição tem uma única reflexão no banco.
- **Fix task**: em `registro/reflexoes_repositorio_test.dart`, acrescentar `'REF-04: editing one reflection leaves the others untouched'`. Semear uma 2ª reflexão (no mesmo ponto e em outro), editar a 1ª e afirmar que as outras mantêm `texto` e `editadaEm == null` (sonda P3).
- **Verify**: reaplicar M22 (`reflexoes_repositorio.dart:55`, `WHERE` sem `id`) → falha.
- **Priority**: Major (perda de dado pessoal sensível numa regressão) · ~5 min

### Fix 3: AC-17: desmarcar um ponto pode esvaziar a coleção (M32)

- **Root cause**: as coleções testadas têm um só ponto quando se desmarca.
- **Fix task**: em `registro/colecoes_repositorio_test.dart` (COL-02), guardar Caminho 2 e 81 na mesma coleção, tirar o 2 e afirmar `pontos == [caminho81]` (sonda P4). Vale espelhar no teste de tela COL-02 com um 2º ponto semeado.
- **Verify**: reaplicar M32 (`colecoes_repositorio.dart:68-72`) → falha.
- **Priority**: Major · ~5 min

### Fix 4: AC-16 e a varredura de AC-24: "tudo ou nada" não é provado (M29, M30b)

- **Root cause**: o único caso testado falha na validação do nome, antes de qualquer escrita.
- **Fix task**: em `registro/colecoes_repositorio_test.dart`, criar no banco de teste um trigger `BEFORE INSERT ON pontos_da_colecao BEGIN SELECT RAISE(ABORT, 'falha'); END`. Afirmar que `criar('Família', comPonto: …)` lança e que `colecoes_pessoais` fica vazia (P1). Fazer o mesmo com um trigger em `marcos` para `responderSugestoes([...])` (P2).
- **Verify**: reaplicar M29 e M30b → cada um falha no seu teste.
- **Priority**: Medium · ~10 min

### Fix 5: AC-27: a página do ponto não é conferida depois de excluir a coleção

- **Fix task**: em `registro/colecoes_test.dart` (COL-07 Excluir), depois de excluir, abrir o Caminho 2 a partir de "Família" e afirmar `'Nas coleções: Família'` `findsOneWidget` e `textContaining('Trabalho')` `findsNothing` (sonda P6).
- **Priority**: Minor · ~5 min

### Fix 6: edge case A14 em Coleções (M47)

- **Fix task**: em `registro/colecoes_test.dart`, semear uma coleção com um ponto que não existe na `colecaoDeTeste` (Caminho 3) e mais o Caminho 2. Afirmar "1 ponto" na lista (sonda P5) e um só item na página da coleção.
- **Verify**: reaplicar M47 (`colecoes_page.dart:87`) → falha.
- **Priority**: Minor · ~5 min

### Spec-precision: AC-01, "o banco relata uma cifra ativa"

- **Decision needed (spec)**: `PRAGMA cipher` responde `chacha20` também num arquivo em claro (P9), então a asserção `infra/banco_cifrado_test.dart:66-69` não prova que a cifra está ativa. Sugestão: trocar a frase por "outra chave não lê o arquivo", que já está testado em `infra/banco_cifrado_test.dart:72-85` e mata M49. Depois, apagar ou rebaixar a asserção sobre `PRAGMA cipher` no teste CIFRA-01. ~5 min.

### Riscos sem fix nesta rodada

- M42 (`toLocal`) só é discriminado porque esta máquina está em UTC−3. Quando houver CI, rodar os testes de data com `TZ` fixo e diferente de UTC.
- Edge case 1, editor com texto longo: coberto só pela sonda P7. Pode entrar junto com o Fix 1, no mesmo arquivo.
- AD-004: 24 nomes de teste começam pelo `group`. Renomear os grupos ou pôr o ID no nome do grupo (~5 min).

---

## Requirement Traceability Update

| Requirement | Previous Status | New Status |
| --- | --- | --- |
| CIFRA-01 | Implemented | ✅ Verified (spec-precision gap: "cifra ativa") |
| CIFRA-02 | Implemented | ✅ Verified |
| CIFRA-03 | Implemented | ✅ Verified |
| CIFRA-04 | Implemented | ✅ Verified |
| CIFRA-05 | Implemented | ✅ Verified |
| REF-01 | Implemented | ❌ Needs Fix (Fix 1) |
| REF-02 | Implemented | ✅ Verified |
| REF-03 | Implemented | ✅ Verified |
| REF-04 | Implemented | ❌ Needs Fix (Fix 2) |
| REF-05 | Implemented | ✅ Verified |
| REF-06 | Implemented | ✅ Verified |
| REF-07 | Implemented | ✅ Verified |
| REF-08 | Implemented | ✅ Verified |
| FAV-01 | Implemented | ✅ Verified |
| FAV-02 | Implemented | ✅ Verified |
| COL-01 | Implemented | ❌ Needs Fix (Fix 4) |
| COL-02 | Implemented | ❌ Needs Fix (Fix 3) |
| COL-03 | Implemented | ✅ Verified |
| COL-04 | Implemented | ⚠️ Verified (edge A14 → Fix 6) |
| COL-05 | Implemented | ✅ Verified |
| COL-06 | Implemented | ✅ Verified |
| COL-07 | Implemented | ❌ Needs Fix (Fix 5) |
| PAG-01 | Implemented | ✅ Verified |
| PAG-02 | Implemented | ✅ Verified |
| SUG-01 | Implemented | ✅ Verified |
| SUG-02 | Implemented | ❌ Needs Fix (Fix 4, atomicidade) |
| SUG-03 | Implemented | ✅ Verified |

(O Verifier não edita `spec.md`; o orquestrador aplica esta tabela.)

---

## Summary

**Overall**: ❌ Not Ready (só nos testes). O produto se comporta como o spec pede: 9/9 sondas passam no HEAD, o gate passa e o APK gera. Seis comportamentos protegidos pelo spec ficaram sem teste capaz de pegar uma regressão.

**Spec-anchored check**: 23/27 ACs com o resultado do spec afirmado por inteiro; 4 parciais (AC-06, AC-16, AC-17, AC-27); 1 spec-precision gap (AC-01)
**Sensor**: 43/49 mortos; 6 sobreviventes (M22, M29, M30b, M32, M38, M47); 0 travados
**Gate**: exit 0. Motor 51, app 164, validador 6 passed, 0 failed; análise sem issues; format limpo; APK debug gerado com sqlite3mc e backup desligado

**What works**:
- Cifra desde o primeiro byte e recusa de SQLite sem cifra.
- Chave gravada antes do arquivo, nunca gerada com banco existente.
- Falha de chave ou cofre: arquivo intocado, `null`, log só com o tipo.
- Backup e transferência desligados, conferidos também no APK.
- Regras de texto e de nome no motor.
- Ordem de reflexões, favoritos, coleções e pontos.
- Cascata só nos vínculos.
- Sugestões respondidas por criar, "Agora não" ou voltar.
- PopScope de descarte.
- Falha de gravação mantém o texto, com dois tipos de erro (L-001 aplicada).
- Página do ponto acompanha as mudanças e troca de registro no "Próximo".

**Issues found**: Fix 1–6 e o spec-precision gap do AC-01, acima. Juntos, ~45 min, só em testes.

**Next steps**:
1. Rodada 1: Fix 1–4 (Major/Medium), depois Fix 5–6 e a revisão do AC-01. Re-verificação com M22, M29, M30b, M32, M38 e M47 reaplicados.
2. UAT das suposições "não — UAT" e abertura no aparelho (TD-004).

---

## Lessons recorded (`lessons.py`, project-local)

- **L-003 → confirmed** (ac_gap, AC-27: a página do Caminho 2 não é conferida). Mesmo padrão da v0.2 (AC-10); recorrência 2 (ler, guardar).
- **L-005** (surviving_mutant M38): provar a guarda de toque duplo chamando o callback duas vezes antes da reconstrução.
- **L-006** (surviving_mutant M22, M32): numa escrita que mira uma linha, semear uma linha vizinha e afirmar que ela fica intacta.
- **L-007** (surviving_mutant M29, M30b): provar "tudo ou nada" fazendo uma instrução posterior falhar (trigger que aborta) e afirmar que nada persistiu.
- **L-008** (surviving_mutant M47): edge case que vale para toda tela que mostra dado guardado → testar em cada tela.
- **L-009** (spec_precision_gap AC-01): definir "cifra ativa" por algo que difere entre arquivo cifrado e em claro, não por um pragma que responde nos dois casos.
- L-001 não foi contrariada: a falha de gravação e a de abertura foram testadas com dois tipos de erro, e M09 e M39 morreram. L-002 e L-004 não se aplicam.

---

## Round 1 — Re-verification (fix diff)

**Date**: 2026-10-03
**Diff**: `19bf448..a37523f`: 9f1e8d8 (F1), 76b04a6 (F2), f1a4a07 (F3), 37e88b8 (F4), 85a6617 (F5), f70e52d (F6), 388969e (F7), a37523f (F8). Só mudaram testes e o `spec.md` (AC-01 `[revised r1]` + linha "Revisões"). `git diff 2e9b930..a37523f -- apps/ponto_mobile/lib packages apps/ponto_mobile/android apps/ponto_mobile/pubspec.yaml` → 0 linhas: nenhum código de produto mudou desde a rodada 0. Por isso as mortes de produto da rodada 0 continuam valendo, exceto onde o teste que matava foi alterado; esses casos (M01, M49) foram reaplicados.

### Gaps da rodada 0

| Gap | Commit | `file:line` + asserção | Mutante | Result |
| --- | --- | --- | --- | --- |
| 1 · AC-06 / REF-01: o 2º toque não era entregue | 9f1e8d8 | `apps/ponto_mobile/test/registro/reflexao_na_pagina_test.dart:86-87`: `tocarGuardar(); tocarGuardar();` (o `onPressed` capturado, chamado duas vezes antes da reconstrução). `:90`: `textosGuardados == ['Quero ser útil hoje.']`. `:91`: a página do Caminho 2 aparece | M38 (sem a guarda) morto. M38c (sem a guarda e com o botão sempre habilitado) morto | ✅ Closed |
| 2 · AC-09 / REF-04: a edição podia reescrever as outras | 76b04a6 | `registro/reflexoes_repositorio_test.dart:77-88`: edita a do Caminho 2. `:86`: a do 81 fica com `'Do oitenta e um.'`. `:87`: `editadaEm, isNull` | M22 (`WHERE` sem `id`) morto | ✅ Closed |
| 3 · AC-17 / COL-02: desmarcar podia esvaziar a coleção | f1a4a07 | `registro/colecoes_repositorio_test.dart:116-124`: Família com Caminho 2 e 81; tirar o 2. `:123`: `pontos == [caminho81]` | M32 (`tirar` sem o filtro de ponto) morto | ✅ Closed |
| 4 · AC-16 + varredura do AC-24: "tudo ou nada" | 37e88b8 | `registro/colecoes_repositorio_test.dart:35-38`: trigger `RAISE(ABORT)` por tabela. `:71-83`: falha no vínculo; `criar(…, comPonto:)` → `throwsA(isA<SqliteException>())` e `atuais(), isEmpty`. `:260-273`: falha em `marcos`; `responderSugestoes([...])` lança, `atuais(), isEmpty` e `sugestoesRespondidas(), isFalse` | M29 morto (sem transação). M29b morto (transação mantida, falha do vínculo engolida: coleção sem o ponto). M30b morto (sem transação, minha forma). M30c morto (`transaction` trocado por um helper que só roda o corpo, a forma do implementador) | ✅ Closed |
| 5 · AC-27: a página do ponto não era conferida | 85a6617 | `registro/colecoes_test.dart:357-363`: depois de excluir "Trabalho", abre Família → Caminho 2. `:362`: `'Nas coleções: Família'` `findsOneWidget`. `:363`: `textContaining('Trabalho')` `findsNothing` | Controle de isolamento (só no rascunho): tirei as asserções anteriores do teste e transformei `excluir` em no-op. A asserção nova **falha sozinha** ("Found 0 widgets with text 'Nas coleções: Família'"). O mesmo teste isolado passa no HEAD | ✅ Closed |
| 6 · edge case A14 em Coleções | f70e52d | `registro/colecoes_test.dart:117-137`: coleção com Caminho 3 (ausente) + Caminho 2 → "1 ponto" no item. `:196-215`: a página da coleção mostra 1 `ListTile`, a referência do 2, e o banco guarda os 2 (`:214` `hasLength(2)`) | M47 (contagem inclui o ausente) morto | ✅ Closed |
| 7 · AC-01: spec-precision gap ("cifra ativa") | 388969e | spec AC-01 `[revised r1]`: Expected = bytes sem o texto e sem `SQLite format 3` + "aberto com outra chave, o arquivo não pode ser lido". `apps/ponto_mobile/test/infra/banco_cifrado_test.dart:61-62` (bytes) e `:65-79` (outra chave → `throwsA(anything)`). Saiu a asserção vazia sobre `PRAGMA cipher` | M49 (sem `PRAGMA key`) continua morto por 4 testes (CIFRA-01 ×3, CIFRA-04 wrong key). M01 continua morto (CIFRA-02 ×2) | ✅ Closed, com uma nota: a sonda **P10** mostra que um arquivo **em claro**, aberto com uma chave, também não é lido (`DriftRemoteException`). Então "outra chave não lê", sozinho, não distingue cifrado de claro; quem prova a cifra são as asserções sobre os bytes (`:61-62`), que M49 mata. O AC está provado por inteiro. Só a linha "Revisões" do spec ("Agora o observável é 'outra chave não lê o arquivo'") aponta para a parte que não discrimina. Sugestão (~2 min): citar a ausência do cabeçalho e do texto como o observável da cifra |
| nota · edge case 1: reflexão longa no editor | a37523f | `registro/reflexao_na_pagina_test.dart:216-255`: 320 px a 2,6×, texto longo. `:243`: `maxScrollExtent > 0` no editor. `:252-253`: o texto guardado aparece na página com `maxLines` nulo e sem reticências | M50 (a reflexão na página cortada em 3 linhas com reticências) morto | ✅ Closed |

**ACs depois da rodada 1**: 27/27 com o resultado do spec afirmado por inteiro. 0 spec-precision gaps abertos. Edge cases: 7/7.

### Discrimination Sensor (rodada 1)

Cópia de rascunho recriada a partir da árvore real em `a37523f` (`cp -a`, sem `build/`). Mesmo harness da rodada 0: uma mutação por vez, substituição exata, arquivos de teste focados com `timeout`, suíte inteira para qualquer sobrevivente, e restauração conferida depois de cada mutação.

| # | File:line | Description | Killed? |
| --- | --- | --- | --- |
| M38 | `apps/ponto_mobile/lib/registro/editor_de_reflexao_page.dart:171` | sem a guarda de toque duplo | ✅ REF-01 double tap |
| M38c | `editor_de_reflexao_page.dart:62` + `:171` | sem a guarda e com o botão sempre habilitado | ✅ REF-01 double tap |
| M22 | `apps/ponto_mobile/lib/registro/reflexoes_repositorio.dart:55` | `WHERE` da edição sem `id` | ✅ REF-04 others untouched |
| M32 | `apps/ponto_mobile/lib/registro/colecoes_repositorio.dart:68-72` | `tirar` sem o filtro de ponto | ✅ COL-02 keeps the other points |
| M29 | `colecoes_repositorio.dart:32-37` | `criar` sem transação | ✅ COL-01 failure leaves no collection |
| M29b | `colecoes_repositorio.dart:35` | transação mantida, falha do vínculo engolida | ✅ COL-01 failure leaves no collection |
| M30b | `colecoes_repositorio.dart:85-99` | `responderSugestoes` sem transação (closure chamada) | ✅ SUG-02 failure creates nothing |
| M30c | `colecoes_repositorio.dart:86` | `transaction` → helper que só roda o corpo | ✅ SUG-02 failure creates nothing |
| M47 | `apps/ponto_mobile/lib/registro/colecoes_page.dart:87` | contagem inclui pontos ausentes dos livros | ✅ COL-04 counts only present points |
| M50 | `apps/ponto_mobile/lib/registro/registro_do_ponto.dart:192` | reflexão na página com `maxLines: 3` + reticências | ✅ REF-01 long reflection |
| M01 | `apps/ponto_mobile/lib/infra/banco_cifrado.dart:28` | guarda da cifra desligada (regressão depois do F7) | ✅ CIFRA-02 ×2 |
| M49 | `banco_cifrado.dart:15` | sem `setup` (sem `PRAGMA key`) (regressão depois do F7) | ✅ CIFRA-01 ×3, CIFRA-04 wrong key |

**Result**: 12/12 killed ✅, 0 hung. Somando as duas rodadas: as 43 mortes da rodada 0 continuam valendo, porque o produto não mudou e nenhum teste que matava foi enfraquecido. As duas checagens afetadas pelo F7 (M01, M49) foram reaplicadas e continuam mortas. Os 6 sobreviventes da rodada 0 morreram agora. Nenhum sobrevivente aberto.

### Probes (rodada 1)

| # | Sonda | Resultado |
| --- | --- | --- |
| P10 | arquivo criado **sem** chave (em claro), aberto com `abrirBancoCifrado(arquivo, 'b2' * 32)` e lido | lança `DriftRemoteException`: "outra chave não lê" vale também para um arquivo em claro (nota do gap 7) |
| F5-iso | teste COL-07 sem as asserções anteriores + `excluir` no-op / o mesmo teste isolado no HEAD | falha em `'Nas coleções: Família'` / passa |

### Gate Check (rodada 1)

- **Gate command**: o mesmo da rodada 0 (com `set -o pipefail`), rodado na árvore real em `a37523f`
- **Result**: cada etapa saiu com 0
  - `validar.py`: ok nas 3 obras. Validador: **6** OK
  - Motor: format 20 arquivos, 0 mudados; analyze "No issues found!"; **51** passed
  - App: format 63 arquivos, 0 mudados; analyze "No issues found! (ran in 2.8s)"; **171** passed
- **Delta vs rodada 0**: app +7. Novos: F2 +1, F3 +1, F4 +2, F6 +2, F8 +1. Estendidos: F1 e F5. F7 removeu uma asserção sem poder de discriminação
- **Delta vs antes da feature**: motor 38 → 51 (+13) · app 46 → 171 (+125) · validador 6 → 6
- **Weakened assertions**: só a asserção sobre `PRAGMA cipher` saiu (F7). Ela não discriminava nada (sonda P9 da rodada 0). M49, que ela supostamente guardava, continua morto por 4 testes
- **Failures / skips**: nenhum. Árvore real: `git status --porcelain` igual antes e depois; HEAD continua `a37523f`

### Rulings do implementador

- **(a) 24 nomes de teste que começam pelo `group`**: concordo que não bloqueia. O motivo do AD-004 (rastreio por busca textual) continua atendido; só a letra ("começa com o ID") não é seguida. Para a regra não ficar ambígua, sugiro registrar a interpretação no próprio AD-004 do `.specs/STATE.md` ("o ID aparece no nome completo, inclusive pelo `group`"). ~2 min, fora desta feature.
- **(b) fixar `TZ` para o M42 no item de CI**: concordo que é escopo do CI. Ressalva: isso **ainda não está registrado** em lugar nenhum além deste relatório (`grep` por TZ/fuso em `docs/backlog.md`, `docs/roadmap.md`, `.specs/TECH-DEBT.md` e `.specs/STATE.md` → vazio). Uma linha no item de CI de `docs/backlog.md` (ou em `TECH-DEBT.md`) evita que o fato se perca. ~2 min.

### Lessons (rodada 1)

Nenhuma lição nova: a rodada saiu sem sinal (nenhum sobrevivente, nenhum AC aberto, nenhum spec-precision gap). Uma correção para o mantenedor: o exemplo "or a wrong key failing" no texto da **L-009** (candidate) está errado pela sonda P10, porque uma chave errada também falha num arquivo em claro. O `lessons.py` não tem comando de edição, e o texto não deve ser editado à mão. Recomendo que o mantenedor troque o exemplo por "such as a missing file header".

### Requirement Traceability Update (rodada 1)

| Requirement | Rodada 0 | Rodada 1 |
| --- | --- | --- |
| CIFRA-01 | ✅ Verified (spec-precision gap) | ✅ Verified (AC revisado r1) |
| CIFRA-02 … CIFRA-05 | ✅ Verified | ✅ Verified |
| REF-01 | ❌ Needs Fix | ✅ Verified |
| REF-02, REF-03 | ✅ Verified | ✅ Verified |
| REF-04 | ❌ Needs Fix | ✅ Verified |
| REF-05 … REF-08 | ✅ Verified | ✅ Verified |
| FAV-01, FAV-02 | ✅ Verified | ✅ Verified |
| COL-01 | ❌ Needs Fix | ✅ Verified |
| COL-02 | ❌ Needs Fix | ✅ Verified |
| COL-03 | ✅ Verified | ✅ Verified |
| COL-04 | ⚠️ Verified (edge A14) | ✅ Verified |
| COL-05, COL-06 | ✅ Verified | ✅ Verified |
| COL-07 | ❌ Needs Fix | ✅ Verified |
| PAG-01, PAG-02 | ✅ Verified | ✅ Verified |
| SUG-01, SUG-03 | ✅ Verified | ✅ Verified |
| SUG-02 | ❌ Needs Fix | ✅ Verified |

(O Verifier não edita `spec.md`; o orquestrador aplica esta tabela: todos os 27 ✅ Verified.)

### Summary (rodada 1)

**Overall**: ✅ Ready (verificação automatizada). Faltam o UAT interativo e a abertura num aparelho real (TD-004).

**Spec-anchored check**: 27/27 ACs com o resultado do spec afirmado; 0 spec-precision gaps abertos; edge cases 7/7
**Sensor**: rodada 1 com 12/12 mortos. Somando: 49 mutações válidas da rodada 0 + 4 checagens novas (M38c, M29b, M30c, M50), nenhum sobrevivente aberto
**Gate**: exit 0. Motor 51 · app 171 · validador 6 passed, 0 failed; análise sem issues; format limpo

**Não bloqueiam**:
1. Linha "Revisões" do AC-01: apontar a ausência do cabeçalho e do texto como o observável da cifra (P10).
2. Registrar o `TZ` fixo no item de CI.
3. Registrar a interpretação do AD-004.
4. Corrigir o exemplo da L-009.
