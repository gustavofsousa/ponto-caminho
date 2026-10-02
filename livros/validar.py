#!/usr/bin/env python3
"""Valida as invariantes dos arquivos de obra em livros/.

Sem dependências externas. Checa o que realmente importa e o que um validador
de schema genérico não pegaria:

  - campos obrigatórios presentes;
  - capítulos numerados de 1..N sem buracos;
  - intervalos de pontos contíguos e dentro do total da obra;
  - cada ponto dentro do intervalo do seu capítulo;
  - totalCapitulos batendo com o índice;
  - pontos e capítulos marcados com nota "mock" (dado de desenvolvimento).

Uso: python3 livros/validar.py [--estrito]
  --estrito  trata dado mock como erro — use antes de qualquer build de publicação.
"""
import json
import pathlib
import sys

RAIZ = pathlib.Path(__file__).parent
OBRIGATORIOS = ("id", "versaoDados", "status", "colecaoId", "obra", "capitulos", "pontos")
MOCK = "mock"


def validar(caminho, estrito=False):
    erros, avisos = [], []
    doc = json.loads(caminho.read_text(encoding="utf-8"))

    for campo in OBRIGATORIOS:
        if campo not in doc:
            erros.append(f"campo obrigatório ausente: {campo}")
    if erros:
        return erros, avisos

    obra, caps, pontos = doc["obra"], doc["capitulos"], doc["pontos"]
    total = obra["totalPontos"]

    # Dado mock destrava o desenvolvimento, mas nunca pode chegar a uma publicação.
    mocks = sum(1 for item in caps + pontos if item.get("nota") == MOCK)
    if mocks:
        (erros if estrito else avisos).append(f"{mocks} item(ns) mock — substituir pelo texto/índice real")
    if doc["status"] == "estrutura" and pontos:
        erros.append("status = 'estrutura' mas o array 'pontos' não está vazio")
    if doc["status"] == "completo" and len(pontos) != total:
        erros.append(f"status = 'completo' mas há {len(pontos)} pontos para um total de {total}")

    if not caps:
        avisos.append("índice de capítulos vazio")
        return erros, avisos

    # Numeração 1..N sem buracos.
    numeros = [c["numero"] for c in caps]
    if numeros != list(range(1, len(caps) + 1)):
        erros.append(f"capítulos não numerados de 1 a {len(caps)} sem buracos")

    declarado = obra.get("totalCapitulos")
    if declarado is not None and declarado != len(caps):
        erros.append(f"totalCapitulos = {declarado} mas o índice tem {len(caps)} capítulos")

    # Contiguidade dos intervalos, ignorando extremos ainda não confirmados.
    anterior = 0
    for c in caps:
        ini, fim = c.get("pontoInicial"), c.get("pontoFinal")
        if ini is None or fim is None:
            avisos.append(f"cap. {c['numero']}: intervalo incompleto ({ini}-{fim})")
            if fim is not None:
                anterior = fim
            continue
        if fim < ini:
            erros.append(f"cap. {c['numero']}: intervalo invertido ({ini}-{fim})")
        if anterior and ini != anterior + 1:
            erros.append(f"cap. {c['numero']}: começa em {ini}, esperado {anterior + 1}")
        anterior = fim

    if anterior and anterior != total:
        erros.append(f"último ponto do índice é {anterior}, mas totalPontos = {total}")

    intervalos = {c["numero"]: (c.get("pontoInicial"), c.get("pontoFinal")) for c in caps}
    for p in pontos:
        ini, fim = intervalos.get(p["capituloNumero"], (None, None))
        if ini is not None and fim is not None and not ini <= p["numero"] <= fim:
            erros.append(f"ponto {p['numero']} fora do intervalo do cap. {p['capituloNumero']} ({ini}-{fim})")

    pendentes = [c["numero"] for c in caps if not c.get("validado")]
    if pendentes:
        avisos.append(f"{len(pendentes)} capítulo(s) não conferidos na edição impressa: {pendentes}")

    return erros, avisos


def main():
    estrito = "--estrito" in sys.argv[1:]
    arquivos = sorted(p for p in RAIZ.glob("*.json")
                      if p.name not in {"_schema.json", "colecao.json"})
    falhou = False
    for arq in arquivos:
        erros, avisos = validar(arq, estrito)
        marca = "FALHOU" if erros else "ok"
        print(f"{arq.name}: {marca}")
        for e in erros:
            print(f"  erro:   {e}")
        for a in avisos:
            print(f"  aviso:  {a}")
        falhou = falhou or bool(erros)
    return 1 if falhou else 0


if __name__ == "__main__":
    sys.exit(main())
