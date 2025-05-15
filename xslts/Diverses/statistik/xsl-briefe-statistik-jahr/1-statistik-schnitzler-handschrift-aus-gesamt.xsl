<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.0">
    <xsl:output method="xml" indent="true"/>
    <xsl:mode on-no-match="shallow-copy"/>

    <!-- Das zieht "kurrent, latintype"-Werte von Briefen an Schnitzler aus Gesamt. Die Idee ist, dass
   Schnitzler einheitlich gesammelt hat-->

    <xsl:template match="root">
        <xsl:element name="root">
            <xsl:for-each
                select="TEI[teiHeader/fileDesc/titleStmt//author/@ref = '#2121' and descendant::physDesc and not(descendant::physDesc/objectDesc/desc/@type = 'telegramm') and not(descendant::physDesc[1]/objectDesc/desc/@subtype = 'ms_abschrift')]">
                <xsl:variable name="correspActionSentDate"
                    select="descendant::correspDesc[1]/correspAction[@type = 'sent']/date"
                    as="node()"/>
                <xsl:element name="correspondence">
                    <xsl:attribute name="target">
                        <xsl:value-of select="@id"/>
                    </xsl:attribute>
                    <xsl:attribute name="jahr">
                        <xsl:choose>
                            <xsl:when test="$correspActionSentDate/@when">
                                <xsl:value-of select="substring($correspActionSentDate/@when, 1, 4)"
                                />
                            </xsl:when>
                            <xsl:when test="$correspActionSentDate/@notBefore">
                                <xsl:value-of
                                    select="substring($correspActionSentDate/@notBefore, 1, 4)"/>
                            </xsl:when>
                            <xsl:when test="$correspActionSentDate/@notAfter">
                                <xsl:value-of
                                    select="substring($correspActionSentDate/@notAfter, 1, 4)"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="name">
                        <xsl:variable name="physDesci"
                            select="descendant::witness[@n = '1']//physDesc" as="node()"/>
                        <xsl:choose>
                            <xsl:when
                                test="$physDesci/typeDesc/typeNote[@medium = 'schreibmaschine']">
                                <xsl:text>Schreibmaschine</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when
                                        test="$physDesci/handDesc/handNote[@corresp = '#2121'] and not($physDesci/handDesc/handNote[@corresp = '#2121'][2])">
                                        <xsl:value-of
                                            select="$physDesci/handDesc/handNote[@corresp = '#2121'][1]/@style"
                                        />
                                    </xsl:when>
                                    <xsl:when test="$physDesci/handDesc/handNote[not(@corresp)]">
                                        <xsl:value-of select="$physDesci/handDesc/handNote/@style"/>
                                    </xsl:when>
                                    <xsl:when
                                        test="$physDesci/handDesc/handNote[@corresp = '#2121'][1]/@style = $physDesci/handDesc/handNote[@corresp = '#2121'][2]/@style">
                                        <xsl:value-of
                                            select="$physDesci/handDesc/handNote[@corresp = '#2121'][1]/@style"
                                        />
                                    </xsl:when>
                                    <xsl:when
                                        test="$physDesci/handDesc/handNote[@corresp = '#2121']/@style = 'kurrent' and $physDesci/handDesc/handNote[@corresp = '#2121']/@style = 'latintype'">
                                        <xsl:text>mixed</xsl:text>
                                    </xsl:when>
                                    <xsl:when
                                        test="$physDesci/handDesc/handNote[@corresp = '#2121']/@style = 'kurrent' and $physDesci/handDesc/handNote[@corresp = '#2121']/@style = 'nicht_anzuwenden'">
                                        <xsl:text>kurrent</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>Sonderfall</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>

                            </xsl:otherwise>

                        </xsl:choose>
                    </xsl:attribute>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
