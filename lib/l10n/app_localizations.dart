import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'EletroLab'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu laboratório virtual de circuitos'**
  String get appSubtitle;

  /// No description provided for @menuFirstSteps.
  ///
  /// In pt, this message translates to:
  /// **'Primeiros Passos'**
  String get menuFirstSteps;

  /// No description provided for @menuChallenges.
  ///
  /// In pt, this message translates to:
  /// **'Desafios'**
  String get menuChallenges;

  /// No description provided for @menuSandbox.
  ///
  /// In pt, this message translates to:
  /// **'Bancada Livre'**
  String get menuSandbox;

  /// No description provided for @menuSettings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get menuSettings;

  /// No description provided for @firstStepsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Primeiros Passos'**
  String get firstStepsTitle;

  /// No description provided for @firstStepsBanner.
  ///
  /// In pt, this message translates to:
  /// **'Observe. Você precisa conhecer esses símbolos para esta atividade.'**
  String get firstStepsBanner;

  /// No description provided for @challengeMode.
  ///
  /// In pt, this message translates to:
  /// **'Modo Desafio'**
  String get challengeMode;

  /// No description provided for @challengeInstructionsHeader.
  ///
  /// In pt, this message translates to:
  /// **'Instruções da Atividade:'**
  String get challengeInstructionsHeader;

  /// No description provided for @challenge1Step1.
  ///
  /// In pt, this message translates to:
  /// **'1. Verifique o funcionamento do circuito fechando o interruptor.'**
  String get challenge1Step1;

  /// No description provided for @challenge1Step2.
  ///
  /// In pt, this message translates to:
  /// **'2. Crie o diagrama do circuito clicando no botão amarelo.'**
  String get challenge1Step2;

  /// No description provided for @challengeObserveInstruction.
  ///
  /// In pt, this message translates to:
  /// **'1. Observe o circuito e verifique as conexões.'**
  String get challengeObserveInstruction;

  /// No description provided for @challengeMakeDiagramInstruction.
  ///
  /// In pt, this message translates to:
  /// **'2. Crie o diagrama do circuito clicando no botão amarelo.'**
  String get challengeMakeDiagramInstruction;

  /// No description provided for @challengeDragSymbolsInstruction.
  ///
  /// In pt, this message translates to:
  /// **'Arraste ou selecione os símbolos para completar o diagrama esquemático.'**
  String get challengeDragSymbolsInstruction;

  /// No description provided for @circuitDiagramButton.
  ///
  /// In pt, this message translates to:
  /// **'Diagrama Elétrico'**
  String get circuitDiagramButton;

  /// No description provided for @buttonVerify.
  ///
  /// In pt, this message translates to:
  /// **'Verificar'**
  String get buttonVerify;

  /// No description provided for @buttonReset.
  ///
  /// In pt, this message translates to:
  /// **'Reiniciar'**
  String get buttonReset;

  /// No description provided for @buttonStart.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar'**
  String get buttonStart;

  /// No description provided for @buttonBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get buttonBack;

  /// No description provided for @buttonClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get buttonClose;

  /// No description provided for @buttonComplete.
  ///
  /// In pt, this message translates to:
  /// **'Concluir Desafio'**
  String get buttonComplete;

  /// No description provided for @buttonRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar Novamente'**
  String get buttonRetry;

  /// No description provided for @dialogCorrectTitle.
  ///
  /// In pt, this message translates to:
  /// **'Diagrama Correto!'**
  String get dialogCorrectTitle;

  /// No description provided for @dialogIncorrectTitle.
  ///
  /// In pt, this message translates to:
  /// **'Diagrama Incorreto'**
  String get dialogIncorrectTitle;

  /// No description provided for @dialogCorrectMsg.
  ///
  /// In pt, this message translates to:
  /// **'Parabéns! Você posicionou corretamente todos os símbolos esquemáticos do circuito.'**
  String get dialogCorrectMsg;

  /// No description provided for @dialogIncorrectMsg.
  ///
  /// In pt, this message translates to:
  /// **'Alguns símbolos estão no local incorreto ou faltando. Revise o tipo de componente e tente novamente!'**
  String get dialogIncorrectMsg;

  /// No description provided for @switchClosed.
  ///
  /// In pt, this message translates to:
  /// **'Interruptor: FECHADO'**
  String get switchClosed;

  /// No description provided for @switchOpen.
  ///
  /// In pt, this message translates to:
  /// **'Interruptor: ABERTO'**
  String get switchOpen;

  /// No description provided for @symbolsPaletteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Símbolos'**
  String get symbolsPaletteTitle;

  /// No description provided for @compBattery.
  ///
  /// In pt, this message translates to:
  /// **'Bateria'**
  String get compBattery;

  /// No description provided for @compConnectingWire.
  ///
  /// In pt, this message translates to:
  /// **'Fio de conexão'**
  String get compConnectingWire;

  /// No description provided for @compSwitch.
  ///
  /// In pt, this message translates to:
  /// **'Interruptor'**
  String get compSwitch;

  /// No description provided for @compBulb.
  ///
  /// In pt, this message translates to:
  /// **'Lâmpada'**
  String get compBulb;

  /// No description provided for @compResistor.
  ///
  /// In pt, this message translates to:
  /// **'Resistor'**
  String get compResistor;

  /// No description provided for @compDiode.
  ///
  /// In pt, this message translates to:
  /// **'Diodo'**
  String get compDiode;

  /// No description provided for @compLED.
  ///
  /// In pt, this message translates to:
  /// **'LED'**
  String get compLED;

  /// No description provided for @compMotor.
  ///
  /// In pt, this message translates to:
  /// **'Motor'**
  String get compMotor;

  /// No description provided for @menuFirstStepsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Uma introdução interativa aos conceitos de circuitos elétricos.'**
  String get menuFirstStepsDesc;

  /// No description provided for @menuChallengesDesc.
  ///
  /// In pt, this message translates to:
  /// **'Resolva desafios e coloque o conhecimento em prática.'**
  String get menuChallengesDesc;

  /// No description provided for @menuSandboxDesc.
  ///
  /// In pt, this message translates to:
  /// **'Monte e experimente seus próprios circuitos livremente.'**
  String get menuSandboxDesc;

  /// No description provided for @menuSettingsDesc.
  ///
  /// In pt, this message translates to:
  /// **'Ajuste aparência, simulação e acessibilidade.'**
  String get menuSettingsDesc;

  /// No description provided for @challengesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Desafios de Circuitos'**
  String get challengesTitle;

  /// No description provided for @challengesHeaderTitle.
  ///
  /// In pt, this message translates to:
  /// **'Coloque a mão na massa!'**
  String get challengesHeaderTitle;

  /// No description provided for @challengesHeaderDesc.
  ///
  /// In pt, this message translates to:
  /// **'Escolha um dos desafios abaixo para aplicar os conceitos aprendidos e montar circuitos práticos.'**
  String get challengesHeaderDesc;

  /// No description provided for @challengesAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Desafios Disponíveis ({count})'**
  String challengesAvailable(Object count);

  /// No description provided for @challengeStatusCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Concluído'**
  String get challengeStatusCompleted;

  /// No description provided for @challengeStatusAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Disponível'**
  String get challengeStatusAvailable;

  /// No description provided for @challenge1Title.
  ///
  /// In pt, this message translates to:
  /// **'Desafio 1: Acenda a Lâmpada'**
  String get challenge1Title;

  /// No description provided for @challenge1Desc.
  ///
  /// In pt, this message translates to:
  /// **'Monte seu primeiro circuito elétrico funcional ligando uma fonte de energia a uma lâmpada.'**
  String get challenge1Desc;

  /// No description provided for @challenge2Title.
  ///
  /// In pt, this message translates to:
  /// **'Desafio 2: Controle com Interruptor'**
  String get challenge2Title;

  /// No description provided for @challenge2Desc.
  ///
  /// In pt, this message translates to:
  /// **'Adicione um componente de controle para poder ligar e desligar a luz do circuito com segurança.'**
  String get challenge2Desc;

  /// No description provided for @challenge3Title.
  ///
  /// In pt, this message translates to:
  /// **'Desafio 3: Proteção com Resistor'**
  String get challenge3Title;

  /// No description provided for @challenge3Desc.
  ///
  /// In pt, this message translates to:
  /// **'Utilize um resistor para limitar a corrente e proteger componentes sensíveis como um LED.'**
  String get challenge3Desc;

  /// No description provided for @challenge1DetailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Desafio 1: Acenda a Lâmpada e Monte o Diagrama'**
  String get challenge1DetailTitle;

  /// No description provided for @challenge2DetailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Desafio 2: Circuito com Motor e Diagrama'**
  String get challenge2DetailTitle;

  /// No description provided for @challenge3DetailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Desafio 3: Circuito com Resistor e Diagrama Completo'**
  String get challenge3DetailTitle;

  /// No description provided for @sandboxTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bancada Livre'**
  String get sandboxTitle;

  /// No description provided for @sandboxDesc.
  ///
  /// In pt, this message translates to:
  /// **'A bancada livre do EletroLab. Em breve você poderá montar e experimentar circuitos sem objetivos obrigatórios.'**
  String get sandboxDesc;

  /// No description provided for @underConstruction.
  ///
  /// In pt, this message translates to:
  /// **'Em construção'**
  String get underConstruction;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @settingsAppearanceLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Aparência e Idioma'**
  String get settingsAppearanceLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In pt, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @settingsLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma / Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSimulation.
  ///
  /// In pt, this message translates to:
  /// **'Simulação'**
  String get settingsSimulation;

  /// No description provided for @settingsShowCurrent.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar corrente'**
  String get settingsShowCurrent;

  /// No description provided for @settingsShowValues.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar valores'**
  String get settingsShowValues;

  /// No description provided for @settingsShowGrid.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar grade'**
  String get settingsShowGrid;

  /// No description provided for @settingsShowTerminals.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar terminais'**
  String get settingsShowTerminals;

  /// No description provided for @settingsAnimateCurrent.
  ///
  /// In pt, this message translates to:
  /// **'Animar a corrente'**
  String get settingsAnimateCurrent;

  /// No description provided for @settingsAccessibility.
  ///
  /// In pt, this message translates to:
  /// **'Acessibilidade'**
  String get settingsAccessibility;

  /// No description provided for @settingsUiSize.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho da interface'**
  String get settingsUiSize;

  /// No description provided for @settingsHighContrast.
  ///
  /// In pt, this message translates to:
  /// **'Alto contraste'**
  String get settingsHighContrast;

  /// No description provided for @settingsReduceAnimations.
  ///
  /// In pt, this message translates to:
  /// **'Reduzir animações'**
  String get settingsReduceAnimations;

  /// No description provided for @settingsData.
  ///
  /// In pt, this message translates to:
  /// **'Dados'**
  String get settingsData;

  /// No description provided for @settingsRestoreDefaults.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar configurações padrão'**
  String get settingsRestoreDefaults;

  /// No description provided for @settingsResetProgress.
  ///
  /// In pt, this message translates to:
  /// **'Resetar progresso'**
  String get settingsResetProgress;

  /// No description provided for @settingsResetProgressSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Disponível nas próximas versões.'**
  String get settingsResetProgressSubtitle;

  /// No description provided for @compPhysical.
  ///
  /// In pt, this message translates to:
  /// **'Componente Físico'**
  String get compPhysical;

  /// No description provided for @compSchematic.
  ///
  /// In pt, this message translates to:
  /// **'Símbolo Esquemático'**
  String get compSchematic;

  /// No description provided for @compFunction.
  ///
  /// In pt, this message translates to:
  /// **'Função no Circuito:'**
  String get compFunction;

  /// No description provided for @compSymbolMeaning.
  ///
  /// In pt, this message translates to:
  /// **'Significado do Símbolo:'**
  String get compSymbolMeaning;

  /// No description provided for @compActivateState.
  ///
  /// In pt, this message translates to:
  /// **'Ativar Estado'**
  String get compActivateState;

  /// No description provided for @compDeactivateState.
  ///
  /// In pt, this message translates to:
  /// **'Desativar Estado'**
  String get compDeactivateState;

  /// No description provided for @compUnderstood.
  ///
  /// In pt, this message translates to:
  /// **'Entendi'**
  String get compUnderstood;

  /// No description provided for @quizWhichSymbol.
  ///
  /// In pt, this message translates to:
  /// **'Qual é o símbolo correspondente ao componente abaixo?'**
  String get quizWhichSymbol;

  /// No description provided for @quizQuestionCount.
  ///
  /// In pt, this message translates to:
  /// **'Pergunta {current} de {total}'**
  String quizQuestionCount(Object current, Object total);

  /// No description provided for @quizCorrect.
  ///
  /// In pt, this message translates to:
  /// **'Correto! Símbolo identificado com sucesso.'**
  String get quizCorrect;

  /// No description provided for @quizIncorrect.
  ///
  /// In pt, this message translates to:
  /// **'Incorreto! Este é o símbolo de {name}.'**
  String quizIncorrect(Object name);

  /// No description provided for @quizResultTitle.
  ///
  /// In pt, this message translates to:
  /// **'Resultado do Desafio'**
  String get quizResultTitle;

  /// No description provided for @quizResultMsg.
  ///
  /// In pt, this message translates to:
  /// **'Você acertou {score} de {total} símbolos esquemáticos!'**
  String quizResultMsg(Object score, Object total);

  /// No description provided for @quizBackStudy.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao Estudo'**
  String get quizBackStudy;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
