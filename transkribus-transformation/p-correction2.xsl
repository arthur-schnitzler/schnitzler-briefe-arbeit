<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>

<xsl:template match="//*:letter-begin|//*:letter-end"/>

<xsl:template match="tei:div">
    <xsl:element name="div">
        <xsl:copy-of select="@*"/>
    <xsl:for-each-group select="node()" group-ending-with="descendant::tei:*[name()='paragraph-start' or name()='closer' or name()='opener']">
        <xsl:choose>
            <xsl:when test="current-group()/descendant-or-self::tei:opener">
                <xsl:element name="opener">
                    <xsl:for-each-group select="current-group()" group-adjacent="name()='closer'">
                        <xsl:apply-templates select="current-group()"/>
                        <xsl:if test="not(position()=last())">
                            <xsl:element name="lb" namespace="http://www.tei-c.org/ns/1.0"/>
                        </xsl:if>
                    </xsl:for-each-group>
                </xsl:element>
            </xsl:when>
            <xsl:when test="current-group()/descendant-or-self::tei:closer">
                <xsl:element name="closer">
                    <xsl:for-each-group select="current-group()" group-adjacent="name()='closer'">
                        <xsl:apply-templates select="current-group()"/>
                        <xsl:if test="not(position()=last())">
                            <xsl:element name="lb" namespace="http://www.tei-c.org/ns/1.0"/>
                        </xsl:if>
                    </xsl:for-each-group>
                </xsl:element>
            </xsl:when>
            <xsl:when test="current-group()/descendant-or-self::*">
                <xsl:element name="p">
                    <xsl:copy-of select="current-group()"/>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:for-each-group>
    </xsl:element>
</xsl:template>

<xsl:template match="tei:closer/text()">
    <xsl:value-of select="."/>
</xsl:template>
<xsl:template match="tei:opener|tei:closer">
    <xsl:apply-templates/>
</xsl:template>

    <!--<xsl:template match="//tei:paragraph-start">
        <xsl:choose>
            <xsl:when test=".[preceding::tei:paragraph-start]">
                <xsl:element name="p-end"/>
                <xsl:element name="p-end"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&lt;p&gt;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->

</xsl:stylesheet>
