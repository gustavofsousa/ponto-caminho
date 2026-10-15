# livros/

Dados de conteúdo da coleção `caminho-sulco-forja`.

```
colecao.json     a coleção e as obras que a compõem
caminho.json     metadados + índice dos 46 capítulos + pontos mock
sulco.json       metadados + índice provisório (mock) + pontos mock
forja.json       metadados + índice provisório (mock) + pontos mock
_schema.json     contrato que todo arquivo de obra deve satisfazer
validar.py       validação das invariantes — sem dependências
```

```bash
python3 livros/validar.py            # desenvolvimento: mock vira aviso
python3 livros/validar.py --estrito  # publicação: mock vira erro
```

## Dado mock — para desenvolver antes do texto real

Todo ponto ou capítulo com `"nota": "mock"` é **inventado**, não é texto de São Josemaría. Existe
só para o app ter o que mostrar: a numeração e o capítulo são plausíveis, o texto não.

- *Caminho*: índice real, 10 pontos mock (caps. 1, 3 e 11).
- *Sulco* e *Forja*: índice **provisório** (capítulos de tamanho igual) e 5 pontos mock cada.

Para trocar pelo real: substitua `texto` (e o capítulo, em *Sulco*/*Forja*), apague a `nota`,
incremente `versaoDados` e rode o validador. `--estrito` falha enquanto restar qualquer mock —
é o portão de qualquer build de publicação.

Antes de ingerir texto real, registre em `obra.edicao` a edição concreta usada (editora, ano,
tradutor, ISBN).

## Estado dos dados

| Obra    | Pontos | Capítulos          | Índice                 | Texto       |
| ------- | ------ | ------------------ | ---------------------- | ----------- |
| Caminho | 999    | 46                 | 39/46 conferidos       | 10 mock     |
| Sulco   | 1000   | a confirmar        | provisório (mock)      | 5 mock      |
| Forja   | 1055   | 13 _(a confirmar)_ | provisório (mock)      | 5 mock      |

| Capítulos | Questão                                                                                           |
| --------- | ------------------------------------------------------------------------------------------------- |
| 1–2       | Corte entre _Caráter_ e _Direção_ dentro de 1–80                                                  |
| 9–10      | Corte entre _Propósitos_ e _Escrúpulos_ dentro de 247–264                                         |
| 31        | _Alegria_ termina em 656 ou 666? 666 é o valor consistente com _Outras virtudes_ começando em 667 |

## Como preencher um índice

Para cada capítulo da obra, na ordem:

```json
{
  "numero": 1,
  "slug": "carater",
  "titulo": "Caráter",
  "tituloOriginal": "Carácter",
  "pontoInicial": 1,
  "pontoFinal": 55,
  "validado": true
}
```

Marque `"validado": true` **só** depois de conferir título, ordem e intervalo contra a edição
impressa. Depois rode `validar.py`. Ele checa três coisas:

- A numeração vai de 1 a N sem buracos.
- Os intervalos são contíguos.
- O último ponto do índice bate com `obra.totalPontos`.

Ao mudar qualquer dado de conteúdo, **incremente `versaoDados`**. Uma coleção é imutável dentro de
uma versão — é isso que mantém estáveis as referências já guardadas pelos usuários em anotações e
coleções pessoais. Ver [`docs/modelo.md`](../docs/modelo.md) §1.

## Identificadores

Um ponto é endereçado assim, e é essa string que aparece em deep links e exportações:

```
ponto:<colecao>/<obra>/<numero>
ponto:caminho-sulco-forja/caminho/1
```

Na interface, nunca se mostra o identificador cru — mostra-se a **referência**:

> **Caminho**, capítulo _Caráter_, ponto **1**
