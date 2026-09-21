#!/bin/bash
# Doppelklick-Starter fuer python/stempel_abgleich.py (im Finder ausfuehrbar).
cd "$(dirname "$0")" || exit 1
python3 python/stempel_abgleich.py
echo
read -n 1 -s -r -p "Fenster mit beliebiger Taste schliessen..."
