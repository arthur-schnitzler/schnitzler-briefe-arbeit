<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:output method="text"/>
    <xsl:strip-space elements="*"/>
    <!-- subst root persName address body div sourceDesc physDesc witList msIdentifier fileDesc teiHeader correspDesc correspAction date witnessdate -->
    <!-- Globale Parameter -->
   
   <!-- Das erzeugt aus Liste der Briefwechsel den Parameter:
   <xsl:param name="personen" as="array(xs:string*)"
        select="['#12438', ('#10992', '#5558', '#4395'), ('#2147', '#2260'), '#10762', ('#10815', '#10818'), ('#10863', '#13923', '#10860', '#2668'), '#10912', '#10955', '#11002', '#11036', '#2281', '#11148', '#11098', '#11617', ('#11740', '#2292'), ('#11230', '#15716', '#29150'), '#11763', '#11988', '#12176', '#12183', '#12225', '#12740', '#13055', '#13068', ('#12071', '#5822'), ('#11527', '#12408'), ('#11061', '#11324'), '#13212', '#12170', '#9550', '#4986', ('#14328', '#35015'), ('#2563', '#41355'), '#28812', '#2450', '#26121', '#3557', '#2416']"/>
   -->
   
    
    <xsl:template match="list">
       <xsl:text>[</xsl:text>
        <xsl:apply-templates select="correspondence"/>
        <xsl:text>]</xsl:text>
    </xsl:template>
    
    <xsl:template match="correspondence">
        <xsl:choose>
            <xsl:when test="not(sub-person)">
                <xsl:text>'</xsl:text>
                <xsl:value-of select="writer/@id"/>
                <xsl:text>'</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>('</xsl:text>
                <xsl:value-of select="writer/@id"/>
                <xsl:text>', </xsl:text>
                <xsl:for-each select="sub-person">
                    <xsl:text>'</xsl:text>
                    <xsl:value-of select="@id"/>
                    <xsl:text>'</xsl:text>
                    <xsl:if test="not(position()=last())">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:text>)</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="not(position()=last())">
            <xsl:text>, 
</xsl:text>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>