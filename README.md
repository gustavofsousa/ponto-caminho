# Ponto do Caminho

**Um ponto para refletir.**

Aplicativo mobile de leitura espiritual católica construído em torno de *Caminho*, *Sulco* e
*Forja*, de São Josemaría Escrivá.

Não um repositório de frases. Um lugar onde a leitura vira percurso:

```
texto → silêncio → reflexão → anotação → releitura → vida prática
```

## Estado

**v0.3 — Guardar.** Sobre a leitura da v0.2 (biblioteca → obra → capítulo → ponto, tema e
tamanho de texto): reflexões cifradas no aparelho, favoritos e coleções pessoais, tudo visível na
página do ponto. Texto ainda **mock** e nunca rodado num aparelho real.
Ver [`docs/roadmap.md`](docs/roadmap.md) e [`.specs/features/guardar/`](.specs/features/guardar/).

## Documentação

| Documento | O que contém |
| --- | --- |
| [`AGENTS.md`](AGENTS.md) | Regras do repositório para humanos e agentes |
| [`docs/roadmap.md`](docs/roadmap.md) | Ordem de construção, por versão |
| [`docs/dominios.md`](docs/dominios.md) | Domínios, regras de fronteira e onde mora o código |
| [`docs/backlog.md`](docs/backlog.md) | O que cada domínio pode virar, e as decisões pendentes |
| [`docs/modelo.md`](docs/modelo.md) | Modelo conceitual e vocabulário — motor de pontos, registro pessoal, privacidade |
| [`docs/onepager.md`](docs/onepager.md) | Visão geral: problema, proposta, público, riscos e métricas |
| [`docs/tom-de-voz.md`](docs/tom-de-voz.md) | Boas-vindas, tom de voz e microcopy |
| [`docs/mensagem-inicial.md`](docs/mensagem-inicial.md) | Briefing original, na íntegra |
| [`docs/adr/`](docs/adr/) | Decisões de arquitetura (ADR) |
| [`docs/LESSONS.md`](docs/LESSONS.md) | O que aprendemos construindo |
| [`livros/`](livros/) | Dados das três obras: schema, índices, mock e validação |

```bash
python3 livros/validar.py
(cd packages/ponto_motor && dart test)
(cd apps/ponto_mobile && flutter test && flutter run)
```
