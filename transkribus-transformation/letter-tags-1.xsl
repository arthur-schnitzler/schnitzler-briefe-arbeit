<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="//tei:pb[position() = 1]">
        <xsl:text>&lt;letter&gt;</xsl:text>
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="//tei:pb[position() > 1]">
        <xsl:for-each select=".">
            <xsl:choose>
                <xsl:when test="./preceding-sibling::tei:seite[1][contains(., '&lt;/letter&gt;')]">
                    <xsl:text>&lt;/letter&gt;&lt;letter&gt;</xsl:text>
                    <xsl:copy-of select="."/>
                </xsl:when>
                <xsl:when test="./following-sibling::tei:seite[1][contains(., '&lt;letter&gt;')]">
                    <xsl:text>&lt;/letter&gt;&lt;letter&gt;</xsl:text>
                    <xsl:copy-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="//tei:seite[last()]">
        <xsl:copy-of select="."/>
        <xsl:text>&lt;/letter&gt;</xsl:text>
    </xsl:template>

</xsl:stylesheet>
