<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:foo="whatever"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="xs"
                version="3.0">
    <xsl:output indent="yes"/>
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="@xml:id[parent::tei:TEI]">
        <xsl:variable name="wert" select="substring-before(substring(substring-after(document-uri(/), 'XML/data/'), 1),'.xml')"/>
       <xsl:attribute name="xml:id">
           <xsl:value-of select="$wert"/>
       </xsl:attribute>
   </xsl:template>
    
    <xsl:template match="tei:editionStmt">
        <xsl:element name="editionStmt" namespace="http://www.tei-c.org/ns/1.0">
        <xsl:copy-of select="tei:edition"/>
        <xsl:copy-of select="tei:respStmt"/>
        <xsl:element name="idno" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:variable name="wert" select="substring-before(substring(substring-after(document-uri(/), 'XML/data/'), 1),'.xml')"/>
            <xsl:attribute name="type">
                <xsl:text>asi</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="n">
            <xsl:value-of select="$wert"/>
            </xsl:attribute>
        </xsl:element>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>
