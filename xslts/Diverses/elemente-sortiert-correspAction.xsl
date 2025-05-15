<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:output method="xml" indent="yes"/>
    <!-- Identity template: copies all nodes and attributes unchanged -->
    <xsl:mode on-no-match="shallow-copy"/>
    
    <!-- Template to match correspAction elements -->
    <xsl:template match="tei:correspAction">
        <xsl:element name="correspAction" namespace="http://www.tei-c.org/ns/1.0">
        <xsl:copy-of select="@*|tei:persName"/>
        <!-- Copy the correspAction element -->
        <xsl:copy-of select="tei:date"/>
            <xsl:copy-of select="tei:placeName"/>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>