<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="yes" method="xml" encoding="utf-8" omit-xml-declaration="false"/>
    <xsl:strip-space elements="*"/>
    <!-- Dieses XSLT überprüft, ob manche Daten plus Nummer doppelt sind -->
    <xsl:template match="tei:correspDesc">
        <xsl:element name="correspDesc" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:variable name="datum" select="@ana"/>
            <xsl:if test="preceding-sibling::tei:correspDesc/@ana = $datum">
                <xsl:attribute name="doppelter-tag">
                    <xsl:value-of select="substring-before($datum, '_')"/>
                </xsl:attribute>
                <xsl:attribute name="n">
                    <xsl:value-of select="substring-after($datum, '_')"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="@* | *"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
