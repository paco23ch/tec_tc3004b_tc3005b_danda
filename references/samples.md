### **Exercise 1: Creational Focus (Themed RPG Level Generator)**
**Patterns:** **Abstract Factory** & **Builder**

**Problem Statement:**
A game studio is developing an RPG. The game has different **Themes** (e.g., Ice, Lava). Each theme has its own set of **Monsters** and **Obstacles**. Currently, a `Level` class is responsible for everything: checking the theme, deciding which monsters to spawn, and managing the complex steps of building a level (adding rooms, spawning monsters, placing a boss). This results in a massive constructor with rigid conditional logic that makes adding a "Forest" theme almost impossible without rewriting the entire class.

#### **Initial Code (To be Refactored)**
<details>
<summary>Java - Initial Code</summary>

```java
import java.util.*;

class Level {
    public String theme;
    public List<String> contents = new ArrayList<>();

    public Level(String theme, int rooms, boolean hasBoss) {
        this.theme = theme;
        // The "Problem": High coupling and rigid conditionals
        for (int i = 0; i < rooms; i++) {
            if (theme.equalsIgnoreCase("Ice")) {
                contents.add("Ice Room with Frost Giant");
                contents.add("Ice Trap");
            } else if (theme.equalsIgnoreCase("Lava")) {
                contents.add("Lava Room with Fire Demon");
                contents.add("Spike Trap");
            }
        }
        if (hasBoss) {
            if (theme.equalsIgnoreCase("Ice")) contents.add("BOSS: Ice Dragon");
            else if (theme.equalsIgnoreCase("Lava")) contents.add("BOSS: Fire Lord");
        }
    }

    public void show() { System.out.println("Level [" + theme + "]: " + contents); }
}

public class Main {
    public static void main(String[] args) {
        Level iceLevel = new Level("Ice", 2, true);
        iceLevel.show();
    }
}
```
</details>

<details>
<summary>Python - Initial Code</summary>

```python
class Level:
    def __init__(self, theme, rooms, has_boss):
        self.theme = theme
        self.contents = []
        # Smelly code: Rigid conditionals for theme and construction
        for _ in range(rooms):
            if theme == "Ice":
                self.contents.append("Ice Room with Frost Giant")
                self.contents.append("Ice Trap")
            elif theme == "Lava":
                self.contents.append("Lava Room with Fire Demon")
                self.contents.append("Spike Trap")
        
        if has_boss:
            if theme == "Ice": self.contents.append("BOSS: Ice Dragon")
            elif theme == "Lava": self.contents.append("BOSS: Fire Lord")

    def show(self):
        print(f"Level [{self.theme}]: {self.contents}")

if __name__ == "__main__":
    ice_level = Level("Ice", 2, True)
    ice_level.show()
```
</details>

#### **Refactored Solution**
<details>
<summary>Java - Refactored</summary>

```java
import java.util.*;

// 1. Abstract Factory for Themed Entities
interface ThemeFactory {
    String createMonster();
    String createBoss();
}

class IceThemeFactory implements ThemeFactory {
    public String createMonster() { return "Frost Giant"; }
    public String createBoss() { return "Ice Dragon"; }
}

// 2. Builder for Complex Level Construction
class LevelBuilder {
    private ThemeFactory factory;
    private List<String> contents = new ArrayList<>();

    public LevelBuilder(ThemeFactory factory) { this.factory = factory; }

    public void buildRoom() { contents.add("Room with " + factory.createMonster()); }
    public void buildBoss() { contents.add("BOSS: " + factory.createBoss()); }
    public List<String> getResult() { return contents; }
}

public class Main {
    public static void main(String[] args) {
        LevelBuilder builder = new LevelBuilder(new IceThemeFactory());
        builder.buildRoom();
        builder.buildRoom();
        builder.buildBoss();
        System.out.println("Refactored Level: " + builder.getResult());
    }
}
```
</details>

<details>
<summary>Python - Refactored</summary>

```python
from abc import ABC, abstractmethod

# 1. Abstract Factory
class ThemeFactory(ABC):
    @abstractmethod
    def create_monster(self): pass
    @abstractmethod
    def create_boss(self): pass

class IceThemeFactory(ThemeFactory):
    def create_monster(self): return "Frost Giant"
    def create_boss(self): return "Ice Dragon"

# 2. Builder
class LevelBuilder:
    def __init__(self, factory: ThemeFactory):
        self.factory = factory
        self.contents = []

    def build_room(self):
        self.contents.append(f"Room with {self.factory.create_monster()}")

    def build_boss(self):
        self.contents.append(f"BOSS: {self.factory.create_boss()}")

    def get_result(self):
        return self.contents

if __name__ == "__main__":
    builder = LevelBuilder(IceThemeFactory())
    builder.build_room()
    builder.build_boss()
    print(f"Refactored Level: {builder.get_result()}")
```
</details>

**Explanation:**
*   **Abstract Factory:** Decouples the `Level` from specific monsters. Adding a new theme only requires a new factory class.
*   **Builder:** Separates the construction logic (adding rooms/bosses) from the representation, allowing for different level sequences using the same factory.

---

### **Exercise 2: Structural Focus (Secure Payment Gateway)**
**Patterns:** **Adapter** & **Decorator**

**Problem Statement:**
A system uses a standard `PaymentProcessor` interface. We need to integrate a third-party `LegacyAPI` that has completely different method names. Additionally, the system must support adding **Logging** and **Encryption** to any payment dynamically. Currently, developers are manually editing classes to add logging, violating the Open/Closed Principle.

#### **Initial Code (To be Refactored)**
<details>
<summary>Java - Initial Code</summary>

```java
class LegacyAPI {
    void executeTransaction(double val) { System.out.println("Legacy Pay: " + val); }
}

class PaymentService {
    LegacyAPI api = new LegacyAPI();

    void process(double amount, boolean secure) {
        // Smelly code: Hardcoded logic for encryption/logging
        System.out.println("Logging payment..."); 
        if (secure) {
            System.out.println("Encrypting data...");
            api.executeTransaction(amount);
        } else {
            api.executeTransaction(amount);
        }
    }
}
```
</details>

<details>
<summary>Python - Initial Code</summary>

```python
class LegacyAPI:
    def execute_transaction(self, val):
        print(f"Legacy Pay: {val}")

class PaymentService:
    def __init__(self):
        self.api = LegacyAPI()

    def process(self, amount, secure=False):
        # Smelly code: Manual boilerplate inside business logic
        print("Logging payment...")
        if secure:
            print("Encrypting data...")
            self.api.execute_transaction(amount)
        else:
            self.api.execute_transaction(amount)
```
</details>

#### **Refactored Solution**
<details>
<summary>Java - Refactored</summary>

```java
interface PaymentProcessor { void process(double amount); }

// 1. Adapter: Adapts LegacyAPI to PaymentProcessor
class LegacyAdapter implements PaymentProcessor {
    private LegacyAPI api = new LegacyAPI();
    public void process(double amount) { api.executeTransaction(amount); }
}

// 2. Decorator: Adds behaviors dynamically
abstract class PaymentDecorator implements PaymentProcessor {
    protected PaymentProcessor wrapped;
    public PaymentDecorator(PaymentProcessor p) { this.wrapped = p; }
    public void process(double amount) { wrapped.process(amount); }
}

class LoggingDecorator extends PaymentDecorator {
    public LoggingDecorator(PaymentProcessor p) { super(p); }
    public void process(double amount) {
        System.out.println("Log: Processing " + amount);
        super.process(amount);
    }
}
```
</details>

<details>
<summary>Python - Refactored</summary>

```python
class PaymentProcessor(ABC):
    @abstractmethod
    def process(self, amount): pass

# 1. Adapter
class LegacyAdapter(PaymentProcessor):
    def __init__(self): self.api = LegacyAPI()
    def process(self, amount): self.api.execute_transaction(amount)

# 2. Decorator
class PaymentDecorator(PaymentProcessor):
    def __init__(self, processor): self.processor = processor
    def process(self, amount): self.processor.process(amount)

class LoggingDecorator(PaymentDecorator):
    def process(self, amount):
        print(f"Log: Processing {amount}")
        super().process(amount)
```
</details>

**Explanation:**
*   **Adapter:** Wraps the `LegacyAPI` to match the `PaymentProcessor` interface, resolving the incompatibility [21, Artifact 7].
*   **Decorator:** Allows "stacking" features (Logging, then Encryption) at runtime without modifying the base classes, adhering to the Open/Closed Principle [21, Artifact 7].

---

### **Exercise 3: Behavioral Focus (Document Workflow & Notification)**
**Patterns:** **State** & **Observer**

**Problem Statement:**
A `Document` can be in `DRAFT`, `REVIEW`, or `PUBLISHED` states. Editing is allowed in `DRAFT`, but forbidden in `PUBLISHED`. When the state changes to `PUBLISHED`, a `Marketing` department must be notified. Currently, the `Document` class is full of `if-else` blocks and hardcoded department references.

#### **Initial Code (To be Refactored)**
<details>
<summary>Java - Initial Code</summary>

```java
class Document {
    String state = "DRAFT";

    void edit() {
        if (state.equals("DRAFT")) System.out.println("Editing...");
        else if (state.equals("PUBLISHED")) System.out.println("Error: Cannot edit!");
    }

    void publish() {
        if (state.equals("REVIEW")) {
            state = "PUBLISHED";
            System.out.println("Notifying Marketing..."); // Hardcoded dependency
        }
    }
}
```
</details>

<details>
<summary>Python - Initial Code</summary>

```python
class Document:
    def __init__(self):
        self.state = "DRAFT"

    def edit(self):
        if self.state == "DRAFT": print("Editing...")
        elif self.state == "PUBLISHED": print("Error: Locked!")

    def publish(self):
        if self.state == "REVIEW":
            self.state = "PUBLISHED"
            print("Notifying Marketing...") # Hardcoded
```
</details>

#### **Refactored Solution**
<details>
<summary>Java - Refactored</summary>

```java
import java.util.*;

// 1. Observer: Notification System
interface Subscriber { void update(String msg); }

// 2. State: Behavior changes based on internal state
interface State { void edit(); }

class DraftState implements State { public void edit() { System.out.println("Editing Draft..."); } }
class PublishedState implements State { public void edit() { System.out.println("Access Denied!"); } }

class Document {
    private State state = new DraftState();
    private List<Subscriber> subs = new ArrayList<>();

    public void addSub(Subscriber s) { subs.add(s); }
    public void setState(State s) { 
        this.state = s; 
        if (s instanceof PublishedState) subs.forEach(sub -> sub.update("Doc Published!"));
    }
    public void edit() { state.edit(); }
}
```
</details>

<details>
<summary>Python - Refactored</summary>

```python
# 1. State
class State(ABC):
    @abstractmethod
    def edit(self): pass

class DraftState(State):
    def edit(self): print("Editing...")

class PublishedState(State):
    def edit(self): print("Error: Published!")

# 2. Observer
class Document:
    def __init__(self):
        self._state = DraftState()
        self._observers = []

    def attach(self, obs): self._observers.append(obs)
    
    def set_state(self, state):
        self._state = state
        if isinstance(state, PublishedState):
            for obs in self._observers: obs.notify("Published!")

    def edit(self): self._state.edit()
```
</details>

**Explanation:**
*   **State:** Eliminates conditional bloat by delegating behavior to specific state classes [21, Artifact 4].
*   **Observer:** Decouples the `Document` from the `Marketing` department. New departments (e.g., Legal) can subscribe without changing the `Document` code [21, Artifact 4].
