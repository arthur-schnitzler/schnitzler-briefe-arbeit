<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:foo="whatever" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <!-- Dieses XSLT macht in correspActions folgendes:
        
        - es ergänzt ca. Enddaten für den Erhalt mit einem Zeitfenster von 5 Tagen nach dem Abschicken
        - es  datiert den Erhalt von Telegrammen auf den Absendezeitpunkt
    
    -->
    <!-- Unabhängig von Schnitzler, wenn kein Empfangsdatum bekannt ist, wird a) wenn es im selben Ort kommuniziert, der Zeitraum von 2, sonst b) von 5 Tagen ergänzt -->
    <xsl:template
        match="tei:correspAction[@type = 'received' and not(tei:date) and preceding-sibling::tei:correspAction[@type = 'sent']/tei:date/@when]">
        <xsl:variable name="sendedatum"
            select="preceding-sibling::tei:correspAction[@type = 'sent']/tei:date/@when"
            as="xs:date"/>
        <xsl:element name="correspAction" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@* | *"/>
            <xsl:choose>
                <xsl:when
                    test="tei:placeName/@ref = preceding-sibling::tei:correspAction[@type = 'sent']/tei:placeName/@ref">
                    <xsl:element name="date" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="evidence">
                            <xsl:text>conjecture</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="notBefore">
                            <xsl:value-of select="$sendedatum"/>
                        </xsl:attribute>
                        <xsl:attribute name="notAfter">
                            <xsl:value-of select="$sendedatum + xs:dayTimeDuration('P3D')"/>
                        </xsl:attribute>
                        <xsl:text>[</xsl:text>
                        <xsl:value-of select="foo:formatdate($sendedatum)"/>
                        <xsl:text> – </xsl:text>
                        <xsl:value-of
                            select="foo:formatdate($sendedatum + xs:dayTimeDuration('P3D'))"/>
                        <xsl:text>?]</xsl:text>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="date" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="evidence">
                            <xsl:text>conjecture</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="notBefore">
                            <xsl:value-of select="$sendedatum + xs:dayTimeDuration('P1D')"/>
                        </xsl:attribute>
                        <xsl:attribute name="notAfter">
                            <xsl:value-of select="$sendedatum + xs:dayTimeDuration('P5D')"/>
                        </xsl:attribute>
                        <xsl:text>[</xsl:text>
                        <xsl:value-of
                            select="foo:formatdate($sendedatum + xs:dayTimeDuration('P1D'))"/>
                        <xsl:text> – </xsl:text>
                        <xsl:value-of
                            select="foo:formatdate($sendedatum + xs:dayTimeDuration('P5D'))"/>
                        <xsl:text>?]</xsl:text>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    <!-- ein Telegramm kommt am gleichen Tag an, also correspDesc ergänzen-->
    <xsl:template
        match="tei:correspAction[@type = 'received' and not(tei:date) and ancestor::tei:TEI/descendant::tei:objectDesc/tei:desc/@type = 'telegramm']">
        <xsl:element name="correspAction">
            <xsl:attribute name="type">
                <xsl:text>received</xsl:text>
            </xsl:attribute>
            <xsl:copy-of select="tei:*"/>
            <xsl:element name="date" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="evidence">
                    <xsl:text>conjecture</xsl:text>
                </xsl:attribute>
                <xsl:variable name="correspvorher"
                    select="preceding-sibling::tei:correspAction[@type = 'sent'][1]/tei:date[1]"
                    as="node()"/>
                <xsl:copy-of select="$correspvorher/@*[not(name() = 'n')]"/>
                <xsl:value-of select="$correspvorher"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:function name="foo:formatdate">
        <xsl:param name="date-incoming" as="xs:date"/>
        <xsl:variable name="date" select="string($date-incoming)" as="xs:string"/>
        <xsl:variable name="tag" as="xs:string">
            <xsl:choose>
                <xsl:when test="starts-with(tokenize($date, '-')[3], '0')">
                    <xsl:value-of select="substring(tokenize($date, '-')[3], 2)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="tokenize($date, '-')[3]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="monat" as="xs:string">
            <xsl:choose>
                <xsl:when test="starts-with(tokenize($date, '-')[2], '0')">
                    <xsl:value-of select="substring(tokenize($date, '-')[2], 2)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="tokenize($date, '-')[2]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$tag"/>
        <xsl:text>.&#160;</xsl:text>
        <xsl:value-of select="$monat"/>
        <xsl:text>.&#160;</xsl:text>
        <xsl:value-of select="tokenize($date, '-')[1]"/>
    </xsl:function>
    <xsl:template match="tei:correspAction/tei:date/@n">
        <xsl:attribute name="n">
            <xsl:if test="string-length(.) = 1">
                <xsl:text>0</xsl:text>
            </xsl:if>
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
</xsl:stylesheet>
