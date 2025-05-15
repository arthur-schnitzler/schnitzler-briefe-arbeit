<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    version="3.0">
    <xsl:output method="text" indent="false"/>
    <xsl:mode on-no-match="shallow-skip" />
  
  <!-- Dieses XSLT erstellt eine Liste der URIS für PMB-->
  
 
  
    <xsl:template match="tei:*/@n">
        <xsl:value-of select="normalize-space(.)"/><xsl:text>&#9;</xsl:text><xsl:value-of select="concat('https://schnitzler-briefe.acdh.oeaw.ac.at/pages/hits.html?searchkey=pmb',., '#_')"/><xsl:text>&#10;</xsl:text></xsl:template>
</xsl:stylesheet>