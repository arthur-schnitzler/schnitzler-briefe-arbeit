<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:number="http://dummy/" xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    xmlns:functx="http://www.functx.com" version="3.0"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="yes" method="xml" encoding="utf-8" omit-xml-declaration="false"/>
    
   <!-- Dieses XSL schreibt statt der Punkte am Satzende ein element full-stop -->
    
        
        <xsl:template match="tei:physDesc/tei:p">
            <xsl:variable name="marked-text" as="node()*">
                <xsl:apply-templates mode="insert-marker"/>
            </xsl:variable>
            <xsl:for-each-group select="$marked-text" group-ending-with="full-stop">
                <incident>
                    <xsl:apply-templates select="current-group()"/>
                </incident>
            </xsl:for-each-group>
        </xsl:template>
        
        <xsl:mode name="insert-marker" on-no-match="shallow-copy"/>
        
    <xsl:template mode="insert-marker" match="tei:physDesc/tei:p/text()">
            <xsl:analyze-string select="." regex="\.">
                <xsl:matching-substring>
                    <full-stop>.</full-stop>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:template>
        
        <xsl:template match="full-stop">
            <xsl:text>.</xsl:text>
        </xsl:template>
        
   
</xsl:stylesheet>
