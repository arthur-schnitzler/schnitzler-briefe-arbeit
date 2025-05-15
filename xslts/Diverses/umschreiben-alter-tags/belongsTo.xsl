<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0">
    <xsl:output method="xml" encoding="utf-8" indent="no"/>
    <!-- Identity template : copy all text nodes, elements and attributes -->
    <!-- <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>-->
    <xsl:template match="teiHeader"/>
    <xsl:template match="TEI">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template
        match="person[occupation = 'Zeichner' or occupation = 'Lithograph' or occupation = 'Radierer' or occupation = 'Maler' or occupation = 'Bildhauer']">
        <xsl:text/>
        <xsl:value-of select="persName/surname"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="persName/forename"/>
        <xsl:text> (</xsl:text>
        <xsl:value-of select="substring(birth/@when-iso, 1, 4)"/>
        <xsl:text>–</xsl:text>
        <xsl:value-of select="substring(death//@when-iso, 1, 4)"/>
        <xsl:text>) </xsl:text>
        <xsl:text> \emph{</xsl:text>
        <xsl:value-of select="occupation" separator=", "/>
        <xsl:text>} 
        </xsl:text>
    </xsl:template>
    <xsl:template match="person"/>
</xsl:stylesheet>
