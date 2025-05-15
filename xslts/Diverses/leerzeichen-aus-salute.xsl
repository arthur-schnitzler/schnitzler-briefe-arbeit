<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:foo="whatever" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    
    
    <!-- Vorlage für tei:salute-Elemente -->
    <xsl:template match="tei:p/tei:salute[not(child::*) and ends-with(text(), ' ')]">
        <xsl:element name="salute" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:element>
        <!-- Prüfen, ob nach dem tei:salute-Element nur Whitespace kommt -->
        <xsl:variable name="followingWhitespace" select="normalize-space(following-sibling::node()[1])"/>
        <xsl:choose>
            <!-- Fall 1: Nach dem tei:salute-Element kommt nur Whitespace -->
            <xsl:when test="normalize-space($followingWhitespace)='' and following-sibling::node()[2][name()='space']"/>
            <xsl:when test="normalize-space($followingWhitespace)=''">
                   <xsl:element name="space" namespace="http://www.tei-c.org/ns/1.0">
                       <xsl:attribute name="unit"><xsl:text>chars</xsl:text></xsl:attribute>
                       <xsl:attribute name="quantity"><xsl:text>1</xsl:text></xsl:attribute>
                   </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
