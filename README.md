# Godotquarium

This repository is an attempt to implement the original 25-year-old C++ *Insaniquarium* logic into the Godot Engine. 

---

### Hunger
* **Reference:** See `guppy_feeding.gd`:
```fish.hunger = randi_range(600, 800)```

### Known issue

* **Coins:** Coins are not working at the moment.
* **Feeding:** Fish will always swim up and left when food is dropped and sometimes get stuck on the left border.
