<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="supportxml" select="document('support.xml')"/>
    <xsl:key name="supportlookup" match="item" use="@id"/>
    <xsl:template match="tei:witness[@n = '1']//tei:supportDesc[not(@support)][1]">
        <xsl:if test="key('supportlookup', ancestor::tei:TEI/@xml:id, $supportxml)">
            <xsl:element name="supportDesc" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of select="@*|*"/>
            <xsl:element name="support" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of
                    select="key('supportlookup', ancestor::tei:TEI/@xml:id, $supportxml)/desc" copy-namespaces="no"/>
            </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
