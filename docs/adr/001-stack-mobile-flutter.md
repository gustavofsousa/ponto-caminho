# ADR-001 — Stack mobile: Flutter + Dart, motor como pacote Dart puro

- **Data:** 2026-10-02
- **Status:** Accepted
- **Origem:** RFD "stack mobile + armazenamento local", conversa de 2026-10-02

## Contexto

A v0.1 precisa de um app rodando no celular, com o motor de pontos separado da UI. As reflexões
são dado pessoal religioso e precisam ser cifradas em repouso desde a v0.3. Nem expo-sqlite
(SQLCipher) nem drift (SQLite3MultipleCiphers) cifram um banco já existente em claro sem migração
explícita — então o banco cifrável entra junto com a stack. O desenvolvimento é feito em Linux,
sem Mac.

## Fatores de decisão

1. Qualidade da leitura, ou seja, controle de tipografia: a decisão de maior impacto no produto.
2. Banco local cifrável já na primeira versão.
3. Formato que já conhecemos: `02_pathling-game` usa core em Dart puro + app Flutter, e há o plugin `dart`.
4. Build de iOS sem Mac.

## Opções consideradas

- **A. Expo + TypeScript + expo-sqlite/SQLCipher.** Mesma linguagem da stack web; EAS compila iOS
  na nuvem. O argumento principal era reaproveitar o motor em TS numa web/API da v3.0.
- **B. Flutter + Dart + drift/SQLite3MultipleCiphers.** ← escolhida
- **C. PWA.** Descartada: no iOS o Safari pode apagar o armazenamento, não há cifra real e não há widget.

## Decisão

**B.** Flutter desenha a própria UI, então o mesmo layout e a mesma tipografia valem no Android e
no iOS: 95% do desenvolvimento acontece no Android/Linux. O iOS compila na nuvem por Codemagic ou
GitHub Actions com runner macOS, configurado uma vez.

O motivo de reaproveitar o motor na v3.0 foi rejeitado por **YAGNI**: trocar a melhor ferramenta
para o produto que existe agora (v0.x/v1.0) por uma superfície hipotética é otimização prematura.
Se a v3.0 chegar, portar a lógica pura de Dart para TS custa dias. A regra virou princípio em
`_hq/AGENTS.md` ("Plan for the future, don't be a futurologist").

## Consequências

- ✅ Um único formato de monorepo no workspace (`packages/ponto_motor` + `apps/ponto_mobile`, igual ao pathling).
- ✅ Motor em Dart puro, testável com `dart test`, sem Flutter.
- ✅ Banco cifrável disponível (drift + `sqlite3mc`) quando `registro` chegar (v0.3).
- ⚠️ Pipeline de iOS (Codemagic/macOS runner) é trabalho próprio, antes do primeiro TestFlight.
- ⚠️ Uma web futura não reaproveita o motor sem portar o código. Aceito.
- ⚠️ A tipografia precisa de fontes empacotadas no app, com licença de embutir.
