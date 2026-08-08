#!/bin/bash
# Regressionstest für pruefe_brief.py.
#
# Jede Zeile in FAELLE nennt eine Briefdatei und eine Zeichenfolge, die im
# Befundteil des Prüfberichts vorkommen muss. Alle Fälle stammen aus LEKTORAT.md,
# sind also echte, am XML verifizierte Fehler.
#
# Aufruf aus dem Repo-Wurzelverzeichnis:  bash pruefung/test_pruefung.sh
#
# Schlägt ein Fall fehl, nachdem der zugehörige Fehler in editions/ korrigiert
# wurde, ist das kein Defekt des Skripts – dann den Fall hier streichen.

cd "$(dirname "$0")/.." || exit 1

FAELLE=(
  "L03640:Gehart"                    # Namensform im Kommentar
  "L03986:Vedenig"                   # rs-Anzeigetext
  "L04318:Berhardi"                  # rs-Anzeigetext, Werktitel
  "L03960:engültig"                  # Tippfehler Maschinschrift
  "L03960:herzlicnsten"              # Tippfehler Maschinschrift
  "L04007:seine Frau seine Frau"     # Wortgruppendopplung im Kommentar
  "L04196:gleichfalls"               # Wortgruppendopplung im Brieftext
  "L02910:Datum ≠"                   # date/@when weicht vom Anzeigetext ab
  "L03650:Trennzeichen"              # weiches Trennzeichen U+00AD
  "L04026:vonSonntag"                # fehlendes Leerzeichen an Elementgrenze
  "L03997:FriedrichHofreiter"        # fehlendes Leerzeichen im Kommentar
  "L04093:Kraus"                     # durchgerutschter Registereintrag
  "L02806:ders"                      # Tippfehler im Kommentar
  "L03018:Erwähung"                  # Tippfehler im Kommentar
  "L03055:gelang"                    # Grammatik im Kommentar
  "L04324:es sich"                   # Wortgruppendopplung im Kommentar
  "L04111:Satzzeichen doppelt"       # », ,« im Brieftext
  "L02614:Theile Theile"             # Wortdopplung im Brieftext
  "L04318:fucht"                     # ſ/f-Verlesung
)

fehler=0
for fall in "${FAELLE[@]}"; do
  datei="${fall%%:*}"
  erwartet="${fall#*:}"
  bericht=$(python3 pruefung/pruefe_brief.py "$datei" --quiet 2>/dev/null |
            sed -n '/## 1 Maschinelle/,/## 2 Brieftext/p')
  if echo "$bericht" | grep -qiF "$erwartet"; then
    printf '  ok       %-8s %s\n' "$datei" "$erwartet"
  else
    printf '  FEHLER   %-8s %s (nicht gemeldet)\n' "$datei" "$erwartet"
    fehler=$((fehler + 1))
  fi
done

echo
if [ "$fehler" -eq 0 ]; then
  echo "Alle ${#FAELLE[@]} Fälle bestanden."
else
  echo "$fehler von ${#FAELLE[@]} Fällen fehlgeschlagen."
  exit 1
fi
