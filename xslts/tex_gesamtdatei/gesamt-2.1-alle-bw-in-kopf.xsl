<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array" exclude-result-prefixes="#all"
    version="3.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:key name="sent-by" match="TEI"
        use="descendant::correspDesc/correspAction[@type = 'sent']/persName/@ref"/>
    <xsl:key name="received-by" match="TEI"
        use="descendant::correspDesc/correspAction[@type = 'received']/persName/@ref"/>
    <xsl:variable name="sent-by-arthur"
        select="key('sent-by', ('#pmb2121', '#pmb2173', '#pmb12698', '#pmb12692'))"/>
    <xsl:variable name="received-by-arthur"
        select="key('received-by', ('#pmb2121', '#pmb2173', '#pmb12698', '#pmb12692'))"/>
  
    <xsl:template match="/*">
        <xsl:element name="root">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="TEI">
        <TEI bw="GESAMT" xml:id="xxxx">
            <xsl:apply-templates select="@* | node()"/>
        </TEI>
    </xsl:template>
</xsl:stylesheet>
