"""Testes das invariantes de validar.py. Rodar: python3 -m unittest discover -s livros -p 'test_*.py'"""
import json
import pathlib
import tempfile
import unittest

import validar


def obra(pontos):
    return {
        "id": "teste",
        "versaoDados": "0.1.0",
        "status": "parcial",
        "colecaoId": "colecao-teste",
        "obra": {"titulo": "Teste", "idioma": "pt-BR", "totalPontos": 4, "totalCapitulos": 2},
        "capitulos": [
            {"numero": 1, "slug": "um", "titulo": "Um", "pontoInicial": 1, "pontoFinal": 2, "validado": True},
            {"numero": 2, "slug": "dois", "titulo": "Dois", "pontoInicial": 3, "pontoFinal": 4, "validado": True},
        ],
        "pontos": pontos,
    }


def ponto(numero, capitulo):
    return {"numero": numero, "capituloNumero": capitulo, "ordem": numero, "texto": f"Texto {numero}."}


def erros_de(doc):
    with tempfile.TemporaryDirectory() as pasta:
        arquivo = pathlib.Path(pasta) / "teste.json"
        arquivo.write_text(json.dumps(doc), encoding="utf-8")
        erros, _ = validar.validar(arquivo)
    return erros


class InvariantesDosPontos(unittest.TestCase):
    def test_base02_numero_repetido_e_erro(self):
        erros = erros_de(obra([ponto(1, 1), ponto(3, 2), ponto(3, 2)]))

        self.assertIn("ponto 3 repetido", erros)

    def test_base03_capitulo_inexistente_e_erro(self):
        erros = erros_de(obra([ponto(1, 1), ponto(4, 9)]))

        self.assertIn("ponto 4: capítulo 9 não existe no índice", erros)

    def test_base02_base03_obra_valida_nao_tem_erro(self):
        self.assertEqual(erros_de(obra([ponto(1, 1), ponto(2, 1), ponto(3, 2)])), [])


if __name__ == "__main__":
    unittest.main()
