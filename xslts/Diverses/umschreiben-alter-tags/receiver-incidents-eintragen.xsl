<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei" version="3.0">
    <xsl:output method="xml" encoding="utf-8" indent="yes"/>
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="row[textform = preceding-sibling::row/textform]"/>
    
    <xsl:template match="row">
        <xsl:variable name="txtform" select="textform"/>
        <xsl:element name="row">
        <xsl:element name="textform">
            <xsl:value-of select="textform"/>
        </xsl:element>
        <xsl:element name="indexform">
            <xsl:choose>
                <xsl:when test="not(contains($txtform, ' '))">
                    <xsl:value-of select="$txtform"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="ende" select="tokenize($txtform, ' ')[last()]"/>
                    <xsl:value-of select="concat($ende, ', ', substring-before($txtform, $ende))"/>
                </xsl:otherwise>
            </xsl:choose>
            
            
        </xsl:element>    
            <xsl:element name="subentry"> </xsl:element>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>
