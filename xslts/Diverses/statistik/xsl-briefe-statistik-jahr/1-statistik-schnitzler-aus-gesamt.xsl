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
            <xsl:for-each select="descendant::correspDesc[correspAction[@type='sent']/persName/@ref='#2121' and correspContext/ref[@type='belongsToCorrespondence']/@target=correspAction[@type='received']/persName/@ref]/correspContext/ref[@type='belongsToCorrespondence']">
            <xsl:variable name="correspActionSentDate" select="ancestor::correspDesc[1]/correspAction[@type='sent']/date" as="node()"/>
            <xsl:element name="correspondence">
                <xsl:attribute name="target">
                    <xsl:value-of select="@target"/>
                </xsl:attribute>
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
                <xsl:attribute name="name">
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:attribute>
        </xsl:element>
            </xsl:for-each></xsl:element>
    </xsl:template>
</xsl:stylesheet>
