<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mam="martinfunktion" exclude-result-prefixes="#all" version="3.0">
    <xsl:output method="xml" indent="no" encoding="UTF-8"/>
    <!-- Identity template: copy everything by default -->
    <xsl:mode on-no-match="shallow-copy"/>

    <!--
        Für Briefe, deren Datum laut Beleg (z. B. Poststempel) nicht sicher
        einem bestimmten Tag zugeordnet werden kann, sondern nur auf zwei
        aufeinanderfolgende Tage eingegrenzt ist (±1 Tag Unsicherheit).

        Auf die geöffnete Brief-Datei angewendet, ändert diese Transformation:

        1. .../titleStmt/title[@level='a']: das Datum am Ende des Titels
           bekommt die eckige-Klammer-"oder"-Notation, z. B. aus
           "..., 22. 5. 1910" wird "..., [21. oder 22]. 5. 1910"
           (bei Monatswechsel: "..., [31. 3. oder 1. 4.]. 1910").

        2. .../correspDesc/correspAction[@type='sent']/date: der Anzeigetext
           bekommt dieselbe Notation, und statt @when stehen @notBefore
           (Vortag) und @notAfter (bisheriger @when-Wert).

        Der Tag vor dem bisherigen Datum wird dabei per Datumsarithmetik
        berechnet (löst Monats- und Jahreswechsel/Schaltjahre korrekt auf).
    -->

    <!-- 1. Titel in titleStmt -->
    <xsl:template match="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level = 'a']">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:analyze-string select="string(.)" regex="(\d{{1,2}})\.\p{{Zs}}(\d{{1,2}})\.\p{{Zs}}(\d{{4}})$">
                <xsl:matching-substring>
                    <xsl:value-of select="mam:datum-unsicher(
                        xs:integer(regex-group(1)),
                        xs:integer(regex-group(2)),
                        xs:integer(regex-group(3)))"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:copy>
    </xsl:template>

    <!-- 2. Datum in correspAction[@type='sent'] -->
    <xsl:template
        match="tei:teiHeader/tei:profileDesc/tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date[@when]">
        <xsl:variable name="wenn" as="xs:date" select="xs:date(@when)"/>
        <xsl:variable name="vortag" as="xs:date" select="$wenn - xs:dayTimeDuration('P1D')"/>
        <xsl:copy>
            <xsl:apply-templates select="@*[not(local-name() = 'when')]"/>
            <xsl:attribute name="notBefore" select="format-date($vortag, '[Y0001]-[M01]-[D01]')"/>
            <xsl:attribute name="notAfter" select="format-date($wenn, '[Y0001]-[M01]-[D01]')"/>
            <xsl:analyze-string select="string(.)" regex="(\d{{1,2}})\.\p{{Zs}}(\d{{1,2}})\.\p{{Zs}}(\d{{4}})$">
                <xsl:matching-substring>
                    <xsl:value-of select="mam:datum-unsicher(
                        xs:integer(regex-group(1)),
                        xs:integer(regex-group(2)),
                        xs:integer(regex-group(3)))"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:copy>
    </xsl:template>

    <!--
        Baut aus Tag/Monat/Jahr eines gesicherten Datums die "oder"-Notation
        für den Vortag. Zwischenräume sind immer ein geschütztes Leerzeichen
        (Editionskonvention), außer unmittelbar vor/nach "oder" – dort steht
        ein normales Leerzeichen, damit dort ein Zeilenumbruch möglich ist.
    -->
    <xsl:function name="mam:datum-unsicher" as="xs:string">
        <xsl:param name="tag" as="xs:integer"/>
        <xsl:param name="monat" as="xs:integer"/>
        <xsl:param name="jahr" as="xs:integer"/>

        <xsl:variable name="nbsp" as="xs:string" select="'&#160;'"/>

        <xsl:variable name="original" as="xs:date"
            select="xs:date(concat(string($jahr), '-', format-number($monat, '00'), '-', format-number($tag, '00')))"/>
        <xsl:variable name="vortag" as="xs:date" select="$original - xs:dayTimeDuration('P1D')"/>
        <xsl:variable name="vortag-tag" as="xs:integer" select="xs:integer(day-from-date($vortag))"/>
        <xsl:variable name="vortag-monat" as="xs:integer" select="xs:integer(month-from-date($vortag))"/>
        <xsl:variable name="vortag-jahr" as="xs:integer" select="xs:integer(year-from-date($vortag))"/>

        <xsl:choose>
            <!-- Vortag liegt im selben Monat -->
            <xsl:when test="$vortag-jahr = $jahr and $vortag-monat = $monat">
                <xsl:value-of
                    select="concat('[', $vortag-tag, '.', ' ', 'oder', ' ', $tag, '].', $nbsp, $monat, '.', $nbsp, $jahr)"/>
            </xsl:when>
            <!-- Monatswechsel, gleiches Jahr -->
            <xsl:when test="$vortag-jahr = $jahr">
                <xsl:value-of
                    select="concat('[', $vortag-tag, '.', $nbsp, $vortag-monat, '.', ' ', 'oder', ' ', $tag, '.', $nbsp, $monat, '.].', $nbsp, $jahr)"/>
            </xsl:when>
            <!-- Jahreswechsel (31.12. / 1.1.) -->
            <xsl:otherwise>
                <xsl:value-of
                    select="concat('[', $vortag-tag, '.', $nbsp, $vortag-monat, '.', $nbsp, $vortag-jahr, ' ', 'oder', ' ', $tag, '.', $nbsp, $monat, '.', $nbsp, $jahr, ']')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
