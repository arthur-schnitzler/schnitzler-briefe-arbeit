<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:key name="supportDesclookup" match="tei:TEI" use="@xml:id"/>
    <xsl:template match="tei:objectDesc[not(child::tei:supportDesc/tei:extent)]">
        <xsl:variable name="current-xmlid" select="ancestor::tei:TEI/@xml:id" as="xs:string"/>
        <xsl:variable name="dateiname" select="concat('alt/alt_', $current-xmlid, '.xml')" as="xs:string"/>
        <xsl:variable name="witnessNr" select="ancestor::tei:witness/@n"/>
        <xsl:element name="objectDesc" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*"/>
            <xsl:element name="supportDesc" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of select="tei:supportDesc/@*|tei:supportDesc/*"/>
                <xsl:copy-of select="key('supportDesclookup', $current-xmlid, document($dateiname))/descendant::tei:listWit/tei:witness[@n=$witnessNr]//tei:supportDesc/*"/>
                
                
            </xsl:element>
            
            
        </xsl:element>
        
        
        
    </xsl:template>
</xsl:stylesheet>
