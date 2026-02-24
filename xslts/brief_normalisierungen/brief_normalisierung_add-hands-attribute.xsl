<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs" version="3.0">
    <xsl:output method="xml" indent="no" encoding="UTF-8"/>
    <!-- Identity template: copy everything by default -->
    <xsl:mode on-no-match="shallow-copy"/>
    <!-- Template for handDesc element -->
    <xsl:template match="tei:handDesc">
        <xsl:copy>
            <!-- Copy existing attributes first -->
            <xsl:apply-templates select="@*"/>
            <!-- Add or update @hands attribute if there is more than one handNote -->
            <xsl:variable name="handNoteCount" select="count(descendant::tei:handNote)"/>
            <xsl:variable name="distinctCorrespCount">
                <xsl:choose>
                    <xsl:when
                        test="descendant::tei:handNote[1] and not(descendant::tei:handNote[2])">
                        <xsl:value-of select="1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="count(distinct-values(descendant::tei:handNote/@corresp))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:attribute name="hands">
                <xsl:value-of select="$distinctCorrespCount"/>
            </xsl:attribute>
            <!-- Process child elements -->
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- Template to remove existing @hands attribute (will be recalculated above) -->
    <xsl:template match="tei:handDesc/@hands"/>
</xsl:stylesheet>
