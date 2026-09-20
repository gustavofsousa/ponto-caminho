# Ponto do Caminho

**Um ponto para refletir.**

Aplicativo de leitura espiritual católica construído em torno de *Caminho*, *Sulco* e *Forja*,
de São Josemaría Escrivá.

Não um repositório de frases. Um lugar onde a leitura vira percurso:

```
texto → silêncio → reflexão → anotação → releitura → vida prática
```

## Documentação

| Documento | O que contém |
| --- | --- |
| [`one-page.md`](./one-page.md) | Visão geral: problema, proposta, público, escopo da v1, riscos e métricas |
| [`Roadmap.md`](./Roadmap.md) | Fases de construção, da licença das obras à extensão do motor |
| [`domínio.md`](./domínio.md) | Modelo conceitual e linguagem do projeto — motor de pontos, registro pessoal, direitos |
| [`mensagem-inicial.md`](./mensagem-inicial.md) | Briefing original do projeto, na íntegra — fonte de verdade sobre a intenção do produto |
| [`tom-de-voz.md`](./tom-de-voz.md) | Boas-vindas, tom de voz e biblioteca de microcopy |
| [`livros/`](./livros/) | Dados das três obras: schema, índices e validação |

## Estado do projeto

**Fase 0 — fundações.** Documentação de produto escrita; conteúdo ainda não licenciado.

> ⚠️ As três obras são protegidas por direito autoral e **não estão em domínio público**.
> Os arquivos em `livros/` contêm metadados e índices, nunca o texto dos pontos.
> Ver [`livros/README.md`](./livros/README.md).

```bash
python3 livros/validar.py
```
