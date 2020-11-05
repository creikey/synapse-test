rm -fr exports && mkdir exports && godot-headless --path src --export web "$(readlink -f exports/index.html)" && butler push exports creikey/synapse-test:web
rm -fr exports && mkdir exports && godot-headless --path src --export win "$(readlink -f exports/synapse.exe)" && butler push exports creikey/synapse-test:win

