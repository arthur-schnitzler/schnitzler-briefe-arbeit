<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="yes" method="xml" encoding="utf-8" omit-xml-declaration="false"/>
    <xsl:param name="correspList" select="document('correspList.xml')"/>
    <xsl:key name="corresp-lookup" match="correspDesc" use="@date"/>
    
    <xsl:template match="tei:ref[@type='schnitzler-briefe']">
        <xsl:element name="ref" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="type">
                <xsl:text>schnitzler-briefe</xsl:text>
            </xsl:attribute>
            <xsl:if test="@subtype"><xsl:attribute name="subtype">
                <xsl:value-of select="@subtype"/>
            </xsl:attribute></xsl:if>
           <xsl:attribute name="target">
               <xsl:variable name="date_n" select="concat(tokenize(@target, '_')[1],'_', tokenize(@target, '_')[2]) "/>
               <xsl:value-of select="key('corresp-lookup', $date_n, $correspList)/@xml:id"/>
           </xsl:attribute>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:anchor[@type='commentary' or @type='textConst']">
        <xsl:variable name="xmlid" select="ancestor::tei:TEI/@xml:id"/>
        <xsl:variable name="beginn" select="substring(@xml:id, 1,2)"/>
        <xsl:variable name="ende" select="tokenize(@xml:id, '_')[last()]"/>
        <xsl:element name="anchor" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="concat($beginn, $xmlid,'_', $ende)"/>
            </xsl:attribute>
            <xsl:attribute name="type">
                <xsl:value-of select="@type"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:note[@type='commentary' or @type='textConst']">
        <xsl:variable name="xmlid" select="ancestor::tei:TEI/@xml:id"/>
        <xsl:variable name="beginn" select="substring(@xml:id, 1,2)"/>
        <xsl:variable name="ende" select="tokenize(@xml:id, '_')[last()]"/>
        <xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="concat($beginn, $xmlid,'_', $ende)"/>
            </xsl:attribute>
            <xsl:attribute name="type">
                <xsl:value-of select="@type"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    
</xsl:stylesheet>
