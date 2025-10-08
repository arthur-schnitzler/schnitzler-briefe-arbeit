<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" version="3.0"
    xmlns:mam="whatever"
    exclude-result-prefixes="xs fn tei">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="*" mode="copy-no-namespaces">
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()" mode="copy-no-namespaces"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="comment() | processing-instruction()" mode="copy-no-namespaces">
        <xsl:copy/>
    </xsl:template>
    <xsl:param name="listperson" select="document('../../python-temp/listperson.xml')"/>
    <xsl:key name="listperson-lookup"
        match="/tei:TEI[1]/tei:text[1]/tei:body[1]/tei:listPerson[1]/tei:person" use="@xml:id"/>
    <!-- Named template for adding persons -->
    <xsl:template name="add-persons">
        <xsl:param name="existing-persons" as="node()"/>
        <xsl:param name="context-node" as="node()"/>
        <xsl:param name="bibl-list" as="node()"/>
        <xsl:for-each
            select="distinct-values($context-node/tei:bibl/tei:author/@*[name()='key' or name()='ref'])">
            <xsl:variable name="current-id"
                select="concat('pmb', replace(replace(., '#', ''), 'pmb', ''))"/>
            <xsl:choose>
                <xsl:when test="$existing-persons//*:item = $current-id">
                    <!-- Person already exists in local listPerson, skip -->
                </xsl:when>
                <xsl:otherwise>
                    <!-- Check if this author is only in bibl elements with ana="comment" -->
                    <xsl:variable name="author-in-commentary-bibl" select="$bibl-list//*:bibl[@ana='comment'][tei:author/@*[name()='key' or name()='ref']/concat('pmb', replace(replace(., '#', ''), 'pmb', '')) = $current-id]"/>
                    <xsl:variable name="author-in-non-commentary-bibl" select="$bibl-list//*:bibl[not(@ana='comment')][tei:author/@*[name()='key' or name()='ref']/concat('pmb', replace(replace(., '#', ''), 'pmb', '')) = $current-id]"/>

                    <xsl:choose>
                        <xsl:when
                            test="key('listperson-lookup', $current-id, $listperson)[1]">
                            <xsl:element name="person" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:copy-of select="key('listperson-lookup', $current-id, $listperson)[1]/@xml:id"/>
                                <xsl:if test="exists($author-in-commentary-bibl) and not(exists($author-in-non-commentary-bibl))">
                                    <xsl:attribute name="ana">
                                        <xsl:text>comment</xsl:text>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:copy-of select="key('listperson-lookup', $current-id, $listperson)[1]/node()"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="nummer"
                                select="replace($current-id, 'pmb', '')"/>
                            <xsl:variable name="eintrag"
                                select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/tei/person/', $nummer))"
                                as="xs:string"/>
                            <xsl:choose>
                                <xsl:when test="doc-available($eintrag)">
                                  <xsl:element name="person"
                                  namespace="http://www.tei-c.org/ns/1.0">
                                  <xsl:attribute name="xml:id">
                                  <xsl:value-of select="concat('pmb', $nummer)"/>
                                  </xsl:attribute>
                                  <xsl:if test="exists($author-in-commentary-bibl) and not(exists($author-in-non-commentary-bibl))">
                                      <xsl:attribute name="ana">
                                          <xsl:text>comment</xsl:text>
                                      </xsl:attribute>
                                  </xsl:if>
                                  <xsl:variable name="eintrag_inhalt"
                                  select="document($eintrag)/person"/>
                                  <xsl:apply-templates
                                  select="$eintrag_inhalt/persName[not(@type = 'loschen')] | $eintrag_inhalt/birth | $eintrag_inhalt/death | $eintrag_inhalt/sex | $eintrag_inhalt/occupation | $eintrag_inhalt/idno"
                                  mode="copy-no-namespaces"/>
                                  </xsl:element>
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
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="tei:back[tei:listBibl[1]/tei:bibl/tei:author[1]]">
        <xsl:element name="back" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:variable name="persons" as="node()?">
                <list>
                    <xsl:for-each select="child::tei:listPerson/tei:person/@xml:id">
                        <item>
                            <xsl:value-of select="."/>
                        </item>
                    </xsl:for-each>
                </list>
            </xsl:variable>
            <xsl:variable name="bibl-list" as="node()">
                <list>
                    <xsl:copy-of select="tei:listBibl/tei:bibl"/>
                </list>
            </xsl:variable>
            <xsl:element name="listPerson" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:if test="tei:listPerson">
                    <xsl:copy-of select="tei:listPerson/*"/>
                </xsl:if>
                <xsl:call-template name="add-persons">
                    <xsl:with-param name="existing-persons" select="$persons"/>
                    <xsl:with-param name="context-node" select="tei:listBibl"/>
                    <xsl:with-param name="bibl-list" select="$bibl-list"/>
                </xsl:call-template>
            </xsl:element>
            <xsl:copy-of select="*[not(name() = 'listPerson')]"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
