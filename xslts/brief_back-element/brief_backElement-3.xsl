<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <!-- Das hier tut nur den PMB-import etwas anpassen -->
    <xsl:template match="@when-iso">
        <xsl:attribute name="when">
            <xsl:choose>
                <xsl:when test="string-length(substring-before(., '-')) = 4">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="string-length(substring-before(., '-')) = 3">
                            <xsl:value-of select="concat('0', .)"/>
                        </xsl:when>
                        <xsl:when test="string-length(substring-before(., '-')) = 2">
                            <xsl:value-of select="concat('00', .)"/>
                        </xsl:when>
                        <xsl:when test="string-length(substring-before(., '-')) = 1">
                            <xsl:value-of select="concat('000', .)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="@notAfter-iso">
        <xsl:attribute name="notAfter">
            <xsl:choose>
                <xsl:when test="string-length(substring-before(., '-')) = 4">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="string-length(substring-before(., '-')) = 3">
                            <xsl:value-of select="concat('0', .)"/>
                        </xsl:when>
                        <xsl:when test="string-length(substring-before(., '-')) = 2">
                            <xsl:value-of select="concat('00', .)"/>
                        </xsl:when>
                        <xsl:when test="string-length(substring-before(., '-')) = 1">
                            <xsl:value-of select="concat('000', .)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="tei:date[contains(.,'&lt;')]">
        <xsl:element name="date" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="substring-before(., '&lt;')"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@notBefore-iso">
        <xsl:attribute name="notBefore">
            <xsl:choose>
                <xsl:when test="string-length(substring-before(., '-')) = 4">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="string-length(substring-before(., '-')) = 3">
                            <xsl:value-of select="concat('0', .)"/>
                        </xsl:when>
                        <xsl:when test="string-length(substring-before(., '-')) = 2">
                            <xsl:value-of select="concat('00', .)"/>
                        </xsl:when>
                        <xsl:when test="string-length(substring-before(., '-')) = 1">
                            <xsl:value-of select="concat('000', .)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="@from-iso">
        <xsl:attribute name="from">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@to-iso">
        <xsl:attribute name="to">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="@key">
        <xsl:attribute name="ref">
            <xsl:value-of select="concat('pmb', .)"/>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="tei:placeName/@ref[contains(.,'place__')]|tei:placeName/@key[contains(.,'place__')]">
        <xsl:attribute name="ref">
            <xsl:value-of select="concat('pmb', replace(.,'place__',''))"/>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="tei:back//tei:title/@type[. = 'main']"/>
    <xsl:template match="tei:back//tei:bibl/tei:author/@ref|tei:back//tei:bibl/tei:author/@key">
        <xsl:attribute name="ref">
            <xsl:choose>
                <xsl:when test="starts-with(., 'pmbperson__') or starts-with(., 'person__')">
                    <xsl:value-of select="concat('pmb', substring-after(., 'person__'))"/>
                </xsl:when>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="tei:back//tei:idno[@type = 'URL']">
        <xsl:element name="idno" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="type">
                <xsl:text>URL</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="subtype">
                <xsl:choose>
                    <xsl:when test="contains(., 'wikipedia')">
                        <xsl:text>wikipedia</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'geonames')">
                        <xsl:text>geonames</xsl:text>
                    </xsl:when>
                    <xsl:when test="starts-with(., 'https://www.')">
                        <xsl:value-of
                            select="substring-before(substring-after(., 'https://www.'), '.')"/>
                    </xsl:when>
                    <xsl:when test="starts-with(., 'http://www.')">
                        <xsl:value-of
                            select="substring-before(substring-after(., 'http://www.'), '.')"/>
                    </xsl:when>
                    <xsl:when test="starts-with(., 'https://')">
                        <xsl:value-of select="substring-before(substring-after(., 'https://'), '.')"
                        />
                    </xsl:when>
                    <xsl:when test="starts-with(., 'http://')">
                        <xsl:value-of select="substring-before(substring-after(., 'https://'), '.')"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-before(., '.')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:back//tei:listBibl[tei:bibl/@type = 'collections']"/>
    <xsl:template match="tei:back//tei:bibl/tei:note[@type = 'collections']"/>
    <xsl:template match="tei:back//tei:listBibl/tei:bibl/@xml:id">
        <xsl:attribute name="xml:id">
            <xsl:choose>
                <xsl:when test="contains(., 'work__')">
                    <xsl:value-of select="concat('pmb', substring-after(., 'work__'))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="tei:back//tei:listPerson/tei:person/@xml:id">
        <xsl:attribute name="xml:id">
            <xsl:choose>
                <xsl:when test="contains(., 'person__')">
                    <xsl:value-of select="concat('pmb', substring-after(., 'person__'))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="tei:back//tei:listPlace/tei:place/@xml:id">
        <xsl:attribute name="xml:id">
            <xsl:choose>
                <xsl:when test="contains(., 'place__')">
                    <xsl:value-of select="concat('pmb', substring-after(., 'place__'))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="tei:back//tei:listOrg/tei:org/@xml:id">
        <xsl:attribute name="xml:id">
            <xsl:choose>
                <xsl:when test="contains(., 'org__')">
                    <xsl:value-of select="concat('pmb', substring-after(., 'org__'))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="tei:back//tei:note[@type = 'IDNO']">
        <xsl:element name="idno" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="type">
                <xsl:text>URL</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="subtype">
                <xsl:choose>
                    <xsl:when test="contains(., 'wikipedia')">
                        <xsl:text>wikipedia</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'wikidata')">
                        <xsl:text>wikidata</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'geonames')">
                        <xsl:text>geonames</xsl:text>
                    </xsl:when>
                    <xsl:when test="starts-with(., 'https://')">
                        <xsl:value-of select="substring-before(substring-after(., 'https://'), '.')"
                        />
                    </xsl:when>
                    <xsl:when test="starts-with(., 'http://')">
                        <xsl:value-of select="substring-before(substring-after(., 'https://'), '.')"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-before(., '.')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:back//tei:orgName[contains(@type, 'uri')]">
        <xsl:element name="idno" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="type">
                <xsl:text>URL</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="subtype">
                <xsl:choose>
                    <xsl:when test="contains(., 'wikipedia')">
                        <xsl:text>wikipedia</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'wikidata')">
                        <xsl:text>wikidata</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'geonames')">
                        <xsl:text>geonames</xsl:text>
                    </xsl:when>
                    <xsl:when test="starts-with(., 'https://')">
                        <xsl:value-of select="substring-before(substring-after(., 'https://'), '.')"
                        />
                    </xsl:when>
                    <xsl:when test="starts-with(., 'http://')">
                        <xsl:value-of select="substring-before(substring-after(., 'https://'), '.')"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-before(., '.')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:title[@type = 'bibliografische_angabe']">
        <xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="type">
                <xsl:text>bibliografische_angabe</xsl:text>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:title[@type = 'uri_worklink']">
        <xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="type">
                <xsl:text>uri_worklink</xsl:text>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:title[contains(@type, 'wikipedia')]">
        <xsl:element name="idno" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="type">
                <xsl:text>URL</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="subtype">
                <xsl:choose>
                    <xsl:when test="contains(., 'wikipedia')">
                        <xsl:text>wikipedia</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'wikidata')">
                        <xsl:text>wikidata</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'geonames')">
                        <xsl:text>geonames</xsl:text>
                    </xsl:when>
                    <xsl:when test="starts-with(., 'https://')">
                        <xsl:value-of select="substring-before(substring-after(., 'https://'), '.')"
                        />
                    </xsl:when>
                    <xsl:when test="starts-with(., 'http://')">
                        <xsl:value-of select="substring-before(substring-after(., 'https://'), '.')"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-before(., '.')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:back//tei:placeName[. = preceding-sibling::tei:placeName/.]"/>
    <xsl:template match="tei:back//tei:listEvent"/>
    <xsl:template
        match="tei:listOrg[not(child::*)] | tei:listBibl[not(child::*)] | tei:listPerson[not(child::*)] | tei:listPlace[not(child::*)]"
    />
</xsl:stylesheet>
