<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
    
    <xsl:output indent="no"
               method="text"
               encoding="utf-8"
               omit-xml-declaration="yes"/>
    
   <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="note|teiHeader"/>
    
    <xsl:template match="TEI">
        <xsl:value-of select="teiHeader/fileDesc/titleStmt/title[@level='a']"/>
        <xsl:apply-templates select="text"/>
    </xsl:template>
    
    <xsl:template match="p|dateline"><xsl:apply-templates/><xsl:text>
</xsl:text></xsl:template>
    
    
</xsl:stylesheet>
