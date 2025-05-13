<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    
    <!-- Dieses Template überprüft die logische Konsistenz der ISO-Daten in 
    correspAction, also ob 
    -->
    
    <xsl:template match="tei:correspAction[not(fn:position()=1)]/tei:date[1]/@when">
        <xsl:variable name="previous-attribute" as="xs:date">
            <xsl:choose>
                <xsl:when test="ancestor::tei:correspAction[1]/preceding-sibling::tei:correspAction[tei:date][1]/tei:date[1]/@when">
                    <xsl:value-of select="ancestor::tei:correspAction[1]/preceding-sibling::tei:correspAction[tei:date][1]/tei:date[1]/@when"/>
                </xsl:when>
                <xsl:when test="ancestor::tei:correspAction[1]/preceding-sibling::tei:correspAction[tei:date][1]/tei:date[1]/@to">
                    <xsl:value-of select="ancestor::tei:correspAction[1]/preceding-sibling::tei:correspAction[tei:date][1]/tei:date[1]/@to"/>
                </xsl:when>
                <xsl:when test="ancestor::tei:correspAction[1]/preceding-sibling::tei:correspAction[tei:date][1]/tei:date[1]/@notAfter">
                    <xsl:value-of select="ancestor::tei:correspAction[1]/preceding-sibling::tei:correspAction[tei:date][1]/tei:date[1]/@notAfter"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="when">
            <xsl:value-of select="."/>
        </xsl:attribute>
        <xsl:if test="xs:date($previous-attribute) > xs:date(.)">
            <xsl:attribute name="error">
                <xsl:text>Zeitabfolge Fehler 1</xsl:text>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:correspAction[not(fn:position()=1)]/tei:date[1]/@notBefore">
        <xsl:variable name="previous-attribute" as="xs:date">
            <xsl:choose>
                <xsl:when test="ancestor::tei:correspAction[1]/preceding-sibling::tei:correspAction[tei:date][1]/tei:date[1]/@when">
                    <xsl:value-of select="ancestor::tei:correspAction[1]/preceding-sibling::tei:correspAction[tei:date][1]/tei:date[1]/@when"/>
                </xsl:when>
                <xsl:when test="ancestor::tei:correspAction[1]/preceding-sibling::tei:correspAction[tei:date][1]/tei:date[1]/@to">
                    <xsl:value-of select="ancestor::tei:correspAction[1]/preceding-sibling::tei:correspAction[tei:date][1]/tei:date[1]/@to"/>
                </xsl:when>
                <xsl:when test="ancestor::tei:correspAction[1]/preceding-sibling::tei:correspAction[tei:date][1]/tei:date[1]/@notBefore">
                    <xsl:value-of select="ancestor::tei:correspAction[1]/preceding-sibling::tei:correspAction[tei:date][1]/tei:date[1]/@notBefore"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="notBefore">
            <xsl:value-of select="."/>
        </xsl:attribute>
        <xsl:if test="xs:date($previous-attribute) > xs:date(.)">
            <xsl:attribute name="error">
                <xsl:text>Zeitabfolge Fehler 1</xsl:text>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:correspAction[not(fn:position()=1)]/tei:date[1]/@to">
        <xsl:variable name="previous-attribute" as="xs:date">
            <xsl:choose>
                <xsl:when test="ancestor::tei:correspAction[1]/preceding-sibling::tei:correspAction[tei:date][1]/tei:date[1]/@when">
                    <xsl:value-of select="ancestor::tei:correspAction[1]/preceding-sibling::tei:correspAction[tei:date][1]/tei:date[1]/@when"/>
                </xsl:when>
                <xsl:when test="ancestor::tei:correspAction[1]/preceding-sibling::tei:correspAction[tei:date][1]/tei:date[1]/@to">
                    <xsl:value-of select="ancestor::tei:correspAction[1]/preceding-sibling::tei:correspAction[tei:date][1]/tei:date[1]/@to"/>
                </xsl:when>
                <xsl:when test="ancestor::tei:correspAction[1]/preceding-sibling::tei:correspAction[tei:date][1]/tei:date[1]/@notAfter">
                    <xsl:value-of select="ancestor::tei:correspAction[1]/preceding-sibling::tei:correspAction[tei:date][1]/tei:date[1]/@notAfter"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="to">
            <xsl:value-of select="."/>
        </xsl:attribute>
        <xsl:if test="xs:date($previous-attribute) > xs:date(.)">
            <xsl:attribute name="error">
                <xsl:text>Zeitabfolge Fehler 1</xsl:text>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
