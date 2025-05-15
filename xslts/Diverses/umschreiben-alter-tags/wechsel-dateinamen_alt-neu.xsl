<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.tei-c.org/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    
    
    
        <xsl:template match="/">
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
            
            <!--   <xsl:variable name="sender">
                <xsl:for-each select="//tei:correspDesc/tei:correspAction[@type='sent']/tei:persName">
                    <xsl:choose>
                        <xsl:when test="@ref='pmb2121'">
                  <xsl:text>-AS</xsl:text>
               </xsl:when>
                        <xsl:when test="@ref='A002038'">
                  <xsl:text>-OS</xsl:text>
               </xsl:when>
                        <xsl:otherwise>
                  <xsl:text>-</xsl:text>
                  <xsl:value-of select="substring-before(normalize-space(.), ', ')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            
            <xsl:variable name="receiver">
                <xsl:for-each select="//tei:correspDesc/tei:correspAction[@type='received']/tei:persName">
                    <xsl:choose>
                        <xsl:when test="@ref='pmb2121'">
                  <xsl:text>-AS</xsl:text>
               </xsl:when>
                        <xsl:when test="@ref='A002038'">
                  <xsl:text>-OS</xsl:text>
               </xsl:when>
                        <xsl:otherwise>
                  <xsl:text>-</xsl:text>
                  <xsl:value-of select="substring-before(normalize-space(.), ', ')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>-->
            
            
            <xsl:choose>
                <xsl:when test="string-length($nummer)=1">
                    <xsl:result-document href="../neu/{concat($datum,'_0',$nummer)}.xml"><!-- @n auf zweistellige Nummern vereinheitlichen -->
                        <xsl:apply-templates/>
                    </xsl:result-document>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:result-document href="../neu/{concat($datum,'_',$nummer)}.xml">
                        <xsl:apply-templates/>
                    </xsl:result-document>
                </xsl:otherwise>
            </xsl:choose>
            
            
        </xsl:template>
</xsl:stylesheet>
