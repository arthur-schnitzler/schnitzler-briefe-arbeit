<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="//tei:seite">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="//tei:page">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="//text()">
        <xsl:analyze-string select="." regex="¬[\n]\s*(.*)¬[\n]\s*">
            <xsl:matching-substring>
                <xsl:value-of select="normalize-space(regex-group(1))" disable-output-escaping="yes"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:analyze-string select="." regex="¬[\n]\s*(.*)">
                    <xsl:matching-substring>
                        <xsl:value-of select="normalize-space(regex-group(1))" disable-output-escaping="yes"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                <xsl:value-of select="." disable-output-escaping="yes"/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
        
        <!--<xsl:value-of select="translate(., '¬', '')" disable-output-escaping="yes"/>-->
    </xsl:template>
    
    <xsl:template match="@continued"/>

</xsl:stylesheet>
