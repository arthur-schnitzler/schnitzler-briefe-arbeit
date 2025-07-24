<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all">
    <!-- Für Klarheit, Identity-Template -->
    <xsl:mode on-no-match="shallow-copy"/>
    <!-- Hauptregel: Ersetze <pmb ref="pmb296012"/> -->
    <xsl:template match="*:pmb">
        <xsl:variable name="ref" select="replace(replace(@ref, '#', ''), 'pmb', '')"/>
        <!-- Lade das Event-Dokument -->
        <xsl:variable name="event-url"
            select="concat('https://pmb.acdh.oeaw.ac.at/apis/tei/event/', $ref)"/>
        <xsl:variable name="event-doc" select="parse-xml(unparsed-text($event-url))"/>
        <xsl:variable name="event" select="$event-doc/*"/>
        <!-- Extrahiere Datum und Werk -->
        <xsl:variable name="date" select="$event/@when-iso"/>
        <xsl:variable name="event-type" select="$event/*:eventName/@n"/>
        <xsl:variable name="listBibl" as="node()">
            <xsl:element name="listBibl" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of
                    select="$event/*:listBibl/*:bibl[not(child::*:note = 'wird rezensiert in')]"/>
            </xsl:element>
        </xsl:variable>
        <xsl:variable name="event-place" select="$event/*:listPlace/*:place[1]/*:placeName[1]"
            as="node()?"/>
        <xsl:variable name="event-org"
            select="$event/*:note[@type = 'listorg']/*:listOrg[*:org[@role = 'veranstaltet von']]"
            as="node()?"/>
        <xsl:text>Die </xsl:text>
        <xsl:value-of select="$event-type"/>
        <xsl:text> von </xsl:text>
        <xsl:for-each select="$listBibl//*:title">
            <xsl:element name="rs" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="type">
                    <xsl:text>work</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="ref">
                    <xsl:value-of select="concat('#', @key)"/>
                </xsl:attribute>
                <xsl:value-of select="."/>
            </xsl:element>
            <xsl:if test="not(position() = last())">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text> fand am </xsl:text>
        <xsl:element name="date" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="when">
                <xsl:value-of select="$date"/>
            </xsl:attribute>
            <xsl:value-of select="format-date(xs:date($date), '[D1].&#160;[M1].&#160;[Y0001]')"/>
        </xsl:element>
        <xsl:if test="$event-org/*:org[@role = 'veranstaltet von'][1]">
            <xsl:text> am </xsl:text>
            <xsl:for-each select="$event-org/*:org[@role = 'veranstaltet von']/*:orgName">
                <xsl:element name="rs" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="type">
                        <xsl:text>org</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="ref">
                        <xsl:value-of select="concat('#', @key)"/>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </xsl:element>
                <xsl:if test="not(position() = last())">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
        <xsl:if test="$event-place/@key">
            <xsl:text> im </xsl:text>
            <xsl:element name="rs" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="type">
                    <xsl:text>place</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="ref">
                    <xsl:value-of select="concat('#', $event-place/@key)"/>
                </xsl:attribute>
                <xsl:value-of select="$event-place"/>
            </xsl:element>
        </xsl:if>
        <xsl:text> statt.</xsl:text>
    </xsl:template>
</xsl:stylesheet>
