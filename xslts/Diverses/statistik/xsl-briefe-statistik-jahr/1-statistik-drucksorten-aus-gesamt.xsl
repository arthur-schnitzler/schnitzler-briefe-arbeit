<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.0">
    <xsl:output method="xml" indent="true"/>
    <xsl:mode on-no-match="shallow-copy"/>
   
   <!-- Das zieht nur die Werte von Briefen an Schnitzler aus Gesamt. Die Idee ist, dass
   Schnitzler einheitlich gesammelt hat-->
   
    <xsl:template match="root">
        <xsl:element name="root">
            <xsl:for-each select="TEI[descendant::correspAction[@type='sent']/persName/@ref='#2121']">
            <xsl:variable name="correspActionSentDate" select="descendant::correspDesc[1]/correspAction[@type='sent']/date" as="node()"/>
                <xsl:if test="not(descendant::physDesc/objectDesc/desc/@type='widmung') or not(descendant::physDesc)">
                <xsl:element name="correspondence">
                <xsl:attribute name="jahr">
                    <xsl:choose>
                        <xsl:when test="$correspActionSentDate/@when">
                            <xsl:value-of select="substring($correspActionSentDate/@when, 1,4)"/>
                        </xsl:when>
                        <xsl:when test="$correspActionSentDate/@notBefore">
                            <xsl:value-of select="substring($correspActionSentDate/@notBefore, 1,4)"/>
                        </xsl:when>
                        <xsl:when test="$correspActionSentDate/@notAfter">
                            <xsl:value-of select="substring($correspActionSentDate/@notAfter, 1,4)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:attribute>
                    <xsl:attribute name="monat">
                        <xsl:choose>
                            <xsl:when test="$correspActionSentDate/@when">
                                <xsl:value-of select="tokenize($correspActionSentDate/@when,'-')[2]"/>
                            </xsl:when>
                            <xsl:when test="(tokenize($correspActionSentDate/@notBefore,'-')[2]=tokenize($correspActionSentDate/@notAfter,'-')[2]) and (tokenize($correspActionSentDate/@notBefore,'-')[1]=tokenize($correspActionSentDate/@notAfter,'-')[1])">
                                <xsl:value-of select="tokenize($correspActionSentDate/@notBefore,'-')[2]"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                <xsl:attribute name="name">
                    <xsl:variable name="objctDsc" select="descendant::physDesc/objectDesc"/>
                   <xsl:choose>
                       <xsl:when test="$objctDsc/desc[@type='brief']">Brief</xsl:when>
                       <xsl:when test="$objctDsc/desc[@subtype='bildpostkarte']">Bildpostkarte</xsl:when>
                       <xsl:when test="$objctDsc/desc[@type='telegramm']">Telegramm</xsl:when>
                       <xsl:when test="$objctDsc/desc[@subtype='visitenkarte']">Visitenkarte</xsl:when>
                       <xsl:when test="$objctDsc/desc[@subtype='postkarte']">Postkarte</xsl:when>
                       <xsl:when test="$objctDsc/desc[@subtype='briefkarte']">Briefkarte</xsl:when>
                       <xsl:when test="$objctDsc/desc[@type='kartenbrief']">Kartenbrief</xsl:when>
                       <xsl:otherwise>Anderes</xsl:otherwise>
                   </xsl:choose>
                    
                </xsl:attribute>
        </xsl:element></xsl:if>
            </xsl:for-each></xsl:element>
    </xsl:template>
</xsl:stylesheet>
