<!-- AccessXmlDeclarationAndSchema.xslt -->
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <!-- FORGET IT FOR NOW -->
    
    
    <!-- Define the output properties including the XML declaration -->
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
    
    <!-- Identity transform to copy everything as is -->
    <xsl:mode on-no-match="shallow-copy"/>
    
    <?xml-model href="https://raw.githubusercontent.com/acdh-oeaw/legalkraus-documentation/master/odd/legalkraus_transcr.rng" type="" schematypens="http://relaxng.org/ns/structure/1.0"?>
    <?xml-model href="https://raw.githubusercontent.com/acdh-oeaw/legalkraus-documentation/master/schematron/legalkraus_transcr.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"?>
    
    
    <!-- Add the processing instruction for the schema link -->
    <xsl:template match="/">
        <!-- Copy the existing XML declaration -->
        <xsl:copy-of select="processing-instruction('xml')"/>
        <!-- Add the schema link -->
        <xsl:processing-instruction name="xml-model">
            
                <xsl:text>target="https://raw.githubusercontent.com/arthur-schnitzler/arthur-schnitzler-arbeit/main/meta/asbwschema.xsd"</xsl:text>
            
            
                <xsl:text>type="application/xml"</xsl:text>
            
        </xsl:processing-instruction>
        <xsl:apply-templates/>
    </xsl:template>
</xsl:stylesheet>
