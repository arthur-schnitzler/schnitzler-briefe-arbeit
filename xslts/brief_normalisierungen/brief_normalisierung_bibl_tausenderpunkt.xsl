<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" version="3.0" xmlns:mam="martinfunktion">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <!-- ursprünglich führt das Regex nur 11.000-erpunkte in Zeitungsnummern ein, also aus 12345 wird 12.345 (nicht für vierstellige Zahlen), aber
  es wird auch nach H. und Nr. und Jg. ein fixes Leerzeichen gesetzt-->
    <!-- Template für das <bibl>-Element -->
    <xsl:template
        match="tei:bibl[not(ancestor::tei:back)]//text()[not(ancestor::tei:date) and not(ancestor::tei:title)]">
        <!-- Analyse des Textinhalts des Elements -->
        <xsl:analyze-string select="." regex="(Nr\.)(&#160;|\s)(\d{{5,}})">
            <!-- Wenn das Muster passt -->
            <xsl:matching-substring>
                <xsl:text>Nr.&#160;</xsl:text>
                <xsl:variable name="string-length-rest"
                    select="fn:string-length(regex-group(3)) mod 3"/>
                <xsl:value-of select="mam:dreischritt(regex-group(3), $string-length-rest)"/>
            </xsl:matching-substring>
            <!-- Wenn das Muster nicht passt (optional) -->
            <xsl:non-matching-substring>
                <xsl:analyze-string select="." regex="(Jg.\s)">
                    <xsl:matching-substring>
                        <xsl:text>Jg.&#160;</xsl:text>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:analyze-string select="." regex="(Nr.\s)">
                            <xsl:matching-substring>
                                <xsl:text>Nr.&#160;</xsl:text>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:analyze-string select="." regex="(H.\s)">
                                    <xsl:matching-substring>
                                        <xsl:text>H.&#160;</xsl:text>
                                    </xsl:matching-substring>
                                    <xsl:non-matching-substring>
                                        <xsl:analyze-string select="." regex="(S.\s)">
                                            <xsl:matching-substring>
                                                <xsl:text>S.&#160;</xsl:text>
                                            </xsl:matching-substring>
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
    </xsl:template>
    <xsl:function name="mam:dreischritt">
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="rest" as="xs:integer"/>
        <xsl:variable name="string-length" as="xs:integer" select="fn:string-length($string)"/>
        <xsl:choose>
            <xsl:when test="$rest != 0">
                <xsl:value-of select="substring($string, 1, $rest)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring($string, 1, 3)"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="$string-length &gt; 3">
                <xsl:text>.</xsl:text>
                <xsl:choose>
                    <xsl:when test="$rest != 0">
                        <xsl:value-of select="mam:dreischritt(substring($string, $rest + 1), 0)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="mam:dreischritt(substring($string, 4), 0)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
