import 'package:ponto_motor/ponto_motor.dart';

const _meses = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

/// "12 de março de 2026, 6h40" — hora cheia sem minutos ("6h"), no fuso do
/// aparelho. Formato do `docs/tom-de-voz.md` §4.
String dataEHora(DateTime momento) {
  final local = momento.toLocal();
  final minutos = local.minute == 0
      ? ''
      : local.minute.toString().padLeft(2, '0');
  return '${local.day} de ${_meses[local.month - 1]} de ${local.year}, '
      '${local.hour}h$minutos';
}

/// A linha que acompanha uma reflexão: quando foi escrita e, se for o caso,
/// quando foi editada.
String escritoEm(Reflexao reflexao) => switch (reflexao.editadaEm) {
  null => 'Escrito em ${dataEHora(reflexao.criadaEm)}.',
  final editadaEm =>
    'Escrito em ${dataEHora(reflexao.criadaEm)} · '
        'editado em ${dataEHora(editadaEm)}.',
};
