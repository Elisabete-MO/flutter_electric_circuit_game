// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EletroLab';

  @override
  String get appSubtitle => 'Your virtual circuit lab';

  @override
  String get menuFirstSteps => 'First Steps';

  @override
  String get menuChallenges => 'Start Challenges';

  @override
  String get menuSandbox => 'Workbench';

  @override
  String get menuSettings => 'Settings';

  @override
  String get firstStepsTitle => 'First Steps';

  @override
  String get firstStepsBanner =>
      'Observe. You have to know these symbols for this activity.';

  @override
  String get challengeMode => 'Challenge Mode';

  @override
  String get challengeInstructionsHeader => 'Activity Instructions:';

  @override
  String get challenge1Step1 =>
      '1. Check for any loose connections by closing the switch.';

  @override
  String get challenge1Step2 =>
      '2. Make a diagram of the circuit by clicking the yellow button.';

  @override
  String get challengeObserveInstruction =>
      '1. Observe this circuit and check its components.';

  @override
  String get challengeMakeDiagramInstruction =>
      '2. Make a diagram of the circuit by clicking the yellow button.';

  @override
  String get challengeDragSymbolsInstruction =>
      'Catch/Drag the symbols with mouse to complete the circuit diagram.';

  @override
  String get circuitDiagramButton => 'circuit diagram';

  @override
  String get buttonVerify => 'VERIFY';

  @override
  String get buttonReset => 'RESET';

  @override
  String get buttonStart => 'Start';

  @override
  String get buttonBack => 'Back';

  @override
  String get buttonClose => 'Close';

  @override
  String get buttonComplete => 'Complete Challenge';

  @override
  String get buttonRetry => 'Try Again';

  @override
  String get dialogCorrectTitle => 'Correct Diagram!';

  @override
  String get dialogIncorrectTitle => 'Incorrect Diagram';

  @override
  String get dialogCorrectMsg =>
      'Congratulations! You correctly placed all schematic symbols in the circuit.';

  @override
  String get dialogIncorrectMsg =>
      'Some symbols are missing or in the wrong place. Review component types and try again!';

  @override
  String get switchClosed => 'Switch: CLOSED';

  @override
  String get switchOpen => 'Switch: OPEN';

  @override
  String get symbolsPaletteTitle => 'Symbols';

  @override
  String get compBattery => 'Battery';

  @override
  String get compConnectingWire => 'Connecting wire';

  @override
  String get compSwitch => 'Switch';

  @override
  String get compBulb => 'Bulb';

  @override
  String get compResistor => 'Resistor';

  @override
  String get compDiode => 'Diode';

  @override
  String get compLED => 'LED';

  @override
  String get compMotor => 'Motor';

  @override
  String get menuFirstStepsDesc =>
      'An interactive introduction to electrical circuit concepts.';

  @override
  String get menuChallengesDesc =>
      'Solve challenges and put your knowledge into practice.';

  @override
  String get menuSandboxDesc =>
      'Build and experiment with your own circuits freely.';

  @override
  String get menuSettingsDesc =>
      'Adjust appearance, simulation, and accessibility.';

  @override
  String get challengesTitle => 'Circuit Challenges';

  @override
  String get challengesHeaderTitle => 'Get hands-on!';

  @override
  String get challengesHeaderDesc =>
      'Choose one of the challenges below to apply learned concepts and build practical circuits.';

  @override
  String challengesAvailable(Object count) {
    return 'Available Challenges ($count)';
  }

  @override
  String get challengeStatusCompleted => 'Completed';

  @override
  String get challengeStatusAvailable => 'Available';

  @override
  String get challenge1Title => 'Challenge 1: Light the Bulb';

  @override
  String get challenge1Desc =>
      'Build your first working electrical circuit connecting a power source to a light bulb.';

  @override
  String get challenge2Title => 'Challenge 2: Control with Switch';

  @override
  String get challenge2Desc =>
      'Add a control component to safely switch the circuit light on and off.';

  @override
  String get challenge3Title => 'Challenge 3: Resistor Protection';

  @override
  String get challenge3Desc =>
      'Use a resistor to limit current and protect sensitive components like LEDs.';

  @override
  String get challenge1DetailTitle =>
      'Challenge 1: Light the Bulb & Build Diagram';

  @override
  String get challenge2DetailTitle => 'Challenge 2: Motor Circuit & Diagram';

  @override
  String get challenge3DetailTitle =>
      'Challenge 3: Resistor Circuit & Full Diagram';

  @override
  String get sandboxTitle => 'Workbench';

  @override
  String get sandboxDesc =>
      'EletroLab free workbench. Soon you will be able to build and experiment without fixed objectives.';

  @override
  String get underConstruction => 'Under Construction';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearanceLanguage => 'Appearance & Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSimulation => 'Simulation';

  @override
  String get settingsShowCurrent => 'Show current';

  @override
  String get settingsShowValues => 'Show values';

  @override
  String get settingsShowGrid => 'Show grid';

  @override
  String get settingsShowTerminals => 'Show terminals';

  @override
  String get settingsAnimateCurrent => 'Animate current';

  @override
  String get settingsAccessibility => 'Accessibility';

  @override
  String get settingsUiSize => 'Interface size';

  @override
  String get settingsHighContrast => 'High contrast';

  @override
  String get settingsReduceAnimations => 'Reduce animations';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsRestoreDefaults => 'Restore default settings';

  @override
  String get settingsResetProgress => 'Reset progress';

  @override
  String get settingsResetProgressSubtitle => 'Available in upcoming releases.';

  @override
  String get compPhysical => 'Physical Component';

  @override
  String get compSchematic => 'Schematic Symbol';

  @override
  String get compFunction => 'Circuit Function:';

  @override
  String get compSymbolMeaning => 'Symbol Meaning:';

  @override
  String get compActivateState => 'Activate State';

  @override
  String get compDeactivateState => 'Deactivate State';

  @override
  String get compUnderstood => 'Understood';

  @override
  String get quizWhichSymbol =>
      'Which symbol corresponds to the component below?';

  @override
  String quizQuestionCount(Object current, Object total) {
    return 'Question $current of $total';
  }

  @override
  String get quizCorrect => 'Correct! Symbol identified successfully.';

  @override
  String quizIncorrect(Object name) {
    return 'Incorrect! This is the symbol for $name.';
  }

  @override
  String get quizResultTitle => 'Challenge Result';

  @override
  String quizResultMsg(Object score, Object total) {
    return 'You got $score out of $total schematic symbols correct!';
  }

  @override
  String get quizBackStudy => 'Back to Study';
}
