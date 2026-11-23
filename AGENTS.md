# Minecraft project constraints

Use Java Edition 1.20.1 as the existing calculator's reference. Later versions are separate compatibility experiments, not proof of equivalence.

Preserve vanilla circuit rules: signal strength 0–15, dust attenuation, comparator arithmetic, repeater delays, update ordering, piston behavior and game tick semantics. Do not replace arithmetic with command blocks, scripted outputs, custom gate blocks, altered redstone, or faster simulation rules.

Automation may place, inspect and remove blocks and apply inputs. A claimed calculator result must come from the actual circuit. Dedicated fixtures test tooling only; label them accordingly.

Keep installation binaries, game instances, account files, tokens, logs, worlds and screenshots in ignored local storage. Publish no telephone numbers or email addresses, including in Git identities. Use the non-address Git identity `noreply` locally. Review every staged file and every commit before publishing. Do not import whole launcher/game/config directories.

Use upstream tools without replacing their internals. Record blocked and untested capabilities honestly. Downloaded is not loaded; loaded is not functionally verified.

AutoJS is installed separately for local debugging. Do not include it in exported modpacks. Keep bridges on loopback. Preserve original worlds and MATLAB sources.

Before recommending or launching a calculator profile, inspect its actual game directory and version. A matching display name/version does not prove the profile is usable. Operate only on a verified world copy in an isolated instance; record source hashes before copying, verify the copy, and check source hashes after the run. Never launch the original saves directory for verification. Keep the unmodified copy and source manifest in ignored local storage. A launcher repair is intermediate: resume the authorized circuit verification after confirming launch.

Keep routine integrity checks internal. Do not report hash values or successful hash comparisons unless explicitly requested. Report an integrity check only when it finds a problem that affects the task. Progress and completion messages should state the user-visible result and any material failure or limitation.

AutoJS.command does not propagate a rejected Minecraft command as a tool failure. Inspect the game log and the resulting state. In a 1.20.1 integrated server, use the actual saveAll API for persistence; do not assume the dedicated-server save-all command exists. Verify saved command-block changes by rereading the region files before claiming the debugger repair is persistent.

Before claiming calculator agreement or a circuit defect, independently establish the physical input source, its encoding and load/reset sequence, and the register/latch phase. A value seen inside a multiplexed observation channel is an input candidate, not proof of the external input. Label comparisons that assume input or phase as conditional; preserve any numerical mismatch without treating it as a proven circuit defect.
