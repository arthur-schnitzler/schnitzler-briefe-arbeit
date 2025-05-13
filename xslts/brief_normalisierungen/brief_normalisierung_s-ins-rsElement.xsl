<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs math" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:template match="text()[not(ancestor::tei:rs) and matches(., '(^s)([ \t.,;!?:\r\n])') and preceding-sibling::*[1][self::tei:rs]]">
        <xsl:analyze-string select="." regex="(^s)([ \t.,;!?:\r\n])(.*)">
            <xsl:matching-substring>
                <xsl:choose>
                    <xsl:when test="normalize-space(regex-group(2)) = '' and normalize-space(regex-group(3)) =''">
                        <xsl:element name="space" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="unit">
                            <xsl:text>chars</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="quantity">
                            <xsl:text>1</xsl:text>
                        </xsl:attribute>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(regex-group(2), regex-group(3))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    <xsl:template match="text()[not(ancestor::tei:rs) and matches(., '(^s$)') and preceding-sibling::*[1][self::tei:rs]]"/>
    <xsl:template match="tei:rs[following-sibling::node()[1][matches(., '(^s)([ \t.,;!?:\r\n])')]]">
        <xsl:variable name="folgender-text" as="xs:string" select="following-sibling::node()[1][self::text()[starts-with(., 's')]][1]"/>
        <xsl:variable name="match" as="xs:boolean" select="matches($folgender-text, '(^s)([ \t.,;!?:\r\n])')"/>
        <xsl:choose>
            <xsl:when test="$match">
                <xsl:element name="rs" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:copy-of select="@*"/>
                    
                    <xsl:choose>
                        <xsl:when test="child::*[1]">
                            <xsl:apply-templates/><xsl:element name="s" namespace="http://www.tei-c.org/ns/1.0"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates/><xsl:text>s</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="rs" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:copy-of select="@*|*"/>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:rs[following-sibling::node()[1][matches(., '^s$')]]">
        <xsl:variable name="folgender-text" as="xs:string" select="following-sibling::node()[1]"/>
        <xsl:variable name="match" as="xs:boolean" select="matches($folgender-text, '^s$')"/>
        <xsl:choose>
            <xsl:when test="$match">
                <xsl:element name="rs" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:copy-of select="@*"/>
                    <xsl:choose>
                        <xsl:when test="child::*[1]">
                            <xsl:apply-templates/>
                            <xsl:element name="s" namespace="http://www.tei-c.org/ns/1.0"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates/>
                            <xsl:text>s</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="rs" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:copy-of select="@*|*"/>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
