# ADR-002 — Registro cifrado no aparelho, chave no Keystore/Keychain

- **Data:** 2026-10-02
- **Status:** Accepted — tomada pelo agente no fluxo delegado da v0.3; revisar no UAT
- **Origem:** backlog › `infra` ("onde guardar a chave do banco — decidir na v0.3"), spec
  `.specs/features/guardar/` (A2, A3, A4)

## Contexto

A v0.3 começa a guardar reflexões, favoritos e coleções pessoais. Reflexões são dado pessoal
religioso (`modelo.md` §7): precisam estar cifradas em repouso desde o primeiro byte, e o ADR-001
já escolheu drift + SQLite3MultipleCiphers justamente porque cifrar um banco em claro depois exige
migração. Faltava decidir **onde mora a chave** e o que acontece quando ela some. Não há conta nem
servidor na v1.0: tudo fica no aparelho.

## Fatores de decisão

1. Nenhum byte do registro em claro no disco — nem em backup.
2. Nada do que o leitor escreveu pode ser apagado ou sobrescrito por um erro de chave.
3. Nenhuma senha para o leitor lembrar: a v1.0 é para um leitor real, sem fricção.
4. Funcionar no Android hoje e no iOS depois, sem código próprio por plataforma.

## Opções consideradas

- **A. Chave aleatória no armazenamento seguro do sistema** (Keystore no Android, Keychain no iOS,
  via `flutter_secure_storage`). ← escolhida
- **B. Chave derivada de uma senha do leitor.** Descartada: senha esquecida = registro perdido, e
  fricção a cada abertura para um app de leitura serena.
- **C. Chave guardada junto do app (arquivo, preferências).** Descartada: quem copia o arquivo do
  banco copia a chave junto — cifra de fachada.

## Decisão

**A.** No primeiro uso, o app gera 32 bytes com `Random.secure()`, **grava a chave no cofre antes
de criar o arquivo** e abre o banco com `PRAGMA key`. A abertura confere `PRAGMA cipher`: sem cifra,
o registro não abre (nunca cai para um banco em claro).

Regras que acompanham a decisão:

- **Nunca gerar chave com banco existente.** Cofre vazio (ou que falha) + arquivo presente = registro
  indisponível; o arquivo fica intocado e a leitura do app segue normal. O `flutter_secure_storage`
  apaga uma chave que não consegue decifrar (`resetOnError`), então essa guarda é o que impede uma
  chave nova de sobrescrever o banco antigo.
- **Backup do Android desligado** (`allowBackup="false"` + regras de extração excluindo nuvem e
  transferência entre aparelhos). A chave do Keystore não migra; um banco restaurado sem ela seria
  ilegível.
- **Log sem conteúdo.** Falhas do registro vão ao log só com o tipo do erro (AD-009).

## Consequências

- ✅ O arquivo do registro é ilegível fora do app, inclusive para quem o copia com acesso ao disco.
- ✅ Zero fricção: o leitor nunca vê chave nem senha.
- ⚠️ Trocar ou perder o aparelho perde o registro. Aceito até a v2.0 (conta opcional + exportação),
  que é quando esta decisão deve ser revista.
- ⚠️ Um cofre corrompido pelo sistema torna o registro ilegível para sempre — o app avisa e não
  apaga nada; não há recuperação.
- ⚠️ iOS (Keychain, backup do iCloud) não foi configurado nem testado: sem Mac nesta máquina (TD-005).
