<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="tei:supportDesc[tei:extent/tei:measure[not(. ='') and not(tei:support)]]">
        <xsl:copy-of select="*[not(name()='extent')]"/>
        <xsl:element name="extent" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="descendant::tei:measure">
                <xsl:element name="measure" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:copy-of select="@*"/>
                </xsl:element>
            </xsl:for-each>
            <xsl:element name="support" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:value-of select="tei:extent/tei:measure[not(. ='')]"/>
            </xsl:element>
        </xsl:element>
        
        
        
    </xsl:template>
    
        
        
        
      
</xsl:stylesheet>
