<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei" version="3.0">
    <xsl:output method="xml" encoding="utf-8" indent="yes"/>
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="tei:incident[@type='archival']/tei:desc[contains(.,'an Stelle') and contains(.,'Zählung')]">
        <xsl:choose>
            <xsl:when test="tei:quote/tei:del and not(tei:quote[2])">
                <xsl:element name="incident" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="type">
                        <xsl:text>archival-i</xsl:text>
                    </xsl:attribute>
                    <xsl:text>Mit Bleistift von unbekannter Hand nummeriert: »</xsl:text><xsl:copy-of select="tei:quote/tei:del"/><xsl:text>«.</xsl:text>
                </xsl:element>
                <xsl:element name="incident" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="type">
                        <xsl:text>archival-ii</xsl:text>
                    </xsl:attribute>
                    <xsl:text>Mit Bleistift von unbekannter Hand nummeriert: »</xsl:text><xsl:copy-of select="tei:quote/text()[last()]/normalize-space(.)"/><xsl:text>«.</xsl:text>
                </xsl:element>
            </xsl:when>
            <xsl:when test="tei:quote[2] and not(tei:quote[3])">
                <xsl:element name="incident" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="type">
                        <xsl:text>archival-i</xsl:text>
                    </xsl:attribute>
                    <xsl:text>Mit Bleistift von unbekannter Hand nummeriert: »</xsl:text><xsl:copy-of select="tei:quote[1]"/><xsl:text>«.</xsl:text>
                </xsl:element>
                <xsl:element name="incident" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="type">
                        <xsl:text>archival-ii</xsl:text>
                    </xsl:attribute>
                    <xsl:text>Mit Bleistift von unbekannter Hand nummeriert: »</xsl:text><xsl:copy-of select="tei:quote[2]"/><xsl:text>«.</xsl:text>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="incident" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="type">
                        <xsl:text>archival-offen</xsl:text>
                    </xsl:attribute>
                    <xsl:copy-of select="."></xsl:copy-of>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
</xsl:stylesheet>
