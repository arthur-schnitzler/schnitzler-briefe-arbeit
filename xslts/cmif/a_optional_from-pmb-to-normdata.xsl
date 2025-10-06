<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <!-- Das holt die GND-Nummer aus der PMB -->
    <xsl:param name="listperson" select="document('../../indices/listperson.xml')"/>
    <xsl:key name="person-match" match="//tei:text[1]/tei:body[1]/tei:listPerson[1]/tei:person"
        use="@xml:id"/>
    <xsl:param name="listplace" select="document('../../indices/listplace.xml')"/>
    <xsl:key name="place-match" match="//tei:text[1]/tei:body[1]/tei:listPlace[1]/tei:place"
        use="@xml:id"/>
    <xsl:template
        match="tei:persName/@ref[contains(., 'pmb')] | tei:rs[@type = 'person']/@ref[contains(., 'pmb')]">
        <xsl:variable name="nummeri"
            select="replace(replace(replace(., '#', ''), 'pmb', ''), '/', '')"/>
        <!-- Variante, um die Daten aus der PMB zu holen: -->
        <xsl:variable name="eintragi"
            select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/person/', $nummeri))"
            as="xs:string"/>
        <xsl:attribute name="ref">
            <xsl:choose>
                <xsl:when test="$nummeri = '2121'">
                    <xsl:text>https://d-nb.info/gnd/118609807</xsl:text>
                </xsl:when>
                <xsl:when
                    test="key('person-match', concat('pmb', $nummeri), $listperson)/tei:idno[@type = 'gnd' or @subtype = 'gnd'][1]">
                    <xsl:value-of
                        select="key('person-match', concat('pmb', $nummeri), $listperson)/tei:idno[@type = 'gnd' or @subtype = 'gnd'][1]"
                    />
                </xsl:when>
                <xsl:when
                    test="key('person-match', concat('pmb', $nummeri), $listperson)/tei:idno[@type = 'wikidata' or @subtype = 'wikidata'][1]">
                    <xsl:value-of
                        select="key('person-match', concat('pmb', $nummeri), $listperson)/tei:idno[@type = 'wikidata' or @subtype = 'wikidata'][1]"
                    />
                </xsl:when>
                <xsl:when test="doc-available($eintragi)">
                    <xsl:copy-of select="document($eintragi)/descendant::idno[@subtype = 'gnd'][1]"
                        copy-namespaces="no"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="concat('https://pmb.acdh.oeaw.ac.at/entity/', $nummeri, '/')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <!-- Das holt die Geonames-Nummer aus der PMB -->
    <xsl:template
        match="tei:placeName/@ref[contains(., 'pmb')] | tei:rs[@type = 'place']/@ref[contains(., 'pmb')]">
        <xsl:variable name="nummeri"
            select="replace(replace(replace(., '#', ''), 'pmb', ''), '/', '')"/>
        <xsl:variable name="eintragi"
            select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/place/', $nummeri))"
            as="xs:string"/>
        <xsl:attribute name="ref">
            <xsl:choose>
                <xsl:when test="$nummeri = '50'">
                    <xsl:text>https://sws.geonames.org/2761369/</xsl:text>
                </xsl:when>
                <xsl:when
                    test="key('place-match', concat('pmb', $nummeri), $listplace)/tei:idno[@type = 'geonames' or @subtype = 'geonames'][1]">
                    <xsl:value-of
                        select="key('place-match', concat('pmb', $nummeri), $listplace)/tei:idno[@type = 'geonames' or @subtype = 'geonames'][1]"
                    />
                </xsl:when>
                <xsl:when
                    test="key('place-match', concat('pmb', $nummeri), $listplace)/tei:idno[@type = 'gnd' or @subtype = 'gnd'][1]">
                    <xsl:value-of
                        select="key('place-match', concat('pmb', $nummeri), $listplace)/tei:idno[@type = 'gnd' or @subtype = 'gnd'][1]"
                    />
                </xsl:when>
                <xsl:when
                    test="key('place-match', concat('pmb', $nummeri), $listplace)/tei:idno[@type = 'wikidata' or @subtype = 'wikidata'][1]">
                    <xsl:value-of
                        select="key('place-match', concat('pmb', $nummeri), $listplace)/tei:idno[@type = 'wikidata' or @subtype = 'wikidata'][1]"
                    />
                </xsl:when>
                <xsl:when test="doc-available($eintragi)">
                    <xsl:copy-of
                        select="document($eintragi)/descendant::idno[@subtype = 'geonames'][1]"
                        copy-namespaces="no"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="concat('https://pmb.acdh.oeaw.ac.at/entity/', $nummeri, '/')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="tei:correspContext"/>
</xsl:stylesheet>
