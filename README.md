# Acid Biters

Adds a new acid biter type.

## Acid biter description

Acid biters look the same as regular biters, but are bright green. Acid biters inflict more damage than and are faster than regular biters and spiters, but are also significantly weaker. When acid biters die they splash acid on nearby objects and inflict acid damage.

- 1.3x biter speed

- 3x biter damage composed of 1x physical damage and 2x acid damage 

- 0.5x biter health

- splash acid on death

Overall, this results in a biter that is on a rough parity with the existing biter and spiters in terms of difficulty. However, defending against and attacking acid biters will require different tactics than regular biters and spitters.

Acid biters have their own nest types. The nests are the same as regular biter nests except that they spawn acid biters, are green tinted and spray acid when destroyed. As this is a new nest type, it increases the total number of nests by roughly 33% versus base.

## Design principles

### Philosophy

Acid biters should present new challenges to the player(s) and require new tactics when attacking and defending. Unless the new biter type requires significant changes in tactics, the biter should be abandoned.

### Difficulty scaling

Acid biter attributes are pinned to biter and spitter attributes for the corresponding evolution size. For example, if the medium biter has a speed of 51.8km/h then the medium acid biter speed is 1.3x that, or 67.34km/h. This approach should help keep the acid biters a balanced challenge.
