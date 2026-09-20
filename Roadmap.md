# Roadmap

Plano de construção do **Ponto**.

O princípio que governa este roadmap: **uma primeira versão extremamente bem executada em leitura,
favoritos, coleções e ponto aleatório vale mais que muitas funcionalidades superficiais.** Cada fase
abaixo só começa quando a anterior está realmente boa — não quando está tecnicamente pronta.

---

## Fase 0 — Fundações e direitos

**Objetivo:** poder construir sem retrabalho e poder publicar sem risco jurídico.

Esta fase é **bloqueante**. Nada do que vem depois pode ser distribuído sem ela resolvida.

### Direitos autorais — o item crítico

*Caminho*, *Sulco* e *Forja* são obras protegidas. Não são de domínio público e não estarão
tão cedo. Distribuir o texto integral sem licença inviabiliza o produto, por melhor que ele seja.

- [ ] Identificar o titular dos direitos para a edição em português
- [ ] Contatar a editora responsável pela edição brasileira e o detentor dos direitos da obra
- [ ] Negociar licença de uso digital: escopo territorial, idiomas, plataformas, vigência
- [ ] Definir o limite de citação permitido no compartilhamento externo
- [ ] Registrar o texto de atribuição obrigatório
- [ ] Formalizar o instrumento antes de qualquer distribuição pública

> **Enquanto a licença não existir**, o desenvolvimento avança normalmente com uma coleção de
> desenvolvimento (textos próprios ou em domínio público) na mesma estrutura de dados. O motor não
> distingue uma coleção da outra — é exatamente para isso que ele é desacoplado.

### Produto e identidade

- [ ] Fechar nome, território e narrativa da marca
- [ ] Pesquisar e analisar as capas históricas de *Caminho* como referência visual
- [ ] Definir paleta: azul-noite, marfim/areia, terracota/cobre, âmbar
- [ ] Escolher a tipografia editorial para leitura prolongada — decisão de maior impacto no produto
- [ ] Design system: tokens, espaçamento, modo claro e escuro
- [ ] Guia de tom de voz e biblioteca de microcopy (ver [`mensagem-inicial.md`](./mensagem-inicial.md))

### Técnica

- [ ] Definir o schema da coleção e validá-lo ([`livros/_schema.json`](./livros/_schema.json))
- [ ] Pipeline de ingestão: fonte licenciada → JSON validado
- [ ] Esqueleto do motor de pontos como módulo independente do app
- [ ] Escolha de stack mobile, armazenamento local e estratégia de criptografia em repouso
- [ ] CI: validação de schema, lint, testes

**Pronto quando:** a licença está encaminhada, o design system existe, e o motor devolve um ponto
de uma coleção de desenvolvimento.

---

## Fase 1 — A leitura (MVP)

**Objetivo:** alguém consegue abrir o app, encontrar um ponto, ler com prazer e guardar o que
aquilo provocou. Só isso — e muito bem feito.

### Biblioteca e leitura

- [ ] As três obras, com navegação livro → capítulo → ponto
- [ ] Índice por capítulo, com contagem de pontos
- [ ] Leitura contínua e acesso direto a um ponto
- [ ] "Continue de onde parou"
- [ ] Modo claro e escuro, tamanho de fonte ajustável

### Página do ponto

- [ ] Texto integral com tipografia editorial e espaço em branco generoso
- [ ] Referência completa: obra, capítulo, número
- [ ] Ponto anterior / próximo, atravessando capítulos
- [ ] Ações: favoritar · salvar em coleção · escrever reflexão · marcar como lido · compartilhar referência
- [ ] Anotações do usuário para aquele ponto, exibidas na própria página
- [ ] Coleções em que o ponto está salvo

### Registro pessoal

- [ ] Reflexões com data e hora, editáveis e excluíveis
- [ ] Favoritos
- [ ] Coleções próprias, um ponto em várias listas
- [ ] Coleções sugeridas no primeiro uso, todas recusáveis

### Um ponto para agora

- [ ] Ponto aleatório, com preferência por não repetir leituras recentes
- [ ] Filtro opcional por obra

### Acessibilidade — requisito da v1, não melhoria futura

- [ ] Suporte a leitor de tela em toda a navegação
- [ ] Contraste adequado nos dois temas
- [ ] Respeito ao tamanho de fonte do sistema
- [ ] Alvos de toque adequados
- [ ] Respeito a "reduzir movimento"

**Pronto quando:** um leitor real usa o app por duas semanas sem pedir nada que não esteja lá.

**Explicitamente fora:** conta, sincronização, notificação, busca, exportação.
Tudo local, tudo offline, tudo no dispositivo.

---

## Fase 2 — O hábito

**Objetivo:** o app deixa de ser algo que se abre e passa a ser algo que acompanha — sem nunca cobrar.

### Ponto do dia

- [ ] Ponto diário determinístico na tela inicial
- [ ] Configuração: obra ou alternância, dias da semana, horário
- [ ] Notificação **opcional, desligada por padrão**, com cópia serena e sem urgência
- [ ] Histórico dos pontos do dia recebidos
- [ ] Reflexão sobre o ponto do dia

### Busca

- [ ] Busca por palavra-chave no conteúdo autorizado
- [ ] Filtros: obra, capítulo, número, favorito, coleção
- [ ] Busca nas próprias anotações, local e privada
- [ ] Histórico de buscas recentes, apagável

### Progresso

- [ ] Progresso por capítulo e por obra, apresentado com discrição
- [ ] Capítulo como não iniciado / em leitura / concluído
- [ ] Marcação manual de capítulo concluído

**Pronto quando:** alguém volta ao app por vontade própria depois de uma semana longe — e é
recebido sem nenhuma menção à ausência.

> **Guarda-corpo desta fase.** É aqui que a tentação de gamificar aparece: sequência de dias,
> medalhas, lembretes insistentes. Nada disso entra. Uma notificação por dia, no horário que a
> pessoa escolheu, com um texto sereno. Quem não abrir não ouve sobre isso.

---

## Fase 3 — A memória

**Objetivo:** o que foi lido e escrito ao longo de meses começa a devolver valor.
É aqui que o diferencial do produto se realiza de fato.

### Revisita

- [ ] Releitura das anotações por período, obra, capítulo e coleção
- [ ] "Você escreveu sobre este ponto há um ano" — sem notificação, apenas ao abrir o ponto
- [ ] Linha do tempo pessoal de reflexões
- [ ] Revisão periódica opcional das anotações

### Conta e sincronização

- [ ] Conta opcional
- [ ] Sincronização de anotações, favoritos e coleções entre dispositivos
- [ ] Criptografia em trânsito e em repouso
- [ ] Exportação em Markdown, PDF e texto simples
- [ ] Exclusão integral de conta e dados, em um caminho claro e curto

### Busca por ideia

- [ ] Indexação semântica do corpus autorizado
- [ ] Busca em linguagem natural: *"aquele ponto sobre começar de novo depois de falhar"*
- [ ] Resultados sempre como **pontos com referência**, nunca como texto gerado
- [ ] O modelo nunca escreve comentário espiritual, interpretação ou conselho

> **Limite absoluto da IA neste produto:** ela ajuda a *encontrar* o texto do autor.
> Ela não o explica, não o parafraseia e não aconselha sobre ele.
> Anotações pessoais nunca alimentam modelo algum.

**Pronto quando:** um usuário de seis meses encontra valor em reler o próprio caderno.

---

## Fase 4 — A extensão

**Objetivo:** o motor sai do app e alcança outras superfícies e outros conteúdos.

- [ ] Aplicação web com leitura e anotação
- [ ] Widget de tela inicial com o ponto do dia
- [ ] Aplicação desktop
- [ ] Extensão de navegador
- [ ] Integração com ferramentas de notas (Obsidian, Notion)
- [ ] API pública ou privada do motor de pontos
- [ ] Compartilhamento de coleções por link — **somente a lista de pontos, nunca as anotações**
- [ ] Segunda coleção de conteúdo, provando a troca na prática
- [ ] Outros idiomas, conforme a licença permitir
- [ ] Recursos para grupos de formação e círculos de estudo

---

## Fora de escopo — decisões, não pendências

Estes itens não estão "para depois". Estão fora.

| Item | Motivo |
| --- | --- |
| Sequências de dias, medalhas, rankings | Culpa e competição não pertencem à vida interior |
| Feed social, curtidas, comentários públicos | O registro é pessoal por natureza |
| IA que comenta ou interpreta os textos | Não é papel do produto; pertence a pessoas |
| Publicidade | Incompatível com a sensibilidade dos dados |
| Venda ou análise comercial de anotações | Proibido por princípio, não por política |
| Notificações de reengajamento | Manipulação; o app espera, não persegue |

---

## Sequência de decisões

Ordem em que as escolhas precisam ser feitas, porque cada uma condiciona a seguinte:

1. **Licença das obras** — condiciona a existência do produto
2. **Tipografia e design system** — condiciona toda a experiência de leitura
3. **Schema da coleção** — condiciona o motor e a ingestão
4. **Fronteira motor ↔ app** — condiciona a reutilização futura
5. **Modelo de dados local e criptografia** — condiciona a sincronização
6. **Formato de exportação** — condiciona a promessa de portabilidade

---

*Documentos relacionados:* [`one-page.md`](./one-page.md) · [`domínio.md`](./domínio.md) · [`mensagem-inicial.md`](./mensagem-inicial.md) · [`livros/`](./livros/)
