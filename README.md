# ⚡ Flutter Electric Circuit Game

> 🎮 An educational game built with **Flutter + Flame** to make learning basic electrical circuits more visual, interactive, and fun.

---

## ✨ About the Project

**Flutter Electric Circuit Game** is an educational game focused on introducing electrical circuit concepts through interactive challenges.

Instead of only memorizing electrical symbols, players will **use them to solve circuit-based puzzles**, gradually understanding how each component works.

The project is guided by three main ideas:

```text
✨ Fascinate
🎮 Entertain
🧠 Teach
```

The goal is to combine a strong visual identity, engaging gameplay, and meaningful learning in the same experience.

---

## 🎯 Game Concept

Players progress through different levels by completing electrical circuits.

During a level, the player may need to:

* 🔋 identify batteries and power sources;
* 💡 make a lamp turn on;
* 🎚️ use switches to control a circuit;
* 🧲 work with motors and other electrical components;
* 🟫 use resistors correctly;
* ➡️ understand LEDs and polarity;
* 🔍 find faults in incomplete circuits;
* 🧩 build increasingly complex circuits.

The difficulty increases gradually as new concepts and components are introduced.

---

## 🌌 Visual Concept

The game uses a **futuristic electronics laboratory** inspired by cyberpunk interfaces.

The main gameplay environment is a realistic or semi-realistic electronics workbench.

Electrical symbols can be selected through a large **holographic carousel interface**.

```text
             ✦ HOLOGRAPHIC SELECTOR ✦

      ┌────────┐ ┌────────┐ ┌────────┐
      │   M    │ │  /\/\/ │ │  ─| |─ │
      │ Motor  │ │Resistor│ │Battery │
      └────────┘ └────────┘ └────────┘
                         ▲
                    Selected item
```

After selecting the correct symbol, the holographic interface closes and the workbench becomes the main focus again.

The player then places the symbol in the circuit.

If the answer is correct:

```text
Electrical Symbol
        ↓
        ✨
        ↓
Real Component
        ↓
   Circuit works!
        ↓
       💡
```

And yes...

## 💡 The lamp must actually turn on.

That part is non-negotiable. 😄

---

## 🕹️ Gameplay Loop

```text
┌─────────────────────┐
│       LEVEL         │
│  Circuit Challenge  │
└─────────┬───────────┘
          ↓
┌─────────────────────┐
│ Select the Symbol   │
│ Holographic Menu    │
└─────────┬───────────┘
          ↓
┌─────────────────────┐
│ Place Component     │
│ on the Workbench    │
└─────────┬───────────┘
          ↓
      Correct?
       ↙     ↘
     No       Yes
     ↓         ↓
 Try Again   Component
             appears
                ↓
          Circuit reacts
                ↓
               ⚡
```

---

## 🗺️ Level Progression

The game is planned around a progressive level system.

Example:

```text
01 ─── 02 ─── 03 ─── 04 ─── 05
💡     🔋      🔌      🎚️      LED
│
▼
06 ─── 07 ─── 08 ─── 09 ─── 10
🟫     ⚙️      🔍      🧩      ⚡
```

Possible challenges include:

### 🌱 Beginner

* Complete a simple circuit
* Connect a battery and lamp
* Use a switch
* Identify basic symbols

### ⚙️ Intermediate

* Use LEDs
* Add resistors
* Control motors
* Understand polarity

### 🧠 Advanced

* Diagnose broken circuits
* Compare circuit configurations
* Build circuits from schematics
* Solve circuit puzzles with limited components

---

## ⭐ Progress and Rewards

Players may receive stars according to their performance.

```text
⭐⭐⭐  Excellent
⭐⭐☆  Completed with some mistakes
⭐☆☆  Completed with hints
```

Possible progression systems:

* ⭐ stars per level;
* 🏆 score;
* ⏱️ optional time challenges;
* 🔒 unlockable levels;
* 🎁 special challenges;
* ⚡ bonus missions.

The focus is not only on getting a high score.

The main reward is seeing the circuit **actually work**.

---

## 🧪 Free Laboratory Mode

A future feature may include a sandbox mode where players can freely experiment with components.

```text
🧪 FREE LAB

🔋 Battery
💡 Lamp
🎚️ Switch
🟫 Resistor
➡️ LED
⚙️ Motor
〰️ Wires
```

No score.

No timer.

Just experimentation.

---

## 🛠️ Technologies

The project is currently planned with:

* 💙 **Flutter**
* 🔥 **Flame Engine**
* 🎯 **Dart**

Additional technologies may be introduced as the project evolves.

---

## 📁 Initial Project Structure

```text
flutter_electric_circuit_game/
│
├── android/
├── ios/
├── web/
├── linux/
├── macos/
├── windows/
│
├── assets/
│   ├── images/
│   ├── icons/
│   ├── sounds/
│   └── animations/
│
├── lib/
│   ├── game/
│   ├── components/
│   ├── screens/
│   ├── models/
│   └── main.dart
│
├── test/
│
├── pubspec.yaml
└── README.md
```

> The structure may change as the game architecture evolves.

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone <repository-url>
```

### 2. Enter the project

```bash
cd flutter_electric_circuit_game
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run the project

```bash
flutter run
```

---

## 🔥 Adding Flame

If Flame is not installed yet:

```bash
flutter pub add flame
```

Then run:

```bash
flutter pub get
```

---

## 🧭 Current Direction

The current concept explores:

* 🌌 holographic component selection;
* 🧰 interactive electronics workbench;
* ⚡ responsive circuits;
* 💡 animated electrical components;
* 🎮 progressive gameplay;
* ⭐ level-based rewards;
* 🧠 learning through experimentation;
* 🎨 a more mature visual style aimed at teenage students.

---

## 🧩 Development Status

```text
[████░░░░░░] Concept / Early Development
```

Current phase:

* [x] Define initial game concept
* [x] Define visual direction
* [x] Define level progression idea
* [x] Define holographic symbol selector
* [ ] Define final game architecture
* [ ] Implement first playable level
* [ ] Implement circuit logic
* [ ] Implement level system
* [ ] Add animations and visual feedback
* [ ] Add sound effects
* [ ] Build additional levels

---

## 🎓 Educational Goal

The project aims to teach basic electrical concepts through interaction rather than memorization alone.

Instead of:

```text
Read → Memorize → Answer
```

the game encourages:

```text
Observe
   ↓
Experiment
   ↓
Make a decision
   ↓
See what happens
   ↓
Understand
```

---

## ❤️ Project Philosophy

```text
        ✨ FASCINATE
             │
             ▼
        🎮 ENTERTAIN
             │
             ▼
          🧠 TEACH
```

A beautiful visual experience attracts attention.

A good game keeps the player engaged.

Learning happens naturally through both.

---

## 📌 Project Name

`flutter_electric_circuit_game` is currently a working repository name.

The final game title is still under discussion.

---

## ⚡ Let's build some circuits!

```text
      + ────────o──o──────── 💡
      │
     🔋
      │
      └───────────────────────
```

**Connect. Experiment. Discover.**
