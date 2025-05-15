<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.0">
    <xsl:output method="text" indent="true"/>
    <xsl:mode on-no-match="shallow-copy"/>
 
 <xsl:function name="foo:allejahrewieder">
     <xsl:param name="root" as="node()"/>
     <xsl:param name="jahr"/>
     <xsl:value-of select="$jahr"/>
     <xsl:text>&#9;</xsl:text>
     <xsl:value-of select="count($root/correspondence[@jahr=$jahr and @name='kurrent'])"/>
     <xsl:text>&#9;</xsl:text>
     <xsl:value-of select="count($root/correspondence[@jahr=$jahr and @name='latintype'])"/>
     <xsl:text>&#9;</xsl:text>
     <xsl:value-of select="count($root/correspondence[@jahr=$jahr and @name='mixed'])"/>
     <xsl:text>&#9;</xsl:text>
     <xsl:value-of select="count($root/correspondence[@jahr=$jahr and @name='Schreibmaschine'])"/>
     <xsl:text>&#10;</xsl:text>
    <xsl:if test="$jahr &lt; 1931">
         <xsl:value-of select="foo:allejahrewieder($root, $jahr +1)"/>
     </xsl:if>
 </xsl:function>
 
 <xsl:template match="root">
     <xsl:variable name="root" select="current()" as="node()"/>
     <xsl:text>Name&#9;Kurrent&#9;Lateinschrift&#9;Gemischt&#9;Schreibmaschine&#10;</xsl:text>
     <xsl:variable name="root" select="." as="node()"/>
     <xsl:value-of select="foo:allejahrewieder($root, 1890)"/>
 </xsl:template>
 
 
 
</xsl:stylesheet>
