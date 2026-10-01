# Lektorat eines neuen Briefes

Workflow für jeden Brief, der aus `temp/` nach `editions/` wandert. Er besteht
aus zwei Teilen: einer maschinellen Vorprüfung (`pruefe_brief.py`) und einer
kritischen Lektüre nach einer festen Anweisung (`ANWEISUNG.md`), die von jedem
Sprachmodell oder von Hand abgearbeitet werden kann.

## Ablauf

Die Briefe liegen bereits in `editions/` (das Verschieben aus `temp/` geschieht
von Hand). Dann genügt ein Befehl mit Briefnummer oder Nummernbereich:

```bash
python3 pruefung/lektoriere.py 3971               # ein Brief
python3 pruefung/lektoriere.py 3971-3980          # Bereich (fehlende Nummern werden übergangen)
python3 pruefung/lektoriere.py 3971 4002 4010-4015
python3 pruefung/lektoriere.py 3971-3980 -j 4     # vier Briefe parallel (Standard: 3)
python3 pruefung/lektoriere.py 3971 --model opus  # anderes Modell
python3 pruefung/lektoriere.py 3971 --neu         # vorhandene Befunde überschreiben
python3 pruefung/lektoriere.py 3971 --nur-bericht # nur maschinelle Vorprüfung
```

Je Brief geschieht automatisch:

1. maschinelle Vorprüfung → `pruefung/berichte/L#####.md`
2. kritische Lektüre durch `claude -p` nach `ANWEISUNG.md`
   → `pruefung/befunde/L#####.md`

Alle Befundlisten eines Laufs werden zusätzlich in
`pruefung/befunde/_lauf-<Zeitstempel>.md` zusammengefasst. Bereits lektorierte
Briefe werden übersprungen. Voraussetzung: das `claude`-CLI ist installiert und
angemeldet. Berichte und Befunde stehen in `.gitignore`.

Die Einzelschritte (`pruefe_brief.py`, `ANWEISUNG.md`) lassen sich weiterhin
von Hand oder mit einem beliebigen anderen Sprachmodell nutzen; die Anweisung
enthält den vollständigen Fehlerkatalog, die Abgrenzung dessen, was **kein**
Fehler ist, und das Ausgabeformat.

## Ergebnis weiterverarbeiten

Die Befundliste ist so formatiert, dass sie in `LEKTORAT.md` (Abschnitt 4)
angehängt und anschließend mit dem vorhandenen Werkzeug abgearbeitet werden
kann:

```bash
python3 python/lektorat.py --file L03971
```

## `pruefe_brief.py`

```
python3 pruefung/pruefe_brief.py L04318                      # Bericht auf stdout
python3 pruefung/pruefe_brief.py temp/L03971.xml             # Pfad statt ID
python3 pruefung/pruefe_brief.py L04318 --out bericht.md     # zusätzlich in Datei
python3 pruefung/pruefe_brief.py --index-neu                 # Korpusindex neu bauen
```

Geprüft wird maschinell:

| Bereich | Prüfungen |
|---|---|
| Struktur | Platzhalter `XXXX`, leere `target`/Attribute, `<date when>` ≠ Anzeigetext, Datierung ↔ Datumszeile, doppeltes Genitiv-s (`…s</rs>s`), redaktionelle Arbeitsnotizen |
| Verweise | Selbstverweise, fehlende Zieldateien, Datumsverweise weit vom Briefdatum, ungewöhnliche `subtype`-Werte, `source=` statt `subtype=` |
| Herausgebertext | Wort- und Wortgruppendopplungen, Tippfehler (Wörterbuch + Korpusabgleich), alte Rechtschreibung außerhalb von Zitaten, Datumsformat, unpaarige Zeichen, Anführungsstil, Kommentarende, abweichende rs-Anzeigetexte |
| Brieftext | Wortdopplungen, Dreifachbuchstaben, ſ/f-Verlesungen, unbekannte Wörter mit Korpushäufigkeit und Korrekturvorschlag, unpaarige Guillemets, unsichtbare Zeichen, fehlende Leerzeichen an Elementgrenzen, Bezirks- und Namensabgleich gegen die PMB, Unterschrift ↔ Absender |

Die Befunde sind dreistufig: **[Fehler]** (belegt, nur noch zu bestätigen),
[Prüffall] (anzusehen), [Hinweis] (meist harmlos).

### Wie die Wortprüfung funktioniert

Ein Wort wird nur gemeldet, wenn es (a) in keinem der aspell-Wörterbücher steht
(`de_AT`, im Brieftext zusätzlich `de-alt` für die alte Orthografie), (b) sich
nicht als Kompositum aus bekannten Teilen erklären lässt, (c) kein Name aus
`indices/list*.xml` ist und (d) im übrigen Korpus höchstens zweimal vorkommt.
Als **Fehler** eingestuft wird es erst, wenn es ein nahes, im Korpus etabliertes
Nachbarwort gibt (»engültig« → »endgültig«) oder eine ſ/f-Verlesung erklärt
(»fucht« → »ſucht«). Das ist die Signatur eines Transkriptionsfehlers; bloß
seltene Wörter haben sie nicht.

Wiederkehrende Fehlalarme gehören in `pruefung/allowlist.txt`.

### Korpusindex

Beim ersten Aufruf entsteht `pruefung/.cache/korpus-index.json.gz` (Wort-
frequenzen aller `editions/*.xml`, PMB-Namen und Bezirke aus `indices/`,
Attributinventar). Der Aufbau dauert wenige Sekunden, eine Einzelprüfung danach
unter einer Sekunde. Nach größeren Änderungen am Korpus oder an den Indizes:
`--index-neu`. Der Cache steht in `.gitignore`.

### Regressionstest

`bash pruefung/test_pruefung.sh` prüft an 19 in `LEKTORAT.md` verifizierten
Fehlern, ob die maschinellen Prüfungen noch anschlagen. Nach jeder Änderung an
`pruefe_brief.py` laufen lassen. Wird einer dieser Fehler in `editions/`
korrigiert, den betreffenden Fall aus der Liste streichen.

## Abhängigkeiten

- Python 3 mit `lxml`
- `aspell` mit den Wörterbüchern `de_AT` und `de-alt`
  (`brew install aspell` installiert beide)
