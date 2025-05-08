<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei" version="3.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <xsl:message>DEBUG (mets.xml Verarbeitung): Haupt-Template (match="/") gestartet für
            Eingabedokument: <xsl:value-of select="document-uri(.)"/></xsl:message>
        <xsl:call-template name="process_temp_files"/>
        <xsl:message>DEBUG (mets.xml Verarbeitung): Kopiere Haupt-Eingabedokument
            durch.</xsl:message>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
        <xsl:message>DEBUG (mets.xml Verarbeitung): Haupt-Template (match="/")
            beendet.</xsl:message>
    </xsl:template>
    <xsl:template name="process_temp_files">
        <xsl:message>DEBUG (temp Dateien): Template 'process_temp_files' gestartet.</xsl:message>
        <xsl:message>DEBUG (temp Dateien): Aktuelles statisches Basis-URI (XSLT-Pfad?):
                <xsl:value-of select="static-base-uri()"/></xsl:message>
        <xsl:variable name="collection-uri-string" select="'../temp/?select=*.xml;on-error=warning'"/>
        <xsl:message>DEBUG (temp Dateien): String für Collection-URI: '<xsl:value-of
                select="$collection-uri-string"/>'</xsl:message>
        <xsl:message>DEBUG (temp Dateien): Voll aufgelöster Pfad für Collection (Versuch):
                <xsl:value-of select="resolve-uri($collection-uri-string, static-base-uri())"
            /></xsl:message>
        <xsl:variable name="files-in-temp" select="collection($collection-uri-string)"/>
        <xsl:message>DEBUG (temp Dateien): Anzahl gefundener Dateien in '<xsl:value-of
                select="$collection-uri-string"/>': <xsl:value-of select="count($files-in-temp)"
            /></xsl:message>
        <xsl:if test="not(exists($files-in-temp))">
            <xsl:message terminate="no">WARNUNG (temp Dateien): Keine Dateien in '<xsl:value-of
                    select="$collection-uri-string"/>' gefunden oder Fehler beim Laden der Sammlung.
                Überprüfen Sie den Pfad und die Konsolenausgabe auf frühere Fehler/Warnungen des
                Prozessors bezüglich der Sammlung. Voll aufgelöster Pfad für Collection (Basis war
                    <xsl:value-of select="static-base-uri()"/>): <xsl:value-of
                    select="resolve-uri($collection-uri-string, static-base-uri())"/> Mögliche
                Ursache: Der XSLT-Prozessor führt dies nicht im Ordner 'transkribus-transformation'
                aus oder der Unterordner 'temp' existiert dort nicht. </xsl:message>
        </xsl:if>
        <xsl:for-each select="$files-in-temp">
            <xsl:variable name="doc-name" select="concat(//tei:TEI/@xml:id, '.xml')"/>
            <xsl:result-document href="../../temp/{$doc-name}">
                <xsl:apply-templates/>
            </xsl:result-document>
        </xsl:for-each>
        <xsl:message>DEBUG (temp Dateien): Template 'process_temp_files' beendet.</xsl:message>
    </xsl:template>
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:template match="tei:letter | tei:letter-begin" priority="5">
        <xsl:message>DEBUG (Inhaltverarbeitung für <xsl:value-of select="document-uri(root(.))"/>):
            Spezifisches Template für &lt;<xsl:value-of select="name(.)"/>&gt; angewendet. Inhalt
            wird entpackt.</xsl:message>
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="tei:page[@type = 'letter-begin']">
        <xsl:apply-templates/>
    </xsl:template>
</xsl:stylesheet>
