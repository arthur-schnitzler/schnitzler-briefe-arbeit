<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="tei"
                version="2.0">
    
    <xsl:output method="xml" encoding="utf-8" indent="no"/>
    
    
    <!-- Identity template : copy all text nodes, elements and attributes -->  
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@when">
        <xsl:attribute name="when">
        <xsl:choose>
            <xsl:when test="string-length(.) = 4">
                <xsl:value-of select="."/>
                <xsl:text>0000</xsl:text>
            </xsl:when>
            <xsl:when test="string-length(.) = 7">
                <xsl:value-of select="substring(., 1, 4)"/>
                <xsl:value-of select="substring(., 6, 2)"/>
                <xsl:text>00</xsl:text>
            </xsl:when>
            <xsl:when test="string-length(.) = 10">
                <xsl:value-of select="substring(., 1, 4)"/>
                <xsl:value-of select="substring(., 6, 2)"/>
                <xsl:value-of select="substring(., 9, 2)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
                <xsl:text>BIEBIE</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@notBefore">
        <xsl:attribute name="notBefore">
            <xsl:choose>
                <xsl:when test="string-length(.) = 4">
                    <xsl:value-of select="."/>
                    <xsl:text>0000</xsl:text>
                </xsl:when>
                <xsl:when test="string-length(.) = 7">
                    <xsl:value-of select="substring(., 1, 4)"/>
                    <xsl:value-of select="substring(., 6, 2)"/>
                    <xsl:text>00</xsl:text>
                </xsl:when>
                <xsl:when test="string-length(.) = 10">
                    <xsl:value-of select="substring(., 1, 4)"/>
                    <xsl:value-of select="substring(., 6, 2)"/>
                    <xsl:value-of select="substring(., 9, 2)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                    <xsl:text>BIoBIo</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@notAfter">
        <xsl:attribute name="notAfter">
            <xsl:choose>
                <xsl:when test="string-length(.) = 4">
                    <xsl:value-of select="."/>
                    <xsl:text>0000</xsl:text>
                </xsl:when>
                <xsl:when test="string-length(.) = 7">
                    <xsl:value-of select="substring(., 1, 4)"/>
                    <xsl:value-of select="substring(., 6, 2)"/>
                    <xsl:text>00</xsl:text>
                </xsl:when>
                <xsl:when test="string-length(.) = 10">
                    <xsl:value-of select="substring(., 1, 4)"/>
                    <xsl:value-of select="substring(., 6, 2)"/>
                    <xsl:value-of select="substring(., 9, 2)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                    <xsl:text>BIABIA</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
</xsl:stylesheet>
