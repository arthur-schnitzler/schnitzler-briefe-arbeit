<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="tei:change[xs:date(@when) le xs:date(preceding-sibling::tei:change[1]/@when)]">
        <xsl:variable name="firstDate" select="xs:date(preceding-sibling::tei:change[1]/@when)"/>
        <xsl:variable name="lastDate" select="xs:date(@when)"/>
        
        <xsl:copy>
            <!-- Wenn das letzte Datum vor oder gleich dem ersten Datum liegt, ändern wir das Datum -->
            <xsl:choose>
                <xsl:when test="$lastDate le $firstDate">
                    <!-- Ersetze das 'when'-Attribut durch das erste Datum plus einen Tag -->
                    <xsl:attribute name="when">
                        <xsl:value-of select="$firstDate + xs:dayTimeDuration('P1D')"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Behalte das ursprüngliche 'when'-Attribut bei -->
                    <xsl:copy-of select="@when"/>
                </xsl:otherwise>
            </xsl:choose>
            
            <!-- Kopiere alle anderen Attribute -->
            <xsl:copy-of select="@*[name() != 'when']"/>
            
            <!-- Kopiere den Inhalt des Elements -->
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>