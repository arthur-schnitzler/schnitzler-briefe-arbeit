<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="yes" method="xml" encoding="utf-8" omit-xml-declaration="false"/>
    <!-- passt die notes an -->
    <!-- Identity template to copy nodes as-is -->
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="tei:note[@type = 'commentary' or @type = 'textConst']/@corresp">
        <xsl:variable name="alter-identifier" select="." as="attribute()" />
        <xsl:variable name="neuer-identifier"
            select="ancestor::tei:text/descendant::tei:anchor[@alt= $alter-identifier][1]/@xml:id"
            as="attribute()"/>
        
        <xsl:attribute name="corresp">
            <xsl:value-of select="$neuer-identifier"/>
        </xsl:attribute>
    </xsl:template>
    <!-- Match tei:anchor[@type='commentary'] elements -->
    <xsl:template match="tei:anchor[@type = 'commentary' or @type = 'textConst']/@alt"/>
</xsl:stylesheet>
