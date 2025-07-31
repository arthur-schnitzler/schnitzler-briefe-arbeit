<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="yes" method="xml" encoding="utf-8" omit-xml-declaration="false"/>
    
    <!-- das fügt jedem anchor ein neues Attribut hinzu,
    das den zähler hat -->
    
    <!-- Identity template to copy nodes as-is -->
    <xsl:mode on-no-match="shallow-copy"/>
    
    <!-- Match tei:anchor[@type='commentary'] elements -->
    <xsl:template match="tei:anchor[@type='commentary' or @type='textConst']">
        <xsl:variable name="typ" select="@type"/>
        <xsl:variable name="xmlid" select="ancestor::tei:TEI/@xml:id"/>
        <xsl:variable name="i">
            <xsl:number count="tei:anchor[@type=$typ]" from="tei:body" level="any" />
        </xsl:variable>
        <xsl:element name="anchor" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@type"/>
            <xsl:attribute name="xml:id">
                <xsl:choose>
                    <xsl:when test="$typ='textConst'">
                        <xsl:value-of select="concat('T_',$xmlid,'-',$i)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('K_',$xmlid,'-',$i)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="alt">
                <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
        </xsl:element>
            
            
        
    </xsl:template>
    
    <!-- Verzeichnis der Faksimiles -->
    <xsl:template match="tei:TEI[not(tei:facsimile)]">
        <xsl:element name="TEI" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="tei:teiHeader"/>
            <xsl:if
                test="descendant::tei:pb/@facs[. != '' and not(contains(., '.pdf')) and not(starts-with(., 'http'))]">
                <xsl:element name="facsimile" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:for-each select="descendant::tei:pb/distinct-values(@facs)">
                        <xsl:element name="graphic" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="url">
                                <xsl:value-of select="."/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:element>
            </xsl:if>
            <xsl:apply-templates select="tei:text"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
