<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="tei:witness">
        <xsl:element name="witness" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="n">
                <xsl:value-of select="@n"/>
            </xsl:attribute>
            <xsl:element name="objectType" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="corresp">
                <xsl:choose>
                    <xsl:when test="descendant::tei:objectDesc/tei:desc[@type='karte']">
                        <xsl:text>karte</xsl:text>  
                        
                    </xsl:when>
                    <xsl:when test="descendant::tei:objectDesc/tei:desc[@type='bild']">
                        <xsl:text>bild</xsl:text>                        
                    </xsl:when>
                    <xsl:when test="descendant::tei:objectDesc/tei:desc[@type='kartenbrief']">
                        <xsl:text>kartenbrief</xsl:text>                        
                    </xsl:when>
                    <xsl:when test="descendant::tei:objectDesc/tei:desc[@type='brief']">
                        <xsl:text>brief</xsl:text>                        
                    </xsl:when>
                    <xsl:when test="descendant::tei:objectDesc/tei:desc[@type='telegramm']">
                        <xsl:text>telegramm</xsl:text>                        
                    </xsl:when>
                    <xsl:when test="descendant::tei:objectDesc/tei:desc[@type='widmung']">
                        <xsl:text>widmung</xsl:text>                        
                    </xsl:when>
                    <xsl:when test="descendant::tei:objectDesc/tei:desc[@type='anderes']">
                        <xsl:text>anderes</xsl:text>                        
                    </xsl:when>
                </xsl:choose>
                </xsl:attribute>
                <xsl:apply-templates
                    select="descendant::tei:objectDesc/tei:desc[not(starts-with(@type, '_')) and not(@type = 'umschlag') and not(@type = 'reproduktion') and not(@type = 'fragment')]"
                />
            </xsl:element>
            <xsl:apply-templates select="*"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:objectDesc">
        <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="objectDesc">
            <xsl:if test="tei:desc[@type = 'reproduktion']">
                <xsl:attribute name="form">
                    <xsl:choose>
                        <xsl:when test="tei:desc[@type = 'reproduktion']/@subtype">
                            <xsl:value-of select="tei:desc[@type = 'reproduktion']/@subtype"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="tei:desc[@type = 'reproduktion']/@type"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:if>
            <xsl:element name="supportDesc">
                <xsl:element name="extent">
                    <xsl:if test="tei:desc/@type = 'karte'">
                        <xsl:element name="measure">
                            <xsl:attribute name="unit">
                                <xsl:text>karte</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="quantity">
                                <xsl:text>1</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:if>
                    <xsl:apply-templates
                        select="tei:desc[(starts-with(@type, '_')) or (@type = 'umschlag')]"/>
                </xsl:element>
                <xsl:if test="tei:desc[@type = 'fragment']">
                    <xsl:element name="condition" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="ana">
                            <xsl:text>fragment</xsl:text>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:if>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:desc[@type = '_blaetter']">
        <xsl:element name="measure" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="unit">
                <xsl:text>blatt</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="quantity">
                <xsl:value-of select="@n"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:desc[@type = '_seiten']">
        <xsl:element name="measure" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="unit">
                <xsl:text>seite</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="quantity">
                <xsl:value-of select="@n"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:desc[@type = 'umschlag']">
        <xsl:element name="measure" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="unit">
                <xsl:text>umschlag</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:editionStmt/tei:idno"/>
    <xsl:template match="tei:publicationStmt/tei:date">
        <xsl:element name="date" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="when">
                <xsl:text>2023</xsl:text>
            </xsl:attribute>
            <xsl:text>2023</xsl:text>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
