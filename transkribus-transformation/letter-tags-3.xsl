<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>

    <!-- delete all closing letter tags (i. e. strings) if they are not directly before a &lt;letter&gt; string -->

    <xsl:variable name="closing-tag" select="//*/text()[contains(., '&lt;/letter&gt;')]"/>

    <xsl:template match="$closing-tag">
        <xsl:choose>
            <xsl:when test="contains(., '&lt;/letter&gt;&lt;letter&gt;')">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="replace(., '&lt;/letter&gt;', '')"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

</xsl:stylesheet>
