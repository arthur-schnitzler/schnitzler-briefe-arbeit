# partOf.xml Generator

Ein eigenständiges Skript zur Generierung von `partOf.xml` aus PMB-Relationsdaten.

## Was macht das Skript?

Das Skript `generate_partOf.py` extrahiert hierarchische Ortsbeziehungen aus der PMB-Datenbank und erstellt eine strukturierte XML-Datei. Diese enthält "gehört zu" und "enthält"-Beziehungen zwischen Orten (z.B. "Wien gehört zu Österreich", "Café Central ist in Wien").

## Funktionsweise

1. **Datendownload**: Lädt `relations.csv` von PMB herunter
2. **Filterung**: Extrahiert nur "gehört zu" und "enthält"-Beziehungen
3. **Transformation**: Wendet XSLT-Transformation an, um die finale Struktur zu erstellen
4. **Ausgabe**: Generiert eine saubere `partOf.xml`-Datei

## Voraussetzungen

```bash
pip install requests
```

- Java Runtime (für Saxon XSLT-Prozessor)
- Saxon XSLT-Prozessor JAR-Datei (wird automatisch heruntergeladen mit `./dl_saxon.sh`)

## Verwendung

### Einfache Verwendung
```bash
python3 generate_partOf.py
```

### Mit benutzerdefinierten Optionen
```bash
python3 generate_partOf.py --output-dir ./meine-ausgabe --saxon-jar ./saxon/saxon-he-12.5.jar
```

### Alle Optionen
```bash
python3 generate_partOf.py --help
```

## Ausgabeformat

Die generierte `partOf.xml` hat folgende Struktur:

```xml
<root>
    <p>This file contains partOf-relations of places...</p>
    <list>
        <item id="pmb50"><!-- Wien -->
            <contains id="pmb51"/><!-- 1. Bezirk -->
            <contains id="pmb52"/><!-- 2. Bezirk -->
            <!-- ... -->
        </item>
        <item id="pmb51"><!-- 1. Bezirk -->
            <contains id="pmb123"/><!-- Café Central -->
            <!-- ... -->
        </item>
    </list>
</root>
```

## Integration in andere Projekte

Das Skript ist vollständig eigenständig und kann in anderen Projekten verwendet werden:

1. Kopiere `generate_partOf.py` in dein Projekt
2. Installiere die Abhängigkeiten (`requests`, Java, Saxon)
3. Führe das Skript aus

## Parameter

- `--csv-url`: URL zur PMB relations.csv (Standard: PMB-Server)
- `--output-dir`: Ausgabeverzeichnis (Standard: `./output`)
- `--saxon-jar`: Pfad zur Saxon JAR-Datei (Standard: `./saxon/saxon-he-12.5.jar`)
- `--keep-temp`: Temporäre Dateien nicht löschen (für Debugging)