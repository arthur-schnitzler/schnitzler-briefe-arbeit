<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="true"/>
    <!-- Hauptregel für das TEI-Element -->
    <xsl:template match="
            tei:body[
            ancestor::tei:TEI[
            descendant::tei:objectType[@ana = 'bildpostkarte']
            and not(descendant::tei:div[@type = 'image'])
            and not(ancestor::*:root)
            ]
            ]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="node()"
                group-adjacent="boolean(self::tei:div[@type = 'writingSession' and @n = '1'])">
                <xsl:choose>
                    <xsl:when test="current-grouping-key()">
                        <!-- Hier wird <div type="image"/> eingefügt -->
                        <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="type">
                                <xsl:text>image</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
