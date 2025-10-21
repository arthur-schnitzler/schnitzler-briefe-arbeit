<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="tei:text">
        <xsl:variable name="tei-root" select="ancestor::tei:TEI" as="node()"/>
        <xsl:element name="text" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*" copy-namespaces="false"/>
            <xsl:copy-of select="*[not(self::tei:back)]" copy-namespaces="false"/>
            <xsl:element name="back" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:element name="listPerson" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:choose>
                        <xsl:when test="$tei-root/descendant::tei:rs/@ref[contains(., '#')][1]">
                            <!-- rs mit Raute -->
                            <xsl:variable name="person-im-text" as="node()">
                                <xsl:element name="listPerson"
                                    namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:for-each
                                        select="distinct-values($tei-root/descendant::*[(@type = 'person' or name() = 'persName' or name() = 'author') and not(ancestor::tei:back) and not(ancestor::tei:note[@type = 'commentary'])]/@ref/tokenize(., '#'))">
                                        <xsl:if test="normalize-space(.) != ''">
                                            <xsl:element name="person"
                                                namespace="http://www.tei-c.org/ns/1.0">
                                                <xsl:attribute name="xml:id">
                                                  <xsl:value-of select="replace(., '#', '')"/>
                                                </xsl:attribute>
                                            </xsl:element>
                                        </xsl:if>
                                    </xsl:for-each>
                                </xsl:element>
                            </xsl:variable>
                            <xsl:variable name="person-implied" as="node()">
                                <xsl:element name="listPerson"
                                    namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:for-each
                                        select="distinct-values($tei-root/descendant::tei:rs[@type = 'person' and @subtype = 'implied' and not(ancestor::tei:back) and not(ancestor::tei:note[@type = 'commentary'])]/@ref/tokenize(., '#'))">
                                        <xsl:if test="normalize-space(.) != ''">
                                            <xsl:element name="person"
                                                namespace="http://www.tei-c.org/ns/1.0">
                                                <xsl:attribute name="xml:id">
                                                  <xsl:value-of select="replace(., '#', '')"/>
                                                </xsl:attribute>
                                            </xsl:element>
                                        </xsl:if>
                                    </xsl:for-each>
                                </xsl:element>
                            </xsl:variable>
                            <xsl:copy-of select="$person-im-text/*"/>
                            <xsl:for-each
                                select="distinct-values($tei-root/descendant::tei:note[@type = 'commentary']/descendant::tei:rs[@type = 'person']/@ref/tokenize(., '#'))">
                                <xsl:variable name="current" select="."/>
                                <xsl:if
                                    test="normalize-space(.) != '' and not($person-im-text//tei:person/@xml:id = $current)">
                                    <xsl:element name="person"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="replace(., '#', '')"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="ana">
                                            <xsl:text>comment</xsl:text>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:for-each select="$person-implied//tei:person">
                                <xsl:variable name="current" select="@xml:id"/>
                                <xsl:if test="not($person-im-text//tei:person[@xml:id = $current and not(ancestor::tei:rs[@subtype = 'implied'])])">
                                    <xsl:element name="person"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="$current"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="ana">
                                            <xsl:text>implied</xsl:text>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:for-each
                                select="distinct-values($tei-root/descendant::tei:handShift/@scribe)">
                                <xsl:element name="person" namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:attribute name="xml:id">
                                        <xsl:value-of select="replace(., '#', '')"/>
                                    </xsl:attribute>
                                </xsl:element>
                            </xsl:for-each>
                            <xsl:for-each
                                select="distinct-values($tei-root/descendant::tei:handNote/@corresp)">
                                <xsl:if test="not(. = 'schreibkraft')">
                                    <xsl:element name="person"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="replace(., '#', '')"/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="person-im-text" as="node()">
                                <xsl:element name="listPerson"
                                    namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:for-each
                                        select="distinct-values($tei-root/descendant::tei:*[(@type = 'person' or name() = 'persName' or name() = 'author') and not(ancestor::tei:note[@type = 'commentary'])]/@ref/tokenize(., ' '))">
                                        <xsl:if test="normalize-space(.) != ''">
                                            <xsl:element name="person"
                                                namespace="http://www.tei-c.org/ns/1.0">
                                                <xsl:attribute name="xml:id">
                                                  <xsl:value-of select="replace(., '#', '')"/>
                                                </xsl:attribute>
                                            </xsl:element>
                                        </xsl:if>
                                    </xsl:for-each>
                                </xsl:element>
                            </xsl:variable>
                            <xsl:variable name="person-implied" as="node()">
                                <xsl:element name="listPerson"
                                    namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:for-each
                                        select="distinct-values($tei-root/descendant::tei:rs[@type = 'person' and @subtype = 'implied' and not(ancestor::tei:back) and not(ancestor::tei:note[@type = 'commentary'])]/@ref/tokenize(., ' '))">
                                        <xsl:if test="normalize-space(.) != ''">
                                            <xsl:element name="person"
                                                namespace="http://www.tei-c.org/ns/1.0">
                                                <xsl:attribute name="xml:id">
                                                  <xsl:value-of select="replace(., '#', '')"/>
                                                </xsl:attribute>
                                            </xsl:element>
                                        </xsl:if>
                                    </xsl:for-each>
                                </xsl:element>
                            </xsl:variable>
                            <xsl:copy-of select="$person-im-text/*"/>
                            <xsl:for-each
                                select="distinct-values($tei-root/descendant::tei:note[@type = 'commentary']/descendant::tei:rs[@type = 'person']/@ref/tokenize(., '#'))">
                                <xsl:variable name="current" select="."/>
                                <xsl:if
                                    test="normalize-space(.) != '' and not($person-im-text//tei:person/@xml:id = $current)">
                                    <xsl:element name="person"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="replace(., '#', '')"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="ana">
                                            <xsl:text>comment</xsl:text>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:for-each select="$person-implied//tei:person">
                                <xsl:variable name="current" select="@xml:id"/>
                                <xsl:if test="not($person-im-text//tei:person[@xml:id = $current and not(ancestor::tei:rs[@subtype = 'implied'])])">
                                    <xsl:element name="person"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="$current"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="ana">
                                            <xsl:text>implied</xsl:text>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:for-each
                                select="distinct-values($tei-root/descendant::tei:handShift/@scribe)">
                                <xsl:element name="person" namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:attribute name="xml:id">
                                        <xsl:value-of select="replace(., '#', '')"/>
                                    </xsl:attribute>
                                </xsl:element>
                            </xsl:for-each>
                            <xsl:for-each
                                select="distinct-values($tei-root/descendant::tei:handNote/@corresp)">
                                <xsl:if test="not(. = 'schreibkraft')">
                                    <xsl:element name="person"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="replace(., '#', '')"/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
                <xsl:element name="listBibl" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:variable name="bibl-im-text">
                        <xsl:if
                            test="$tei-root/descendant::tei:rs[@type = 'work' and not(ancestor::tei:back) and not(ancestor::tei:note[@type = 'commentary'])]/@ref[contains(., '#')][1]">
                            <!-- rs mit Raute -->
                            <xsl:for-each
                                select="distinct-values($tei-root/descendant::tei:rs[@type = 'work' and not(ancestor::tei:back) and not(ancestor::tei:note[@type = 'commentary'])]/@ref/tokenize(., '#'))">
                                <xsl:if test="normalize-space(.) != ''">
                                    <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="replace(., '#', '')"/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:variable name="bibl-implied">
                        <xsl:for-each
                            select="distinct-values($tei-root/descendant::tei:rs[@type = 'work' and @subtype = 'implied' and not(ancestor::tei:back) and not(ancestor::tei:note[@type = 'commentary'])]/@ref/tokenize(., '#'))">
                            <xsl:if test="normalize-space(.) != ''">
                                <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:attribute name="xml:id">
                                        <xsl:value-of select="replace(., '#', '')"/>
                                    </xsl:attribute>
                                </xsl:element>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:copy-of select="$bibl-im-text/*"/>
                    <xsl:if
                        test="$tei-root/tei:text[1]/tei:body[1]/descendant::tei:note[@type = 'commentary']/descendant::tei:rs[@type = 'work']/@ref[contains(., '#')]">
                        <!-- Works that appear only in commentary -->
                        <xsl:for-each
                            select="distinct-values($tei-root/tei:text[1]/tei:body[1]/descendant::tei:note[@type = 'commentary']/descendant::tei:rs[@type = 'work']/@ref/tokenize(., '#'))">
                            <xsl:variable name="current" select="replace(., '#', '')"/>
                            <xsl:if
                                test="normalize-space($current) != '' and not($bibl-im-text//tei:bibl/@xml:id = $current)">
                                <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:attribute name="xml:id">
                                        <xsl:value-of select="$current"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="ana">
                                        <xsl:text>comment</xsl:text>
                                    </xsl:attribute>
                                </xsl:element>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:for-each select="$bibl-implied//tei:bibl">
                        <xsl:variable name="current" select="@xml:id"/>
                        <xsl:if test="not($bibl-im-text//tei:bibl[@xml:id = $current and not(ancestor::tei:rs[@subtype = 'implied'])])">
                            <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="xml:id">
                                    <xsl:value-of select="$current"/>
                                </xsl:attribute>
                                <xsl:attribute name="ana">
                                    <xsl:text>implied</xsl:text>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:for-each
                        select="distinct-values($tei-root/descendant::tei:biblStruct//tei:title/@ref/tokenize(., '#'))">
                        <xsl:if test="normalize-space(.) != ''">
                            <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="xml:id">
                                    <xsl:value-of select="replace(., '#', '')"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="$tei-root/tei:teiHeader/descendant::tei:title/@ref">
                        <xsl:for-each
                            select="distinct-values($tei-root/tei:teiHeader/descendant::tei:title/@ref)">
                            <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="xml:id">
                                    <xsl:value-of select="replace(., '#', '')"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:element>
                <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:choose>
                        <xsl:when test="$tei-root/descendant::tei:rs/@ref[contains(., '#')][1]">
                            <!-- rs mit Raute -->
                            <xsl:variable name="place-in-text"><xsl:for-each
                                select="distinct-values($tei-root/descendant::tei:*[(@type = 'place' or name() = 'placeName') and not(ancestor::tei:back) and not(ancestor::tei:note[@type = 'commentary'])]/@ref/tokenize(., '#'))">
                                <xsl:if test="normalize-space(.) != ''">
                                    <xsl:element name="place"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="replace(., '#', '')"/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each></xsl:variable>
                            <xsl:variable name="place-implied">
                                <xsl:for-each
                                    select="distinct-values($tei-root/descendant::tei:rs[@type = 'place' and @subtype = 'implied' and not(ancestor::tei:back) and not(ancestor::tei:note[@type = 'commentary'])]/@ref/tokenize(., '#'))">
                                    <xsl:if test="normalize-space(.) != ''">
                                        <xsl:element name="place"
                                            namespace="http://www.tei-c.org/ns/1.0">
                                            <xsl:attribute name="xml:id">
                                                <xsl:value-of select="replace(., '#', '')"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:copy-of select="$place-in-text/*"/>
                            <xsl:for-each
                                select="distinct-values($tei-root/tei:text[1]/tei:body[1]/descendant::tei:note[@type='commentary']/descendant::tei:rs[@type = 'place']/@ref/tokenize(., '#'))">
                                <xsl:variable name="current" select="."/>
                                <xsl:if test="normalize-space(.) != '' and not($place-in-text/descendant::tei:place/@ref= $current)">
                                    <xsl:element name="place"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="replace(., '#', '')"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="ana">
                                            <xsl:text>comment</xsl:text>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:for-each select="$place-implied//tei:place">
                                <xsl:variable name="current" select="@xml:id"/>
                                <xsl:if test="not($place-in-text//tei:place[@xml:id = $current and not(ancestor::tei:rs[@subtype = 'implied'])])">
                                    <xsl:element name="place"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="$current"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="ana">
                                            <xsl:text>implied</xsl:text>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="place-in-text">
                                <xsl:for-each
                                select="distinct-values($tei-root/descendant::tei:*[(@type = 'place' or name() = 'placeName') and not(ancestor::tei:back) and not(ancestor::tei:note[@type = 'commentary'])]/@ref/tokenize(., ' '))">
                                <xsl:if test="normalize-space(.) != ''">
                                    <xsl:element name="place"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="replace(., '#', '')"/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each></xsl:variable>
                            <xsl:variable name="place-implied">
                                <xsl:for-each
                                    select="distinct-values($tei-root/descendant::tei:rs[@type = 'place' and @subtype = 'implied' and not(ancestor::tei:back) and not(ancestor::tei:note[@type = 'commentary'])]/@ref/tokenize(., ' '))">
                                    <xsl:if test="normalize-space(.) != ''">
                                        <xsl:element name="place"
                                            namespace="http://www.tei-c.org/ns/1.0">
                                            <xsl:attribute name="xml:id">
                                                <xsl:value-of select="replace(., '#', '')"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:copy-of select="$place-in-text/*"/>
                            <xsl:for-each
                                select="distinct-values($tei-root/tei:text[1]/tei:body[1]/descendant::tei:note[@type='commentary']/descendant::tei:rs[@type = 'place']/@ref/tokenize(., ' '))">
                                <xsl:variable name="current" select="."/>
                                <xsl:if test="normalize-space(.) != '' and not($place-in-text/descendant::tei:place/@ref= $current)">
                                    <xsl:element name="place"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="replace(., '#', '')"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="ana">
                                            <xsl:text>comment</xsl:text>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:for-each select="$place-implied//tei:place">
                                <xsl:variable name="current" select="@xml:id"/>
                                <xsl:if test="not($place-in-text//tei:place[@xml:id = $current and not(ancestor::tei:rs[@subtype = 'implied'])])">
                                    <xsl:element name="place"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="$current"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="ana">
                                            <xsl:text>implied</xsl:text>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
                <xsl:element name="listOrg" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:choose>
                        <xsl:when test="$tei-root/descendant::tei:rs/@ref[contains(., '#')][1]">
                            <!-- rs mit Raute -->
                            <xsl:variable name="org-in-text"><xsl:for-each
                                select="distinct-values($tei-root/descendant::tei:*[(@type = 'org' or name() = 'orgName') and not(ancestor::tei:back) and not(ancestor::tei:note[@type = 'commentary'])]/@ref/tokenize(., '#'))">
                                <xsl:if test="normalize-space(.) != ''">
                                    <xsl:element name="org" namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="replace(., '#', '')"/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each></xsl:variable>
                            <xsl:variable name="org-implied">
                                <xsl:for-each
                                    select="distinct-values($tei-root/descendant::tei:rs[@type = 'org' and @subtype = 'implied' and not(ancestor::tei:back) and not(ancestor::tei:note[@type = 'commentary'])]/@ref/tokenize(., '#'))">
                                    <xsl:if test="normalize-space(.) != ''">
                                        <xsl:element name="org" namespace="http://www.tei-c.org/ns/1.0">
                                            <xsl:attribute name="xml:id">
                                                <xsl:value-of select="replace(., '#', '')"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:copy-of select="$org-in-text/*"/>
                            <xsl:for-each
                                select="distinct-values($tei-root/tei:text[1]/tei:body[1]/descendant::tei:note[@type='commentary']/descendant::tei:rs[@type = 'org']/@ref/tokenize(., '#'))">
                                <xsl:variable name="current" select="."/>
                                <xsl:if test="normalize-space(.) != '' and not($org-in-text/descendant::tei:org/@ref= $current)">
                                    <xsl:element name="org"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="replace(., '#', '')"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="ana">
                                            <xsl:text>comment</xsl:text>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:for-each select="$org-implied//tei:org">
                                <xsl:variable name="current" select="@xml:id"/>
                                <xsl:if test="not($org-in-text//tei:org[@xml:id = $current and not(ancestor::tei:rs[@subtype = 'implied'])])">
                                    <xsl:element name="org"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="$current"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="ana">
                                            <xsl:text>implied</xsl:text>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="org-in-text">
                                <xsl:for-each
                                select="distinct-values($tei-root/descendant::tei:*[(@type = 'org' or name() = 'orgName') and not(ancestor::tei:back) and not(ancestor::tei:note[@type = 'commentary'])]/@ref/tokenize(., ' '))">
                                <xsl:if test="normalize-space(.) != ''">
                                    <xsl:element name="org" namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="replace(., '#', '')"/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each></xsl:variable>
                            <xsl:variable name="org-implied">
                                <xsl:for-each
                                    select="distinct-values($tei-root/descendant::tei:rs[@type = 'org' and @subtype = 'implied' and not(ancestor::tei:back) and not(ancestor::tei:note[@type = 'commentary'])]/@ref/tokenize(., ' '))">
                                    <xsl:if test="normalize-space(.) != ''">
                                        <xsl:element name="org" namespace="http://www.tei-c.org/ns/1.0">
                                            <xsl:attribute name="xml:id">
                                                <xsl:value-of select="replace(., '#', '')"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:copy-of select="$org-in-text/*"/>
                            <xsl:for-each
                                select="distinct-values($tei-root/tei:text[1]/tei:body[1]/descendant::tei:note[@type='commentary']/descendant::tei:rs[@type = 'org']/@ref/tokenize(., ' '))">
                                <xsl:variable name="current" select="."/>
                                <xsl:if test="normalize-space(.) != '' and not($org-in-text/descendant::tei:org/@ref= $current)">
                                    <xsl:element name="org"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="replace(., '#', '')"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="ana">
                                            <xsl:text>comment</xsl:text>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:for-each select="$org-implied//tei:org">
                                <xsl:variable name="current" select="@xml:id"/>
                                <xsl:if test="not($org-in-text//tei:org[@xml:id = $current and not(ancestor::tei:rs[@subtype = 'implied'])])">
                                    <xsl:element name="org"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="$current"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="ana">
                                            <xsl:text>implied</xsl:text>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
                <xsl:element name="listEvent" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:choose>
                        <xsl:when test="$tei-root/descendant::tei:rs/@ref[contains(., '#')][1]">
                            <!-- rs mit Raute -->
                            <xsl:variable name="event-in-text"><xsl:for-each
                                select="distinct-values($tei-root/descendant::tei:*[(@type = 'event' or name() = 'eventName') and not(ancestor::tei:back) and not(ancestor::tei:note[@type = 'commentary'])]/@ref/tokenize(., '#'))">
                                <xsl:if test="normalize-space(.) != ''">
                                    <xsl:element name="event"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="replace(., '#', '')"/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each></xsl:variable>
                            <xsl:variable name="event-implied">
                                <xsl:for-each
                                    select="distinct-values($tei-root/descendant::tei:rs[@type = 'event' and @subtype = 'implied' and not(ancestor::tei:back) and not(ancestor::tei:note[@type = 'commentary'])]/@ref/tokenize(., '#'))">
                                    <xsl:if test="normalize-space(.) != ''">
                                        <xsl:element name="event"
                                            namespace="http://www.tei-c.org/ns/1.0">
                                            <xsl:attribute name="xml:id">
                                                <xsl:value-of select="replace(., '#', '')"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:copy-of select="$event-in-text/*"/>
                            <xsl:for-each
                                select="distinct-values($tei-root/tei:text[1]/tei:body[1]/descendant::tei:note[@type='commentary']/descendant::tei:rs[@type = 'event']/@ref/tokenize(., '#'))">
                                <xsl:variable name="current" select="."/>
                                <xsl:if test="normalize-space(.) != '' and not($event-in-text/descendant::tei:event/@ref= $current)">
                                    <xsl:element name="event"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="replace(., '#', '')"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="ana">
                                            <xsl:text>comment</xsl:text>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:for-each select="$event-implied//tei:event">
                                <xsl:variable name="current" select="@xml:id"/>
                                <xsl:if test="not($event-in-text//tei:event[@xml:id = $current and not(ancestor::tei:rs[@subtype = 'implied'])])">
                                    <xsl:element name="event"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="$current"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="ana">
                                            <xsl:text>implied</xsl:text>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="event-in-text">
                                <xsl:for-each
                                select="distinct-values($tei-root/descendant::tei:*[(@type = 'event' or name() = 'eventName') and not(ancestor::tei:back) and not(ancestor::tei:note[@type = 'commentary'])]/@ref/tokenize(., ' '))">
                                <xsl:if test="normalize-space(.) != ''">
                                    <xsl:element name="event"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="replace(., '#', '')"/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each></xsl:variable>
                            <xsl:variable name="event-implied">
                                <xsl:for-each
                                    select="distinct-values($tei-root/descendant::tei:rs[@type = 'event' and @subtype = 'implied' and not(ancestor::tei:back) and not(ancestor::tei:note[@type = 'commentary'])]/@ref/tokenize(., ' '))">
                                    <xsl:if test="normalize-space(.) != ''">
                                        <xsl:element name="event"
                                            namespace="http://www.tei-c.org/ns/1.0">
                                            <xsl:attribute name="xml:id">
                                                <xsl:value-of select="replace(., '#', '')"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:copy-of select="$event-in-text/*"/>
                            <xsl:for-each
                                select="distinct-values($tei-root/tei:text[1]/tei:body[1]/descendant::tei:note[@type='commentary']/descendant::tei:rs[@type = 'event']/@ref/tokenize(., ' '))">
                                <xsl:variable name="current" select="."/>
                                <xsl:if test="normalize-space(.) != '' and not($event-in-text/descendant::tei:event/@ref= $current)">
                                    <xsl:element name="event"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="replace(., '#', '')"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="ana">
                                            <xsl:text>comment</xsl:text>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:for-each select="$event-implied//tei:event">
                                <xsl:variable name="current" select="@xml:id"/>
                                <xsl:if test="not($event-in-text//tei:event[@xml:id = $current and not(ancestor::tei:rs[@subtype = 'implied'])])">
                                    <xsl:element name="event"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="$current"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="ana">
                                            <xsl:text>implied</xsl:text>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
