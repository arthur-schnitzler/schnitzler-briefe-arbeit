<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="tei"
                version="2.0">
    
    <xsl:output method="xml" encoding="utf-8" indent="yes"/>
    
   <xsl:template match="description">
      <xsl:element name="row">
         <xsl:for-each select="tokenize(., ' ')">
            <xsl:element name="pmb-id">
               <xsl:value-of select="substring-after(.,'#')"/>
            </xsl:element>
            <xsl:element name="HBAS-uri">
               <xsl:value-of select="concat('https://bahrschnitzler.acdh.oeaw.ac.at/entity/',.)"/>
            </xsl:element>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
    
    <xsl:template match="report">
        <xsl:element name="report">
        <xsl:apply-templates select="//description"/>
        </xsl:element>
    </xsl:template>
    
    
    
</xsl:stylesheet>
