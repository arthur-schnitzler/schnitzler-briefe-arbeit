<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    <xsl:output method="xml" omit-xml-declaration="yes"/>
    <xsl:mode on-no-match="shallow-skip"/>

    <!-- Angewendet auf ein unspezifisches Dokument namens "fehlende-bilder-am-server.xml", 
        gleicht dieses XSLT die Faksimiles am Server (gelistet in faksimiles-am-server.xml) 
        mit den @facs-Werten in den XML-Dokumenten im Ordner "editions" ab 
        und erstellt eine Liste mit Bilddateinamen, die noch NICHT auf dem Server liegen -->

    <!-- Liste mit Faksimiles am Server -->
    <xsl:param name="facs-list" select="document('faksimiles-am-server.xml')"/>

    <!-- Key für Faksimile-Name aus Serverliste -->
    <xsl:key name="facs-name" match="*:p"
        use="substring-before(substring-after(., 'forIIIF/'), '.jp2')"/>

    <!-- Pfad zum Ordner "editions" -->
    <xsl:param name="editions-dir">../../arthur-schnitzler-arbeit/editions</xsl:param>

    <!-- Variable für alle XML-Dokumente in "editions" -->
    <xsl:variable name="editions"
        select="collection(concat($editions-dir, '/?select=L0*.xml;recurse=yes'))"/>

    <!-- Abgleich -->
    <xsl:template match="/">
        <xsl:element name="list">
            <xsl:for-each select="$editions//tei:pb/@facs">
                <xsl:variable name="facs-value" select="."/>
                <xsl:choose>
                    <xsl:when test="key('facs-name', $facs-value, $facs-list)"/>
                    <xsl:otherwise>
                        <xsl:element name="missingFacsOnServer">
                            <xsl:value-of select="$facs-value"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
