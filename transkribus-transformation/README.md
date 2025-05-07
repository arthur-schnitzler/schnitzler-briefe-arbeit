# page2tei

## I -> Transkribus-Export

- Export des Transkribus-Dokuments als PAGE nach "trans-out"
    - ohne weiteres Unterverzeichnis speichern, also drei Objekte: metadata.xml, mets.xml und page-folder

## II -> page2tei-1-Transformation (trans-out/mets.xml)

- Transformation der mets-Datei mit page2tei-0.xsl (Ausgabedatei: ${currentFileURL})

- Transformation der mets-Datei mit letter-tags-1.xsl (Ausgabedatei: ${currentFileURL})

- Transformation der mets-Datei mit letter-tags-2.xsl (Ausgabedatei: ${currentFileURL})

- Transformation der mets-Datei mit letter-tags-3.xsl (Ausgabedatei: ${currentFileURL})

- Transformation der mets-Datei mit letter-tags-4.xsl (Ausgabedatei: ${currentFileURL})

- Transformation der mets-Datei mit replace_seite-esc-lb-continued.xsl (Ausgabedatei: ${currentFileURL})

## III -> page2tei-2-Transformation (trans-out/mets.xml)

- Transformation der mets-Datei mit split-files.xsl (Ausgabedatei: ${pd}/editions/Untitled.xml)
    - Muss manuell an Jahrgang, involvierte Personen etc. angepasst werden

## IV - page2tei-3-Transformation (alle neuen Dateien in editions markieren)

- Transformation der neuen XML-Dateien mit strip-letter.xsl (Ausgabedatei: ${currentFileURL})

- Transformation der neuen XML-Dateien mit p-correction1.xsl (Ausgabedatei: ${currentFileURL})

- Transformation der neuen XML-Dateien mit p-correction2.xsl (Ausgabedatei: ${currentFileURL})

- Transformation der neuen XML-Dateien mit de-escape.xsl (Ausgabedatei: ${currentFileURL})

## V - back-element-hinzufügen (alle neuen Dateien in editions markieren)

- Transformation der neuen xml-Dateien mit back-element-hinzufügen-Transformation

## Code

The original page2tei-transformation is from @dariok with contributions from @tboenig, @peterstadler and @tillgrallert.

## Adaptions (and everything else)
- @laurauntner
- @mepherl
