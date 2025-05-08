# page2tei

## I -> Transkribus-Export

- Export des Transkribus-Dokuments als PAGE 2013 nach "transkribus-export"
    - ohne weiteres Unterverzeichnis speichern, also drei Objekte: metadata.xml, mets.xml und page-folder


## II Einstellungen der Export-Parameter
in der Datei import-parameter.xml ein neues parameter-set anlegen

## II -> mets-transformation starten 
    
sie verarbeitet mets.xml mit:
  
  - 1_mets.xsl
  - 2_mets.xsl
  - 3_mets_split-files.xsl
    
so dass danach die neuen dateien im unterordner temp sind

## III - temp/*.xml (alle neuen Dateien verarbeiten)

    - 4_strip-letter.xsl
    - 5_create-paragraphs.xsl
    - 6_combine-closer-opener.xsl

## Code

The original page2tei-transformation is from @dariok with contributions from @tboenig, @peterstadler and @tillgrallert.

## Adaptions (and everything else)
- @laurauntner
- @mepherl
