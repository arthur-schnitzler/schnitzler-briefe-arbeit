<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:foo="whatever"
                exclude-result-prefixes="xs"
                version="3.0">
    <xsl:output indent="yes"/>
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:function name="foo:umlaute-entfernen">
        <xsl:param name="umlautstring"/>
        <xsl:value-of select="replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace($umlautstring,'ä','ae'), 'ö', 'oe'), 'ü', 'ue'), 'ß', 'ss'), 'Ä', 'Ae'), 'Ü', 'Ue'), 'Ö', 'Oe'), 'é', 'e'), 'è', 'e'), 'É', 'E'), 'È', 'E'),'ò', 'o'), 'Č', 'C'), 'D’','D'), 'd’','D'), 'Ś', 'S'), '’', ' '), '&amp;', 'und'), 'ë', 'e'), '!', ''), 'č', 'c'), 'Ł', 'L')"/>
    </xsl:function>
    
    
    
    
    <xsl:template match="@xml:id[//tei:correspDesc and parent::tei:TEI]">
       <xsl:variable name="datum">
           <xsl:choose>
               <xsl:when test="//tei:correspDesc[1]/tei:correspAction[@type='sent']/tei:date[1]/@when">
                   <xsl:value-of select="//tei:correspDesc/tei:correspAction[@type='sent']/tei:date[1]/@when"/>
               </xsl:when>
               <xsl:when test="//tei:correspDesc/tei:correspAction[@type='sent']/tei:date[1]/@notBefore">
                   <xsl:value-of select="//tei:correspDesc/tei:correspAction[@type='sent']/tei:date[1]/@notBefore"/>
               </xsl:when>
               <xsl:when test="//tei:correspDesc/tei:correspAction[@type='sent']/tei:date[1]/@notAfter">
                   <xsl:value-of select="//tei:correspDesc/tei:correspAction[@type='sent']/tei:date[1]/@notAfter"/>
               </xsl:when>
           </xsl:choose>
       </xsl:variable>
       <xsl:variable name="nummer"
           select="//tei:correspDesc/tei:correspAction[@type='sent']/tei:date[1]/@n"/>
        
       <xsl:variable name="sender">
           <xsl:for-each select="//tei:correspDesc/tei:correspAction[@type='sent']/tei:persName">
               <xsl:if test="not(position()=1)">
                   <xsl:text>-</xsl:text>
               </xsl:if>
               <xsl:choose>
                   <xsl:when test="@ref='#2121'">
                       <xsl:text>AS</xsl:text>
                   </xsl:when>
                   <xsl:when test="@ref='#2173'">
                       <xsl:text>OS</xsl:text>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:text></xsl:text>
                       <xsl:value-of select="substring-before(normalize-space(.), ', ')"/>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:for-each>
       </xsl:variable>
       <xsl:variable name="receiver">
           <xsl:for-each select="//tei:correspDesc/tei:correspAction[@type='received']/tei:persName">
               <xsl:if test="not(position()=1)">
                   <xsl:text>-</xsl:text>
               </xsl:if>
               <xsl:choose>
                   <xsl:when test="@ref='#2121'">
                       <xsl:text>AS</xsl:text>
                   </xsl:when>
                   <xsl:when test="@ref='#2173'">
                       <xsl:text>OS</xsl:text>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:value-of select="substring-before(normalize-space(.), ', ')"/>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:for-each>
       </xsl:variable>
        <xsl:variable name="qwert" as="xs:string">
            <xsl:choose>
                <xsl:when test="string-length($nummer)=1">
                    <xsl:value-of select="foo:umlaute-entfernen(concat('L', $datum,'_0',$nummer, '_', $sender,'_', $receiver))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="foo:umlaute-entfernen(concat('L', $datum,'_',$nummer, '_', $sender,'_', $receiver))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
       <xsl:attribute name="xml:id">
           <xsl:value-of select="$qwert"/>
       </xsl:attribute>
   </xsl:template>

  
</xsl:stylesheet>
