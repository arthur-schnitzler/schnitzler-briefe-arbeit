<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:number="http://dummy/" xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    xmlns:functx="http://www.functx.com" version="3.0"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="yes" method="xml" encoding="utf-8" omit-xml-declaration="false"/>
    
   <!-- Dieses XSL schreibt statt der Punkte am Satzende ein element full-stop -->
    
        
      <xsl:template match="tei:objectDesc">
          <xsl:element name="objectDesc" namespace="http://www.tei-c.org/ns/1.0">
              <xsl:copy-of select="tei:supportDesc"/>
              <xsl:copy-of select="tei:supportDesc/tei:layoutDesc"/>
          </xsl:element> 
      </xsl:template>
    
   
                  
              
              
          
          
        
       
   
</xsl:stylesheet>
