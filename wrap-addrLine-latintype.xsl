<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <!-- Identity template: copy everything by default -->
    <xsl:mode on-no-match="shallow-copy"/>

    <!-- Template für addrLine: Inhalt in tei:hi[@rend='latintype'] einpacken -->
    <xsl:template match="tei:TEI[not(descendant::tei:div[@type='address']/tei:address[2]) and descendant::tei:handNote[@style='lateinische-kurrent' and tei:p='Adresse']]/descendant::tei:div[@type='address']//tei:addrLine">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="hi" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="rend">
                <xsl:text>latintype</xsl:text>
            </xsl:attribute>
                <xsl:apply-templates select="node()"/>
            
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <!-- Template zum Löschen von tei:handNote[@style='lateinische-kurrent' and tei:p='Adresse'] -->
    <xsl:template match="tei:TEI[not(descendant::tei:div[@type='address']/tei:address[2]) and descendant::tei:handNote[@style='lateinische-kurrent' and tei:p='Adresse' and (@corresp = preceding-sibling::tei:handNote/@corresp or @corresp = following-sibling::tei:handNote/@corresp)]]/descendant::tei:handNote[@style='lateinische-kurrent'][tei:p='Adresse']"/>

</xsl:stylesheet>
