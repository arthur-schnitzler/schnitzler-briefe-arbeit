<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="//tei:div[@type='writingSession']">
        <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="type">
                <xsl:value-of select="'writingSession'"/>
            </xsl:attribute>
            <xsl:attribute name="n">
                <xsl:value-of select="'1'"/>
            </xsl:attribute>
        <xsl:copy-of select="node()"/>
        <xsl:text>&lt;/p&gt;</xsl:text>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>
