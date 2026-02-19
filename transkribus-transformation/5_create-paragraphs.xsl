<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="3.0">
    
    <xsl:output method="xml" indent="yes" />
    
    <xsl:template match="/">
        <xsl:call-template name="process_temp_files"/>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="process_temp_files">
        <xsl:variable name="collection-uri-string" select="'../temp/?select=*.xml;on-error=warning'"/>
        <xsl:variable name="files-in-temp" select="collection($collection-uri-string)"/>
        <xsl:for-each select="$files-in-temp">
            <xsl:variable name="doc-name" select="concat(//tei:TEI/@xml:id, '.xml')"/>
            <xsl:result-document href="../../temp/{$doc-name}">
                <xsl:apply-templates/>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:mode on-no-match="shallow-copy"/>
    


    <xsl:template match="tei:paragraph-start">
        <!-- paragraph-start Milestones werden entfernt, da sie nur für Gruppierung verwendet werden -->
    </xsl:template>
    
    <!-- Sonderbehandlung für opener, date, dateline, postscript -->
    <xsl:template match="tei:opener | tei:date | tei:dateline | tei:postscript" priority="1">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="descendant::tei:paragraph">
                    <p xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:apply-templates select="node()"/>
                    </p>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- Gruppierung im writingSession -->
    <xsl:template match="tei:div[@type='writingSession']" priority="1">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="node()"
                group-starting-with="tei:paragraph-start | tei:closer | tei:dateline | tei:postscript | tei:opener">

                <xsl:variable name="first" select="current-group()[1]"/>

                <xsl:choose>
                    <xsl:when test="$first[self::tei:paragraph-start]">
                        <p xmlns="http://www.tei-c.org/ns/1.0">
                            <xsl:apply-templates select="current-group()[position() > 1]"/>
                        </p>
                    </xsl:when>
                    <xsl:when test="$first[self::tei:closer or self::tei:dateline or self::tei:postscript or self::tei:opener]">
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
   
    
</xsl:stylesheet>