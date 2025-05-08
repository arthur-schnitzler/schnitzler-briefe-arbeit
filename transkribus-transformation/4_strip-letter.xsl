<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei" version="3.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <xsl:call-template name="process_temp_files"/>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template name="process_temp_files">
        <xsl:variable name="collection-uri-string" select="'../temp/?select=*.xml;on-error=warning'"/>
        <xsl:variable name="files-in-temp" select="collection($collection-uri-string)"/>
        <xsl:if test="not(exists($files-in-temp))"> </xsl:if>
        <xsl:for-each select="$files-in-temp">
            <xsl:variable name="doc-name" select="concat(//tei:TEI/@xml:id, '.xml')"/>
            <xsl:result-document href="../../temp/{$doc-name}">
                <xsl:apply-templates/>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:template match="tei:letter | tei:letter-begin" priority="5">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="tei:page[@type = 'letter-begin']">
        <xsl:apply-templates/>
    </xsl:template>
</xsl:stylesheet>
