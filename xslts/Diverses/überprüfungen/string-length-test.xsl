<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei"
    version="2.0">
    
    <xsl:output method="xml" encoding="utf-8" indent="yes"/>
    <xsl:mode on-no-match="shallow-skip" />
    
    <xsl:template match="tei:row/tei:cell">
        <xsl:apply-templates/>
    </xsl:template>
    
</xsl:stylesheet>