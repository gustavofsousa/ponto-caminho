import 'package:drift/drift.dart';
import 'package:ponto_motor/ponto_motor.dart';

/// Cada vez que o leitor abriu um ponto (`docs/modelo.md` §4). Mora no banco
/// cifrado do registro: o que alguém lê revela tanto quanto o que escreve.
@DataClassName('LinhaDeLeitura')
class Leituras extends Table {
  // INVARIANT: "mais recente" é o maior id — a ordem de gravação, nunca
  // `lidoEm`, que segue o relógio do aparelho e pode voltar (AD-010).
  IntColumn get id => integer().autoIncrement()();
  TextColumn get pontoId => text()();
  DateTimeColumn get lidoEm => dateTime()();
  TextColumn get origem => textEnum<OrigemDaLeitura>()();
}
