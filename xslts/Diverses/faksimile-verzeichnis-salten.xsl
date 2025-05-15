<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:output method="text"/>
    <xsl:template match="*:root">
        <xsl:text>"Identifier","URL, "Titel","Datum", "ISO (when, from, notBefore)", "ISO (to, notAfter)", "Faksimile"&#10;</xsl:text>
        <xsl:for-each select="TEI[descendant::pb[starts-with(@facs, 'Wienbibliothek_AS_FS_')][1]]">
            <xsl:variable name="current" as="node()" select="."/>
            <xsl:variable name="xmlId" select="@id"/>
            <xsl:variable name="URL" select="concat('https://schnitzler-briefe.acdh.oeaw.ac.at', $xmlId, '.html')"/>
            <xsl:variable name="title"
                select="normalize-space(descendant::*:title[@level = 'a'][1])"/>
            <xsl:variable name="correspDate"
                select="normalize-space(descendant::*:correspAction[1]/*:date)"/>
            <xsl:variable name="when"
                select="descendant::*:correspAction[1]/*:date/@*[name() = 'when' or name() = 'from' or name() = 'notBefore']"/>
            <xsl:variable name="notAfterOrTo"
                select="descendant::*:correspAction[1]/*:date/@*[name() = 'notAfter' or name() = 'to']"/>
            <xsl:variable name="item" as="node()">
                <list>
                    <xsl:for-each select="$current/distinct-values(descendant::*:pb/@facs)">
                        <xsl:element name="item">
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:for-each>
                </list>
            </xsl:variable>
            <xsl:for-each select="$item//item"><!-- wenn hier [1] angehängt wird, dann wird jeder Brief mit einer Zeile, es
                werden 
            nicht aber alle Faksimiles ausgegeben -->
                <xsl:value-of
                    select="concat($xmlId, ',&quot;', $URL, '&quot;,&quot;', $title, '&quot;,&quot;', $correspDate, '&quot;,', $when, ',', $notAfterOrTo, ',', .)"/>
                <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
