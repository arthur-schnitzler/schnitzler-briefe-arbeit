<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="*" mode="copy-no-namespaces">
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()" mode="copy-no-namespaces"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:back/tei:listPerson[not(child::*)]"/>
    <xsl:template match="tei:back/tei:listPlace[not(child::*)]"/>
    <xsl:template match="tei:back/tei:listOrg[not(child::*)]"/>
    <xsl:template match="tei:back/tei:listBibl[not(child::*)]"/>
    <xsl:template match="comment() | processing-instruction()" mode="copy-no-namespaces">
        <xsl:copy/>
    </xsl:template>
    <xsl:template match="tei:back/tei:listPerson[child::*]">
        <xsl:element name="listPerson" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="distinct-values(tei:person/@xml:id)">
                <xsl:choose>
                    <xsl:when test=". = '2121' or .='pmb2121' or . = '#pmb2121'">
                        <person xml:id="pmb2121">
                            <!-- Sonderregel für Schnitzler -->
                            <tei:persName>
                                <tei:surname>Schnitzler</tei:surname>
                                <tei:forename>Arthur</tei:forename>
                            </tei:persName>
                            <tei:birth>
                                <tei:date when="1862-05-15">15. 5. 1862</tei:date>
                                <tei:placeName ref="#pmb50">Wien</tei:placeName>
                            </tei:birth>
                            <tei:death>
                                <tei:date when="1931-10-21">21. 10. 1931</tei:date>
                                <tei:placeName ref="#pmb50">Wien</tei:placeName>
                            </tei:death>
                            <occupation code="90">Schriftsteller*in</occupation>
                            <occupation code="97">Mediziner*in</occupation>
                            <idno type="gnd">https://d-nb.info/gnd/118609807/</idno>
                        </person>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="nummer" select="substring-after(., 'pmb')"/>
                        <xsl:variable name="eintrag"
                            select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/person/', $nummer))"
                            as="xs:string"/>
                        <xsl:choose>
                            <xsl:when test="doc-available($eintrag)">
                                <xsl:element name="person" namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:attribute name="xml:id">
                                        <xsl:value-of select="concat('pmb', $nummer)"/>
                                    </xsl:attribute>
                                    <xsl:variable name="eintrag_inhalt"
                                        select="document($eintrag)/person"/>
                                    <xsl:apply-templates
                                        select="$eintrag_inhalt/persName[not(@type = 'loschen')] | $eintrag_inhalt/birth | $eintrag_inhalt/death | $eintrag_inhalt/sex | $eintrag_inhalt/occupation | $eintrag_inhalt/idno"
                                        mode="copy-no-namespaces"/>
                                </xsl:element>
                                <!--<xsl:apply-templates select="document($eintrag)" mode="copy-no-namespaces"/>-->
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:element name="error">
                                    <xsl:attribute name="type">
                                        <xsl:text>person</xsl:text>
                                    </xsl:attribute>
                                    <xsl:value-of select="$nummer"/>
                                </xsl:element>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:back/tei:listBibl[child::*]">
        <xsl:element name="listBibl" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="distinct-values(tei:bibl/@xml:id)">
                <xsl:variable name="nummer" select="substring-after(., 'pmb')"/>
                <xsl:variable name="eintrag"
                    select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/work/', $nummer))"
                    as="xs:string"/>
                <xsl:choose>
                    <xsl:when test="doc-available($eintrag)">
                        <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="concat('pmb', $nummer)"/>
                            </xsl:attribute>
                            <xsl:variable name="eintrag_inhalt" select="document($eintrag)/bibl"/>
                            <xsl:apply-templates
                                select="$eintrag_inhalt/title[not(@type = 'loschen')] | $eintrag_inhalt/author | $eintrag_inhalt/date | $eintrag_inhalt/note[@type] | $eintrag_inhalt/idno"
                                mode="copy-no-namespaces"/>
                        </xsl:element>
                        <!--<xsl:apply-templates select="document($eintrag)" mode="copy-no-namespaces"/>-->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="error">
                            <xsl:attribute name="type">
                                <xsl:text>bibl</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of select="$nummer"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:back/tei:listPlace[child::*]">
        <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="distinct-values(tei:place/@xml:id)">
                <xsl:variable name="nummer" select="substring-after(., 'pmb')"/>
                <xsl:variable name="eintrag"
                    select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/place/', $nummer))"
                    as="xs:string"/>
                <xsl:choose>
                    <xsl:when test="doc-available($eintrag)">
                        <xsl:apply-templates select="document($eintrag)" mode="copy-no-namespaces"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="error">
                            <xsl:attribute name="type">
                                <xsl:text>place</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of select="$nummer"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:back/tei:listOrg[child::*]">
        <xsl:element name="listOrg" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="distinct-values(tei:org/@xml:id)">
                <xsl:variable name="nummer" select="substring-after(., 'pmb')"/>
                <xsl:variable name="eintrag"
                    select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/org/', $nummer))"
                    as="xs:string"/>
                <xsl:choose>
                    <xsl:when test="doc-available($eintrag)">
                        <xsl:apply-templates select="document($eintrag)" mode="copy-no-namespaces"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="error">
                            <xsl:attribute name="type">
                                <xsl:text>org</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of select="$nummer"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
