<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="tei:objectType[not(@ana)]">
        <xsl:element name="objectType" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*"/>
            <xsl:if test="tei:desc/@subtype">
                <xsl:attribute name="ana">
                    <xsl:value-of select="tei:desc/@subtype"/>
                </xsl:attribute>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:objectDesc/tei:desc"/>
    <xsl:template
        match="tei:extent[ancestor::tei:witness/tei:objectType/@corresp = 'telegramm']">
        <xsl:element name="extent" namespace="http://www.tei-c.org/ns/1.0">
        <xsl:element name="measure" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="unit">
                <xsl:text>telegramm</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="quantity">
                <xsl:text>1</xsl:text>
            </xsl:attribute>
        </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template
        match="tei:extent[ancestor::tei:witness/tei:objectType/@corresp = 'kartenbrief']">
        <xsl:element name="extent" namespace="http://www.tei-c.org/ns/1.0">
        <xsl:element name="measure" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="unit">
                <xsl:text>kartenbrief</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="quantity">
                <xsl:text>1</xsl:text>
            </xsl:attribute>
        </xsl:element></xsl:element>
    </xsl:template>
</xsl:stylesheet>
