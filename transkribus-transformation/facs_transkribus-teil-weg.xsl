<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:param name="dateiname" select="substring-before(tokenize(document-uri(/), '/')[last()], '.xml')" as="xs:string"/>
    
   <xsl:template match="tei:pb/@facs[contains(.,' HS.')]">
       <xsl:attribute name="facs">
           <xsl:value-of select="substring-after(., ' ')"/>
       </xsl:attribute>
   </xsl:template>
    
    <!-- Das hier schreibt auch die XML-ID neu -->
    
    <xsl:template match="tei:TEI/@xml:id">
        <xsl:attribute name="xml:id">
            <xsl:value-of select="$dateiname"/>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="tei:editionStmt/tei:idno">
            <xsl:element name="idno" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:variable name="wert" select="substring-after($dateiname, 'L')"/>
                <xsl:attribute name="type">
                    <xsl:text>schnitzler-briefe</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="n">
                    <xsl:value-of select="$wert"/>
                </xsl:attribute>
            </xsl:element>
    </xsl:template>
    
    
    
    
</xsl:stylesheet>