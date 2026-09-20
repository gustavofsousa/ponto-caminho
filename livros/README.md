# livros/

Dados de conteúdo da coleção `caminho-sulco-forja`.

```
colecao.json     a coleção e as obras que a compõem
caminho.json     metadados + índice dos 46 capítulos
sulco.json       metadados (índice pendente)
forja.json       metadados (índice pendente)
_schema.json     contrato que todo arquivo de obra deve satisfazer
validar.py       validação das invariantes — sem dependências
```

```bash
python3 livros/validar.py
```

---

## ⚠️ Direitos autorais — leia antes de popular qualquer texto

**Nenhum arquivo aqui contém o texto dos pontos, e isso é intencional.**

*Caminho*, *Sulco* e *Forja* são obras protegidas por direito autoral. São Josemaría Escrivá
faleceu em 1975; as obras **não estão em domínio público** e não estarão tão cedo em nenhuma
jurisdição relevante. Distribuir o texto integral sem licença formal inviabiliza o produto.

Por isso os três arquivos estão com:

```json
"status": "estrutura",
"direitos": { "dominioPublico": false, "licenciado": false },
"pontos": []
```

O `validar.py` trata isso como **erro**, não como aviso: se alguém popular `pontos` enquanto
`direitos.licenciado` for `false`, a validação falha. O portão é automático justamente para não
depender de memória.

**O que precisa acontecer antes de ingerir texto** — ver Fase 0 do [`Roadmap.md`](../Roadmap.md):

1. Obter licença formal do titular dos direitos para a edição em português.
2. Registrar em `direitos`: `titular`, `licenca`, `escopo`, `validoAte`, `atribuicaoExigida`.
3. Definir `limiteCitacao` — quantos pontos podem ser compartilhados integralmente fora do app.
   `null` significa que só a **referência** pode ser compartilhada.
4. Registrar em `obra.edicao` a edição concreta usada (editora, ano, tradutor, ISBN).
5. Só então rodar a ingestão e mudar `status` para `parcial` ou `completo`.

> **Para desenvolver enquanto a licença não sai:** crie uma coleção de desenvolvimento com textos
> próprios ou em domínio público, no mesmo schema. O motor de pontos não distingue uma coleção da
> outra — é exatamente para isso que ele é desacoplado do conteúdo.

---

## Estado dos dados

| Obra | Pontos | Capítulos | Índice | Texto |
| --- | --- | --- | --- | --- |
| Caminho | 999 | 46 | 39/46 conferidos | — |
| Sulco | 1000 | a confirmar | pendente | — |
| Forja | 1055 | 13 *(a confirmar)* | pendente | — |

### Pendências abertas

O índice de *Caminho* foi reconstituído a partir de fontes públicas cruzadas entre si
(escriva.org e a edição crítico-histórica de Pedro Rodríguez via leercamino.org). As páginas
de índice desses sites estão bloqueadas pelo proxy de egresso do ambiente onde este documento
foi produzido, então a reconstituição foi feita por busca. **Tudo abaixo se resolve em poucos
minutos com o livro impresso na mão.**

**Caminho — capítulos 17 e 18 (pontos 387–416).** Única lacuna real. O intervalo corresponde a
dois capítulos, e não foi possível confirmar os títulos nem o ponto de corte entre eles. Um deles
é o capítulo conhecido em espanhol como *El plano de tu santidad*. A existência de dois capítulos
aí é dedução — é o que faz a numeração fechar em 46 e alinhar com as âncoras confirmadas
(cap. 27 = Humildade, cap. 31 = Alegria, cap. 32 = Outras virtudes, cap. 34 = Luta interior,
cap. 35 = Postrimerias, cap. 36 = A vontade de Deus, cap. 44 = O apóstolo).

**Caminho — intervalos a conferir**, marcados com `"validado": false`:

| Capítulos | Questão |
| --- | --- |
| 1–2 | Corte entre *Caráter* e *Direção* dentro de 1–80 |
| 9–10 | Corte entre *Propósitos* e *Escrúpulos* dentro de 247–264 |
| 31 | *Alegria* termina em 656 ou 666? 666 é o valor consistente com *Outras virtudes* começando em 667 |

**Sulco e Forja — índices completos.** Nenhum dos dois tem índice de capítulos ainda. Para *Forja*,
o número de 13 capítulos vem de fonte secundária e precisa ser conferido. Para *Sulco*, só se
confirmou a existência de um capítulo *Sinceridade*.

**Títulos em português.** Os títulos foram traduzidos a partir do espanhol e precisam ser
substituídos pelos títulos exatos da edição brasileira que for licenciada. O campo
`tituloOriginal` guarda o espanhol e serve de âncora para essa conferência.

---

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

Marque `"validado": true` **apenas** depois de conferir título, ordem e intervalo contra a edição
impressa. Rode `validar.py` em seguida: ele checa que a numeração vai de 1 a N sem buracos, que os
intervalos são contíguos e que o último ponto do índice bate com `obra.totalPontos`.

Ao mudar qualquer dado de conteúdo, **incremente `versaoDados`**. Uma coleção é imutável dentro de
uma versão — é isso que mantém estáveis as referências já guardadas pelos usuários em anotações e
coleções pessoais. Ver [`domínio.md`](../domínio.md) §1.

## Identificadores

Um ponto é endereçado assim, e é essa string que aparece em deep links e exportações:

```
ponto:<colecao>/<obra>/<numero>
ponto:caminho-sulco-forja/caminho/1
```

Na interface, nunca se mostra o identificador cru — mostra-se a **referência**:

> **Caminho**, capítulo *Caráter*, ponto **1**
