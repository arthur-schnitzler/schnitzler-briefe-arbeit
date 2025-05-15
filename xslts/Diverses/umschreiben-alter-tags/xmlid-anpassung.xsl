<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="xs"
                version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    
   <xsl:template match="@xml:id[parent::tei:TEI and not(. = substring(substring-before(tokenize(base-uri(), '/')[last()], '.xml'), 1, 7))]">
        <xsl:variable name="qwert"
                    select="substring(substring-before(tokenize(base-uri(), '/')[last()], '.xml'), 1, 7)"/>
       <xsl:attribute name="xml:id">
           <xsl:value-of select="$qwert"/>
       </xsl:attribute>
   </xsl:template>
    

    
   <xsl:template match="@n[parent::tei:idno[parent::tei:publicationStmt]]">
      <xsl:variable name="qwert"
                    select="substring(substring-before(tokenize(base-uri(), '/')[last()], '.xml'), 4, 4)"/>
      <xsl:attribute name="n">
        <xsl:value-of select="$qwert"/>
      </xsl:attribute>
    
   </xsl:template>
    
</xsl:stylesheet>
