<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="#all">
    
    <!-- Identitätstransformation -->
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    
    <!-- Verarbeite das Dokument-Element -->
    <xsl:template match="/tei:TEI[contains(@xsi:schemaLocation, 'asbw')]">
        <xsl:text>&#10;</xsl:text>
        <xsl:text disable-output-escaping="yes">&lt;?xml-model href="../meta/schnitzler-briefe-schematron.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?&gt;
</xsl:text>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <!-- Attributänderung schemaLocation -->
            <xsl:attribute name="xsi:schemaLocation">
                <xsl:value-of select="replace(@xsi:schemaLocation, 'asbwschema\.xsd', 'schnitzler-briefe-schema.xsd')"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
