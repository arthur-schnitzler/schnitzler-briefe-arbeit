<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
    
    <xsl:output indent="false"
        method="text"
        encoding="utf-8"
        omit-xml-declaration="false"/>
    
    
 <!-- Diese Datei zieht alle Seitenanzahlen der Buchausgabe Fliedls aus ASBW-Gesamt -->
    
    <xsl:template match="root">
        <xsl:element name="root">
            <xsl:for-each select="TEI[teiHeader[1]/fileDesc[1]/sourceDesc[1]/listBibl[1]/biblStruct/@corresp='ASBH']">
                <xsl:sort select="teiHeader[1]/fileDesc[1]/sourceDesc[1]/listBibl[1]/biblStruct[@corresp='ASBH']/monogr/biblScope/substring-before(., '–')" data-type="number"/>
                <xsl:variable name="correspDesc" select="descendant::correspDesc" as="node()"/>
                <xsl:variable name="seite" select="teiHeader[1]/fileDesc[1]/sourceDesc[1]/listBibl[1]/biblStruct[@corresp='ASBH']/monogr/biblScope"/>
                <xsl:value-of select="tokenize($seite, '–')[1]"/><xsl:text>|</xsl:text>
                <xsl:value-of select="$seite"/><xsl:text>|</xsl:text>
                <xsl:value-of select="$correspDesc/correspAction[@type='sent']/persName[1]"/><xsl:text>|</xsl:text>
                <xsl:choose>
                    <xsl:when test="$correspDesc/correspAction[@type='sent']/date/@when">
                        <xsl:value-of select="$correspDesc/correspAction[@type='sent']/date/@when"/>
                    </xsl:when>
                    <xsl:when test="$correspDesc/correspAction[@type='sent']/date/@notBefore">
                        <xsl:value-of select="$correspDesc/correspAction[@type='sent']/date/@notBefore"/>
                    </xsl:when>
                    <xsl:when test="$correspDesc/correspAction[@type='sent']/date/@notAfter">
                        <xsl:value-of select="$correspDesc/correspAction[@type='sent']/date/@notAfter"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:text>|</xsl:text>
                <xsl:value-of select="normalize-space(teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level='a'])"/><xsl:text>;
</xsl:text>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>