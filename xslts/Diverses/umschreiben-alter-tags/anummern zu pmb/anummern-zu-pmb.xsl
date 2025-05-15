<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="tei"
                version="2.0">
    
    <xsl:output method="xml" encoding="utf-8" indent="yes"/>
    
    <xsl:param name="konkordanz" select="document('konkordanz.xml')"/>
    <xsl:key name="konk-lookup" match="row" use="alteNr"/>
    
    
    <!-- Identity template : copy all text nodes, elements and attributes -->  
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@key">
        <xsl:attribute name="ref">
            <xsl:choose>
                <xsl:when test=".=''"/>
                <xsl:when test="starts-with(., 'pmb') and not(contains(., ' '))">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:when test="string-length(normalize-space(.))=7 and starts-with(., 'A')">
                    <xsl:choose>
                        <xsl:when test="not(key('konk-lookup', normalize-space(.), $konkordanz)/pmb)">
                            <xsl:value-of select="."/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('pmb', key('konk-lookup', normalize-space(.), $konkordanz)/pmb)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="tokenize(.,' ')">
                        <xsl:choose>
                            <xsl:when test="starts-with(., 'pmb')">
                                <xsl:value-of select="."/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="not(key('konk-lookup', normalize-space(.), $konkordanz)/pmb)">
                                        <xsl:value-of select="."/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat('pmb', key('konk-lookup', normalize-space(.), $konkordanz)/pmb)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="not(position()=last())">
                     <xsl:text> </xsl:text>
                  </xsl:if>
                    </xsl:for-each>
                </xsl:otherwise>    
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="@scribe">
        <xsl:attribute name="scribe">
            <xsl:choose>
                <xsl:when test=".=''"/>
                <xsl:when test="starts-with(., 'pmb') and not(contains(., ' '))">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:when test="string-length(normalize-space(.))=7 and starts-with(., 'A')">
                    <xsl:choose>
                        <xsl:when test="not(key('konk-lookup', ., $konkordanz)/pmb)">
                            <xsl:value-of select="."/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('pmb', key('konk-lookup', ., $konkordanz)/pmb)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="tokenize(.,' ')">
                        <xsl:choose>
                            <xsl:when test="starts-with(., 'pmb')">
                                <xsl:value-of select="."/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="not(key('konk-lookup', ., $konkordanz)/pmb)">
                                        <xsl:value-of select="."/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat('pmb', key('konk-lookup', ., $konkordanz)/pmb)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="not(position()=last())">
                     <xsl:text> </xsl:text>
                  </xsl:if>
                    </xsl:for-each>
                </xsl:otherwise>    
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
</xsl:stylesheet>
