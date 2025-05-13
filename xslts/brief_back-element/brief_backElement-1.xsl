<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
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
    <xsl:template match="tei:text">
        <xsl:element name="text" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*" copy-namespaces="false"/>
            <xsl:copy-of select="*[not(self::tei:back)]" copy-namespaces="false"/>
            <xsl:element name="back" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:element name="listPerson" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::tei:TEI/descendant::tei:rs/@ref[contains(., '#')][1]">
                            <!-- rs mit Raute -->
                            <xsl:for-each
                                select="distinct-values(ancestor::tei:TEI/descendant::*[(@type = 'person' or name() = 'persName' or name() = 'author') and not(ancestor::tei:back)]/@ref/tokenize(., '#'))">
                                <xsl:if test="normalize-space(.) != ''">
                                    <xsl:element name="person"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="."/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:for-each
                                select="distinct-values(ancestor::tei:TEI/descendant::tei:handShift/@scribe)">
                                <xsl:element name="person" namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:attribute name="xml:id">
                                        <xsl:value-of select="replace(., '#', '')"/>
                                    </xsl:attribute>
                                </xsl:element>
                            </xsl:for-each>
                            <xsl:for-each
                                select="distinct-values(ancestor::tei:TEI/descendant::tei:handNote/@corresp)">
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
                        <!--<xsl:when test="not(ancestor::tei:TEI/descendant::tei:rs[@type = 'person'])">
                            <xsl:for-each select="distinct-values(ancestor::tei:TEI/descendant::tei:*[name()='persName' or name()='author']/@ref)">
                                <xsl:if test="normalize-space(.) != ''">
                                    <xsl:element name="person"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="."/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>-->
                        <xsl:otherwise>
                            <xsl:for-each
                                select="distinct-values(ancestor::tei:TEI/descendant::tei:*[(@type = 'person' or name() = 'persName' or name() = 'author')]/@ref/tokenize(., ' '))">
                                <xsl:if test="normalize-space(.) != ''">
                                    <xsl:element name="person"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="."/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:for-each
                                select="distinct-values(ancestor::tei:TEI/descendant::tei:handShift/@scribe)">
                                <xsl:element name="person" namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:attribute name="xml:id">
                                        <xsl:value-of select="replace(., '#', '')"/>
                                    </xsl:attribute>
                                </xsl:element>
                            </xsl:for-each>
                            <xsl:for-each
                                select="distinct-values(ancestor::tei:TEI/descendant::tei:handNote/@corresp)">
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
                    <xsl:if test="ancestor::tei:TEI/descendant::tei:rs[@type = 'work' and not(ancestor::tei:back)]/@ref[contains(., '#')][1]">
                        <!-- rs mit Raute -->
                        <xsl:for-each
                            select="distinct-values(ancestor::tei:TEI/descendant::tei:rs[@type = 'work' and not(ancestor::tei:back)]/@ref/tokenize(., '#'))">
                            <xsl:if test="normalize-space(.) != ''">
                                <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:attribute name="xml:id">
                                        <xsl:value-of select="replace(., '#', '')"/>
                                    </xsl:attribute>
                                </xsl:element>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:for-each
                        select="distinct-values(ancestor::tei:TEI/descendant::tei:biblStruct//tei:title/@ref/tokenize(., '#'))">
                        <xsl:if test="normalize-space(.) != ''">
                            <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:attribute name="xml:id">
                                    <xsl:value-of select="replace(., '#', '')"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="ancestor::tei:TEI/tei:teiHeader/descendant::tei:title/@ref">
                        <xsl:for-each select="distinct-values(ancestor::tei:TEI/tei:teiHeader/descendant::tei:title/@ref)">
                        
                        <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="xml:id">
                                <xsl:value-of
                                    select="replace(., '#', '')"
                                />
                            </xsl:attribute>
                        </xsl:element>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:element>
                <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::tei:TEI/descendant::tei:rs/@ref[contains(., '#')][1]">
                            <!-- rs mit Raute -->
                            <xsl:for-each
                                select="distinct-values(ancestor::tei:TEI/descendant::tei:*[(@type = 'place' or name() = 'placeName') and not(ancestor::tei:back)]/@ref/tokenize(., '#'))">
                                <xsl:if test="normalize-space(.) != ''">
                                    <xsl:element name="place"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="."/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each
                                select="distinct-values(ancestor::tei:TEI/descendant::tei:*[(@type = 'place' or name() = 'placeName') and not(ancestor::tei:back)]/@ref/tokenize(., ' '))">
                                <xsl:if test="normalize-space(.) != ''">
                                    <xsl:element name="place"
                                        namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="."/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
                <xsl:element name="listOrg" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:choose>
                        <xsl:when
                            test="ancestor::tei:TEI/descendant::tei:rs/@ref[contains(., '#')][1]">
                            <!-- rs mit Raute -->
                            <xsl:for-each
                                select="distinct-values(ancestor::tei:TEI/descendant::tei:*[(@type = 'org' or name() = 'orgName') and not(ancestor::tei:back)]/@ref/tokenize(., '#'))">
                                <xsl:if test="normalize-space(.) != ''">
                                    <xsl:element name="org" namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="."/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each
                                select="distinct-values(ancestor::tei:TEI/descendant::tei:*[(@type = 'org' or name() = 'orgName') and not(ancestor::tei:back)]/@ref/tokenize(., ' '))">
                                <xsl:if test="normalize-space(.) != ''">
                                    <xsl:element name="org" namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="."/>
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
