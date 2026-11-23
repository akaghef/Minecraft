# Minecraft project constraints

Use Java Edition 1.20.1 as the existing calculator's reference. Later versions are separate compatibility experiments, not proof of equivalence.

Preserve vanilla circuit rules: signal strength 0–15, dust attenuation, comparator arithmetic, repeater delays, update ordering, piston behavior and game tick semantics. Do not replace arithmetic with command blocks, scripted outputs, custom gate blocks, altered redstone, or faster simulation rules.

Automation may place, inspect and remove blocks and apply inputs. A claimed calculator result must come from the actual circuit. Dedicated fixtures test tooling only; label them accordingly.

Keep installation binaries, game instances, account files, tokens, logs, worlds and screenshots in ignored local storage. Publish no telephone numbers or email addresses, including in Git identities. Use the non-address Git identity `noreply` locally. Review every staged file and every commit before publishing. Do not import whole launcher/game/config directories.

Use upstream tools without replacing their internals. Record blocked and untested capabilities honestly. Downloaded is not loaded; loaded is not functionally verified.

AutoJS is installed separately for local debugging. Do not include it in exported modpacks. Keep bridges on loopback. Preserve original worlds and MATLAB sources.
