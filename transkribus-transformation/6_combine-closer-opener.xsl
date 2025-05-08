<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei" version="3.0">
    <xsl:output method="xml" indent="yes"/>
    <!-- Template für alle Elemente -->
    <xsl:mode name="m" on-no-match="shallow-copy"/>
    
    <!-- Alle apply-templates mit mode="m" -->
    <xsl:template match="/">
        <xsl:call-template name="process_temp_files"/>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="m"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Auch im process_temp_files -->
    <xsl:template name="process_temp_files">
        <xsl:variable name="collection-uri-string" select="'../temp/?select=*.xml;on-error=warning'"/>
        <xsl:variable name="files-in-temp" select="collection($collection-uri-string)"/>
        <xsl:for-each select="$files-in-temp">
            <xsl:variable name="doc-name" select="concat(//tei:TEI/@xml:id, '.xml')"/>
            <xsl:result-document href="../../temp/{$doc-name}">
                <xsl:apply-templates mode="m"/>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Dein spezielles closer-Merging-Template bekommt auch den Modus -->
    <xsl:template match="*" mode="m">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="m"/>
            <xsl:for-each-group select="node()" group-adjacent="boolean(self::tei:closer)">
                <xsl:choose>
                    <xsl:when test="current-grouping-key()">
                        <closer xmlns="http://www.tei-c.org/ns/1.0">
                            <xsl:for-each select="current-group()">
                                <xsl:apply-templates select="node()" mode="m"/>
                                <xsl:if test="position() != last()">
                                    <lb/>
                                </xsl:if>
                            </xsl:for-each>
                        </closer>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()" mode="m"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
    <!-- Winkelzeichen verbindet Wörter -->
    <xsl:template match="//text()">
        <xsl:value-of select="translate(., '¬', '')" disable-output-escaping="yes"/>
    </xsl:template>
</xsl:stylesheet>
