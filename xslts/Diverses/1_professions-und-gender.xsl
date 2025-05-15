<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
   
   <xsl:template match="female[normalize-space(.)='']"/>
   
   <xsl:template match="row[not(contains(name, '/'))]">
       <xsl:element name="row">
           <xsl:copy-of select="id"/>
           <xsl:element name="name">
               <xsl:value-of select="normalize-space(name)"/><xsl:text>/</xsl:text>
               <xsl:value-of select="normalize-space(female)"/>
           </xsl:element>
           
       </xsl:element>
       
   </xsl:template>
   
    
</xsl:stylesheet>
