<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="#all">
    <!-- Identitätstransformation -->
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="tei:note[(@type = 'commentary' or @type = 'textConst') and not(@corresp)]">
        <xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*[not(name()='xml:id')]"/>
            <xsl:attribute name="corresp">
                <xsl:value-of select="replace(@xml:id, 'h', '')"/>
            </xsl:attribute>
            <xsl:copy-of select="text()|*"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
