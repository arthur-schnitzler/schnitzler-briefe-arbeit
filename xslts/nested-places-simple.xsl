<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <!-- Key für schnelle Suche -->
    <xsl:key name="children" match="tei:place" use="tei:location[@type='located_in_place']/tei:placeName/@key"/>

    <xsl:template match="/">
        <xsl:apply-templates select="tei:TEI"/>
    </xsl:template>

    <xsl:template match="tei:TEI">
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="tei:teiHeader"/>
            <text>
                <body>
                    <listPlace>
                        <!-- Kopiere nur Top-Level Orte (die nicht selbst ein located_in_place haben) -->
                        <xsl:for-each select="//tei:place[not(tei:location[@type='located_in_place'])]">
                            <xsl:apply-templates select="." mode="copy-all"/>
                        </xsl:for-each>
                    </listPlace>
                </body>
            </text>
        </TEI>
    </xsl:template>

    <!-- Kopiere jeden Ort -->
    <xsl:template match="tei:place" mode="copy-all">
        <xsl:param name="hierarchy-path" select="''"/>

        <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
            <!-- Erstelle neue eindeutige ID basierend auf ursprünglicher ID und Pfad -->
            <xsl:attribute name="xml:id">
                <xsl:value-of select="@xml:id"/>
                <xsl:if test="$hierarchy-path != ''">
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="translate($hierarchy-path, '#', '')"/>
                </xsl:if>
            </xsl:attribute>

            <!-- Speichere ursprüngliche ID in corresp -->
            <xsl:attribute name="corresp">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="@xml:id"/>
            </xsl:attribute>

            <!-- Kopiere andere Attribute außer xml:id -->
            <xsl:copy-of select="@*[not(name() = 'xml:id')]"/>

            <!-- Kopiere alle Elemente außer located_in_place -->
            <xsl:copy-of select="*[not(self::tei:location[@type='located_in_place'])]"/>

            <!-- Füge Kinder hinzu, falls vorhanden -->
            <xsl:variable name="current-id" select="@xml:id"/>
            <xsl:variable name="children" select="key('children', $current-id)"/>

            <xsl:if test="$children">
                <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:apply-templates select="$children" mode="copy-all">
                        <xsl:with-param name="hierarchy-path" select="concat($hierarchy-path, '-', $current-id)"/>
                    </xsl:apply-templates>
                </xsl:element>
            </xsl:if>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>