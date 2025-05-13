<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">
    
    <!-- Identische Kopie aller Nodes, außer Text -->
    <xsl:mode on-no-match="shallow-copy"/>
    
    <!-- Verarbeitung von Textknoten -->
    <xsl:template match="text()">
        <xsl:analyze-string select="." regex="([mn])&#x0304;">
            <xsl:matching-substring>
                <xsl:element name="c" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="rendition">
                        <xsl:text>#gemination-</xsl:text>
                        <xsl:value-of select="regex-group(1)"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
</xsl:stylesheet>
