<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <!-- Diese XSLT zählt alle Zeichen einschließlich Leerzeichen im edierten Text. Anpassungen
    sind vorgesehen für Sonderzeichen und Vordrucke. -->
    <xsl:template match="tei:extent">
        <xsl:element name="extent" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="*[not(@unit = 'zeichenanzahl')]"/>
            <xsl:variable name="character-count"
                select="sum(ancestor::tei:TEI/tei:text/tei:body//text()[not(ancestor::tei:note) and not(ancestor::tei:back) and not(ancestor::tei:hi[@rend = 'pre-print'])]/string-length(normalize-space(.)))"/>
            <xsl:variable name="number-of-spaces"
                select="count(ancestor::tei:TEI/tei:text/tei:body/descendant::tei:space[not(ancestor::tei:note) and not(ancestor::tei:back) and not(ancestor::tei:hi[@rend = 'pre-print'])])"/>
            <xsl:variable name="dots"
                select="sum(ancestor::tei:TEI/descendant::tei:c[not(ancestor::tei:note) and not(ancestor::tei:back) and not(ancestor::tei:hi[@rend = 'pre-print'])]/@n)"/>
            <xsl:variable name="c-ohne-dots"
                select="count(ancestor::tei:TEI/tei:text/tei:body/descendant::tei:c[not(ancestor::tei:note) and not(ancestor::tei:back) and not(@n) and not(ancestor::tei:hi[@rend = 'pre-print'])])"/>
            <xsl:element name="measure" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="unit">
                    <xsl:text>zeichenanzahl</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="quantity">
                    <xsl:value-of
                        select="sum($character-count + $number-of-spaces + $dots + $c-ohne-dots)"/>
                </xsl:attribute>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:sourceDesc[not(tei:listWit)]/tei:listBibl[1]/tei:biblStruct[1]">
        <xsl:element name="biblStruct" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@* | * except tei:note[@type = 'zeichenanzahl']"/>
            <xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="type">
                    <xsl:text>zeichenanzahl</xsl:text>
                </xsl:attribute>
                <xsl:variable name="character-count"
                    select="sum(ancestor::tei:TEI/tei:text/tei:body//text()[not(ancestor::tei:note) and not(ancestor::tei:back) and not(ancestor::tei:hi[@rend = 'pre-print'])]/string-length(normalize-space(.)))"/>
                <xsl:variable name="number-of-spaces"
                    select="count(ancestor::tei:TEI/tei:text/tei:body/descendant::tei:space[not(ancestor::tei:note) and not(ancestor::tei:back) and not(ancestor::tei:hi[@rend = 'pre-print'])])"/>
                <xsl:variable name="dots"
                    select="sum(ancestor::tei:TEI/descendant::tei:c[not(ancestor::tei:note) and not(ancestor::tei:back) and not(ancestor::tei:hi[@rend = 'pre-print'])]/@n)"/>
                <xsl:variable name="c-ohne-dots"
                    select="count(ancestor::tei:TEI/tei:text/tei:body/descendant::tei:c[not(ancestor::tei:note) and not(ancestor::tei:back) and not(@n) and not(ancestor::tei:hi[@rend = 'pre-print'])])"/>
                <xsl:element name="measure" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="unit">
                        <xsl:text>zeichenanzahl</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="quantity">
                        <xsl:value-of
                            select="sum($character-count + $number-of-spaces + $dots + $c-ohne-dots)"
                        />
                    </xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
