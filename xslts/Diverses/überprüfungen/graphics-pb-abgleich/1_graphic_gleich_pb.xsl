<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0">
    <xsl:output method="xml" encoding="utf-8" indent="true"/>
    <!-- Identity template : copy all text nodes, elements and attributes -->
    <!-- <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>-->

<xsl:template match="root">
    <xsl:element name="root">
        <xsl:apply-templates select="TEI"/>
    </xsl:element>
</xsl:template>

<xsl:template match="TEI">
    <xsl:if test="descendant::facsimile/graphic and not(starts-with(descendant::pb[1]/@facs, 'https:'))">
    <xsl:element name="TEI">
        <xsl:attribute name="datei">
            <xsl:choose>
                <xsl:when test="descendant::correspDesc/correspAction[1]/date/@when">
                    <xsl:value-of select="concat('https://schnitzler-briefe.acdh.oeaw.ac.at/pages/show.html?document=',descendant::correspDesc/correspAction[1]/date/@when, '_', descendant::correspDesc/correspAction[1]/date/@n, '.xml', '&amp;' , 'stylesheet=critical')"/>
                </xsl:when>
                <xsl:when test="descendant::correspDesc/correspAction[1]/date/@notBefore">
                    <xsl:value-of select="concat('https://schnitzler-briefe.acdh.oeaw.ac.at/pages/show.html?document=',descendant::correspDesc/correspAction[1]/date/@notBefore, '_', descendant::correspDesc/correspAction[1]/date/@n, '.xml', '&amp;' , 'stylesheet=critical')"/>
                </xsl:when>
                <xsl:when test="descendant::correspDesc/correspAction[1]/date/@notAfter">
                    <xsl:value-of select="concat('https://schnitzler-briefe.acdh.oeaw.ac.at/pages/show.html?document=',descendant::correspDesc/correspAction[1]/date/@notAfter, '_', descendant::correspDesc/correspAction[1]/date/@n, '.xml', '&amp;' , 'stylesheet=critical')"/>
                </xsl:when>
            </xsl:choose>
        </xsl:attribute>
    <xsl:apply-templates select="descendant::pb/@facs"/>
        <xsl:apply-templates select="descendant::facsimile/graphic/@url"/>
    </xsl:element>
    </xsl:if>
</xsl:template>    
    
<xsl:template match="pb/@facs">
        <xsl:element name="pb">
            <xsl:value-of select="."/>
        </xsl:element>
</xsl:template>
    
    <xsl:template match="facsimile/graphic/@url">
        <xsl:element name="graphic">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    
    

</xsl:stylesheet>
