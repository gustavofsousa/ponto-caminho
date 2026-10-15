# ponto_motor

O motor de pontos do Ponto. É Dart puro: sem Flutter e sem I/O. Ele não conhece nenhuma obra em
particular. Ele recebe uma `Colecao` e responde sobre ela.

## O que o motor faz

| Pasta (`lib/src/`) | Domínio | Responde |
| --- | --- | --- |
| `colecao/` | `colecao` | carregar e ler uma coleção (obra, capítulo, ponto) e o id de um ponto |
| `selecao/` | `selecao` | qual ponto mostrar: por id, aleatório, anterior e próximo na sequência |
| `leitura/` | `leitura` | o que foi lido e por onde continuar |
| `registro/` | `registro` | reflexão e coleção pessoal |

O ponto de entrada é `lib/ponto_motor.dart`. Os domínios e as fronteiras estão em
[`docs/dominios.md`](../../docs/dominios.md). O vocabulário está em [`docs/modelo.md`](../../docs/modelo.md).

## Regras

- O motor nunca importa Flutter nem faz I/O. O app (`apps/ponto_mobile`) orquestra as telas e faz o
  I/O.
- Os nomes do domínio ficam em português sem acento (`ponto`, `obra`, `capitulo`, `colecao`). Nunca
  traduza.

## Testes

```sh
cd packages/ponto_motor
dart pub get
dart test
```

`test/livros_contract_test.dart` checa o contrato dos dados reais em `livros/`.
