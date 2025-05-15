<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:foo="whatever"
    exclude-result-prefixes="xs"
    version="3.0">
    <xsl:output indent="yes"/>
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="tei:pb/@facs[contains(., ' ')]">
        <xsl:attribute name="facs">
        <xsl:value-of select="substring-after(., ' ')"/>
        </xsl:attribute>
    </xsl:template>
   
   
</xsl:stylesheet>
