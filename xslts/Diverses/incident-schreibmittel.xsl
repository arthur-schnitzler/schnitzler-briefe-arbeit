<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="tei:incident[not(@rend) and starts-with(tei:desc/text()[1], 'mit ')]">
        <xsl:element name="incident" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="starts-with(tei:desc, 'mit Bleistift ')">
                    <xsl:attribute name="rend">
                        <xsl:text>bleistift</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="starts-with(tei:desc, 'mit rotem Buntstift ')">
                    <xsl:attribute name="rend">
                        <xsl:text>roter-buntstift</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="starts-with(tei:desc, 'mit blauem Buntstift ')">
                    <xsl:attribute name="rend">
                        <xsl:text>blauer-buntstift</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="starts-with(tei:desc, 'mit grünem Buntstift ')">
                    <xsl:attribute name="rend">
                        <xsl:text>gruener-buntstift</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="starts-with(tei:desc, 'mit schwarzer Tinte ')">
                    <xsl:attribute name="rend">
                        <xsl:text>schwarze-tinte</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="starts-with(tei:desc, 'mit blauer Tinte ')">
                    <xsl:attribute name="rend">
                        <xsl:text>blaue-tinte</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="starts-with(tei:desc, 'mit grüner Tinte ')">
                    <xsl:attribute name="rend">
                        <xsl:text>grüne-tinte</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="starts-with(tei:desc, 'mit roter Tinte ')">
                    <xsl:attribute name="rend">
                        <xsl:text>rote-tinte</xsl:text>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:desc/text()[1]">
        <xsl:analyze-string select="." regex="^mit Bleistift ">
            <xsl:matching-substring/>
            <xsl:non-matching-substring>
                <xsl:analyze-string select="." regex="^mit rotem Buntstift ">
                    <xsl:matching-substring/>
                    <xsl:non-matching-substring>
                        <xsl:analyze-string select="." regex="^mit blauem Buntstift ">
                            <xsl:matching-substring/>
                            <xsl:non-matching-substring>
                                <xsl:analyze-string select="." regex="^mit grünem Buntstift ">
                                    <xsl:matching-substring/>
                                    <xsl:non-matching-substring>
                                        <xsl:analyze-string select="." regex="^mit schwarzer Tinte ">
                                            <xsl:matching-substring/>
                                            <xsl:non-matching-substring>
                                                <xsl:analyze-string select="."
                                                  regex="^mit blauer Tinte ">
                                                  <xsl:matching-substring/>
                                                  <xsl:non-matching-substring>
                                                  <xsl:analyze-string select="."
                                                  regex="^mit grüner Tinte ">
                                                  <xsl:matching-substring/>
                                                  <xsl:non-matching-substring>
                                                  <xsl:analyze-string select="."
                                                  regex="^mit roter Tinte ">
                                                  <xsl:matching-substring/>
                                                  <xsl:non-matching-substring>
                                                  <xsl:value-of select="."/>
                                                  </xsl:non-matching-substring>
                                                  </xsl:analyze-string>
                                                  </xsl:non-matching-substring>
                                                  </xsl:analyze-string>
                                                  </xsl:non-matching-substring>
                                                </xsl:analyze-string>
                                            </xsl:non-matching-substring>
                                        </xsl:analyze-string>
                                    </xsl:non-matching-substring>
                                </xsl:analyze-string>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
</xsl:stylesheet>
