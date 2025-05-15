<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0">
    <xsl:output method="xml" encoding="utf-8" indent="true"/>
    <!-- Identity template : copy all text nodes, elements and attributes -->
    <!-- <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>-->

<xsl:template match="root">
    <xsl:element name="root">
        <xsl:apply-templates select="TEI">
            <xsl:sort select="@datei"/>
        </xsl:apply-templates>
    </xsl:element>
</xsl:template>

<xsl:template match="TEI">
        <xsl:apply-templates select="pb"/>
</xsl:template>    
    
<xsl:template match="pb">
    <xsl:choose>
        <xsl:when test="starts-with(text(), 'http')"/>
        <xsl:when test="following-sibling::graphic/text()=text()"/>
        <xsl:otherwise>
            <xsl:element name="pb-offen">
                <xsl:attribute name="datei">
                    <xsl:value-of select="parent::TEI/@datei"/>
                </xsl:attribute>
                <xsl:value-of select="text()"/>
            </xsl:element>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
</xsl:stylesheet>
