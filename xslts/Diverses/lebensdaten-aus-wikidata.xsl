<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mam="whatever" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <!-- Das hier nimmt eine q nummer und gibt den API-Abfrage-String zurück -->
    <xsl:function name="mam:get-wikidata-string" as="xs:string?">
        <xsl:param name="wikidata-entry" as="xs:string"/>
        <xsl:variable name="wikidata-entity">
            <xsl:choose>
                <xsl:when test="starts-with($wikidata-entry, 'Q')">
                    <xsl:value-of select="normalize-space($wikidata-entry)"/>
                </xsl:when>
                <xsl:when test="starts-with($wikidata-entry, 'https://www.wikidata.org/entity/')">
                    <xsl:value-of
                        select="normalize-space(substring-after($wikidata-entry, 'https://www.wikidata.org/entity/'))"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="normalize-space(concat('Q', tokenize($wikidata-entry, 'Q')[last()]))"
                    />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of
            select="concat('https://www.wikidata.org/w/api.php?action=wbgetentities&amp;format=xml&amp;ids=', $wikidata-entity,'')"
        />
    </xsl:function>
    <!-- Geburtsdaten -->
    <xsl:template
        match="tei:person[tei:idno/@type = 'wikidata']/tei:birth[not(tei:date) or string-length(tei:date) = 4]">
        <xsl:element name="birth" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*"/>
            <xsl:variable name="wikidata-entry"
                select="parent::tei:person/tei:idno[@type = 'wikidata'][1]" as="xs:string"/>
            <xsl:variable name="get-string" as="xs:string"
                select="mam:get-wikidata-string($wikidata-entry)"> </xsl:variable>
            <!-- 1. Datum -->
            <xsl:choose>
                <xsl:when
                    test="document($get-string)/descendant::property[@id = 'P569']/claim[1]/mainsnak[1]/datavalue[1]/value[1]/@time">
                    <xsl:element name="date" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:variable name="datumZeit"
                            select="document($get-string)/descendant::property[@id = 'P569']/claim[1]/mainsnak[1]/datavalue[1]/value[1]/@time"/>
                        <xsl:variable name="datum">
                            <xsl:choose>
                                <xsl:when
                                    test="contains($datumZeit, 'T') and contains($datumZeit, '-00-00')">
                                    <xsl:value-of select="substring-before($datumZeit, '-00-00T')"/>
                                </xsl:when>
                                <xsl:when test="contains($datumZeit, 'T')">
                                    <xsl:value-of select="substring-before($datumZeit, 'T')"/>
                                </xsl:when>
                                <xsl:when test="contains($datumZeit, '-00-00')">
                                    <xsl:value-of select="substring-before($datumZeit, '-00-00')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$datumZeit"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="starts-with($datum, '+')">
                                <xsl:value-of select="substring($datum, 2)"/>
                            </xsl:when>
                            <xsl:when test="starts-with($datum, '-')">
                                <xsl:value-of
                                    select="concat(substring($datumZeit, 2), '&lt;0001-01-01&gt;')"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$datum"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="tei:date"/>
                </xsl:otherwise>
            </xsl:choose>
            <!-- 2. Geburtsort -->
            <xsl:choose>
                <xsl:when
                    test="document($get-string)/descendant::property[@id = 'P19']/claim[1]/mainsnak[1]/datavalue[1]/value[1]/@id">
                    <xsl:variable name="ortsuri-wikidata"
                        select="document($get-string)/descendant::property[@id = 'P19']/claim[1]/mainsnak[1]/datavalue[1]/value[1]/@id"/>
                    <xsl:element name="placeName" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:choose>
                            <xsl:when test="$ortsuri-wikidata != ''">
                                <xsl:attribute name="type">
                                    <xsl:text>wikidata</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="ref">
                                    <xsl:value-of select="$ortsuri-wikidata"/>
                                </xsl:attribute>
                                <xsl:value-of
                                    select="document(mam:get-wikidata-string($ortsuri-wikidata))/api[1]/entities[1]/entity[1]/labels[1]/label[@language = 'de']/@value"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$ortsuri-wikidata"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="tei:placeName"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    <!-- TOD -->
    <xsl:template
        match="tei:person[tei:idno/@type = 'wikidata']/tei:death[not(tei:date) or string-length(tei:date) = 4]">
        <xsl:element name="death" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*"/>
            <xsl:variable name="wikidata-entry"
                select="parent::tei:person/tei:idno[@type = 'wikidata'][1]" as="xs:string"/>
            <xsl:variable name="get-string" as="xs:string"
                select="mam:get-wikidata-string($wikidata-entry)"> </xsl:variable>
            <!-- 1. Datum -->
            <xsl:choose>
                <xsl:when
                    test="document($get-string)/descendant::property[@id = 'P570']/claim[1]/mainsnak[1]/datavalue[1]/value[1]/@time">
                    <xsl:element name="date" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:variable name="datumZeit"
                            select="document($get-string)/descendant::property[@id = 'P570']/claim[1]/mainsnak[1]/datavalue[1]/value[1]/@time"/>
                        <xsl:variable name="datum">
                            <xsl:choose>
                                <xsl:when
                                    test="contains($datumZeit, 'T') and contains($datumZeit, '-00-00')">
                                    <xsl:value-of select="substring-before($datumZeit, '-00-00T')"/>
                                </xsl:when>
                                <xsl:when test="contains($datumZeit, 'T')">
                                    <xsl:value-of select="substring-before($datumZeit, 'T')"/>
                                </xsl:when>
                                <xsl:when test="contains($datumZeit, '-00-00')">
                                    <xsl:value-of select="substring-before($datumZeit, '-00-00')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$datumZeit"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="starts-with($datum, '+')">
                                <xsl:value-of select="substring($datum, 2)"/>
                            </xsl:when>
                            <xsl:when test="starts-with($datum, '-')">
                                <xsl:value-of
                                    select="concat(substring($datumZeit, 2), '&lt;0001-01-01&gt;')"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$datum"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="tei:date"/>
                </xsl:otherwise>
            </xsl:choose>
            <!-- 2. Geburtsort -->
            <xsl:choose>
                <xsl:when
                    test="document($get-string)/descendant::property[@id = 'P20']/claim[1]/mainsnak[1]/datavalue[1]/value[1]/@id">
                    <xsl:variable name="ortsuri-wikidata"
                        select="document($get-string)/descendant::property[@id = 'P20']/claim[1]/mainsnak[1]/datavalue[1]/value[1]/@id"/>
                    <xsl:element name="placeName" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:choose>
                            <xsl:when test="$ortsuri-wikidata != ''">
                                <xsl:attribute name="type">
                                    <xsl:text>wikidata</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="ref">
                                    <xsl:value-of select="$ortsuri-wikidata"/>
                                </xsl:attribute>
                                <xsl:value-of
                                    select="document(mam:get-wikidata-string($ortsuri-wikidata))/api[1]/entities[1]/entity[1]/labels[1]/label[@language = 'de']/@value"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$ortsuri-wikidata"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="tei:placeName"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    <!-- gender -->
    <xsl:template
        match="tei:person[tei:sex[@value = 'not-set'] or not(tei:sex)]/tei:idno[@type = 'wikidata']">
            <xsl:copy-of select="."/>
            <xsl:variable name="wikidata-entry" select="." as="xs:string"/>
            <xsl:choose>
                <xsl:when
                    test="document(mam:get-wikidata-string(mam:get-wikidata-string($wikidata-entry)))/descendant::property[@id = 'P21']/claim/mainsnak/datavalue/value/@id">
                    <xsl:variable name="gender"
                        select="document(mam:get-wikidata-string(mam:get-wikidata-string($wikidata-entry)))/descendant::property[@id = 'P21']/claim/mainsnak/datavalue/value/@id"/>
                    <xsl:element name="sex" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="value">
                            <xsl:choose>
                                <xsl:when test="$gender = 'Q6581097'">
                                    <xsl:text>male</xsl:text>
                                </xsl:when>
                                <xsl:when test="$gender = 'Q6581072'">
                                    <xsl:text>female</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$gender"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
            <xsl:text>
</xsl:text>
        
    </xsl:template>
</xsl:stylesheet>
