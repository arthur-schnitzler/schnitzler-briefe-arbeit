# Anweisung: kritisches Lektorat eines einzelnen Briefes

Diese Anweisung ist die Arbeitsgrundlage für die inhaltliche Prüfung einer
Briefdatei (`editions/L#####.xml`) der Edition *Arthur Schnitzler: Briefwechsel
mit Autorinnen und Autoren*. Sie ist bewusst so geschrieben, dass sie von jedem
hinreichend leistungsfähigen Sprachmodell (oder von einer Person) ohne
Zusatzwissen abgearbeitet werden kann. Alles, was für die Beurteilung nötig ist,
steht hier oder im maschinellen Prüfbericht.

**Sprache der Ausgabe: Deutsch.**

---

## 0 Voraussetzung: maschineller Prüfbericht

Vor der Lektüre wird der maschinelle Bericht erzeugt:

```
python3 pruefung/pruefe_brief.py L04318 --out pruefung/berichte/L04318.md
```

Der Bericht enthält Kopfdaten, die maschinellen Befunde (nach Bereich und
Schwere sortiert), den Brieftext im Klartext, alle Herausgeberkommentare und
eine Tabelle der datierten Verweise. Er ersetzt die Lektüre der XML-Datei
**nicht**: Auszeichnungsfehler sind nur am Roh-XML zu erkennen.

---

## 1 Arbeitsschritte

1. **Prüfbericht lesen.** Jeden dort gemeldeten Befund am Roh-XML verifizieren.
   Maschinelle Befunde sind Verdachtsmomente, keine Urteile: die häufigsten
   Fehlalarme sind seltene, aber korrekte Wörter, originale Wiederholungen des
   Schreibers und historische Schreibungen.
2. **XML vollständig lesen** – Header (`titleStmt`, `correspDesc`, `sourceDesc`),
   `body` und alle Anmerkungen. Das `back`-Element (automatisch aus der PMB
   erzeugte Registerdaten) wird **nicht** geprüft, mit einer Ausnahme:
   Werk-/Personentitel, die im Kommentar sichtbar werden (rs-Anzeigetexte).
3. **Brieftext kritisch lesen** – Abschnitt 2 dieser Anweisung.
4. **Herausgebertext kritisch lesen** – Abschnitt 3.
5. **Datierung, Verweise, Metadaten prüfen** – Abschnitt 4.
6. **Befundliste ausgeben** – Abschnitt 6, im dort vorgeschriebenen Format.

Grundregeln:

- **Nichts erfinden.** Jeder Befund muss durch eine Stelle im XML belegbar sein;
  Zitate aus der Datei buchstabengetreu übernehmen.
- **Am Roh-XML verifizieren.** Was wie ein Fehler aussieht, ist oft ein Artefakt
  der Darstellung (Elementgrenzen, leere `ref`-Elemente, `<c>`-Sonderzeichen).
- **Sachaussagen prüfen, nicht raten.** Wo externes Wissen nötig ist (Daten,
  Titel, Namen, Übersetzungen), entweder aus dem Korpus belegen (andere Briefe,
  `indices/list*.xml`) oder ausdrücklich als Prüffall kennzeichnen.
- **Lieber ein Prüffall zu viel als ein verschwiegener Fehler**, aber jeder
  Befund braucht eine Begründung in einem Satz.

---

## 2 Brieftext: worauf zu achten ist

Der Brieftext ist diplomatisch transkribiert. Historische Orthografie ist
**kein Fehler** (Lang-ſ, »daß«, »thun«, »Litteratur«, »Cravate«, »iſt«,
französische/englische Passagen, Abkürzungen des Schreibers). Gesucht sind
Transkriptionsfehler und Verschreiber, die eine Anmerkung erfordern.

### 2.1 Verlesungsklassen (Transkribus/Kurrent)

| Klasse | Beispiele | Erkennungsmerkmal |
|---|---|---|
| **ſ statt f** | »ſreue« (freue), »ſür« (für), »ſallen« (fallen) | im Deutschen unmögliche Lautfolge |
| **f statt ſ** | »ift« (iſt), »Kunft« (Kunſt), »zu Haufe« (Hauſe), »haft« (haſt) | Wort ergibt im Kontext keinen Sinn |
| **r-Ausfall** | »vowärts«, »nigends«, »ergeifend«, »amer Teufel«, »genzenlos« | ein r fehlt |
| **rn → m** | »Ländem« (Ländern), »übemimmt« (übernimmt) | typisch für Maschinschrift |
| **t-Ausfall** | »Viertelſunde«, »Forsetzungen«, »enziffern«, »iſ« | ein t fehlt |
| **Gemination** | »zuſammmen«, »kannnte«, »Himmmel« | drei gleiche Buchstaben (aus aufgelöstem Geminationsstrich) |
| **Buchstabendreher** | »exisitirt«, »Crataven«, »Arhtur« | |
| **ſ + s doppelt** | »Anſspruch«, »langſsam«, »fortzuſsetzen« | |
| **Silbendoppelung** | »unverrichteteter«, »herzlichlich«, »entgegegen« | |

### 2.2 Weitere Auffälligkeiten im Brieftext

- **Wortdopplungen** (»mit mit«, »und und«). Zu entscheiden ist: Dittografie des
  Schreibers (dann ggf. Anmerkung), rhetorische Wiederholung (»ſehr ſehr«,
  »viele viele« – meist original, kein Befund) oder Transkriptionsversehen.
  Häufungen in einer Datei sprechen für ein Transkriptionsproblem.
- **Grammatisch unmögliche Formen**: »Ich bediene mich Wörter eines Vergleichs«,
  »wirkte … wirken«, »Mein verehrtes Freund«, »seinem Brüder«, »ihr Länge«.
  Meist Verlesung eines ähnlich aussehenden Wortes – Lesevorschlag angeben.
- **Adressen und Datumszeilen**: Bezirksnummern (die Spöttelgasse liegt im
  XVIII., die Ottakringer Straße im XVI. Bezirk), Hausnummern
  (Hasenauerstraße 59, Sternwartestraße 71), Ortsnamen, Jahreszahlen
  (»1. 7. 109« für »901«). Abweichungen entweder als Verschreiber des Schreibers
  mit Anmerkung ausweisen oder als Transkriptionsfehler korrigieren. Kommt
  dieselbe Abweichung bei demselben Schreiber mehrfach vor, ist sie
  wahrscheinlich authentisch (Stichprobe genügt).
- **Unterschrift** ↔ Absender: passt der Name (`<signed>`) zum Absender im
  `correspDesc`?
- **Unpaarige Anführungszeichen** »…«, ›…‹ und Klammern. Kann originalgetreu
  sein; prüfen, ob ein Zeichen bei der Transkription verlorenging.
- **Reste der Transkription**: einzelne Zeichen wie »‹«« in der Unterschrift,
  Punkte mitten im Satz, doppelte Kommata, weiche Trennzeichen (U+00AD).
- **Zeichensetzungs- und Auszeichnungsfehler**: fehlendes Leerzeichen vor einem
  Element (»vonSonntag«), Wörter, die durch die Auszeichnung getrennt werden
  (»Hofrät in«), ein Adjektiv, das fälschlich auf einen Ort verlinkt ist
  (`die guten <rs ref="#pmb50">Wien</rs>er`).

Wenn eine auffällige Form im Brieftext **keine** `note type="textConst"` hat,
ist immer zu vermerken, ob eine Anmerkung fehlt oder die Lesung zu korrigieren
ist. Der Standardsatz dafür lautet: *Prüffall Faksimile*.

---

## 3 Herausgebertext: worauf zu achten ist

Herausgebertext sind `note type="commentary"` (im Bericht als K1, K2 … geführt),
`note type="textConst"`, `supplied type="image-description"` und die Titelangabe
im Header. Er steht in **heutiger Rechtschreibung** und in gepflegtem
Standarddeutsch; hier gilt jede Abweichung als Fehler.

- **Tippfehler**: »identifizert«, »datuert«, »vebrachte«, »erscheinenenden«,
  »exisitieren«, »kondilieren«, »annulieren«, »postitive«, »Erwähung«,
  »Nachlas«, »Inkongito«, »Vistenkarte«, »verwirkklicht«, »for« statt »für«.
- **Wort- und Wortgruppendopplungen**: »von von«, »das am am«, »Die Die
  Premiere«, »seine Frau seine Frau«, »am Volkstheater im Volkstheater«,
  »Es dürfte sich es sich«. Häufig entsteht die Dopplung an der Grenze zwischen
  Rahmentext und rs-Anzeigetext bzw. Zitatanfang.
- **Grammatik**: Kasus- und Kongruenzfehler (»des Rittmeister von Schramms«,
  »einer spontane Beileidsbekundung«, »hatten er«, »ein Brief« statt »einen
  Brief«), fehlende Hilfsverben (»stattgefunden«, »geladen«, »herangezogen
  werden«), verunglückte Partizipial- und Relativkonstruktionen, hängende
  Bezüge, abgebrochene Sätze, doppelte Präpositionen (»am im«), Titel ohne
  Deklination (»in der Neue Freie Presse«).
- **Alte Rechtschreibung**, die im Rahmentext stehen geblieben ist: »läßt«,
  »anläßlich«, »daß«, ebenso Schweizer »ss« (»abschliessende«). In **Zitaten**
  ist die historische Schreibung korrekt und bleibt unangetastet.
- **Sachfehler**: falsche Jahres-, Monats- oder Tagesangaben (die häufigste
  Fehlerklasse überhaupt), falsche Zählungen (»zum 20. Mal« statt 21.), falsche
  Titel (»Casanovas Heimkehr« statt »Heimfahrt«, »Lieutnant Gustl«), falsche
  Namensformen (»Gehart Hauptmann«, »Giradi«, »Andrian-Werbung«, »Terriet«),
  falsche Zuschreibungen (Zitat aus »Die Piccolomini«, nicht »Wallensteins
  Tod«), falsche Übersetzungen (»par dépit« ≠ »aus Neid«; »z. E.« = »zum
  Exempel«; »p. r.« = »pour remercier«), falsche Sachauskünfte (Réaumur-Skala:
  Gefrierpunkt, nicht Taupunkt).
- **Innere Widersprüche**: Abreise- und Rückreisedatum identisch; »zehn Tage
  später« mit demselben Datum; »Zwischen 5. 8. 1899 und 5. 8. 1899«; ein
  Kommentar widerspricht einem Kommentar in einer anderen Datei zur selben
  Sache; die Datierung des Briefes widerspricht dem, was der Kommentar sagt.
  **Rechne Datumsangaben nach** (Wochentage, Jubiläen, Zeitspannen,
  Jahrgangszählungen von Zeitungen).
- **Formalia**: Anmerkung endet ohne Punkt oder mitten im Satz; Übersetzungen
  ohne die übliche Sprachangabe (»französisch: …«); Editionskonvention beim
  Datum (»17. 1. 1912«, nicht »17. 1.1912« oder »17. 01. 1912«); doppelte
  Signatur in bibliografischen Angaben; deutsche Anführungszeichen „…“ statt
  »…« bzw. ›…‹; Anführungsebenen, die nicht aufgehen (»…‹).
- **Unfertiges**: Platzhalter »XXXX«, redaktionelle Arbeitsnotizen im
  publizierten Text (»XXXX CHECK OB ABSAGE«), leere Verweise (»[→]«,
  `target=""`), fehlende Seitenzahlen (»S. XXXX«), offene Fragen im Text
  (»handschriftlich gestrichen oder unterstrichen?«).
  Ausgenommen: `<idno type="handle">XXXX</idno>` im Header – der Handle wird
  erst bei der Publikation vergeben.

---

## 4 Datierung, Verweise, Metadaten

- **Datierung**: Stimmen `title level="a"`, `correspAction/date/@when` und die
  Datumszeile im Brief überein? Weicht die Datumszeile ab (Verschreiber des
  Schreibers, Poststempeldatierung), muss es eine erläuternde Anmerkung geben –
  fehlt sie, ist das ein Befund.
- **`<date when="…">Anzeigetext</date>`**: Attribut und sichtbarer Text müssen
  dasselbe Datum nennen.
- **Tagebuch- und Chronik-Verweise** (`ref type="schnitzler-tagebuch"`,
  `"wienerschnitzler"`, `"schnitzler-kultur"`, `"schnitzler-chronik"`):
  Das Zieldatum muss zum Sachverhalt passen. Zifferndreher im Jahr
  (`1902-02-28` statt `1903-02-28`) und Monatsfehler sind häufig. Die Tabelle
  »Datumsverweise« im Prüfbericht zeigt den Abstand zum Briefdatum.
- **Briefverweise** (`ref type="schnitzler-briefe"`): Zeigt ein Verweis auf den
  Brief selbst, ist er falsch (gemeint ist fast immer der vorangehende oder
  folgende Brief). Existiert die Zieldatei?
- **rs-Anzeigetexte**: Weicht der sichtbare Text von der Namensform im
  PMB-Datensatz ab, ist entweder der Anzeigetext ein Tippfehler oder der
  PMB-Datensatz selbst falsch (dann in der PMB korrigieren und das im Befund
  vermerken).
- **Attribute**: `subtype="cf"`/`"see"` (die Großschreibung `Cf`/`See` kommt im
  Korpus vor, ist aber uneinheitlich); `source=` statt `subtype=` ist ein
  Fehler; doppeltes Genitiv-s an der rs-Grenze (`…s</rs>s`).
- **Header beim Verschieben aus `temp/`**: leere Attribute (`when=""`,
  `quantity=""`, `medium=""`), Titel mit »XXXX«, `revisionDesc/@status`.

---

## 5 Was ausdrücklich **kein** Befund ist

- Historische Orthografie und Grammatik im Brieftext, Lang-ſ, Gemination,
  fremdsprachige Passagen, Abkürzungen, eigenwillige Zeichensetzung.
- Historische Schreibung **innerhalb von Zitaten** im Herausgebertext.
- Rhetorische Wiederholungen (»ſehr ſehr«, »viele viele«, »ganz ganz einſam«).
- Korrekte Dreifachbuchstaben in Komposita (Schlussszene, Schifffahrt).
- Namen, die tatsächlich doppelt lauten (Roda Roda, Baden-Baden).
- Das `back`-Element und die dort automatisch eingespielten PMB-Daten
  (Ausnahme: sichtbare Werk- und Personentitel, siehe oben).
- `<idno type="handle">XXXX</idno>`.
- Sechsstellige Ziel-IDs in `ref type="schnitzler-bahr"` (L0414xx–L0416xx) –
  die gehören zur Schnitzler/Bahr-Edition und sind korrekt.

---

## 6 Ausgabeformat

Die Befunde werden als Markdown-Liste ausgegeben – ein Listenpunkt pro Befund,
in der Reihenfolge: verifizierte Fehler zuerst, danach Prüffälle. Das Format
entspricht dem von `LEKTORAT.md` (Abschnitt 4), damit die Liste dort angehängt
und mit `python3 lektorat.py` abgearbeitet werden kann:

```markdown
## Lektorat L04318 (Datum)

- **L04318, K3 (Kommentar)**: »die Schnitzler Jahre später in dem Drama
  **Professor Berhardi** aufgehen ließ« – rs-Anzeigetext mit fehlendem n:
  »Professor Bernhardi« (im PMB-Datensatz pmb30203 korrekt). Verifiziert.
- **L04318 (Brieftext)**: »der zu eruiren **fucht**« – ſ/f-Verlesung, richtig
  »ſucht«; keine textConst-Anmerkung. Prüffall Faksimile.
```

Regeln für die Einträge:

1. Beginn mit **Dateiname** und Fundstelle (`K3 (Kommentar)`, `(Brieftext)`,
   `(Adresse)`, `(Datierung)`, `T1 (textConst)`).
2. Die beanstandete Stelle wörtlich zitieren, das fragliche Wort **fett**.
3. Korrekturvorschlag oder Erklärung in einem Satz.
4. Abschluss mit dem Status:
   - **Verifiziert.** – am XML belegt und eindeutig falsch (Tippfehler,
     Grammatik, innerer Widerspruch, nachrechenbares Datum).
   - **Prüffall Faksimile.** – Lesung muss an der Handschrift/Vorlage geprüft
     werden (Verschreiber des Schreibers oder Transkriptionsfehler?).
   - **Prüffall.** – Sachfrage, die externe Recherche erfordert.
5. Mehrere Befunde in derselben Anmerkung dürfen zu einem Punkt zusammengefasst
   werden.
6. Gibt es nichts zu beanstanden, wird das ausdrücklich vermerkt:
   `- **L04318**: keine Beanstandungen.`

Am Ende der Liste steht eine Zeile mit der Zusammenfassung:

```
Geprüft: L04318 · 3 verifizierte Fehler, 5 Prüffälle · maschineller Bericht: pruefung/berichte/L04318.md
```
