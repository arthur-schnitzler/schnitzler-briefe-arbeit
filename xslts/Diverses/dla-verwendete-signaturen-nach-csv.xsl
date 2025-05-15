<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="3.0">
    <xsl:mode on-no-match="shallow-skip"/>
    <xsl:output method="xml" indent="yes"/>
   
   <xsl:template match="root">
       <list>
           <xsl:apply-templates select="TEI[descendant::listWit/witness[1]/msDesc/msIdentifier/settlement[contains(., 'Marbach')]]">
               <xsl:sort select="descendant::listWit/witness[1]/msDesc/msIdentifier/idno"/>
           </xsl:apply-templates>
       </list>
   </xsl:template>
   <xsl:template match="TEI[descendant::listWit/witness[1]/msDesc/msIdentifier/settlement[contains(., 'Marbach')]]">
       <item>
       <title>
       <xsl:value-of select="normalize-space(descendant::titleStmt/title[@level='a'])"/></title>
       <idno>
           <xsl:value-of select="normalize-space(descendant::listWit/witness[1]/msDesc/msIdentifier/idno)"/>
       </idno>
       </item>
   </xsl:template>
   
</xsl:stylesheet>
