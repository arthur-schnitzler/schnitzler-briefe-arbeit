<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="tei"
                version="2.0">
    
    <xsl:output method="xml" encoding="utf-8" indent="yes"/>
    
    <xsl:param name="konkordanz" select="document('pmb-orte.xml')"/>
    <xsl:key name="konk-lookup" match="row" use="ortsname"/>
    
    
    <!-- Identity template : copy all text nodes, elements and attributes -->  
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:placeName[not(@key) or @ref='']">
        <xsl:element name="placeName">
            <xsl:attribute name="key">
                <xsl:value-of select="concat('pmb',key('konk-lookup', normalize-space(.), $konkordanz)/pmb)"/>
            </xsl:attribute>
                <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
  
</xsl:stylesheet>
