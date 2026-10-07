# Domínio

Modelo conceitual do **Ponto**. Este documento define a linguagem do projeto: os termos usados aqui
são os mesmos usados no código, no banco, na API e na interface. Quando um termo muda aqui, muda em
todo lugar.

A separação central é entre três camadas:

```
┌─────────────────────────────────────────────────────────┐
│  EXPERIÊNCIA        app mobile · web · desktop · widget │
│                     leitura, navegação, escrita          │
├─────────────────────────────────────────────────────────┤
│  MOTOR DE PONTOS    seleção, sequência, histórico        │
│                     favoritos, listas, anotações         │
├─────────────────────────────────────────────────────────┤
│  CONTEÚDO           coleções de textos curtos            │
│                     Caminho · Sulco · Forja · outras     │
└─────────────────────────────────────────────────────────┘
```

O motor não sabe que existe São Josemaría. Ele sabe que existe uma **Coleção** de **Pontos**
organizados em **Obras** e **Capítulos**. É isso que permite substituir o conteúdo sem reescrever
o produto.

---

## 1. Conteúdo

### Coleção

Um corpus fechado e versionado de textos curtos. É a unidade que se pode trocar.

A coleção inicial é `caminho-sulco-forja`, que agrupa as três obras. Uma coleção futura poderia ser
`regra-de-sao-bento`, `pensamentos-pascal` ou uma compilação própria de um grupo de formação.

| Campo | Tipo | Notas |
| --- | --- | --- |
| `id` | slug | `caminho-sulco-forja` |
| `titulo` | texto | Nome de exibição |
| `idioma` | BCP-47 | `pt-BR` |
| `versaoDados` | semver | Muda quando o texto ou a estruturação mudam |
| `obras` | Obra[] | |
| `direitos` | Direitos | Ver §7 |

> Uma coleção é **imutável dentro de uma versão**. Corrigir um ponto significa publicar uma nova
> `versaoDados`. Isso protege as referências guardadas pelo usuário: uma anotação feita sobre
> *Caminho* 1 continua apontando para o mesmo texto que ele leu.

### Obra

Um dos livros. *Caminho*, *Sulco*, *Forja*.

| Campo | Tipo | Notas |
| --- | --- | --- |
| `id` | slug | `caminho`, `sulco`, `forja` |
| `titulo` | texto | Título na edição em uso |
| `tituloOriginal` | texto | `Camino`, `Surco`, `Forja` |
| `autor` | Autor | |
| `edicao` | Edicao | Editora, ano, tradutor, ISBN |
| `totalPontos` | inteiro | 999 · 1000 · 1055 |
| `capitulos` | Capitulo[] | |

### Capítulo

Agrupamento temático dentro de uma obra, tal como o autor o organizou. **Não é uma invenção do
produto** — é estrutura editorial real, e por isso é a espinha da navegação e do progresso.

| Campo | Tipo | Notas |
| --- | --- | --- |
| `numero` | inteiro | Ordinal dentro da obra |
| `slug` | slug | `carater`, `oracao` |
| `titulo` | texto | `Caráter` |
| `pontoInicial` / `pontoFinal` | inteiro | Intervalo de numeração |

### Ponto

**A unidade atômica do produto.** Tudo — leitura, favorito, anotação, lista, busca, notificação —
se ancora num ponto.

| Campo | Tipo | Notas |
| --- | --- | --- |
| `id` | PontoId | Ver abaixo |
| `obraId` | slug | |
| `capituloNumero` | inteiro | |
| `numero` | inteiro | Numeração do autor, única dentro da obra |
| `ordem` | inteiro | Posição absoluta na obra, para sequência |
| `texto` | texto | Conteúdo integral |
| `temas` | Tema[] | Ver §2 |
| `referenciasBiblicas` | texto[] | Quando houver |

#### PontoId

Identificador estável e legível, usado em URLs, deep links e exportações:

```
ponto:<colecao>/<obra>/<numero>

ponto:caminho-sulco-forja/caminho/1
ponto:caminho-sulco-forja/forja/1055
```

É legível por humanos, estável entre versões de dados e não vaza detalhe de implementação.
Uma anotação exportada em Markdown continua fazendo sentido daqui a dez anos.

#### Referência

A forma de **exibir** um ponto ao usuário — sempre completa, sempre no mesmo formato:

> **Caminho**, capítulo *Caráter*, ponto **1**

É o que aparece no topo da página do ponto, no compartilhamento e em qualquer exportação.
Nunca se mostra o `PontoId` cru na interface.

---

## 2. Tema

Eixo transversal que atravessa as três obras. Um mesmo tema — *fortaleza*, *plano de vida*,
*conhecimento próprio*, *dificuldades* — aparece em pontos de *Caminho*, *Sulco* e *Forja*.

O tema é o que permite a pergunta que motiva boa parte do uso:

> *"Lembro de um ponto que fala sobre isso, mas não lembro as palavras exatas."*

| Campo | Tipo |
| --- | --- |
| `id` | slug |
| `titulo` | texto |
| `descricao` | texto |
| `pontos` | PontoId[] |

Temas são **dado de conteúdo**, não etiquetas do usuário. Etiquetas pessoais vivem em Coleções
pessoais (§4). Na v1 os temas alimentam filtros de busca; a partir da v2.0 alimentam a busca
semântica.

---

## 3. Motor de pontos

O coração reutilizável. Recebe uma coleção e responde a um conjunto pequeno e estável de perguntas.

### Seleção

| Operação | Descrição |
| --- | --- |
| `obterPonto(id)` | Um ponto por ID. |
| `pontoAleatorio(filtro?)` | "Um ponto para agora". Filtrável por obra (v0.4); capítulo e tema estão no backlog. |
| `pontoDoDia(data, preferencias)` | Determinístico: a mesma data e as mesmas preferências devolvem sempre o mesmo ponto. |
| `proximoPonto(id)` / `pontoAnterior(id)` | Sequência de leitura, atravessando fronteiras de capítulo. |
| `buscar(consulta, filtros)` | Busca textual sobre conteúdo autorizado. |

**Sobre o ponto aleatório.** O objetivo não é gamificar a espiritualidade. É reduzir a fricção de
um encontro breve com um texto quando a pessoa não sabe por onde começar. O motor evita repetir
pontos lidos recentemente — não porque "já valeu", mas porque a surpresa é o que dá valor à ação.
"Recentemente" são os **10 últimos pontos distintos** lidos, por qualquer caminho; quando a obra
escolhida não tem ponto fora deles, a janela encolhe a partir dos mais antigos até sobrar um.

**Sobre o ponto do dia.** Determinístico por `(data, semente do usuário, preferências)`. Duas
consequências desejadas: o ponto não muda se o app for reaberto no mesmo dia, e o histórico pode ser
reconstruído sem armazenar nada.

### Preferências do ponto do dia

| Campo | Valores |
| --- | --- |
| `obras` | uma das três, ou alternância entre todas |
| `dias` | todos os dias, ou dias escolhidos da semana |
| `horario` | hora local da notificação |
| `notificar` | ligado/desligado — **desligado por padrão** |

---

## 4. Registro pessoal

Tudo nesta seção pertence ao usuário e é privado por padrão.

### Leitura

Evento: este ponto foi lido, neste momento.

| Campo | Tipo |
| --- | --- |
| `pontoId` | PontoId |
| `lidoEm` | timestamp |
| `origem` | `biblioteca` · `continuacao` · `aleatorio` · `favoritos` · `colecao` (v0.4) — `pontoDoDia` e `busca` entram com a v1.1 e a v1.2 |

A `origem` existe para entender como as pessoas efetivamente chegam ao texto — não para pontuá-las.
Anterior/Próximo contam como `biblioteca`: quem segue adiante está lendo os livros em ordem.

**Leitura em sequência** é a de origem `biblioteca` ou `continuacao` — o fio dos livros. Abrir um
ponto pelo aleatório, por um favorito ou por uma coleção é um desvio: não muda o lugar do leitor.

### Progresso

Derivado das leituras, nunca escrito à mão:

- **Progresso de capítulo** — pontos lidos / total do capítulo.
- **Progresso de obra** — capítulos concluídos / total.
- **Estado do capítulo** — `não iniciado` · `em leitura` · `concluído`.
- **Última leitura em sequência** — o ponto para o qual "Continue de onde parou" aponta: o mais
  recente que ainda existe na coleção, pela ordem de gravação (não pelo relógio do aparelho).

> O progresso é mostrado com discrição. É informação para quem quiser, não cobrança para quem não quiser.

### Anotação

O registro pessoal sobre um ponto: pensamento, propósito, oração, resolução, contexto de vida.
No código e na interface o termo é **reflexão** (`Reflexao`); "anotação" fica como sinônimo aqui.

| Campo | Tipo | Notas |
| --- | --- | --- |
| `id` | uuid | |
| `pontoId` | PontoId | |
| `texto` | texto | |
| `criadaEm` / `editadaEm` | timestamp | Data e hora sempre visíveis |
| `visibilidade` | `privada` | Único valor na v1 |

Editável e excluível pelo autor, sempre. Um ponto pode ter várias anotações ao longo do tempo — e
é justamente a sequência delas, relidas meses depois, que forma a memória espiritual que o produto
promete.

### Favorito

Marcação simples e única por ponto. Existe para acesso rápido, separada das coleções.

### Coleção pessoal

Lista nomeada criada pelo usuário. Um ponto pode estar em várias.

Exemplos que o onboarding sugere: *Pontos para reler* · *Meditação da semana* · *Vida profissional* ·
*Família* · *Direção espiritual* · *Preparação para confissão* · *Virtudes a trabalhar*.

| Campo | Tipo |
| --- | --- |
| `id` | uuid |
| `nome` | texto |
| `pontos` | PontoId[] |
| `compartilhavel` | booleano — v3.0 |

> Quando o compartilhamento chegar, ele expõe **apenas a lista de pontos**. Anotações nunca
> acompanham uma coleção compartilhada. Essa separação é estrutural, não uma opção de privacidade
> que o usuário precise lembrar de desmarcar.

---

## 5. Usuário

Conta **opcional**. O app funciona inteiro sem cadastro, com tudo guardado no dispositivo.
A conta existe por um motivo só: sincronizar entre dispositivos e não perder anos de anotações
quando o aparelho quebrar.

| Campo | Tipo |
| --- | --- |
| `id` | uuid |
| `preferencias` | Preferencias |
| `sementeAleatoria` | inteiro — torna o ponto do dia pessoal |

### Preferências

Leitura (tamanho de fonte, tema claro/escuro/sistema, tipografia), ponto do dia (§3) e
privacidade (§7).

---

## 6. Vocabulário da interface

Termos fixos. Não se usam sinônimos na interface.

| Conceito | Termo | Nunca |
| --- | --- | --- |
| Unidade de texto | **ponto** | versículo, citação, frase, card |
| Registro pessoal | **reflexão** / **anotação** | comentário, post, entrada |
| Lista do usuário | **coleção** | pasta, tag, playlist |
| Seleção aleatória | **um ponto para agora** | sortear, surpresa do dia, random |
| Texto diário | **ponto do dia** | versículo do dia, devocional |
| Retomada | **continue de onde parou** | continuar lendo, retomar progresso |

---

## 7. Direitos e privacidade

### Direitos sobre as obras

*Caminho*, *Sulco* e *Forja* são obras protegidas por direito autoral. **Não são de domínio público.**

O modelo de domínio carrega essa realidade explicitamente, em vez de deixá-la como nota de rodapé:

```
Direitos {
  titular            — quem detém os direitos sobre a obra
  licenca            — instrumento que autoriza o uso no app
  escopo             — territórios, idiomas e plataformas cobertos
  limiteCitacao      — quanto pode ser compartilhado fora do app
  atribuicaoExigida  — texto de crédito obrigatório
  validoAte          — vigência
}
```

Consequências no produto:

- O campo `texto` de um ponto só é populado para obras com licença vigente registrada.
- O compartilhamento respeita `limiteCitacao`: por padrão, compartilha-se a **referência**, não o
  texto integral.
- A atribuição aparece na página do ponto e em qualquer exportação.

Ver [`livros/README.md`](../livros/README.md) para o estado atual dos direitos e o processo de ingestão.

### Anotações

Anotações são **dados pessoais sensíveis de natureza religiosa**. O tratamento reflete isso:

- Criptografadas em repouso.
- Nunca usadas para publicidade.
- Nunca usadas para treinamento público de modelos de IA.
- Nunca compartilhadas sem consentimento explícito e específico.
- Exportáveis e excluíveis pelo usuário, integralmente.
- Telemetria registra **eventos**, nunca **conteúdo** de anotação.

Quando a busca semântica chegar (v2.0), ela opera sobre o corpus autorizado. Buscar dentro das
próprias anotações é uma operação local, distinta, e nunca envia texto pessoal a um serviço externo
sem consentimento explícito daquela funcionalidade.

---

## 8. Fronteiras do domínio

O que o produto deliberadamente **não** modela:

- **Direção espiritual.** O app não aconselha, não interpreta e não substitui acompanhamento humano.
- **Mérito ou desempenho.** Não há pontuação, nível, sequência de dias, ranking ou comparação entre usuários.
- **Comunidade.** Não há feed, curtida, seguidor ou comentário público. A vida interior aqui é pessoal.
- **Obrigação.** Nenhum estado do sistema comunica falha, atraso ou dívida ao usuário.

Estas não são omissões de escopo a serem resolvidas depois. São decisões de produto.
