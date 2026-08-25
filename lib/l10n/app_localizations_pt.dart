// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'EletroLab';

  @override
  String get appSubtitle => 'Seu laboratório virtual de circuitos';

  @override
  String get menuFirstSteps => 'Primeiros passos';

  @override
  String get menuChallenges => 'Começar';

  @override
  String get menuSandbox => 'Banqueta';

  @override
  String get menuSettings => 'Configurações';

  @override
  String get firstStepsTitle => 'Primeiros passos';

  @override
  String get firstStepsBanner =>
      'Observe. Você precisa conhecer esses símbolos para esta atividade.';

  @override
  String get challengeMode => 'Modo Desafio';

  @override
  String get challengeInstructionsHeader => 'Instruções da Atividade:';

  @override
  String get challenge1Step1 =>
      '1. Verifique o funcionamento do circuito fechando o interruptor.';

  @override
  String get challenge1Step2 =>
      '2. Crie o diagrama do circuito clicando no botão amarelo.';

  @override
  String get challengeObserveInstruction =>
      '1. Observe o circuito e verifique as conexões.';

  @override
  String get challengeMakeDiagramInstruction =>
      '2. Crie o diagrama do circuito clicando no botão amarelo.';

  @override
  String get challengeDragSymbolsInstruction =>
      'Arraste ou selecione os símbolos para completar o diagrama esquemático.';

  @override
  String get circuitDiagramButton => 'Diagrama Elétrico';

  @override
  String get buttonVerify => 'Verificar';

  @override
  String get buttonReset => 'Reiniciar';

  @override
  String get buttonStart => 'Iniciar';

  @override
  String get buttonBack => 'Voltar';

  @override
  String get buttonClose => 'Fechar';

  @override
  String get buttonComplete => 'Concluir Desafio';

  @override
  String get buttonRetry => 'Tentar Novamente';

  @override
  String get dialogCorrectTitle => 'Diagrama Correto!';

  @override
  String get dialogIncorrectTitle => 'Diagrama Incorreto';

  @override
  String get dialogCorrectMsg =>
      'Parabéns! Você posicionou corretamente todos os símbolos esquemáticos do circuito.';

  @override
  String get dialogIncorrectMsg =>
      'Alguns símbolos estão no local incorreto ou faltando. Revise o tipo de componente e tente novamente!';

  @override
  String get switchClosed => 'Interruptor: FECHADO';

  @override
  String get switchOpen => 'Interruptor: ABERTO';

  @override
  String get symbolsPaletteTitle => 'Símbolos';

  @override
  String get compBattery => 'Bateria';

  @override
  String get compConnectingWire => 'Fio de conexão';

  @override
  String get compSwitch => 'Interruptor';

  @override
  String get compBulb => 'Lâmpada';

  @override
  String get compResistor => 'Resistor';

  @override
  String get compDiode => 'Diodo';

  @override
  String get compLED => 'LED';

  @override
  String get compMotor => 'Motor';

  @override
  String get menuFirstStepsDesc =>
      'Uma introdução interativa aos conceitos de circuitos elétricos.';

  @override
  String get menuChallengesDesc =>
      'Resolva desafios e coloque o conhecimento em prática.';

  @override
  String get menuSandboxDesc =>
      'Monte e experimente seus próprios circuitos livremente.';

  @override
  String get menuSettingsDesc =>
      'Ajuste aparência, simulação e acessibilidade.';

  @override
  String get challengesTitle => 'Desafios de Circuitos';

  @override
  String get challengesHeaderTitle => 'Coloque a mão na massa!';

  @override
  String get challengesHeaderDesc =>
      'Escolha um dos desafios abaixo para aplicar os conceitos aprendidos e montar circuitos práticos.';

  @override
  String challengesAvailable(Object count) {
    return 'Desafios Disponíveis ($count)';
  }

  @override
  String get challengeStatusCompleted => 'Concluído';

  @override
  String get challengeStatusAvailable => 'Disponível';

  @override
  String get challenge1Title => 'Desafio 1: Acenda a Lâmpada';

  @override
  String get challenge1Desc =>
      'Monte seu primeiro circuito elétrico funcional ligando uma fonte de energia a uma lâmpada.';

  @override
  String get challenge2Title => 'Desafio 2: Controle com Interruptor';

  @override
  String get challenge2Desc =>
      'Adicione um componente de controle para poder ligar e desligar a luz do circuito com segurança.';

  @override
  String get challenge3Title => 'Desafio 3: Proteção com Resistor';

  @override
  String get challenge3Desc =>
      'Utilize um resistor para limitar a corrente e proteger componentes sensíveis como um LED.';

  @override
  String get challenge1DetailTitle =>
      'Desafio 1: Acenda a Lâmpada e Monte o Diagrama';

  @override
  String get challenge2DetailTitle =>
      'Desafio 2: Circuito com Motor e Diagrama';

  @override
  String get challenge3DetailTitle =>
      'Desafio 3: Circuito com Resistor e Diagrama Completo';

  @override
  String get sandboxTitle => 'Banqueta';

  @override
  String get sandboxDesc =>
      'A bancada livre do EletroLab. Em breve você poderá montar e experimentar circuitos sem objetivos obrigatórios.';

  @override
  String get underConstruction => 'Em construção';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsAppearanceLanguage => 'Aparência e Idioma';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsLanguage => 'Idioma / Language';

  @override
  String get settingsSimulation => 'Simulação';

  @override
  String get settingsShowCurrent => 'Mostrar corrente';

  @override
  String get settingsShowValues => 'Mostrar valores';

  @override
  String get settingsShowGrid => 'Mostrar grade';

  @override
  String get settingsShowTerminals => 'Mostrar terminais';

  @override
  String get settingsAnimateCurrent => 'Animar a corrente';

  @override
  String get settingsAccessibility => 'Acessibilidade';

  @override
  String get settingsUiSize => 'Tamanho da interface';

  @override
  String get settingsHighContrast => 'Alto contraste';

  @override
  String get settingsReduceAnimations => 'Reduzir animações';

  @override
  String get settingsData => 'Dados';

  @override
  String get settingsRestoreDefaults => 'Restaurar configurações padrão';

  @override
  String get settingsResetProgress => 'Resetar progresso';

  @override
  String get settingsResetProgressSubtitle =>
      'Disponível nas próximas versões.';

  @override
  String get compPhysical => 'Componente Físico';

  @override
  String get compSchematic => 'Símbolo Esquemático';

  @override
  String get compFunction => 'Função no Circuito:';

  @override
  String get compSymbolMeaning => 'Significado do Símbolo:';

  @override
  String get compActivateState => 'Ativar Estado';

  @override
  String get compDeactivateState => 'Desativar Estado';

  @override
  String get compUnderstood => 'Entendi';

  @override
  String get quizWhichSymbol =>
      'Qual é o símbolo correspondente ao componente abaixo?';

  @override
  String quizQuestionCount(Object current, Object total) {
    return 'Pergunta $current de $total';
  }

  @override
  String get quizCorrect => 'Correto! Símbolo identificado com sucesso.';

  @override
  String quizIncorrect(Object name) {
    return 'Incorreto! Este é o símbolo de $name.';
  }

  @override
  String get quizResultTitle => 'Resultado do Desafio';

  @override
  String quizResultMsg(Object score, Object total) {
    return 'Você acertou $score de $total símbolos esquemáticos!';
  }

  @override
  String get quizBackStudy => 'Voltar ao Estudo';
}
