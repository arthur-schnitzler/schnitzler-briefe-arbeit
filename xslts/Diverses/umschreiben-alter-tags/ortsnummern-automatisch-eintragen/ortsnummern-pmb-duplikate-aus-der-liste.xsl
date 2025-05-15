<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="tei"
                version="2.0">
    
    <xsl:output method="xml" encoding="utf-8" indent="yes"/>
    
    <xsl:template match="root">
        <xsl:element name="root">
         <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
   <xsl:template match="row">
       <xsl:element name="row">
       <xsl:choose>
           <xsl:when test="preceding-sibling::row/ortsname = ortsname">
               <xsl:element name="duplikat"/>
           </xsl:when>
           <xsl:when test="following-sibling::row/ortsname = ortsname">
               <xsl:element name="duplikat"/>
           </xsl:when>
       </xsl:choose>
          <xsl:element name="ortsname">
              <xsl:value-of select="ortsname"/>
          </xsl:element>
          <xsl:element name="pmb">
              <xsl:value-of select="pmb"/>
          </xsl:element>
       </xsl:element>
       
   </xsl:template>
   
   
</xsl:stylesheet>
