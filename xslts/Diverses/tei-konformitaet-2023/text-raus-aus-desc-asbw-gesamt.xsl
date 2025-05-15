<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
     xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="3.0">
    <xsl:mode on-no-match="shallow-skip"/>
    <xsl:output method="xml" indent="yes"/>
   
   <xsl:template match="root">
       <root>
           <xsl:apply-templates select="TEI"/>
       </root>
               
               
   </xsl:template>
   
    <xsl:template match="TEI[descendant::objectDesc/desc[not(starts-with(@type, '_')) and not(.='')]]">
        <xsl:variable name="id" select="@id"/>
        <xsl:for-each select="descendant::witness">
            <xsl:variable name="witness" select="@n"/>
            <xsl:for-each select="descendant::objectDesc/desc[not(starts-with(@type, '_')) and not(.='')]">
                <item>
                    <xsl:attribute name="id">
                        <xsl:value-of select="$id"/>
                    </xsl:attribute>
                    <xsl:attribute name="n">
                        <xsl:value-of select="$witness"/>
                    </xsl:attribute>
                    <xsl:copy-of select="."></xsl:copy-of>
                </item>
                
            </xsl:for-each>
            
        </xsl:for-each>
        
    </xsl:template>
   
</xsl:stylesheet>
