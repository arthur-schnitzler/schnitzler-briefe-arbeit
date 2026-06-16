<?xml version="1.0" encoding="UTF-8"?>
<!-- Kuerzt die PMB-Listen auf wenige relevante Informationen, damit die
     Dateien kleiner und schneller werden. Pro Eintrag werden die Attribute
     (xml:id, ggf. Datum) sowie die unten gewaehlten Kind-Elemente behalten,
     alles andere (idno, listBibl, desc, occupation usw.) entfernt. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei"
    version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="no"/>

    <!-- Personen: persName[1], birth, death -->
    <xsl:template match="tei:person">
        <person>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="tei:persName[1] | tei:birth | tei:death"/>
        </person>
    </xsl:template>

    <!-- Werke (nur die Eintraege der obersten listBibl): title, author -->
    <xsl:template match="tei:body/tei:listBibl/tei:bibl">
        <bibl>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="tei:title | tei:author"/>
        </bibl>
    </xsl:template>

    <!-- Orte: placeName, location -->
    <xsl:template match="tei:place">
        <place>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="tei:placeName | tei:location"/>
        </place>
    </xsl:template>

    <!-- Organisationen: orgName, location -->
    <xsl:template match="tei:org">
        <org>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="tei:orgName | tei:location"/>
        </org>
    </xsl:template>

    <!-- Ereignisse: eventName und der Ort (listPlace mit placeName + location).
         Ereignisse haben kein direktes tei:location; der Ort steckt in
         listPlace/place/location. -->
    <xsl:template match="tei:event">
        <event>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="tei:eventName | tei:listPlace"/>
        </event>
    </xsl:template>

</xsl:stylesheet>
