```markdown
# Godotquarium

This repository is an attempt to implement the original 25-year-old C++ *Insaniquarium* logic into the Godot Engine. 

---

## Known Logic & Status

### Hunger
* **Reference:** See `guppy_feeding.gd`:
```fish.hunger = randi_range(600, 800)```

### Known issue

* **Coin Functionality:** The currency collection system is currently non-functional. The logic linked to `Coin.cpp` is not yet fully integrated with the Board controller. Attempting to click coins will currently trigger errors.
* **Collision Tunneling:** At high speeds, fish may occasionally dance over food pellets without "consuming" them. This is due to a discrepancy between the fish's constant movement and the food's gravity, currently being addressed by optimizing the `FeedingArea` collision detection.

---

## Technical Architecture

This project prioritizes functional parity with the original C++ codebase.

* **`guppy.gd`**: The "brain." Holds all internal state variables (Size, Hunger, Movement States).
* **`guppy_movement.gd`**: The physics layer. Handles pathfinding, wall collisions, and velocity application.
* **`guppy_feeding.gd`**: The consumption layer. Manages hunger thresholds and food collision detection.

---

## To-Do List

* [ ] Implement `HUNGER_DEAD` animation and physics state.
* [ ] Debug `Coin.cpp` logic and integration with the game board.
* [ ] Add Wadsworth pet hiding logic (Invisible/Shadow 0.0 alpha).
* [ ] Refactor movement logic to prevent "tunneling" over food pellets.


```