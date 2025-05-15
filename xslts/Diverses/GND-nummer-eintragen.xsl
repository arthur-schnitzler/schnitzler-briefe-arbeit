<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns="http://www.tei-c.org/ns/1.0"
    version="3.0">
    <xsl:output method="xml" indent="true"/>
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:strip-space elements="*"/>
    <!-- Dieses XSLT ergänzt in einer listperson die GNDS-->
    <xsl:param name="relation-refs" select="document('GNDs.xml')"/>
    <xsl:key name="relation-lookup" match="row" use="Entity_ID/text()"/>
    <xsl:template match="tei:person">
        <xsl:element name="person" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
        <xsl:apply-templates/>
            <!-- hier zwei Varianten. Das eine für die Fassung von schnitzler-briefe: -->
            <xsl:variable name="gnd-da" select="key('relation-lookup', substring-after(@xml:id, 'pmb'), $relation-refs)[1]/URL"/>    
            <!-- hier die Fassung für schnitzler-tagebuch: -->
        <!--<xsl:variable name="gnd-da" select="key('relation-lookup', tei:idno[@type='PMB'], $relation-refs)[1]/URL"/>-->
        <xsl:if test="not(empty($gnd-da))">
            <xsl:variable name="gnd-kurz">
                <xsl:choose>
                    <xsl:when test="starts-with($gnd-da, 'http://d-nb.info/gnd/')">
                        <xsl:value-of select="substring-after($gnd-da, 'http://d-nb.info/gnd/')"/>
                    </xsl:when>
                    <xsl:when test="starts-with($gnd-da, 'https://d-nb.info/gnd/')">
                        <xsl:value-of select="substring-after($gnd-da, 'https://d-nb.info/gnd/')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="tokenize($gnd-da, '/')[last()]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
        <xsl:element name="idno" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="type">
                <xsl:text>GND</xsl:text>
            </xsl:attribute>
            <xsl:value-of select="concat('https://d-nb.info/gnd/', $gnd-kurz)"/>
        </xsl:element>
        </xsl:if>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:idno[@type='GND']"/>
</xsl:stylesheet>
